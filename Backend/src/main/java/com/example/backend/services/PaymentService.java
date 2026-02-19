package com.example.backend.services;

import com.example.backend.dto.response.PaymentResponseDto;
import com.example.backend.entity.*;
import com.example.backend.enums.NotificationType;
import com.example.backend.enums.PaymentStatus;
import com.example.backend.enums.PaymentType;
import com.example.backend.repository.*;
import com.example.backend.security.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static com.example.backend.enums.RewardType.EARN;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepo;
    private final EventRepository eventRepo;
    private final MemberService memberService;
    private final S3Service s3Service;
    private final NotificationService notificationService;
    private final UnityStarsService unityStarsService;
    private final DonationRepository donationRepo;
    private final MembershipFeeRepository membershipRepo;
    private final MemberRepository memberRepository;
    private final JwtUtil jwtUtil;

    @Transactional
    public Payment addDonationPayment(HttpServletRequest request,
                                      Payment payment,
                                      Donation donation) {
        Member member = getMemberFromRequest(request);

        Event event = eventRepo.findById(donation.getEvent().getEventId())
                .orElseThrow(() -> new RuntimeException("Event not found"));

        // CHECK IF DONATION IS ACCEPTED
        if (!event.isDonationAccepted()) {
            throw new RuntimeException("Donations are not accepted for this event");
        }
        Payment saved = createAndSavePayment(member, payment, PaymentType.DONATION);

        donation.setPayment(saved);
        donation.setEvent(event);
        donation.setApproved(false);

        donationRepo.save(donation);

        return saved;
    }

    public Payment addMembershipPayment(HttpServletRequest request, Payment payment, MembershipFee details,YearMonth selectedMonth) {
        Member member = getMemberFromRequest(request);
        List<YearMonth> unpaidMonths = getUnpaidMonths(member.getMemberID());

        if (selectedMonth == null || !unpaidMonths.contains(selectedMonth)) {
            throw new RuntimeException("Selected month already paid or invalid");
        }
        if (selectedMonth.isAfter(YearMonth.now())) {
            throw new RuntimeException("Cannot pay future months");
        }


        details.setPaymentMonth(selectedMonth);
        details.setApproved(false);
        Payment saved = createAndSavePayment(member, payment, PaymentType.MEMBERSHIP);
        details.setPayment(saved);
        membershipRepo.save(details);

        return saved;
    }

    public List<Payment> getMyPayments(HttpServletRequest request) {
        Member member = getMemberFromRequest(request);
        return paymentRepo.findByMember(member);
    }

    public List<Payment> getMyPaymentsByYear(HttpServletRequest request, Integer year) {
        Member member = getMemberFromRequest(request);
        int targetYear = (year != null) ? year : LocalDate.now().getYear();
        return paymentRepo.findByMemberAndYear(member, targetYear);
    }

    // --- helpers to remove duplication ---
    public Member getMemberFromRequest(HttpServletRequest request) {
        Long memberId = jwtUtil.extractUserIdFromRequest(request);
        if (memberId == null) throw new RuntimeException("Invalid token / user id");

        return memberRepository.findById(Math.toIntExact(memberId))
                .orElseThrow(() -> new RuntimeException("Member not found"));
    }

    private Payment createAndSavePayment(Member member, Payment payment, PaymentType type) {
        payment.setMember(member);
        payment.setPaymentType(type);
        payment.setPaymentStatus( PaymentStatus.PENDING);
        if (payment.getPaymentDate() == null) {
            payment.setPaymentDate(LocalDate.now());
        }
        payment.setSubmissionDate(LocalDate.now());
        payment.setSubmissionTime(LocalTime.now());

        return paymentRepo.save(payment);
    }

    private void validateTop4Role(Member admin) {
        List<String> topRoles = List.of(
                "PRESIDENT",
                "VICE_PRESIDENT",
                "SECRETARY",
                "TREASURER"
        );

        if (!topRoles.contains(admin.getRole())) {
            throw new RuntimeException("Only top 4 roles can approve payments");
        }
    }

    @Transactional
    public Payment approvePayment(Long paymentId, Integer adminId) {

        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));

        Member admin = memberService.getMemberById(adminId);
        validateTop4Role(admin);

        if (payment.getPaymentType() == PaymentType.MEMBERSHIP) {

            MembershipFee fee = payment.getMembershipDetails();

            if (fee == null) {
                throw new RuntimeException("Membership fee details not found");
            }

            if (fee.getApproved()) {
                throw new RuntimeException("Membership fee already approved");
            }

            fee.setApproved(true);
            fee.setApprovedBy(admin);
            fee.setApprovedDate(LocalDateTime.now());

            YearMonth paymentMonth = fee.getPaymentMonth();
            if (paymentMonth == null) {
                throw new RuntimeException("Payment month is missing for UnityStars reward");
            }
            LocalDate paymentDate = payment.getPaymentDate();
            YearMonth paymentDateMonth = YearMonth.from(paymentDate);

            //paymentMonth == paymentDate month
            boolean sameMonth = paymentMonth.equals(paymentDateMonth);

            //payment before or on 15th
            boolean beforeDeadline = paymentDate.getDayOfMonth() <= 15;

            //stars not already awarded
            boolean notAwardedYet =
                    !unityStarsService.hasEarnedStarsForMonth(
                            payment.getMember().getMemberID(),
                            paymentMonth
                    );

            if (sameMonth && beforeDeadline && notAwardedYet) {
                unityStarsService.awardStarsForMembership(
                        payment.getMember().getMemberID(),
                        2,
                        EARN,
                        paymentMonth
                );
            }
            //  Notify member
            notificationService.sendNotification(
                    payment.getMember().getMemberID(),
                    "Membership Fee Approved",
                    "Your membership fee payment has been approved.",
                    NotificationType.PAYMENT,
                    true
            );

        } else if (payment.getPaymentType() == PaymentType.DONATION) {

            Donation donation = payment.getDonationDetails();

            if (donation == null) {
                throw new RuntimeException("Donation details not found");
            }

            if (donation.getApproved()) {
                throw new RuntimeException("Donation already approved");
            }

            donation.setApproved(true);
            donation.setApprovedBy(admin);
            donation.setApprovedDate(LocalDateTime.now());

            //  Notify donor
            notificationService.sendNotification(
                    payment.getMember().getMemberID(),
                    "Donation Approved",
                    "Thank you! Your donation has been approved.",
                    NotificationType.PAYMENT,
                    true
            );
        }

        // Update payment status to APPROVED
        payment.setPaymentStatus(PaymentStatus.APPROVED);

        return paymentRepo.save(payment);
    }

    @Transactional
    public void rejectPayment(Long paymentId, PaymentType paymentType, String reason) {
        switch (paymentType) {
            case MEMBERSHIP:
                rejectMembershipFee(paymentId, reason);
                break;
            case DONATION:
                rejectDonation(paymentId, reason);
                break;
            default:
                throw new RuntimeException("Unsupported payment type: " + paymentType);
        }
    }

    private void rejectMembershipFee(Long feeId, String reason) {
        MembershipFee fee = membershipRepo.findByPayment_PaymentId(feeId)
                .orElseThrow(() -> new RuntimeException("MembershipFee not found: " + feeId));

        Payment payment = fee.getPayment();
        if (payment == null) {
            throw new RuntimeException("Payment not found for MembershipFee: " + feeId);
        }
        // Delete slip from S3 if exists
        if (fee.getSlipUrl() != null) {
            s3Service.deleteFile(fee.getSlipUrl());
        }

        Integer userId = null;
        if (fee.getPayment() != null && fee.getPayment().getMember() != null) {
            userId = fee.getPayment().getMember().getMemberID();
        }

        // Delete from DB
        paymentRepo.delete(payment);
        membershipRepo.delete(fee);


        // Notify user
        if (userId != null) {
            notificationService.sendNotification(userId,
                    "Your membership fee payment has been rejected.",
                    "Reason: " + reason,
                    NotificationType.PAYMENT,
                    true);
        }
    }

    private void rejectDonation(Long donationId, String reason) {
        Donation donation = donationRepo.findByPayment_PaymentId(donationId)
                .orElseThrow(() -> new RuntimeException("Donation not found: " + donationId));

        Payment payment = donation.getPayment();
        if (payment == null) {
            throw new RuntimeException("Associated payment not found for MembershipFee: " + donationId);
        }
        // Delete slip from S3 if exists
        if (donation.getSlipUrl() != null) {
            s3Service.deleteFile(donation.getSlipUrl());
        }
        Integer userId = null;
        if (donation.getPayment() != null && donation.getPayment().getMember() != null) {
            userId = donation.getPayment().getMember().getMemberID();
        }

        // Delete from DB
        paymentRepo.delete(payment);

        // Notify user
        if (userId != null) {
            notificationService.sendNotification(userId,
                    "Your membership fee payment has been rejected.",
                    "Reason: " + reason,
                    NotificationType.PAYMENT,
                    true);
        }
    }



        //Edited using response dto Oshan(1/18)
    public List<PaymentResponseDto> getUnapprovedPayments(HttpServletRequest request) {

        Member admin = getMemberFromRequest(request);
        validateTop4Role(admin); // Only top 4 can view

        // Fetch only pending payments
        List<Payment> pendingPayments = paymentRepo.findByPaymentStatus(PaymentStatus.PENDING);

        return pendingPayments.stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    //Add response dto to fix nested json responses Oshan (1/18)
    private PaymentResponseDto mapToDto(Payment payment){
        PaymentResponseDto responseDto = new PaymentResponseDto();

        responseDto.setPaymentId(payment.getPaymentId());
        responseDto.setFullName(payment.getMember().getFullName());
        responseDto.setPaymentType(String.valueOf(payment.getPaymentType()));
        responseDto.setAmount(payment.getAmount());
        responseDto.setRemarks(payment.getRemarks());
        responseDto.setPaymentStatus(String.valueOf(payment.getPaymentStatus()));
        responseDto.setPaymentDate(payment.getPaymentDate());
        responseDto.setSubmissionDate(payment.getSubmissionDate());
        responseDto.setSubmissionTime(payment.getSubmissionTime());

        return responseDto;
    }

    public Double getPendingTotalAmount(HttpServletRequest request) {
        Member member = getMemberFromRequest(request);
        int currentYear = LocalDate.now().getYear();
        return paymentRepo.sumAmountByMemberIdAndStatusAndYear(member.getMemberID(), PaymentStatus.PENDING, currentYear);
    }

    public Double getApprovedTotalAmount(HttpServletRequest request) {
        Member member = getMemberFromRequest(request);
        int currentYear = LocalDate.now().getYear();
        return paymentRepo.sumAmountByMemberIdAndStatusAndYear(member.getMemberID(), PaymentStatus.APPROVED, currentYear);
    }

    public Double getTotalAmount(HttpServletRequest request) {
        Member member = getMemberFromRequest(request);
        int currentYear = LocalDate.now().getYear();
        Double pending = paymentRepo.sumAmountByMemberIdAndStatusAndYear(member.getMemberID(), PaymentStatus.PENDING, currentYear);
        Double approved = paymentRepo.sumAmountByMemberIdAndStatusAndYear(member.getMemberID(), PaymentStatus.APPROVED, currentYear);
        return pending + approved;
    }

    public YearMonth getNextPaymentMonth(Integer memberId) {
        YearMonth lastPaid = membershipRepo.findLastPaidMonth(memberId);

        if (lastPaid == null) {
            return YearMonth.now(); // first-time payment
        }

        return lastPaid.plusMonths(1);
    }

    //Methode to get all records Oshan-2/11
    public List<Payment> getAll(){
        return paymentRepo.findAll();
    }

    public List<YearMonth> getUnpaidMonths(Integer memberId) {

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        YearMonth joinMonth = YearMonth.from(member.getJoinDate());
        YearMonth currentMonth = YearMonth.now();

        List<YearMonth> approvedMonths = membershipRepo.findAllApprovedMonths(memberId);

        List<YearMonth> unpaidMonths = new ArrayList<>();

        YearMonth iter = joinMonth;

        while (!iter.isAfter(currentMonth)) {
            if (!approvedMonths.contains(iter)) {
                unpaidMonths.add(iter);
            }
            iter = iter.plusMonths(1);
        }

        return unpaidMonths;
    }


}



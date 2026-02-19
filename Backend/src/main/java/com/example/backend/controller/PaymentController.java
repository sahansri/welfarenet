package com.example.backend.controller;

import com.example.backend.dto.response.PaymentResponseDto;
import com.example.backend.entity.*;
import com.example.backend.enums.PaymentStatus;
import com.example.backend.enums.PaymentType;
import com.example.backend.services.AttendanceService;
import com.example.backend.services.PaymentService;
import com.example.backend.services.S3Service;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.List;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {


    private final PaymentService paymentService;
    private final AttendanceService attendanceService;
    private final S3Service s3Service;

    public PaymentController(PaymentService paymentService,AttendanceService attendanceService, S3Service s3Service) {
        this.paymentService = paymentService;
        this.attendanceService = attendanceService;
        this.s3Service = s3Service;
    }

    @PostMapping("/donation")
    public ResponseEntity<Payment> addDonationPayment(
            HttpServletRequest request,
            @RequestParam MultipartFile slip,
            @RequestParam Integer eventId,
            @RequestParam Double amount,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate paymentDate,
            @RequestParam(required = false) String remarks) {

        String slipUrl = s3Service.uploadFile(slip);

        Donation donation = new Donation();
        donation.setSlipUrl(slipUrl);
        donation.setRemarks(remarks);

        Event event = new Event();
        event.setEventId(eventId);
        donation.setEvent(event);

        Payment payment = new Payment();
        payment.setAmount(amount);
        payment.setRemarks(remarks);
        payment.setPaymentDate(paymentDate);

        Payment saved = paymentService.addDonationPayment(request, payment, donation);
        return ResponseEntity.ok(saved);
    }

    @PostMapping("/membership")
    public ResponseEntity<Payment> addMembershipPayment(
            HttpServletRequest request,
            @RequestParam MultipartFile slip,
            @RequestParam Double amount,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM") YearMonth selectedMonth,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate paymentDate,
            @RequestParam(required = false) String remarks) {

        String slipUrl = s3Service.uploadFile(slip);

        MembershipFee fee = new MembershipFee();
        fee.setSlipUrl(slipUrl);
        fee.setApproved(false);

        Payment payment = new Payment();
        payment.setAmount(amount);
        payment.setRemarks(remarks);
        payment.setPaymentDate(paymentDate);
        payment.setSubmissionDate(LocalDate.now());
        payment.setSubmissionTime(LocalTime.now());
        payment.setPaymentType(PaymentType.MEMBERSHIP);
        payment.setPaymentStatus(PaymentStatus.PENDING);
        payment.setMembershipDetails(fee);

        Payment saved = paymentService.addMembershipPayment(request, payment, fee,selectedMonth);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/membership/unpaid-months")
    public ResponseEntity<List<YearMonth>> getUnpaidMonths(HttpServletRequest request) {

        Member member = paymentService.getMemberFromRequest(request);

        return ResponseEntity.ok(
                paymentService.getUnpaidMonths(member.getMemberID())
        );
    }

    @GetMapping("/membership/next-month")
    public ResponseEntity<YearMonth> getNextMembershipMonth(HttpServletRequest request) {
        Member member = paymentService.getMemberFromRequest(request);
        return ResponseEntity.ok(
                paymentService.getNextPaymentMonth(member.getMemberID())
        );
    }

    // Get my payments for all time
    @GetMapping("/my-payments")
    public ResponseEntity<List<Payment>> getMyPayments(HttpServletRequest request) {
        return ResponseEntity.ok(paymentService.getMyPayments(request));
    }

    // Get my payments for specific year (defaults to current year)
    @GetMapping("/my-payments-by-year")
    public ResponseEntity<List<Payment>> getMyPaymentsByYear(
            HttpServletRequest request,
            @RequestParam(required = false) Integer year
    ) {
        return ResponseEntity.ok(paymentService.getMyPaymentsByYear(request, year));
    }

    @PutMapping("/{paymentId}/approve")
    public ResponseEntity<Payment> approvePayment(
            @PathVariable Long paymentId,
            HttpServletRequest request
    ) {
        int adminId = attendanceService.extractMemberIdFromToken(request);
        return ResponseEntity.ok(paymentService.approvePayment(paymentId, adminId));
    }

    @PostMapping("/{paymentId}/reject")
    public ResponseEntity<String> rejectPayment(
            @PathVariable Long paymentId,
            @RequestParam String paymentType,
            @RequestParam String reason) {

        PaymentType type;
        try {
            type = PaymentType.valueOf(paymentType.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Invalid payment type: " + paymentType);
        }

        paymentService.rejectPayment(paymentId, type, reason);
        return ResponseEntity.ok("Payment rejected successfully.");
    }

    @GetMapping("/unapproved")
    public ResponseEntity<List<PaymentResponseDto>> getUnapprovedPayments(
            HttpServletRequest request
    ) {
        return ResponseEntity.ok(paymentService.getUnapprovedPayments(request));
    }

    //total pending amount endpoints (yearly)
    @GetMapping("/my-pending-total")
    public ResponseEntity<?> getMyPendingTotal(HttpServletRequest request) {
        Double total = paymentService.getPendingTotalAmount(request);
        return ResponseEntity.ok(new TotalAmountResponse(total));
    }
    //total approved amount endpoints (yearly)
    @GetMapping("/my-approved-total")
    public ResponseEntity<?> getMyApprovedTotal(HttpServletRequest request) {
        Double total = paymentService.getApprovedTotalAmount(request);
        return ResponseEntity.ok(new TotalAmountResponse(total));
    }
    //total amount endpoints (yearly)
    @GetMapping("/my-total")
    public ResponseEntity<?> getMyTotalAmount(HttpServletRequest request) {
        Double total = paymentService.getTotalAmount(request);
        return ResponseEntity.ok(new TotalAmountResponse(total));
    }

    //Get all records Oshan-2/11
    @GetMapping("/getAll")
    public ResponseEntity<List<Payment>> getAllPayments(){
        List<Payment> all = paymentService.getAll();
        return ResponseEntity.ok(all);
    }

    // Inner class for JSON response
    private static class TotalAmountResponse {
        private final Double totalAmount;

        public TotalAmountResponse(Double totalAmount) {
            this.totalAmount = totalAmount;
        }

        public Double getTotalAmount() {
            return totalAmount;
        }
    }

}

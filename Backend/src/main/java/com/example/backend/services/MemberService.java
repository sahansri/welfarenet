package com.example.backend.services;

import com.example.backend.entity.Member;
import com.example.backend.entity.AccDeactivationRequests;
import com.example.backend.enums.MemberStatus;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.AccDeactivationRequestsRepository;
import com.example.backend.repository.MemberRepository;
import com.example.backend.repository.MembershipFeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class MemberService implements UserDetailsService {

    private final MemberRepository memberRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final MembershipFeeRepository membershipFeeRepo;
    private final AccDeactivationRequestsRepository accdeactivationRepo;
    private final NotificationService notificationService;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return org.springframework.security.core.userdetails.User.builder()
                .username(member.getEmail())
                .password(member.getPassword())
                .authorities(new ArrayList<>())  // you can add roles later
                .build();
    }

    public Member getMemberById(Integer id) {
        return memberRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Member not found"));
    }

    public Member updateMemberById(Integer id, Member updatedMember) {

        Optional<Member> optionalMember = memberRepository.findById(id);

        if (optionalMember.isEmpty()) {
            throw new RuntimeException("Member not found");
        }

        Member existing = optionalMember.get();

        // Update ONLY non-null & non-blank values
        if (updatedMember.getFullName() != null && !updatedMember.getFullName().isBlank()) {
            existing.setFullName(updatedMember.getFullName());
        }
        if (updatedMember.getAddress() != null && !updatedMember.getAddress().isBlank()) {
            existing.setAddress(updatedMember.getAddress());
        }
        if (updatedMember.getContactNumber() != null && !updatedMember.getContactNumber().isBlank()) {
            existing.setContactNumber(updatedMember.getContactNumber());
        }
        if (updatedMember.getEmail() != null && !updatedMember.getEmail().isBlank()) {
            existing.setEmail(updatedMember.getEmail());
        }
        if (updatedMember.getHouseNo() != null && !updatedMember.getHouseNo().isBlank()) {
            existing.setHouseNo(updatedMember.getHouseNo());
        }
        if (updatedMember.getJoinDate() != null) {
            existing.setJoinDate(updatedMember.getJoinDate());
        }
        if (updatedMember.getRole() != null && !updatedMember.getRole().isBlank()) {
            existing.setRole(updatedMember.getRole());
        }
        if (updatedMember.getTotalStars() != null) {
            existing.setTotalStars(updatedMember.getTotalStars());
        }
        if (updatedMember.getPassword() != null && !updatedMember.getPassword().isBlank()) {
            existing.setPassword(passwordEncoder.encode(updatedMember.getPassword()));
        }

        return memberRepository.save(existing);
    }

    public Member getMemberByEmail(String email) {
        return memberRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Member not found with email: " + email));
    }


    public Member updateMyDetails(String email, Member updatedMember) {
        Optional<Member> optional = memberRepository.findByEmail(email);
        if (optional.isEmpty()) {
            throw new RuntimeException("Member not found");
        }
        Member existing = optional.get();
        // Update only non-null and non-blank fields
        if (updatedMember.getFullName() != null && !updatedMember.getFullName().isBlank()) {
            existing.setFullName(updatedMember.getFullName());
        }
        if (updatedMember.getContactNumber() != null && !updatedMember.getContactNumber().isBlank()) {
            existing.setContactNumber(updatedMember.getContactNumber());
        }
        if (updatedMember.getAddress() != null && !updatedMember.getAddress().isBlank()) {
            existing.setAddress(updatedMember.getAddress());
        }
        if (updatedMember.getHouseNo() != null && !updatedMember.getHouseNo().isBlank()) {
            existing.setHouseNo(updatedMember.getHouseNo());
        }
        // Update password only if provided
        if (updatedMember.getPassword() != null && !updatedMember.getPassword().isBlank()) {
            existing.setPassword(passwordEncoder.encode(updatedMember.getPassword()));
        }
        return memberRepository.save(existing);
    }

    public String changePassword(String email, String oldPassword, String newPassword) {
        Optional<Member> optional = memberRepository.findByEmail(email);
        if (optional.isEmpty()) {
            return "NOT_FOUND";
        }
        Member member = optional.get();
        // Validate old password
        if (!passwordEncoder.matches(oldPassword, member.getPassword())) {
            return "OLD_PASSWORD_INCORRECT";
        }
        // Update password
        member.setPassword(passwordEncoder.encode(newPassword));
        memberRepository.save(member);
        return "SUCCESS";
    }


    public boolean deleteMember(Integer id) {
        Optional<Member> optional = memberRepository.findById(id);

        if (optional.isEmpty()) {
            return false;
        }

        memberRepository.deleteById(id);
        return true;
    }

    public List<Member> getAllMembers() {
        return memberRepository.findAll();
    }

    // Forgot Password Feature
    public void sendResetOtp(String email) {
        System.out.println(email);
        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email not registered"));

        String otp = String.valueOf(new Random().nextInt(900000) + 100000);
        member.setResetOtp(otp);
        member.setOtpExpiry(LocalDateTime.now().plusMinutes(4));
        member.setOtpVerified(false);

        memberRepository.save(member);

        emailService.sendOtp(email, otp);
    }

    public void verifyResetOtp(String email, String otp) {
        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email not found"));

        if (!otp.equals(member.getResetOtp()))
            throw new RuntimeException("Invalid OTP");

        if (member.getOtpExpiry().isBefore(LocalDateTime.now()))
            throw new RuntimeException("OTP expired");

        member.setOtpVerified(true);
        memberRepository.save(member);
    }

    public void resetPassword(String email, String password, String confirmPassword) {

        if (!password.equals(confirmPassword))
            throw new RuntimeException("Passwords do not match");

        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email not found"));

        if (!Boolean.TRUE.equals(member.getOtpVerified()))
            throw new RuntimeException("OTP not verified");

        String hashed = passwordEncoder.encode(password);
        member.setPassword(hashed);

        // reset OTP fields
        member.setResetOtp(null);
        member.setOtpExpiry(null);
        member.setOtpVerified(false);

        memberRepository.save(member);
    }

    //Service methode for add users Oshan(12/15)
    public Member addMember(Member member){
        if(memberRepository.existsByEmail(member.getEmail())){
            throw new IllegalStateException("Member already exists!");
        }
        return memberRepository.save(member);
    }

    @Transactional
    public void deactivateAccount(Integer memberId, String reason) {

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        //Validate membership fee paid until current month
        YearMonth lastPaidMonth = membershipFeeRepo.findLastPaidMonth(memberId);
        YearMonth currentMonth = YearMonth.now();

        if (lastPaidMonth == null || lastPaidMonth.isBefore(currentMonth)) {
            throw new RuntimeException(
                    "You must pay membership fee up to current month before deactivation.");
        }

        // Save deactivation reason to new table
        AccDeactivationRequests record = new AccDeactivationRequests();
        record.setMember(member);
        record.setReason(reason);
        record.setRequestedAt(LocalDateTime.now());
        record.setLastPaidMonth(lastPaidMonth);

        accdeactivationRepo.save(record);

        // Update member status → INACTIVE
        member.setStatus(MemberStatus.INACTIVE);
        memberRepository.save(member);

        List<Member> admins = memberRepository.findAllByRoleIn(List.of(
                "PRESIDENT", "VICE_PRESIDENT", "SECRETARY", "TREASURER"
        ));

        for (Member admin : admins) {
            notificationService.sendNotification(
                    admin.getMemberID(),
                    "Member Account Deactivated",
                    "Member " + member.getFullName() + " has deactivated their account. Reason: " + reason,
                    NotificationType.MEMBER_STATUS_CHANGE,
                    false
            );
        }
    }

    @Transactional
    public void reactivateAccount(Integer adminId, Integer memberId) {
        
        Member admin = memberRepository.findById(adminId)
                .orElseThrow(() -> new RuntimeException("Admin not found"));

        List<String> topRoles = List.of("PRESIDENT", "VICE_PRESIDENT", "SECRETARY", "TREASURER");
        if (!topRoles.contains(admin.getRole())) {
            throw new RuntimeException("Only admins can reactivate accounts.");
        }

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        member.setStatus(MemberStatus.ACTIVE);
        memberRepository.save(member);

        notificationService.sendNotification(
                member.getMemberID(),
                "Account Reactivated",
                "Your account has been reactivated by the admin.",
                NotificationType.MEMBER_STATUS_CHANGE,
                true
        );
    }

    public List<Member> getAllInactiveMembers() {
        return memberRepository.findByStatus(MemberStatus.INACTIVE);
    }

}

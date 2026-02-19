package com.example.backend.controller;

import com.example.backend.entity.Member;
import com.example.backend.repository.MemberRepository;
import com.example.backend.security.JwtUtil;
import com.example.backend.services.AttendanceService;
import com.example.backend.services.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/member")
public class MemberController {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final MemberService memberService;
    private final JwtUtil jwtUtil;
    private final AttendanceService attendanceService;

    @Autowired
    public MemberController(MemberRepository memberRepository,
                            PasswordEncoder passwordEncoder,
                            MemberService memberService,
                            JwtUtil jwtUtil, AttendanceService attendanceService) {
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.memberService = memberService;
        this.jwtUtil = jwtUtil;
        this.attendanceService = attendanceService;
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyDetails(Authentication authentication) {
        String email = authentication.getName(); // get email from JWT auth
        Optional<Member> optionalMember = memberRepository.findByEmail(email);

        if (optionalMember.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(optionalMember.get());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getMemberById(@PathVariable Integer id) {
        Optional<Member> optionalMember = memberRepository.findById(id);
        return optionalMember.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateMyDetails(@RequestBody Member updatedMember,
                                             Authentication authentication) {
        String email = authentication.getName();
        Member updated = memberService.updateMyDetails(email, updatedMember);
        return ResponseEntity.ok(updated);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateMemberById(@PathVariable Integer id,
                                              @RequestBody Member updatedMember) {
        Member updated = memberService.updateMemberById(id, updatedMember);
        return ResponseEntity.ok(updated);
    }

    @PutMapping("/me/password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> passwords,
                                            Authentication authentication) {
        String email = authentication.getName();
        String oldPassword = passwords.get("oldPassword");
        String newPassword = passwords.get("newPassword");

        if (oldPassword == null || newPassword == null) {
            return ResponseEntity.badRequest().body("Both oldPassword and newPassword are required");
        }
        String result = memberService.changePassword(email, oldPassword, newPassword);

        return switch (result) {
            case "NOT_FOUND" -> ResponseEntity.notFound().build();
            case "OLD_PASSWORD_INCORRECT" -> ResponseEntity.status(401).body("Old password is incorrect");
            case "SUCCESS" -> ResponseEntity.ok("Password changed successfully");
            default -> ResponseEntity.status(500).body("Unknown error occurred");
        };
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMemberById(@PathVariable Integer id) {
        Optional<Member> optionalMember = memberRepository.findById(id);

        if (optionalMember.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        memberRepository.deleteById(id);
        return ResponseEntity.ok("Member deleted successfully");
    }

    @GetMapping("/search/{id}")
    public ResponseEntity<?> searchMemberById(@PathVariable Integer id) {
        Optional<Member> optionalMember = memberRepository.findById(id);
        return optionalMember.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    //Forgot Password Feature
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestParam String email) {
        memberService.sendResetOtp(email);
        return ResponseEntity.ok("OTP sent to email");
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestParam String email,
                                       @RequestParam String otp) {
        memberService.verifyResetOtp(email, otp);
        return ResponseEntity.ok("OTP verified");
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestParam String email,
                                           @RequestParam String password,
                                           @RequestParam String confirmPassword) {
        memberService.resetPassword(email, password, confirmPassword);
        return ResponseEntity.ok("Password updated");
    }

    //for getting All user information Oshan(12/15)
    @GetMapping("/all")
    public ResponseEntity<?> getAll(){
        List<Member> allUsers = memberService.getAllMembers();
        if(allUsers.isEmpty()){
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(allUsers);
    }

    //for add members
    @PostMapping("/add")
    public ResponseEntity<?> addMembers(@RequestBody Member memberinfo){
        Member newMember = new Member();
        newMember.setFullName(memberinfo.getFullName());
        newMember.setEmail(memberinfo.getEmail());
        newMember.setContactNumber(memberinfo.getContactNumber());
        newMember.setAddress(memberinfo.getAddress());
        newMember.setHouseNo(memberinfo.getHouseNo());
        newMember.setRole(memberinfo.getRole());
        newMember.setPassword(passwordEncoder.encode(memberinfo.getPassword()));
        try{
            Member saved = memberService.addMember(newMember);
            System.out.println(saved);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        }
    }

    @PostMapping("/deactivate")
    public ResponseEntity<?> deactivate(
            @RequestBody Map<String, String> body,
            HttpServletRequest request
    ) {
        Long memberId = jwtUtil.extractUserIdFromRequest(request);
        if (memberId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Invalid or missing token");
        }

        String reason = body.get("reason");

        // Convert Long -> Integer safely because Member IDs are Integer in the entity
        if (memberId > Integer.MAX_VALUE || memberId < Integer.MIN_VALUE) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("User id is out of range");
        }

        memberService.deactivateAccount(memberId.intValue(), reason);

        return ResponseEntity.ok("Account deactivated successfully.");
    }

    @PutMapping("/{memberId}/reactivate")
    public ResponseEntity<?> reactivateAccount(
            @PathVariable Integer memberId,
            HttpServletRequest request
    ) {
        // Extract adminId from JWT
        Integer adminId = attendanceService.extractMemberIdFromToken(request);

        memberService.reactivateAccount(adminId, memberId);

        return ResponseEntity.ok("Member account reactivated successfully.");
    }

    @GetMapping("/inactive-members")
    public ResponseEntity<?> getAllInactiveMembers(HttpServletRequest request) {
        
        Integer adminId = attendanceService.extractMemberIdFromToken(request);
        Member admin = memberService.getMemberById(adminId);

        List<String> adminRoles = List.of("PRESIDENT", "VICE_PRESIDENT", "SECRETARY", "TREASURER");
        if (!adminRoles.contains(admin.getRole())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Only admins can view inactive members");
        }

        List<Member> inactiveMembers = memberService.getAllInactiveMembers();

        if (inactiveMembers.isEmpty()) {
            return ResponseEntity.ok("No inactive members found");
        }

        return ResponseEntity.ok(inactiveMembers);
    }
}

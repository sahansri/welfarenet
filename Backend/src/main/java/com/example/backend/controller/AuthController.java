package com.example.backend.controller;

import com.example.backend.entity.Member;
import com.example.backend.entity.RegistrationRequest;
import com.example.backend.enums.MemberStatus;
import com.example.backend.repository.MemberRepository;
import com.example.backend.security.JwtUtil;
import com.example.backend.services.RegistrationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final RegistrationService registrationService;

    public AuthController(AuthenticationManager authenticationManager,
                          JwtUtil jwtUtil,
                          MemberRepository memberRepository,
                          PasswordEncoder passwordEncoder,
                          RegistrationService registrationService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.registrationService = registrationService;
    }

    @PostMapping("/self-register")
    public ResponseEntity<?> selfRegister(
            @RequestParam String fullName,
            @RequestParam String address,
            @RequestParam String contactNumber,
            @RequestParam String email,
            @RequestParam String houseNo,
            @RequestParam MultipartFile proofDocument
    ) {
        registrationService.submitRequest(
                fullName, address, contactNumber, email, houseNo, proofDocument
        );
        return ResponseEntity.ok("Registration request submitted. Wait for admin approval.");
    }

    @GetMapping("/registrations/pending")
    public ResponseEntity<List<RegistrationRequest>> getPendingRegistrations() {
        return ResponseEntity.ok(registrationService.getPendingRegistrations());
    }

    @PostMapping("/approve/{requestId}")
    public ResponseEntity<?> approve(@PathVariable Integer requestId) {
        registrationService.approveRequest(requestId);
        return ResponseEntity.ok("User approved and email sent.");
    }

    @PostMapping("/reject/{requestId}")
    public ResponseEntity<?> reject(
            @PathVariable Integer requestId,
            @RequestBody Map<String, String> body
    ) {
        String reason = body.get("reason");
        registrationService.rejectRequest(requestId, reason);
        return ResponseEntity.ok("Request rejected and email sent.");
    }



    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody Member member) {
        member.setPassword(passwordEncoder.encode(member.getPassword()));
        memberRepository.save(member);
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Member registered successfully");
        return response;
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> loginData) throws Exception {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginData.get("email"), loginData.get("password"))
            );
        } catch (BadCredentialsException e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Incorrect username or password"
            );
        }
        Member member = memberRepository
                .findByEmailAndStatus(loginData.get("email"), MemberStatus.ACTIVE)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.FORBIDDEN,
                        "Account inactive or not found"
                ));

        if (member.getStatus() == MemberStatus.INACTIVE) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Your account is not activated yet. Please wait for admin approval."
            );
        }

        String token = jwtUtil.generateToken(member.getEmail(), member.getRole(), member.getMemberID());
        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("role", member.getRole());
        response.put("memberId", member.getMemberID());
        return response;
    }
}


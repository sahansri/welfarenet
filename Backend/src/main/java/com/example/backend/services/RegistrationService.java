package com.example.backend.services;

import com.example.backend.Utility.PasswordGenerator;
import com.example.backend.entity.Member;
import com.example.backend.entity.RegistrationRequest;
import com.example.backend.enums.MemberStatus;
import com.example.backend.enums.RequestStatus;
import com.example.backend.repository.MemberRepository;
import com.example.backend.repository.RegistrationRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final RegistrationRequestRepository requestRepo;
    private final S3Service s3Service;
    private final MemberRepository memberRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final RegistrationRequestRepository registrationRequestRepo;

    public void submitRequest(
            String fullName,
            String address,
            String contactNumber,
            String email,
            String houseNo,
            MultipartFile proofDoc
    ) {
        if (requestRepo.existsByEmail(email)) {
            throw new RuntimeException("Request already submitted with this email");
        }

        String docUrl = s3Service.uploadFile(proofDoc);

        RegistrationRequest req = new RegistrationRequest();
        req.setFullName(fullName);
        req.setAddress(address);
        req.setContactNumber(contactNumber);
        req.setEmail(email);
        req.setHouseNo(houseNo);
        req.setProofDocumentUrl(docUrl);

        requestRepo.save(req);
    }

    @Transactional
    public void approveRequest(Integer requestId) {

        RegistrationRequest req = requestRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        String randomPassword = PasswordGenerator.generate(); // see below

        Member member = new Member();
        member.setFullName(req.getFullName());
        member.setAddress(req.getAddress());
        member.setContactNumber(req.getContactNumber());
        member.setEmail(req.getEmail());
        member.setHouseNo(req.getHouseNo());
        member.setJoinDate(LocalDate.now());   // ⭐ approved date
        member.setRole("MEMBER");
        member.setPassword(passwordEncoder.encode(randomPassword));
        member.setStatus(MemberStatus.ACTIVE);

        memberRepository.save(member);

        req.setStatus(RequestStatus.APPROVED);
        req.setProcessedAt(LocalDateTime.now());
        requestRepo.save(req);

        emailService.sendMail(
                req.getEmail(),
                "WelfareNet Registration Approved",
                "Dear " + req.getFullName() + ",\n\n" +
                        "Your registration has been APPROVED.\n\n" +
                        "Username: " + req.getEmail() + "\n" +
                        "Password: " + randomPassword + "\n\n" +
                        "Please login and change your password.\n\n" +
                        "Best Regards,\nWelfareNet Team"
        );
    }

    @Transactional
    public void rejectRequest(Integer requestId, String reason) {

        RegistrationRequest req = requestRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        if (req.getProofDocumentUrl() != null && !req.getProofDocumentUrl().isEmpty()) {
            s3Service.deleteFile(req.getProofDocumentUrl());
        }

        emailService.sendMail(
                req.getEmail(),
                "WelfareNet Registration Rejected",
                "Dear " + req.getFullName() + ",\n\n" +
                        "Your registration request has been REJECTED.\n" +
                        "Reason: " + reason + "\n\n" +
                        "Please contact admin for more details.\n\n" +
                        "Best Regards,\nWelfareNet Team"
        );

        requestRepo.delete(req);   // ⭐ requirement
    }

    public List<RegistrationRequest> getPendingRegistrations() {
        return registrationRequestRepo.findByStatus(RequestStatus.PENDING);
    }


}


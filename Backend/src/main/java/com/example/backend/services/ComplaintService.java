package com.example.backend.services;

import com.example.backend.entity.Complaint;
import com.example.backend.entity.Member;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.ComplaintRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepo;
    private final MemberService memberService;
    private final NotificationService notificationService;

    /* MEMBER: Submit complaint/suggestion */
    public Complaint submitComplaint(
            Integer memberId,
            String type,
            String title,
            String description,
            boolean anonymous
    ) {
        Complaint complaint = new Complaint();

        if (!anonymous) {
            Member member = memberService.getMemberById(memberId);
            complaint.setSubmittedBy(member);
        }

        complaint.setType(type);
        complaint.setTitle(title);
        complaint.setDescription(description);
        complaint.setIsAnonymous(anonymous);
        complaint.setIsReviewed(false);
        complaint.setDateSubmitted(LocalDateTime.now());

        return complaintRepo.save(complaint);
    }

    /* MEMBER: View own complaints */
    public List<Complaint> getMemberComplaints(Integer memberId) {
        return complaintRepo.findBySubmittedBy_MemberID(memberId);
    }

    /* ADMIN: View unread complaints */
    public List<Complaint> getUnreadComplaints() {
        return complaintRepo.findByIsReviewedFalse();
    }

    /* ADMIN: Review complaint */
    @Transactional
    public Complaint reviewComplaint(Integer complaintId, Integer adminId, String response) {

        Complaint complaint = complaintRepo.findById(complaintId)
                .orElseThrow(() -> new RuntimeException("Complaint not found"));

        if (complaint.getIsReviewed()) {
            throw new RuntimeException("Complaint already reviewed");
        }

        Member admin = memberService.getMemberById(adminId);

        complaint.setIsReviewed(true);
        complaint.setReviewedBy(admin);
        complaint.setDateReviewed(LocalDateTime.now());
        complaint.setAdminResponse(response);

        Complaint savedComplaint = complaintRepo.save(complaint);

        Member submitter = savedComplaint.getSubmittedBy();
        if (submitter != null) {
            notificationService.sendNotification(
                    submitter.getMemberID(),   // recipient
                    "Complaint Reviewed",
                    "Admin Response: " + response,
                    NotificationType.COMPLAINT,
                    false
            );
        }
        return savedComplaint;
    }

    //Oshan 1/13
    public List<Complaint> getAll(){
        return complaintRepo.findAll();
    }
}


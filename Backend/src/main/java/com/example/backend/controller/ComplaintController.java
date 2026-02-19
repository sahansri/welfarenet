package com.example.backend.controller;

import com.example.backend.entity.Complaint;
import com.example.backend.services.AttendanceService;
import com.example.backend.services.ComplaintService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;
    private final AttendanceService attendanceService;

    //Member endpoints
    // Submit complaint or suggestion
    @PostMapping("/submit")
    public Complaint submitComplaint(
            @RequestParam String type,
            @RequestParam String title,
            @RequestParam String description,
            @RequestParam boolean anonymous,
            HttpServletRequest request
    ) {
        int memberId = attendanceService.extractMemberIdFromToken(request);

        return complaintService.submitComplaint(
                memberId,
                type,
                title,
                description,
                anonymous
        );
    }

    // View member's past complaints
    @GetMapping("/my")
    public List<Complaint> myComplaints(HttpServletRequest request) {
        int memberId = attendanceService.extractMemberIdFromToken(request);
        return complaintService.getMemberComplaints(memberId);
    }

    //Admin endpoints
    // View all unread complaints
    @GetMapping("/unread")
    public List<Complaint> getUnreadComplaints() {
        return complaintService.getUnreadComplaints();
    }

    // Mark complaint as reviewed
    @PostMapping("/review/{complaintId}")
    public Complaint reviewComplaint(
            @PathVariable Integer complaintId,
            @RequestParam String response,
            HttpServletRequest request
    ) {
        int adminId = attendanceService.extractMemberIdFromToken(request);
        return complaintService.reviewComplaint(complaintId, adminId, response);
    }

    //View all complaints Oshan (1/13)
    @GetMapping("/all")
    public List<Complaint> getAllComplaints(){
        return complaintService.getAll();
    }
}


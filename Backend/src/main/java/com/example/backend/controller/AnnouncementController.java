package com.example.backend.controller;

import com.example.backend.entity.Announcement;
import com.example.backend.enums.AnnouncementPriority;
import com.example.backend.services.AnnouncementService;
import com.example.backend.services.AttendanceService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;
    private final AttendanceService attendanceService;

    //VIEW – ALL USERS
    //Edit to return a response Entity Oshan-1/21
    @GetMapping("/getall")
    public ResponseEntity<List<Announcement>> getAllAnnouncements() {
        return ResponseEntity.ok( announcementService.getAllAnnouncements());
    }

    // CREATE – TOP ROLES ONLY
    @PostMapping("/create")
    public Announcement createAnnouncement(
            @RequestBody Announcement newAnnouncement,
            HttpServletRequest request
    ) {
        int adminId = attendanceService.extractMemberIdFromToken(request);
        String title = newAnnouncement.getTitle();
        String description = newAnnouncement.getDescription();
        AnnouncementPriority priority  = newAnnouncement.getPriority();
        LocalDate expiry_date = newAnnouncement.getExpiryDate();
        return announcementService.createAnnouncement(adminId, title, description,priority,expiry_date);
    }

    // UPDATE – TOP ROLES ONLY
    //Changing RequestParams to RequestBody -- Oshan 1/13
    @PutMapping("/update/{id}")
    public Announcement updateAnnouncement(
            @PathVariable Integer id,
            @RequestBody Announcement updatedAnnouncement,
            HttpServletRequest request
    ) {
        int adminId = attendanceService.extractMemberIdFromToken(request);
        String title = updatedAnnouncement.getTitle();
        String description = updatedAnnouncement.getDescription();
        AnnouncementPriority priority = updatedAnnouncement.getPriority();
        LocalDate expiry_date = updatedAnnouncement.getExpiryDate();
        return announcementService.updateAnnouncement(id, adminId, title, description,priority,expiry_date);
    }

    // DELETE – TOP ROLES ONLY
    @DeleteMapping("/delete/{id}")
    public void deleteAnnouncement(
            @PathVariable Integer id,
            HttpServletRequest request
    ) {
        int adminId = attendanceService.extractMemberIdFromToken(request);
        announcementService.deleteAnnouncement(id, adminId);
    }

    @GetMapping("/recent-3")
    public ResponseEntity<List<Announcement>> getRecent3Announcements() {
        return ResponseEntity.ok(announcementService.getRecent3Announcements());
    }

}


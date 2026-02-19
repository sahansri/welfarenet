package com.example.backend.services;

import com.example.backend.entity.Announcement;
import com.example.backend.entity.Member;
import com.example.backend.enums.AnnouncementPriority;
import com.example.backend.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementRepository announcementRepo;
    private final MemberService memberService;

    //CREATE
    //Added priority and expiry Date  Oshan 1-13
    public Announcement createAnnouncement(
            Integer adminId,
            String title,
            String description,
            AnnouncementPriority priority,
            LocalDate expiry_date
    ) {
        Member admin = memberService.getMemberById(adminId);
        validateTopRole(admin);

        Announcement announcement = Announcement.builder()
                .title(title)
                .description(description)
                .postedBy(admin)
                .createdDate(LocalDateTime.now())
                .postedDate(LocalDateTime.now())
                .priority(priority)
                .expiryDate(expiry_date)
                .build();

        return announcementRepo.save(announcement);
    }

    //UPDATE
    public Announcement updateAnnouncement(
            Integer announcementId,
            Integer adminId,
            String title,
            String description,
            AnnouncementPriority priority,
            LocalDate expiry_date
    ) {
        Member admin = memberService.getMemberById(adminId);
        validateTopRole(admin);

        Announcement announcement = announcementRepo.findById(announcementId)
                .orElseThrow(() -> new RuntimeException("Announcement not found"));

        announcement.setTitle(title);
        announcement.setDescription(description);
        announcement.setPostedDate(LocalDateTime.now());
        announcement.setPriority(priority);
        announcement.setExpiryDate(expiry_date);

        return announcementRepo.save(announcement);
    }

    //DELETE
    public void deleteAnnouncement(Integer announcementId, Integer adminId) {
        Member admin = memberService.getMemberById(adminId);
        validateTopRole(admin);

        announcementRepo.deleteById(announcementId);
    }

    //VIEW (ALL USERS)
    public List<Announcement> getAllAnnouncements() {
        return announcementRepo.findAllByOrderByPostedDateDesc();
    }

    //ROLE VALIDATION
    private void validateTopRole(Member member) {
        if (member == null || member.getRole() == null) {
            throw new RuntimeException("Unauthorized");
        }

        String role = member.getRole();

        if (!(role.equals("PRESIDENT")
                || role.equals("admin")
                || role.equals("VICE_PRESIDENT")
                || role.equals("SECRETARY")
                || role.equals("TREASURER"))) {
            throw new RuntimeException("Access denied");
        }
    }

    public List<Announcement> getRecent3Announcements() {
        return announcementRepo.findTop3ByOrderByPostedDateDesc();
    }
}

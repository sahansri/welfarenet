package com.example.backend.scheduler;

import com.example.backend.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class AnnouncementCleanupScheduler {

    private final AnnouncementRepository announcementRepo;

    // Runs every hour
    //Changed to LocalDate oshan-01/29
    @Scheduled(cron = "0 0 * * * *")
    public void deleteExpiredAnnouncements() {
        announcementRepo.deleteByExpiryDateBefore(LocalDate.now());
    }
}

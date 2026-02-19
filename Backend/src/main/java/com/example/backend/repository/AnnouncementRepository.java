package com.example.backend.repository;

import com.example.backend.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Integer> {

    // Latest announcements first
    List<Announcement> findAllByOrderByPostedDateDesc();
    //Changed to LocalDate oshan 01/29
    void deleteByExpiryDateBefore(LocalDate time);
    List<Announcement> findTop3ByOrderByPostedDateDesc();
}

package com.example.backend.repository;

import com.example.backend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Integer recipientId);

    long countByRecipientIdAndReadStatusFalse(Integer recipientId);

    Optional<Notification> findByNotificationIdAndRecipientId(Integer notificationId, Integer recipientId);
}

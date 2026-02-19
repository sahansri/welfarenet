package com.example.backend.services;

import com.example.backend.entity.Notification;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final EmailService emailService;

    public Notification sendNotification(
            Integer recipientId,
            String title,
            String message,
            NotificationType type,
            boolean sendEmail
    ) {

        Notification notification = new Notification();
        notification.setRecipientId(recipientId);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type);
        notification.setReadStatus(false);
        notification.setCreatedAt(LocalDateTime.now());

        Notification saved = notificationRepository.save(notification);

        // real-time notification (new notification)
        messagingTemplate.convertAndSend(
                "/topic/notifications/" + recipientId,
                saved
        );

        // optional: push unread count update
        messagingTemplate.convertAndSend(
                "/topic/notifications/" + recipientId + "/unread-count",
                getUnreadCount(recipientId)
        );

        // Send email
        if (sendEmail) {
            emailService.sendEmailAsync(recipientId, title, message);
        }

        return saved;
    }

    public List<Notification> getNotificationsByRecipient(Integer recipientId) {
        System.out.println(recipientId);
        return notificationRepository
                .findByRecipientIdOrderByCreatedAtDesc(recipientId);
    }

    public Notification markAsRead(Integer notificationId, Integer recipientId) {
        Notification notification = notificationRepository
                .findByNotificationIdAndRecipientId(notificationId, recipientId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));

        if (Boolean.TRUE.equals(notification.getReadStatus())) {
            return notification; // already read, no-op
        }

        notification.setReadStatus(true);
        Notification saved = notificationRepository.save(notification);

        // real-time update (read status changed)
        messagingTemplate.convertAndSend(
                "/topic/notifications/" + recipientId + "/read",
                saved
        );

        // optional: push unread count update
        messagingTemplate.convertAndSend(
                "/topic/notifications/" + recipientId + "/unread-count",
                getUnreadCount(recipientId)
        );

        return saved;
    }

    public long getUnreadCount(Integer recipientId) {
        return notificationRepository
                .countByRecipientIdAndReadStatusFalse(recipientId);
    }

}

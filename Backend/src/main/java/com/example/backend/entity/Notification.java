package com.example.backend.entity;

import com.example.backend.enums.NotificationType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "notifications")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Integer notificationId;

    @Column(name = "title", length = 150, nullable = false)
    private String title;

    @Column(name = "message", length = 500, nullable = false)
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", length = 50, nullable = false)
    private NotificationType type;

    @Column(name = "recipient_id", nullable = false)
    private Integer recipientId;   // Member ID or Admin ID

    @Column(name = "is_read", nullable = false)
    private Boolean readStatus = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // Default constructor
    public Notification() {}

    // explicit equals/hashCode/toString (ID-based, Hibernate-safe)
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Notification that = (Notification) o;
        return notificationId != null
                ? notificationId.equals(that.notificationId)
                : that.notificationId == null;
    }

    @Override
    public int hashCode() {
        return notificationId != null ? notificationId.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Notification{" +
                "notificationId=" + notificationId +
                ", title='" + title + '\'' +
                ", type=" + type +
                ", recipientId=" + recipientId +
                '}';
    }
}


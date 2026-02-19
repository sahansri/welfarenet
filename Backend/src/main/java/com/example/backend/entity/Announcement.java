package com.example.backend.entity;

import com.example.backend.enums.AnnouncementPriority;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "announcements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Announcement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "announcement_id")
    private Integer announcementId;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_date", nullable = false)
    private LocalDateTime createdDate;

    @Column(name = "posted_date", nullable = false)
    private LocalDateTime postedDate;

    // Admin / top-role member who posted
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "posted_by", nullable = false)
    @JsonIgnoreProperties({"email","address","contactNumber","role","houseNo","joinDate","totalStars","password"})
    private Member postedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false)
    private AnnouncementPriority priority;

    @Column(name = "expiry_date", nullable = false)
    private LocalDate expiryDate;

    @OneToMany(mappedBy = "announcement", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AnnouncementAttachment> attachments = new ArrayList<>();

    public void addAttachment(String fileUrl) {
        AnnouncementAttachment att = new AnnouncementAttachment(fileUrl, this);
        attachments.add(att);
    }

    public void removeAttachment(AnnouncementAttachment att) {
        attachments.remove(att);
        att.setAnnouncement(null);
    }

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDateTime.now();
        this.postedDate = LocalDateTime.now();
    }
}


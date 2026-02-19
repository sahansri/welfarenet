package com.example.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "complaints")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "complaint_id")
    private Integer complaintId;

    // Nullable → allows anonymous complaints
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submitted_by")
    @JsonIgnoreProperties({
            "password",
            "address",
            "contactNumber",
            "email",
            "houseNo",
            "role",
            "joinDate",
            "totalStars"
    })
    private Member submittedBy;

    // Admin / top-role member who reviewed the complaint
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    @JsonIgnoreProperties({
            "password",
            "address",
            "contactNumber",
            "email",
            "houseNo",
            "role",
            "joinDate",
            "totalStars"
    })
    private Member reviewedBy;

    //Title(Topic) for the complaint; Oshan(01/11)
    @Column(name="title",nullable=false,columnDefinition = "TEXT")
    private String title;

    @Column(name = "type", nullable = false, length = 30)
    private String type; // COMPLAINT or SUGGESTION

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_anonymous", nullable = false)
    private Boolean isAnonymous;

    @Column(name = "is_reviewed", nullable = false)
    private Boolean isReviewed = false;

    @Column(name = "date_submitted", nullable = false)
    private LocalDateTime dateSubmitted;

    @Column(name = "date_reviewed")
    private LocalDateTime dateReviewed;

    @Column(name = "admin_response", columnDefinition = "TEXT")
    private String adminResponse;

    @PrePersist
    protected void onCreate() {
        this.dateSubmitted = LocalDateTime.now();
        this.isReviewed = false;
    }
}


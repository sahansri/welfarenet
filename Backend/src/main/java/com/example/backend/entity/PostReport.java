package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "post_reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer reportId;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member reporter;

    @ManyToOne
    @JoinColumn(name = "post_id", nullable = false)
    private NewsFeed post;

    @Column(length = 500)
    private String reason;

    @Column(nullable = false)
    private LocalDate reportDate;

    @Column(nullable = false)
    private LocalTime reportTime;

    @PrePersist
    public void prePersist() {
        this.reportDate = LocalDate.now();
        this.reportTime = LocalTime.now();
    }
}


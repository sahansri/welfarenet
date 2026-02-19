package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class EventQrCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long qrId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id")
    private Event event;

    private String qrCodeUrl;
    private LocalDateTime generatedTime;
    private LocalDateTime accessedTime;
    private LocalDateTime expiredTime;

    private boolean isExpired;

    @Column(length = 255)
    private String qrCodeData;  // Encoded JSON / event payload
}

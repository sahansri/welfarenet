package com.example.backend.entity;

import com.example.backend.enums.RequestStatus;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "registration_requests")
@Getter
@Setter
public class RegistrationRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer requestId;


    private String fullName;
    private String address;
    private String contactNumber;

    @Column(unique = true)
    private String email;

    private String houseNo;

    private String proofDocumentUrl;   // stored in S3

    @Enumerated(EnumType.STRING)
    private RequestStatus status = RequestStatus.PENDING;

    private String rejectionReason;

    private LocalDateTime submittedAt = LocalDateTime.now();
    private LocalDateTime processedAt;
}


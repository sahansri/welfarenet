package com.example.backend.entity;

import com.example.backend.enums.PaymentStatus;
import com.example.backend.enums.PaymentType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Entity
@Table(name = "payment")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long paymentId;

    // RELATION → Member who made the payment
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    @JsonIgnoreProperties({
            "password",
            "address",
            "contactNumber",
            "email",
            "houseNo",
            "joinDate",
            "totalStars"
    })
    private Member member;

    @Enumerated(EnumType.STRING)
    private PaymentType paymentType;

    private Double amount;

    private String remarks;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus;

    private LocalDate paymentDate;

    private LocalDate submissionDate;
    private LocalTime submissionTime;

    @OneToOne(mappedBy = "payment", cascade = CascadeType.ALL)
    private Donation donationDetails;

    @OneToOne(mappedBy = "payment", cascade = CascadeType.ALL)
    private MembershipFee membershipDetails;

}


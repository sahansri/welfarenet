package com.example.backend.entity;

import com.example.backend.enums.ClaimStatus;
import com.example.backend.enums.Reward;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "star_claim_requests")
@Data
@NoArgsConstructor
public class StarClaimRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "request_id")
    private Long requestId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "claim_type_id", nullable = false)
    private StarClaimOffer claimOffer;

    @Enumerated(EnumType.STRING)
    @Column(name = "reward", nullable = false, length = 30)
    private Reward reward;

    @Column(nullable = false)
    private Integer starsDeducted; // stars deducted when applying

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private ClaimStatus status = ClaimStatus.PENDING;

    @Column(name = "applied_at" )
    private LocalDateTime appliedAt;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    // who approved/rejected (role/name)
    @Column(length = 150)
    private String processedBy;

    @Column(length = 500)
    private String adminMessage;

    @Column(name = "voucher_reference")
    private String voucherReference;
}

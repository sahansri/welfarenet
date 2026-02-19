package com.example.backend.entity;

import com.example.backend.enums.Reward;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "star_claim_offers")
@Data
@NoArgsConstructor
public class StarClaimOffer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "claim_type_id")
    private Integer claimTypeId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reward", nullable = false, length = 30)
    private Reward reward;

    @Column(name = "stars_required", nullable = false)
    private Integer starsRequired;

    @Column(name = "rewarded_value" ,nullable = false, precision = 10, scale = 2)
    private BigDecimal rewardValue; // e.g., 500.00

    @PrePersist
    @PreUpdate
    private void syncFromReward() {
        this.starsRequired = reward.getPointsRequired();
        this.rewardValue = reward.getVoucherValue();
    }
}


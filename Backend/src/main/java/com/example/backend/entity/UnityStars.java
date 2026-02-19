package com.example.backend.entity;

import com.example.backend.enums.RewardType;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.YearMonth;

@Entity
@Table(name = "unity_stars")
@Data
@NoArgsConstructor
public class UnityStars {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reward_id")
    private Integer rewardID;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "reward_month", nullable = true)
    private YearMonth rewardMonth;

    // positive when earned, zero allowed
    @Column(name = "stars_earned", nullable = false)
    private Integer starsEarned = 0;

    // positive when burned/redeemed
    @Column(name = "stars_burned", nullable = false)
    private Integer starsBurned = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "reward_type", nullable = false)
    private RewardType rewardType;

    // optional FK to StarClaimOffer if this transaction is from burning for a claim
    private Integer claimTypeId;

    @Column(name = "date", nullable = false)
    private LocalDate date;

}

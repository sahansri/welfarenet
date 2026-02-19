package com.example.backend.dto.response;

import com.example.backend.enums.ClaimStatus;
import com.example.backend.enums.Reward;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StarClaimRequestResponseDto {
    private Long requestId;
    private Integer memberId;
    private String memberName;
    private Integer claimTypeId;
    private Reward reward;
    private Integer starsRequired;
    private BigDecimal rewardValue;
    private Integer starsDeducted;
    private ClaimStatus status;
    private LocalDateTime appliedAt;
    private LocalDateTime processedAt;
    private String processedBy;
    private String adminMessage;
}


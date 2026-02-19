package com.example.backend.dto.response;

import com.example.backend.entity.Member;
import com.example.backend.enums.ClaimStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StarClaimsResponseDto {
    public Long requestId;
    public String fullName;
    public BigDecimal rewardValue;
    public Integer starsDeducted;
    public ClaimStatus status;
    public LocalDateTime appliedAt;


}

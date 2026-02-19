package com.example.backend.repository;

import com.example.backend.dto.response.StarClaimsResponseDto;
import com.example.backend.entity.StarClaimRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface StarClaimRequestRepository extends JpaRepository<StarClaimRequest, Long> {

    List<StarClaimRequest> findByMember_MemberID(Integer memberMemberID);

    @Query("""
        SELECT r
        FROM StarClaimRequest r
        JOIN FETCH r.member
        ORDER BY r.appliedAt DESC
    """)
    List<StarClaimRequest> findAllWithMember();

    //Query for fetching claims using DTO's -Oshan 1/29
    @Query("""
    SELECT new com.example.backend.dto.response.StarClaimsResponseDto(
            r.requestId,
            m.fullName,
            o.rewardValue,
            r.starsDeducted,
            r.status,
            r.appliedAt
        )
        FROM StarClaimRequest r
        JOIN r.member m
        JOIN r.claimOffer o
        WHERE r.status = 'PENDING'
        ORDER BY r.appliedAt DESC
    """)
    List<StarClaimsResponseDto> findAllStarClaims();

}

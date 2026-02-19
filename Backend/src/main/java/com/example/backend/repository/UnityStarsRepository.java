package com.example.backend.repository;

import com.example.backend.entity.UnityStars;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.YearMonth;

public interface UnityStarsRepository extends JpaRepository<UnityStars, Integer> {
    @Query("SELECT (COALESCE(SUM(u.starsEarned), 0) - COALESCE(SUM(u.starsBurned), 0)) " +
            "FROM UnityStars u WHERE u.member.memberID = :memberId")
    Integer calculateAvailableStars(@Param("memberId") Integer memberId);

    @Query("SELECT u FROM UnityStars u WHERE u.member.memberID = :memberId AND u.rewardMonth = :rewardMonth")
    UnityStars findByMemberAndMonth(
            @Param("memberId") Integer memberId,
            @Param("rewardMonth") YearMonth rewardMonth
    );
    boolean existsByMember_MemberIDAndRewardMonth(Integer memberId, YearMonth month);

}

package com.example.backend.repository;

import com.example.backend.entity.MembershipFee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.YearMonth;
import java.util.List;
import java.util.Optional;

public interface MembershipFeeRepository extends JpaRepository<MembershipFee, Long> {
    @Query("""
        SELECT MAX(m.paymentMonth)
        FROM MembershipFee m
        WHERE m.payment.member.memberID = :memberId
          AND m.approved = true
    """)
    YearMonth findLastPaidMonth(@Param("memberId") Integer memberId);

    @Query("""
    SELECT m.paymentMonth
    FROM MembershipFee m
    WHERE m.payment.member.memberID = :memberId
      AND m.approved = true
""")
    List<YearMonth> findAllApprovedMonths(@Param("memberId") Integer memberId);

    Optional<MembershipFee> findByPayment_PaymentId(Long paymentID);
}

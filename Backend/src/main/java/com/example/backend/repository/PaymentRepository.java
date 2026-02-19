package com.example.backend.repository;

import com.example.backend.entity.Payment;
import com.example.backend.entity.Member;
import com.example.backend.enums.PaymentStatus;
import com.example.backend.enums.PaymentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByMember(Member member);
    List<Payment> findByPaymentStatus(PaymentStatus status);

    @Query("SELECT COALESCE(SUM(p.amount), 0.0) FROM Payment p WHERE p.member.memberID = :memberId AND p.paymentStatus = :status")
    Double sumAmountByMemberIdAndStatus(@Param("memberId") Integer memberId, @Param("status") PaymentStatus status);

    @Query("""
            SELECT MONTH(p.paymentDate),SUM(p.amount)
            FROM Payment p
            WHERE p.paymentType = com.example.backend.enums.PaymentType.MEMBERSHIP
            AND p.paymentStatus = com.example.backend.enums.PaymentStatus.APPROVED
            AND p.paymentDate BETWEEN :startDate AND :endDate
            GROUP BY MONTH(p.paymentDate)
            ORDER BY MONTH(p.paymentDate)
    """)
    List<Object[]> getMonthlyMembershipTotal(LocalDate startDate,LocalDate endDate);

    @Query("""
            SELECT MONTH(p.paymentDate),SUM(p.amount)
            FROM Payment p
            WHERE p.paymentType = com.example.backend.enums.PaymentType.DONATION
            AND p.paymentStatus = com.example.backend.enums.PaymentStatus.APPROVED
            AND p.paymentDate BETWEEN :startDate AND :endDate
            GROUP BY MONTH(p.paymentDate)
            ORDER BY MONTH(p.paymentDate)
    """)
    List<Object[]> getMonthlyDonationTotal(LocalDate startDate,LocalDate endDate);



    @Query("SELECT COALESCE(SUM(p.amount), 0.0) FROM Payment p WHERE p.member.memberID = :memberId AND p.paymentStatus = :status AND YEAR(p.submissionDate) = :year")
    Double sumAmountByMemberIdAndStatusAndYear(@Param("memberId") Integer memberId, @Param("status") PaymentStatus status, @Param("year") int year);

    @Query("SELECT p FROM Payment p WHERE p.member = :member AND FUNCTION('year', p.paymentDate) = :year")
    List<Payment> findByMemberAndYear(@Param("member") Member member, @Param("year") int year);
}

package com.example.backend.repository;

import com.example.backend.entity.Member;
import com.example.backend.enums.MemberStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;


public interface MemberRepository extends JpaRepository<Member, Integer> {
    Optional<Member> findByEmail(String email);
    Optional<Member> findByEmailAndStatus(String email, MemberStatus status);
    boolean existsByEmail(String email);

    @Query("SELECT m.memberID, m.fullName, m.totalStars FROM Member m")
    List<Object[]> findMemberIdAndMemberNamesAndStarBalance();
    List<Member> findAllByRoleIn(List<String> roles);
    List<Member> findByStatus(MemberStatus status);
}

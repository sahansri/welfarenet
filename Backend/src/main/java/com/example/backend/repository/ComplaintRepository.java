package com.example.backend.repository;

import com.example.backend.entity.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Integer> {

    // Member history
    List<Complaint> findBySubmittedBy_MemberID(Integer memberId);

    // Admin unread complaints
    List<Complaint> findByIsReviewedFalse();

    // Admin reviewed complaints
    List<Complaint> findByIsReviewedTrue();
}


package com.example.backend.repository;

import com.example.backend.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    boolean existsByMember_MemberIDAndEvent_EventId(Long memberId, Long eventId);
    List<Attendance> findByEvent_EventId(Integer eventId);
}


package com.example.backend.services;

import com.example.backend.entity.Attendance;
import com.example.backend.entity.Event;
import com.example.backend.entity.Member;
import com.example.backend.repository.AttendanceRepository;
import com.example.backend.security.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import static com.example.backend.enums.RewardType.EARN;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final AttendanceRepository attendanceRepo;
    private final MemberService memberService;
    private final EventService eventService;
    private final UnityStarsService unityStarsService;
    private final JwtUtil jwtUtil;

    public String markAttendance(Integer memberId, Integer eventId) {

        Member member = memberService.getMemberById(memberId);
        Event event = eventService.getEventById(eventId);

        Long memberLongId = member.getMemberID() != null ? member.getMemberID().longValue() : null;
        Long eventLongId = event.getEventId() != null ? event.getEventId().longValue() : null;

        if (memberId == null || eventId == null) {
            return "Invalid member or event id.";
        }

        boolean exists = attendanceRepo.existsByMember_MemberIDAndEvent_EventId(memberLongId, eventLongId);

        if (exists) {
            return "Attendance already marked.";
        }

        Attendance at = new Attendance();
        at.setMember(member);
        at.setEvent(event);
        at.setAttendanceStatus("PRESENT");

        attendanceRepo.save(at);
        unityStarsService.awardStars(memberId,4,EARN);

        return "Attendance marked successfully.";
    }

    public int extractMemberIdFromToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Missing or invalid Authorization header");
        }

        String token = authHeader.substring(7);
        String email = jwtUtil.extractUsername(token);

        Member member = memberService.getMemberByEmail(email);
        if (member == null || member.getMemberID() == null) {
            throw new RuntimeException("Member not found for email: " + email);
        }
        return member.getMemberID().intValue();
    }

}


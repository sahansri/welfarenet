package com.example.backend.controller;

import com.example.backend.services.AttendanceService;
import com.example.backend.services.EventQrCodeService;
import com.example.backend.services.EventService;
import com.example.backend.services.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;
    private final EventQrCodeService eventQrCodeService;

    @PostMapping("/mark")
    public String markAttendance(
            @RequestParam String qrContent,
            HttpServletRequest request
    ) {

        int memberId = attendanceService.extractMemberIdFromToken(request);

        Integer eventId = eventQrCodeService.validateQrAndGetEventId(qrContent);

        if (eventId == null) {
            return "Invalid or expired QR";
        }

        return attendanceService.markAttendance(memberId, eventId);
    }


}


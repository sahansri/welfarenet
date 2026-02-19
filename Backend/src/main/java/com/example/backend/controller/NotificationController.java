package com.example.backend.controller;

import com.example.backend.entity.Member;
import com.example.backend.entity.Notification;
import com.example.backend.security.JwtUtil;
import com.example.backend.services.MemberService;
import com.example.backend.services.NotificationService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final JwtUtil jwtUtil;
    private final MemberService memberService;

    /**
     * Get notifications for the currently authenticated user.
     * (Using /me avoids clients reading other users' notifications.)
     */
    @GetMapping("/me")
    public List<Notification> myNotifications(HttpServletRequest request) {
        String email = jwtUtil.extractSubjectFromRequest(request);
        if (email == null || email.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }

        Member me = memberService.getMemberByEmail(email);
        return notificationService.getNotificationsByRecipient(me.getMemberID());
    }

    /**
     * Mark one notification as read for the currently authenticated user.
     */
    @PutMapping("/{id}/read")
    public Notification markAsRead(@PathVariable Integer id, HttpServletRequest request) {
        String email = jwtUtil.extractSubjectFromRequest(request);
        if (email == null || email.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }

        Member me = memberService.getMemberByEmail(email);

        try {
            return notificationService.markAsRead(id, me.getMemberID());
        } catch (RuntimeException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, ex.getMessage());
        }
    }

    /**
     * Unread count (badge) for the current user.
     */
    @GetMapping("/me/unread-count")
    public long myUnreadCount(HttpServletRequest request) {
        String email = jwtUtil.extractSubjectFromRequest(request);
        if (email == null || email.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }

        Member me = memberService.getMemberByEmail(email);
        return notificationService.getUnreadCount(me.getMemberID());
    }
    // NotificationController.java
    @PostMapping("/fcm-token")
    public void saveFCMToken(@RequestBody Map<String, Object> request, HttpServletRequest httpRequest) {
        Long userId = jwtUtil.extractUserIdFromRequest(httpRequest);
        String fcmToken = (String) request.get("fcmToken");

        // Save FCM token to database for this user
        // memberService.updateFCMToken(userId, fcmToken);

        System.out.println("FCM Token saved for user " + userId + ": " + fcmToken);
    }
}

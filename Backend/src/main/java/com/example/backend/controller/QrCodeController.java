package com.example.backend.controller;

import com.example.backend.entity.Event;
import com.example.backend.entity.EventQrCode;
import com.example.backend.services.EventQrCodeService;
import com.example .backend.services.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/qr")
@RequiredArgsConstructor
public class QrCodeController {
    private final EventQrCodeService qrService;
    private final EventService eventService;

    @PostMapping("/generate/{eventId}")
    public ResponseEntity<?> generate(@PathVariable Integer eventId) {
        try {
            Event event = eventService.getEventById(eventId);
            EventQrCode qr = qrService.generateQRCode(event);

             return ResponseEntity.ok(qr);
        }catch (Exception e) {
            return ResponseEntity.status(500).body("QR code generation failed: " + e.getMessage());
        }
    }

    @GetMapping("/{eventId}")
    public ResponseEntity<?> getQR(@PathVariable Integer eventId) {

        Event event = eventService.getEventById(eventId);

        LocalDate eventDate = event.getDate();
        LocalDate today = LocalDate.now();

        // BLOCK ACCESS BEFORE EVENT DAY
        if (today.isBefore(eventDate)) {
            return ResponseEntity
                    .status(403)
                    .body("QR code will be available only on the event day.");
        }

        try {
            EventQrCode qr = qrService.getQRCodeForEvent(eventId);

            if (qr == null) {
                return ResponseEntity.status(404).body("QR code not found for this event.");
            }

            return ResponseEntity.ok(qr);
        } catch (RuntimeException ex) {
            // map service runtime "not found" into 404 instead of 500
            return ResponseEntity.status(404).body(ex.getMessage());
        }
    }
}

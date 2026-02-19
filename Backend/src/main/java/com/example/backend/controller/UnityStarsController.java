package com.example.backend.controller;

import com.example.backend.entity.UnityStars;
import com.example.backend.services.UnityStarsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stars")
@RequiredArgsConstructor
public class UnityStarsController {

    private final UnityStarsService unityStarsService;

    /*Award star endpoint (for admin/system)
      Example: /api/stars/award?memberId=5&type=ATTENDANCE
     */
    @PostMapping("/award")
    public ResponseEntity<?> awardStars(
            @RequestParam Integer memberId,
            @RequestParam Integer points
    ) {
        UnityStars rec = unityStarsService.awardStars(memberId, points, com.example.backend.enums.RewardType.EARN);
        return ResponseEntity.ok(rec);
    }

    @GetMapping("/balance/{memberId}")
    public ResponseEntity<?> balance(@PathVariable Integer memberId) {
        int bal = unityStarsService.getMemberBalance(memberId);
        return ResponseEntity.ok(java.util.Map.of("balance", bal));
    }

    @PreAuthorize("hasAnyRole('ADMIN','PRESIDENT','SECRETARY','TREASURER')")
    @GetMapping("/balances")
    public ResponseEntity<List<Map<String, Object>>> getMemberStarBalances() {
        return ResponseEntity.ok(unityStarsService.getMemberStarBalances());
    }
}

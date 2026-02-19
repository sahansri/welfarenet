package com.example.backend.controller;

import com.example.backend.dto.response.StarClaimsResponseDto;
import com.example.backend.dto.response.StarClaimRequestResponseDto;
import com.example.backend.entity.Member;
import com.example.backend.entity.StarClaimOffer;
import com.example.backend.entity.StarClaimRequest;
import com.example.backend.repository.StarClaimOfferRepository;
import com.example.backend.repository.StarClaimRequestRepository;
import com.example.backend.security.JwtUtil;
import com.example.backend.services.MemberService;
import com.example.backend.services.StarClaimService;
import com.example.backend.services.UnityStarsService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/claims")
@RequiredArgsConstructor
public class StarClaimController {

    private final StarClaimService claimService;
    private final StarClaimOfferRepository offerRepository;
    private final StarClaimRequestRepository requestRepository;
    private final MemberService memberService;
    private final UnityStarsService unityStarsService;
    private final JwtUtil jwtUtil;

    //List available claim offers
    @GetMapping("/offers")
    public ResponseEntity<List<StarClaimOffer>> offers() {
        return ResponseEntity.ok(offerRepository.findAll());
    }

    @GetMapping("/redeemable-offers")
    public ResponseEntity<List<StarClaimOffer>> getRedeemableOffers(HttpServletRequest request) {

        // 1. Extract memberId from JWT
        String username = jwtUtil.extractUsernameFromRequest(request);
        Member member = memberService.getMemberByEmail(username);
        Integer memberId = member.getMemberID();

        int availableStars = unityStarsService.getMemberBalance(memberId);

        // 5. Fetch all offers
        List<StarClaimOffer> allOffers = offerRepository.findAll();

        // 6. Filter redeemable offers
        List<StarClaimOffer> redeemableOffers = allOffers.stream()
                .filter(offer -> offer.getStarsRequired() <= availableStars)
                .toList();

        // 7. Return redeemable offers
        return ResponseEntity.ok(redeemableOffers);
    }



    // Member applies for a claim
    @PostMapping("/apply")
    public ResponseEntity<?> apply(
            @RequestParam Integer memberId,
            @RequestParam Integer claimTypeId
    ) {
        StarClaimRequest req = claimService.applyForClaim(memberId, claimTypeId);
        return ResponseEntity.ok(req);
    }

    //Admin approves a claim
    @PostMapping("/approve/{requestId}")
    public ResponseEntity<?> approve(
            @PathVariable Long requestId,
            @RequestParam String voucherReference,
            HttpServletRequest request
    ) {

        String username = jwtUtil.extractUsernameFromRequest(request);
        Member admin = memberService.getMemberByEmail(username);
        String processedBy = admin.getFullName();
        claimService.approveClaim(requestId, processedBy,voucherReference);
        return ResponseEntity.ok("Claim approved. " +
                "Member may collect voucher from treasurer. Voucher reference: " +
                 voucherReference);
    }

    @PostMapping("/issue/{requestId}")
    public ResponseEntity<?> issueVoucher(
            @PathVariable Long requestId,
            HttpServletRequest request
    ) {
        String username = jwtUtil.extractUsernameFromRequest(request);
        Member admin = memberService.getMemberByEmail(username);
        String issuedBy = admin.getFullName();
        claimService.issueVoucher(requestId, issuedBy);
        return ResponseEntity.ok("Voucher issued successfully.");
    }

    // Admin rejects a claim
    //Changing requestParams to requestBody due to limitations
    @PostMapping("/reject/{requestId}")
    public ResponseEntity<?> reject(
            @PathVariable Long requestId,
            @RequestBody String processedBy,
            @RequestBody(required = false) String reason
    ) {
        claimService.rejectClaim(requestId, processedBy, reason == null ? "Rejected by admin" : reason);
        return ResponseEntity.ok("Claim rejected and stars returned to member.");
    }

    //Get a specific request
    @GetMapping("/request/{requestId}")
    public ResponseEntity<?> getRequest(@PathVariable Long requestId) {
        return ResponseEntity.ok(claimService.getRequest(requestId));
    }

    @GetMapping("/getallclaims")
    public ResponseEntity<List<StarClaimRequest>> getAllClaims() {
        return ResponseEntity.ok(claimService.getAllClaimRequests());
    }

    @GetMapping("/getAllStarClaims")
    public ResponseEntity<List<StarClaimsResponseDto>> getAllStarClaims(){
        return ResponseEntity.ok(requestRepository.findAllStarClaims());
    }
    // Get all claim requests history for a specific member
    @GetMapping("/member/requests")
    public ResponseEntity<List<StarClaimRequestResponseDto>> getMemberClaimRequests(HttpServletRequest request) {
        // Extract memberId from JWT
        String username = jwtUtil.extractUsernameFromRequest(request);
        Member member = memberService.getMemberByEmail(username);
        Integer memberId = member.getMemberID();

        List<StarClaimRequestResponseDto> requests = claimService.getClaimRequestsByMemberId(memberId);
        return ResponseEntity.ok(requests);
    }
}

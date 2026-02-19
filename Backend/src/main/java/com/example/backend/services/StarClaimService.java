package com.example.backend.services;

import com.example.backend.dto.response.StarClaimsResponseDto;
import com.example.backend.dto.response.StarClaimRequestResponseDto;
import com.example.backend.entity.*;
import com.example.backend.enums.ClaimStatus;
import com.example.backend.enums.Reward;
import com.example.backend.enums.RewardType;
import com.example.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StarClaimService {

    private final MemberRepository memberRepository;
    private final StarClaimOfferRepository offerRepository;
    private final StarClaimRequestRepository requestRepository;
    private final UnityStarsRepository unityStarsRepository;

    // Member applies for a claim. Immediately deducts stars and creates a PENDING request.
    @Transactional
    public StarClaimRequest applyForClaim(Integer memberId, Integer claimTypeId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        StarClaimOffer offer = offerRepository.findById(claimTypeId)
                .orElseThrow(() -> new RuntimeException("Claim offer not found"));

        Reward reward = offer.getReward();
        int requiredStars = reward.getPointsRequired();

        if (member.getTotalStars() < offer.getStarsRequired()) {
            throw new RuntimeException("Insufficient stars for this reward");
        }

        // Deduct immediately
        int remaining = member.getTotalStars() - requiredStars;
        member.setTotalStars(remaining);
        memberRepository.save(member);

        // audit burn entry
        UnityStars burn = new UnityStars();
        burn.setMember(member);
        burn.setStarsEarned(0);
        burn.setStarsBurned(requiredStars);
        burn.setRewardType(RewardType.BURN);
        burn.setClaimTypeId(offer.getClaimTypeId());
        burn.setDate(java.time.LocalDate.now());
        burn.setRewardMonth(java.time.YearMonth.now());
        unityStarsRepository.save(burn);

        // create claim request
        StarClaimRequest req = new StarClaimRequest();
        req.setMember(member);
        req.setClaimOffer(offer);
        req.setReward(reward);
        req.setStarsDeducted(requiredStars);
        req.setStatus(ClaimStatus.PENDING);
        req.setAppliedAt(LocalDateTime.now());

        return requestRepository.save(req);
    }

    //Approve a pending claim (president/secretary).
    @Transactional
    public void approveClaim(Long requestId, String processedBy, String voucherRef) {
        StarClaimRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Claim request not found"));

        if (req.getStatus() != ClaimStatus.PENDING) {
            throw new RuntimeException("Claim request is not pending");
        }

        req.setStatus(ClaimStatus.APPROVED);
        req.setProcessedAt(LocalDateTime.now());
        req.setProcessedBy(processedBy);

        req.setVoucherReference(voucherRef);
        req.setAdminMessage("Voucher approved. Reference: " + voucherRef
                + ". Collect from treasurer.");
        requestRepository.save(req);
        // Note: stars were already deducted at apply time, so nothing else to do here.
    }

    //Reject a pending claim. Return deducted stars to member.
    @Transactional
    public void rejectClaim(Long requestId, String processedBy, String reason) {
        StarClaimRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Claim request not found"));

        if (req.getStatus() != ClaimStatus.PENDING) {
            throw new RuntimeException("Claim request is not pending");
        }

        // return stars to member
        Member member = req.getMember();
        int restored = member.getTotalStars() + req.getStarsDeducted();
        member.setTotalStars(restored);
        memberRepository.save(member);

        // audit reverse entry (earn back)
        UnityStars reverse = new UnityStars();
        reverse.setMember(member);
        reverse.setStarsEarned(req.getStarsDeducted());
        reverse.setStarsBurned(0);
        reverse.setRewardType(RewardType.EARN);
        reverse.setClaimTypeId(req.getClaimOffer().getClaimTypeId());
        reverse.setDate(java.time.LocalDate.now());
        unityStarsRepository.save(reverse);

        // update request
        req.setStatus(ClaimStatus.REJECTED);
        req.setProcessedAt(LocalDateTime.now());
        req.setProcessedBy(processedBy);
        req.setAdminMessage(reason);
        requestRepository.save(req);
    }

    @Transactional
    public void issueVoucher(Long requestId, String issuedBy) {
        StarClaimRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Claim request not found"));

        if (req.getStatus() != ClaimStatus.APPROVED) {
            throw new RuntimeException("Only approved claims can be issued");
        }

        req.setStatus(ClaimStatus.ISSUED);
        req.setProcessedAt(LocalDateTime.now());
        req.setProcessedBy(issuedBy);

        // Optional: update message to indicate voucher has been collected
        req.setAdminMessage(req.getAdminMessage() + " Voucher has been issued to the member.");

        requestRepository.save(req);
    }

    public List<StarClaimRequest> getAllClaimRequests() {
        return requestRepository.findAllWithMember();
    }

    public Optional<StarClaimRequest> getRequest(Long requestId) {
        return requestRepository.findById(requestId);
    }

    public List<StarClaimRequestResponseDto> getClaimRequestsByMemberId(Integer memberId) {
        List<StarClaimRequest> requests = requestRepository.findByMember_MemberID(memberId);
        return requests.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public int getAvailableStars(Integer memberId) {
        return unityStarsRepository.calculateAvailableStars(memberId);
    }

    //Oshan 1/29
    public List<StarClaimsResponseDto> getAllStarClaimsRequests(){
        return requestRepository.findAllStarClaims();
    }



    private StarClaimRequestResponseDto convertToDto(StarClaimRequest request) {
        StarClaimRequestResponseDto dto = new StarClaimRequestResponseDto();
        dto.setRequestId(request.getRequestId());
        dto.setMemberId(request.getMember().getMemberID());
        dto.setMemberName(request.getMember().getFullName());
        dto.setClaimTypeId(request.getClaimOffer().getClaimTypeId());
        dto.setReward(request.getReward());
        dto.setStarsRequired(request.getClaimOffer().getStarsRequired());
        dto.setRewardValue(request.getClaimOffer().getRewardValue());
        dto.setStarsDeducted(request.getStarsDeducted());
        dto.setStatus(request.getStatus());
        dto.setAppliedAt(request.getAppliedAt());
        dto.setProcessedAt(request.getProcessedAt());
        dto.setProcessedBy(request.getProcessedBy());
        dto.setAdminMessage(request.getAdminMessage());
        return dto;
    }

}

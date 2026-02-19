package com.example.backend.services;

import com.example.backend.entity.Member;
import com.example.backend.entity.UnityStars;
import com.example.backend.enums.RewardType;
import com.example.backend.repository.MemberRepository;
import com.example.backend.repository.UnityStarsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UnityStarsService {

    private final UnityStarsRepository unityStarsRepository;
    private final MemberRepository memberRepository;

    // Award stars for attendance (4), payment (2), volunteer (1).
    @Transactional
    public UnityStars awardStars(Integer memberId, int starsToAward, RewardType rewardType) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        // update member balance
        int newBalance = member.getTotalStars() + starsToAward;
        member.setTotalStars(newBalance);
        memberRepository.save(member);

        // audit record
        UnityStars record = new UnityStars();
        record.setMember(member);
        record.setStarsEarned(starsToAward);
        record.setStarsBurned(0);
        record.setRewardType(rewardType);
        record.setDate(LocalDate.now());

        return unityStarsRepository.save(record);
    }

    @Transactional
    public void awardStarsForMembership(
            Integer memberId,
            Integer stars,
            RewardType rewardType,
            YearMonth paymentMonth
    ) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        int newBalance = member.getTotalStars() + stars;
        member.setTotalStars(newBalance);
        memberRepository.save(member);

        UnityStars starsEntry = new UnityStars();
        starsEntry.setMember(member);
        starsEntry.setStarsEarned(stars);
        starsEntry.setStarsBurned(0);
        starsEntry.setRewardType(rewardType);
        starsEntry.setRewardMonth(paymentMonth);

        //  KEY POINT
        starsEntry.setDate(paymentMonth.atDay(1));

        unityStarsRepository.save(starsEntry);
    }

    public int getMemberBalance(Integer memberId) {
        return memberRepository.findById(memberId)
                .map(Member::getTotalStars)
                .orElse(0);
    }

    public List<Map<String, Object>> getMemberStarBalances() {
        List<Object[]> results = memberRepository.findMemberIdAndMemberNamesAndStarBalance();

        return results.stream().map(row -> {
            Map<String, Object> map = new HashMap<>();
            map.put("memberId",row[0]);
            map.put("memberName", row[1]);
            map.put("availableStars", row[2]);

            return map;
        }).toList();
    }

    public boolean hasEarnedStarsForMonth(Integer memberId, YearMonth month) {
        UnityStars stars = unityStarsRepository.findByMemberAndMonth(memberId, month);
        return stars != null;
    }

}

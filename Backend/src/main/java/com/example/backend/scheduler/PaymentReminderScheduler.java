package com.example.backend.scheduler;

import com.example.backend.entity.Member;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.MemberRepository;
import com.example.backend.services.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.List;
import java.util.Locale;

@Component
@RequiredArgsConstructor
public class PaymentReminderScheduler {

    private final MemberRepository memberRepository;
    private final NotificationService notificationService;

    // Runs every Monday at 8 AM
    @Scheduled(cron = "0 0 8 ? * MON")
    public void remindMembershipFeeDue() {

        LocalDate today = LocalDate.now();
        int weekOfMonth = today.get(WeekFields.of(Locale.getDefault()).weekOfMonth());

        // Only after second week
        if (weekOfMonth <= 2) {
            return;
        }

        List<Member> members = memberRepository.findAll();

        for (Member member : members) {
            notificationService.sendNotification(
                    member.getMemberID(),
                    "Membership Fee Due",
                    "Your membership fee is due. Please make the payment.",
                    NotificationType.PAYMENT,
                    true // email reminder is acceptable
            );
        }
    }
}

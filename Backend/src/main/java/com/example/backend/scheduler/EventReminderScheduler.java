package com.example.backend.scheduler;

import com.example.backend.entity.Event;
import com.example.backend.entity.Member;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.EventRepository;
import com.example.backend.repository.MemberRepository;
import com.example.backend.services.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class EventReminderScheduler {
    private final EventRepository eventRepository;
    private final MemberRepository memberRepository;
    private final NotificationService notificationService;

    // Runs every day at 8 AM
    @Scheduled(cron = "0 0 8 * * ?")
    public void sendEventReminders() {

        LocalDate tomorrow = LocalDate.now().plusDays(1);

        List<Event> events =
                eventRepository.findByDate(tomorrow);

        if (events.isEmpty()) return;

        List<Member> members = memberRepository.findAll();

        for (Event event : events) {
            for (Member member : members) {
                notificationService.sendNotification(
                        member.getMemberID(),
                        "Event Reminder",
                        "Reminder: \"" + event.getEventName() +
                                "\" is happening tomorrow.",
                        NotificationType.EVENT_REMINDER,
                        false
                );
            }
        }
    }
}

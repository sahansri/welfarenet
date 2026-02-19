package com.example.backend.services.serviceImpl;

import com.example.backend.Utility.QrCodeGenerator;
import com.example.backend.entity.Attendance;
import com.example.backend.entity.Event;
import com.example.backend.entity.EventQrCode;
import com.example.backend.entity.Member;
import com.example.backend.enums.NotificationType;
import com.example.backend.repository.AttendanceRepository;
import com.example.backend.repository.EventRepository;
import com.example.backend.repository.MemberRepository;
import com.example.backend.services.EventQrCodeService;
import com.example.backend.services.EventService;
import com.example.backend.services.NotificationService;
import com.example.backend.services.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EventServiceImpl implements EventService{

    private final EventRepository eventRepository;
    private final AttendanceRepository attendanceRepository;
    private final MemberRepository memberRepository;
    private final NotificationService notificationService;
    private final EventQrCodeService eventQrCodeService;

    @Transactional
    @Override
    public Event createEvent(Event event) {
        Event savedEvent =  eventRepository.save(event);
        try {
            EventQrCode qr = eventQrCodeService.generateQRCode(savedEvent);
            savedEvent.setQrCode(qr.getQrCodeUrl());

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("QR code generation failed");
        }

        savedEvent =  eventRepository.save(savedEvent);

        List<Member> members = memberRepository.findAll();

        for (Member member : members) {
            notificationService.sendNotification(
                    member.getMemberID(),
                    "New Event Scheduled",
                    "Event \"" + savedEvent.getEventName() +
                            "\" is scheduled on " + savedEvent.getDate(),
                    NotificationType.EVENT,
                    false
            );
        }

        return savedEvent;
    }

    @Override
    public Event publishEvent(Integer eventId) {
        Event event = getEventById(eventId);
        event.setPublished(true);
        return eventRepository.save(event);
    }

    @Override
    public Event updateEvent(Integer eventId, Event updatedEvent) {
        Event event = getEventById(eventId);   // fetch existing event
        // Update only non-null (and non-blank) fields
        if (updatedEvent.getEventName() != null && !updatedEvent.getEventName().isBlank()) {
            event.setEventName(updatedEvent.getEventName());
        }
        if (updatedEvent.getEventType() != null && !updatedEvent.getEventType().isBlank()) {
            event.setEventType(updatedEvent.getEventType());
        }
        if (updatedEvent.getDate() != null) {
            event.setDate(updatedEvent.getDate());
        }
        //Adding missing fields to updating service Oshan(12/31)
        if(updatedEvent.getDescription() != null){
            event.setDescription(updatedEvent.getDescription());
        }
        if(updatedEvent.getVenue() != null){
            event.setVenue(updatedEvent.getVenue());
        }
        if(updatedEvent.isDonationAccepted() != event.isDonationAccepted()){
            event.setDonationAccepted(updatedEvent.isDonationAccepted());
        }
        if(updatedEvent.getTime() != null){
            event.setTime(updatedEvent.getTime());
        }
        return eventRepository.save(event);
    }


    @Override
    public Event getEventById(Integer eventId) {
        return eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found with ID: " + eventId));
    }

    @Override
    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    @Override
    public void deleteEvent(Integer eventId) {
        eventRepository.deleteById(eventId);
    }

    @Override
    public List<Event> getEventsByMonth(int year, int month) {

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        return eventRepository.findAllByDateBetweenOrderByDateAsc(
                startDate,
                endDate
        );
    }

    @Override
    public List<Event> getRecentEventsLast30Days() {
        LocalDate last30Days = LocalDate.now().minusDays(30);
        return eventRepository.findAllByDateAfterOrderByDateDesc(last30Days);
    }

    @Override
    public List<Event> getUpcomingEvents() {
        LocalDate today = LocalDate.now();
        return eventRepository.findAllByDateAfterOrderByDateAsc(today);
    }

    @Override
    public List<Event> getEventsSortedByDateAsc() {
        return eventRepository.findAllByOrderByDateAsc();
    }

    @Override
    public List<Member> getAttendeesForEvent(Integer eventId) {

        List<Attendance> attendances =
                attendanceRepository.findByEvent_EventId(eventId);

        return attendances.stream()
                .map(Attendance::getMember)
                .collect(Collectors.toList());
    }

    @Override
    public List<Event> getFutureDonationAcceptedEvents() {
        LocalDate today = LocalDate.now();
        return eventRepository.findAllByDateAfterAndDonationAcceptedTrueOrderByDateAsc(today);
    }
}

package com.example.backend.controller;

import com.example.backend.entity.Event;
import com.example.backend.services.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @PostMapping("/create")
    public ResponseEntity<Event> createEvent(@RequestBody Event event) {
        return ResponseEntity.ok(eventService.createEvent(event));
    }

    @PutMapping("/{id}/publish")
    public ResponseEntity<Event> publishEvent(@PathVariable Integer id) {
        return ResponseEntity.ok(eventService.publishEvent(id));
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<Event> updateEvent(
            @PathVariable Integer id,
            @RequestBody Event updatedEvent
    ) {
        System.out.println("update information:"+id+"   "+updatedEvent);
        return ResponseEntity.ok(eventService.updateEvent(id, updatedEvent));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Event> getEventById(@PathVariable Integer id) {
        return ResponseEntity.ok(eventService.getEventById(id));
    }

    @GetMapping("/getAll")
    public ResponseEntity<List<Event>> getAllEvents() {
        return ResponseEntity.ok(eventService.getAllEvents());
    }

    @GetMapping("/by-month")
    public ResponseEntity<List<Event>> getEventsByMonth(
            @RequestParam int year,
            @RequestParam int month
    ) {
        return ResponseEntity.ok(eventService.getEventsByMonth(year, month));
    }

    @GetMapping("/recent")
    public ResponseEntity<List<Event>> getRecentEventsLast30Days() {
        return ResponseEntity.ok(eventService.getRecentEventsLast30Days());
    }

    @GetMapping("/upcoming")
    public ResponseEntity<List<Event>> getUpcomingEvents() {
        return ResponseEntity.ok(eventService.getUpcomingEvents());
    }

    @GetMapping("/upcoming/donation-accepted")
    public ResponseEntity<List<Event>> getFutureDonationAcceptedEvents() {
        return ResponseEntity.ok(eventService.getFutureDonationAcceptedEvents());
    }

    @GetMapping("/sorted-by-date")
    public ResponseEntity<List<Event>> getEventsSortedByDate() {
        List<Event> sortedEvents = eventService.getEventsSortedByDateAsc();
        return ResponseEntity.ok(sortedEvents);
    }

    @GetMapping("/{id}/attendees")
    public ResponseEntity<List<?>> getEventAttendees(@PathVariable Integer id) {
        return ResponseEntity.ok(eventService.getAttendeesForEvent(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteEvent(@PathVariable Integer id) {
        eventService.deleteEvent(id);
        return ResponseEntity.ok("Event deleted successfully");
    }

}


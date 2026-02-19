package com.example.backend.services;

import com.example.backend.entity.Event;
import com.example.backend.entity.Member;

import java.util.List;

public interface EventService {

    Event createEvent(Event event);

    Event publishEvent(Integer eventId);

    Event updateEvent(Integer eventId, Event updatedEvent);

    Event getEventById(Integer eventId);

    List<Event> getAllEvents();

    List<Event> getEventsByMonth(int year, int month);

    List<Event> getRecentEventsLast30Days();

    List<Event> getUpcomingEvents();

    List<Event> getEventsSortedByDateAsc();

    void deleteEvent(Integer eventId);

    List<Member> getAttendeesForEvent(Integer eventId);

    List<Event> getFutureDonationAcceptedEvents();
}

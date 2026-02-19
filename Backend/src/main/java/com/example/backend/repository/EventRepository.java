package com.example.backend.repository;

import com.example.backend.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface EventRepository extends JpaRepository<Event, Integer> {

    List<Event> findAllByOrderByDateAsc();
    List<Event> findAllByDateAfterOrderByDateDesc(LocalDate date);
    List<Event> findAllByDateAfterOrderByDateAsc(LocalDate date);
    List<Event> findAllByDateBetweenOrderByDateAsc(
            LocalDate startDate,
            LocalDate endDate
    );
    List<Event> findByDate(LocalDate date);
    List<Event> findById(int eventId);
    List<Event> findAllByDateAfterAndDonationAcceptedTrueOrderByDateAsc(LocalDate date);
}

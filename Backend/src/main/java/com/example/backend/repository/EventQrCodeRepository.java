package com.example.backend.repository;

import com.example.backend.entity.EventQrCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EventQrCodeRepository extends JpaRepository<EventQrCode, Long> {
    Optional<EventQrCode> findByEvent_EventId(Integer eventId);
}


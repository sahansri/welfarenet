package com.example.backend.repository;

import com.example.backend.entity.RegistrationRequest;
import com.example.backend.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RegistrationRequestRepository
        extends JpaRepository<RegistrationRequest, Integer> {

    boolean existsByEmail(String email);
    List<RegistrationRequest> findByStatus(RequestStatus status);
}


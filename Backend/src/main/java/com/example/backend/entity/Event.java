package com.example.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Entity
@Table(name = "events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer eventId;

    @Column(nullable = false, length = 100)
    private String eventName;

    @Column(nullable = false, length = 50)
    private String eventType;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalTime time;

    @Column(length = 500)
    private String description;

    @Column(nullable = false)
    private boolean published = false;

    @Column(nullable = false)
    private boolean donationAccepted = false;

    //Variable to store venue of a event (Oshan 12/31)
    @Column(nullable=false)
    private String venue;

    @Column(length = 255)
    private String qrCode; // Can store QR code as a Base64 string or URL to image

    // One-to-Many relationship with EventIncome
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EventIncome> eventIncomes;

    // One-to-Many relationship with EventExpense
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EventExpense> eventExpenses;
}


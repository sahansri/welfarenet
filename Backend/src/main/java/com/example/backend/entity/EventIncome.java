package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "event_incomes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventIncome {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer incomeId;

    @Column(nullable = false, length = 100)
    private String source; // e.g., ticket sales, donations

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;
}

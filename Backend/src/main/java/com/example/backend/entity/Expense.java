package com.example.backend.entity;

import com.example.backend.enums.ExpenseType;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "expense")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Expense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long expenseId;

    @Column
    private String title;

    //Added expenses type to differentiate between event expenses,operational and maintenance
    @Enumerated(EnumType.STRING)
    @Column(name="expense_type",nullable = false)
    private ExpenseType expenseType;

    @Column(name="payment_date " ,nullable= false)
    private LocalDate paymentDate;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private Double amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    @JsonIgnoreProperties({"eventType","time", "description", "published", "donationAccepted", "qrCode", "eventIncomes", "eventExpenses"})
    private Event event;

    @JsonFormat(pattern = "yyyy-MM-DD HH:mm")
    private LocalDateTime createdDate;
}

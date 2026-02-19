package com.example.backend.dto.request;

import com.example.backend.enums.ExpenseType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpensesRequestDto {
    private double amount;
    private Integer eventId;
    private ExpenseType expenseType;
    private String title;
    private LocalDate paymentDate;
    private String description;
}

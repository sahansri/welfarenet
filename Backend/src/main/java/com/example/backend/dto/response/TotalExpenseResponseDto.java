package com.example.backend.dto.response;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@Data
@RequiredArgsConstructor
public class TotalExpenseResponseDto {
    private String month;
    private double eventExpenseTotal;
    private double maintenanceExpenseTotal;
    private double otherExpensesTotal;
}

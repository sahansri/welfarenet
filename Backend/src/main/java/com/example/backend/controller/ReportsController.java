package com.example.backend.controller;

import com.example.backend.dto.response.IncomeResponseDto;
import com.example.backend.dto.response.TotalExpenseResponseDto;
import com.example.backend.services.ReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
public class ReportsController {
    private final ReportService reportService;

    public ReportsController(ReportService reportService){
        this.reportService = reportService;
    }

    @GetMapping("/annual-income")
    public ResponseEntity<List<IncomeResponseDto>> getAnnualReport(
            @RequestParam String year
    ){
        List<IncomeResponseDto> details = reportService.getIncomeForYear(year);
        return ResponseEntity.ok(details);
    }

    @GetMapping("/annual-expenses")
    public ResponseEntity<List<TotalExpenseResponseDto>> getAnnualExpenses(
            @RequestParam String year
    ){
        List<TotalExpenseResponseDto> details = reportService.getExpensesForYear(year);
        return ResponseEntity.ok(details);
    }
}

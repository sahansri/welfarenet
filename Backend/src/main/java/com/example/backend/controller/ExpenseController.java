package com.example.backend.controller;

import com.example.backend.dto.request.ExpensesRequestDto;
import com.example.backend.entity.Expense;
import com.example.backend.services.ExpenseService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/expenses")
public class ExpenseController {

    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    //Create
    @PostMapping("/create")
    public ResponseEntity<Expense> createExpense(
            HttpServletRequest request,
            @RequestBody ExpensesRequestDto expense
    ) {
        return ResponseEntity.ok(expenseService.createExpense(request, expense));
    }

    //update
    @PutMapping("/update/{expenseId}")
    public ResponseEntity<Expense> updateExpense(
            HttpServletRequest request,
            @PathVariable Long expenseId,
            @RequestBody Expense expense
    ) {
        return ResponseEntity.ok(
                expenseService.updateExpense(request, expenseId, expense)
        );
    }

    //Delete
    @DeleteMapping("/delete/{expenseId}")
    public ResponseEntity<Void> deleteExpense(
            HttpServletRequest request,
            @PathVariable Long expenseId
    ) {
        expenseService.deleteExpense(expenseId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/all")
    public ResponseEntity<List<Expense>> getAllExpenses(HttpServletRequest request) {
        return ResponseEntity.ok(expenseService.getAllExpenses(request));
    }

    @GetMapping("/event/{eventId}")
    public ResponseEntity<List<Expense>> getExpenses(
            HttpServletRequest request,
            @PathVariable Integer eventId
    ) {
        return ResponseEntity.ok(
                expenseService.getExpensesByEvent(request, eventId)
        );
    }
}


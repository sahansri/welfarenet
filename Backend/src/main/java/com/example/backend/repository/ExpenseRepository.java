package com.example.backend.repository;

import com.example.backend.entity.Event;
import com.example.backend.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    List<Expense> findAllByOrderByCreatedDateDesc();

    List<Expense> findByEventOrderByCreatedDateDesc(Event event);

    @Modifying
    @Query("DELETE FROM Expense e WHERE e.id = :id")
    void deleteExpenseById(@Param("id") Long id);

    @Query("""
            SELECT MONTH(e.paymentDate),SUM(e.amount)
            FROM Expense e
            WHERE e.expenseType = com.example.backend.enums.ExpenseType.EVENT
            AND e.paymentDate BETWEEN :startDate AND :endDate
            GROUP BY MONTH(e.paymentDate)
            ORDER BY MONTH(e.paymentDate)
            """)
    List<Object[]> getMonthlyEventExpensesTotal(LocalDate startDate,LocalDate endDate);

    @Query("""
            SELECT MONTH(e.paymentDate),SUM(e.amount)
            FROM Expense e
            WHERE e.expenseType = com.example.backend.enums.ExpenseType.MAINTENANCE
            AND e.paymentDate BETWEEN :startDate AND :endDate
            GROUP BY MONTH(e.paymentDate)
            ORDER BY MONTH(e.paymentDate)
            """)
    List<Object[]> getMonthlyMaintenanceExpensesTotal(LocalDate startDate,LocalDate endDate);


    @Query("""
            SELECT MONTH(e.paymentDate),SUM(e.amount)
            FROM Expense e
            WHERE e.expenseType IN (
                com.example.backend.enums.ExpenseType.OPERATIONAL,
                com.example.backend.enums.ExpenseType.OTHER
            )
            AND e.paymentDate BETWEEN :startDate AND :endDate
            GROUP BY MONTH(e.paymentDate)
            ORDER BY MONTH(e.paymentDate)
            """)
    List<Object[]> getMonthlyOtherExpenses(LocalDate startDate,LocalDate endDate);
}


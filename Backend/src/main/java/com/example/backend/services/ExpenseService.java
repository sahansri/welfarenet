package com.example.backend.services;

import com.example.backend.dto.request.ExpensesRequestDto;
import com.example.backend.entity.Event;
import com.example.backend.entity.Expense;
import com.example.backend.entity.Member;
import com.example.backend.repository.EventRepository;
import com.example.backend.repository.ExpenseRepository;
import com.example.backend.repository.MemberRepository;
import com.example.backend.security.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final MemberRepository memberRepository;
    private final EventRepository eventRepository;
    private final JwtUtil jwtUtil;

    //Create Expense
    public Expense createExpense(HttpServletRequest request, ExpensesRequestDto expenseRequest) {
        Member member = getMemberFromRequest(request);

        Expense expense = new Expense();

        if (!member.getRole().equals("TREASURER")) {
            throw new RuntimeException("Only Treasurer can add expenses");
        }

        Integer eventId = expenseRequest.getEventId();
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found"));

        expense.setEvent(event);
        expense.setPaymentDate(expenseRequest.getPaymentDate());
        expense.setDescription(expenseRequest.getDescription());
        expense.setExpenseType(expenseRequest.getExpenseType());
        expense.setAmount(expenseRequest.getAmount());
        expense.setTitle(expenseRequest.getTitle());
        expense.setCreatedDate(LocalDateTime.now());

        return expenseRepository.save(expense);
    }

    //Update Expense
    @Transactional
    public Expense updateExpense(HttpServletRequest request, Long expenseId, Expense updated) {
        Member member = getMemberFromRequest(request);

        if (!member.getRole().equals("TREASURER")) {
            throw new RuntimeException("Only Treasurer can update expenses");
        }

        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new RuntimeException("Expense not found"));

        expense.setTitle(updated.getTitle());
        expense.setDescription(updated.getDescription());
        expense.setExpenseType(updated.getExpenseType());
        expense.setAmount(updated.getAmount());
        expense.setPaymentDate(updated.getPaymentDate());

        if (updated.getEvent() != null) {
            Event event = eventRepository.findById(
                    updated.getEvent().getEventId()
            ).orElseThrow(() -> new RuntimeException("Event not found"));

            expense.setEvent(event);
        }

        return expense;
    }

    @Transactional
    public void deleteExpense(Long expenseId) {
        expenseRepository.deleteExpenseById(expenseId);
    }

    public List<Expense> getExpensesByEvent(HttpServletRequest request, Integer eventId) {
        Member member = getMemberFromRequest(request);
        validateTop4Roles(member);

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found"));

        return expenseRepository.findByEventOrderByCreatedDateDesc(event);
    }

    public List<Expense> getAllExpenses(HttpServletRequest request) {
        Member member = getMemberFromRequest(request);
        validateTop4Roles(member);

        return expenseRepository.findAllByOrderByCreatedDateDesc();
    }

    private Member getMemberFromRequest(HttpServletRequest request) {
        Long memberId = jwtUtil.extractUserIdFromRequest(request);
        if (memberId == null) throw new RuntimeException("Invalid token");

        return memberRepository.findById(memberId.intValue())
                .orElseThrow(() -> new RuntimeException("Member not found"));
    }

    private void validateTop4Roles(Member member) {
        List<String> roles = List.of(
                "PRESIDENT",
                "VICE_PRESIDENT",
                "SECRETARY",
                "TREASURER"
        );

        if (!roles.contains(member.getRole())) {
            throw new RuntimeException("Access denied");
        }
    }
}

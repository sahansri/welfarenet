package com.example.backend.dto.response;

import com.example.backend.entity.Member;
import com.example.backend.enums.PaymentStatus;
import com.example.backend.enums.PaymentType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PaymentResponseDto {
    private Long paymentId;
    private String fullName;
    private String paymentType;
    private Double amount;
    private String remarks;
    private String paymentStatus;
    private LocalDate paymentDate;
    private LocalDate submissionDate;
    private LocalTime submissionTime;
}

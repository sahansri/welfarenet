package com.example.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.time.YearMonth;

@Data
@Entity
@Table(name = "membership_fee")
public class MembershipFee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long membershipPaymentDetailId;

    @Column(nullable = false)
    private YearMonth paymentMonth;

    private String slipUrl;

    @Column(nullable = false)
    private Boolean approved = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private Member approvedBy;

    private LocalDateTime approvedDate;

    // RELATION → Payment
    @OneToOne
    @JoinColumn(name = "payment_id")
    @JsonIgnore
    private Payment payment;

    @Converter(autoApply = true)
    public static class YearMonthConverter
            implements AttributeConverter<YearMonth, String> {

        @Override
        public String convertToDatabaseColumn(YearMonth attribute) {
            return attribute == null ? null : attribute.toString(); // yyyy-MM
        }

        @Override
        public YearMonth convertToEntityAttribute(String dbData) {
            return dbData == null ? null : YearMonth.parse(dbData);
        }
    }

}

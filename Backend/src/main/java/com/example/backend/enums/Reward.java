package com.example.backend.enums;

import java.math.BigDecimal;

public enum Reward {

    VOUCHER_500(50, new BigDecimal("500.00")),
    VOUCHER_1000(100, new BigDecimal("1000.00")),
    VOUCHER_2000(200, new BigDecimal("2000.00"));

    private final int pointsRequired;
    private final BigDecimal voucherValue;

    Reward(int pointsRequired, BigDecimal voucherValue) {
        this.pointsRequired = pointsRequired;
        this.voucherValue = voucherValue;
    }

    public int getPointsRequired() {
        return pointsRequired;
    }

    public BigDecimal getVoucherValue() {
        return voucherValue;
    }
}

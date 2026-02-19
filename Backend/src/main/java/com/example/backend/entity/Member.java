package com.example.backend.entity;

import com.example.backend.enums.MemberStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "Members")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Member{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_id")
    private Integer memberID;

    @Column(name = "full_name", length = 100, nullable = false)
    private String fullName;

    @Column(name = "address", length = 200)
    private String address;

    @Column(name = "contact_number", length = 15)
    private String contactNumber;

    @Column(name = "email", length = 100, unique = true)
    private String email;

    @Column(name = "house_no", length = 20)
    private String houseNo;

    @Column(name = "join_date")
    private LocalDate joinDate;

    @Column(name = "role", length = 50)
    private String role;

    @Column(name = "total_stars", nullable = false)
    private Integer totalStars = 0;

    @Column(name = "password", length = 100, nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private MemberStatus status = MemberStatus.ACTIVE;

    //For Forgot Password Feature
    @JsonIgnore
    private String resetOtp;
    @JsonIgnore
    private LocalDateTime otpExpiry;
    @JsonIgnore
    private Boolean otpVerified = false;

    // Default constructor
    public Member() {}

    // explicit equals/hashCode/toString that rely only on the primary id
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Member member = (Member) o;
        return memberID != null ? memberID.equals(member.memberID) : member.memberID == null;
    }

    @Override
    public int hashCode() {
        return memberID != null ? memberID.hashCode() : 0;
    }

    @Override
    public String toString() {
        // keep representation minimal and avoid associations
        return "Member{" + "memberID=" + memberID + ", fullName=" + fullName + '}';
    }
}

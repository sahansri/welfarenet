package com.example.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Setter
@Getter
@Entity
@Table(name = "likes")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Like {

    // Getters & Setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer likeID;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne
    @JoinColumn(name = "post_id", nullable = false)
    @JsonIgnore
    private NewsFeed post;

    @Column(name = "liked_date")
    private LocalDate likedDate;

    @Column(name = "liked_time")
    private LocalTime likedTime;

    // explicit equals/hashCode/toString using identifier only
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Like like = (Like) o;
        return likeID != null ? likeID.equals(like.likeID) : like.likeID == null;
    }

    @Override
    public int hashCode() {
        return likeID != null ? likeID.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Like{" + "likeID=" + likeID + '}';
    }
}
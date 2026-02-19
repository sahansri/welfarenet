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
@Table(name = "comments")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Comment {

    // Getters & Setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer commentID;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne
    @JoinColumn(name = "post_id", nullable = false)
    @JsonIgnore
    private NewsFeed post;

    @Column(name = "comment_text", length = 255)
    private String commentText;

    @Column(name = "comment_date")
    private LocalDate commentDate;

    @Column(name = "comment_time")
    private LocalTime commentTime;

    // explicit equals/hashCode/toString using identifier only
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Comment comment = (Comment) o;
        return commentID != null ? commentID.equals(comment.commentID) : comment.commentID == null;
    }

    @Override
    public int hashCode() {
        return commentID != null ? commentID.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Comment{" + "commentID=" + commentID + '}';
    }
}

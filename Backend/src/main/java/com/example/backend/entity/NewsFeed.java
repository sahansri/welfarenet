package com.example.backend.entity;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "news_feed")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class NewsFeed {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "post_id")
    private Integer postID;

    // Author (Member)
    @ManyToOne
    @JoinColumn(name = "author_id", nullable = false)
    @JsonIgnoreProperties({"address", "contactNumber", "email", "houseNo", "joinDate", "role", "totalPoints", "password","resetOtp","otpExpiry","otpVerified","hibernateLazyInitializer","handler"})
    @ToString.Exclude // exclude association from toString to avoid deep/proxy traversal
    private Member author;

    // Content text
    @Column(columnDefinition = "TEXT") // unlimited text
    private String content;

    @OneToMany(mappedBy = "newsFeed", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<NewsFeedImage> images = new ArrayList<>();

    @Column(name = "date_posted", nullable = false, updatable = false)
    private LocalDate datePosted;

    @Column(name = "time_posted", nullable = false, updatable = false)
    private LocalTime timePosted;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    private List<Like> likes;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    private List<Comment> comments = new ArrayList<>();

    @Column(name = "like_count")
    private Integer likeCount = 0;

    @Column(name = "comment_count")
    private Integer commentCount = 0;

    public void setLikes(List<Like> likes) {
        this.likes = likes;
        this.likeCount = likes != null ? likes.size() : 0;
    }

    public void setComments(List<Comment> comments) {
        this.comments = comments;
        this.commentCount = comments != null ? comments.size() : 0;
    }

    public NewsFeed() {
        this.datePosted = LocalDate.now();
        this.timePosted = LocalTime.now();
        this.likeCount = 0;
        this.commentCount = 0;
    }

    public void setLikeCount(int i) {
        this.likeCount = i;
    }

    public void setCommentCount(int i) {
        this.commentCount = i;
    }

    // Add explicit equals/hashCode/toString that only use the identifier to avoid traversing associations or invoking proxied beans
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        NewsFeed newsFeed = (NewsFeed) o;
        return postID != null ? postID.equals(newsFeed.postID) : newsFeed.postID == null;
    }

    @Override
    public int hashCode() {
        return postID != null ? postID.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "NewsFeed{" + "postID=" + postID + '}';
    }

    public void setImagePaths(List<String> imagePaths) {
        this.images.clear();
        if (imagePaths == null) return;
        for (String path : imagePaths) {
            NewsFeedImage img = new NewsFeedImage();
            img.setImagePath(path);
            img.setNewsFeed(this);
            this.images.add(img);
        }
    }
}
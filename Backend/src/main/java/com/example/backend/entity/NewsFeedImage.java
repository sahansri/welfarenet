package com.example.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
@Table(name = "newsfeed_images")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class NewsFeedImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer imgId;

    @Column(name = "image_path", columnDefinition = "TEXT")
    private String imagePath;

    @ManyToOne
    @JoinColumn(name = "post_id")
    @JsonIgnore
    private NewsFeed newsFeed;

    // getters/setters
    public Integer getImgId() { return imgId; }
    public void setImgId(Integer imgId) { this.imgId = imgId; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public NewsFeed getNewsFeed() { return newsFeed; }
    public void setNewsFeed(NewsFeed newsFeed) { this.newsFeed = newsFeed; }
}

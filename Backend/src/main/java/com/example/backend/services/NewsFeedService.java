package com.example.backend.services;

import com.example.backend.entity.*;
import com.example.backend.repository.CommentRepository;
import com.example.backend.repository.LikeRepository;
import com.example.backend.repository.NewsFeedRepository;
import com.example.backend.repository.PostReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.support.SimpleJpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NewsFeedService {

    private final MemberService memberService;
    private final S3PresignerService presignerService;
    private final PostReportRepository postReportRepository;
    private final NewsFeedRepository newsFeedRepository;
    private final LikeRepository likeRepository;
    private final CommentRepository commentRepository;


    public NewsFeed createPost(Integer authorId, String content, List<String> imagePaths) {
        // Load full member (fixes fullName null issue)
        Member author = memberService.getMemberById(authorId);

        // Validate
        if ((content == null || content.isBlank()) &&
                (imagePaths == null || imagePaths.isEmpty())) {
            throw new RuntimeException("Post must have text or at least one image");
        }

        NewsFeed post = new NewsFeed();
        post.setAuthor(author);
        post.setContent(content);
        post.setImagePaths(imagePaths);
        return newsFeedRepository.save(post);
    }

    public NewsFeed editPost(Integer postId, String content, List<MultipartFile> images) throws IOException {
        NewsFeed post = getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        // Update content if provided
        if (content != null && !content.isBlank()) {
            post.setContent(content);
        }

        // Update images if provided
        if (images != null && !images.isEmpty()) {
            List<String> imagePaths = new ArrayList<>();
            for (MultipartFile img : images) {
                String path = "/uploads/" + img.getOriginalFilename();
                Path uploadPath = Paths.get("uploads/" + img.getOriginalFilename());
                Files.copy(img.getInputStream(), uploadPath, StandardCopyOption.REPLACE_EXISTING);
                imagePaths.add(path);
            }
            post.setImagePaths(imagePaths);
        }

        // Save updated post
        return newsFeedRepository.save(post);
    }

    public List<NewsFeed> getAllPosts() {
        return newsFeedRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<NewsFeed> getAllPostsWithCommentsAndAuthors() {
        // First fetch posts with images and authors
        List<NewsFeed> posts = newsFeedRepository.findAllWithImagesAndAuthors();

        // Then fetch comments separately to avoid MultipleBagFetchException
        if (!posts.isEmpty()) {
            newsFeedRepository.fetchComments(posts);
        }

        // Generate presigned URLs for images
        for (NewsFeed post : posts) {
            if (post.getImages() != null && !post.getImages().isEmpty()) {
                for (NewsFeedImage image : post.getImages()) {
                    try {
                        String key = extractKeyFromUrl(image.getImagePath());
                        String presignedUrl = presignerService.presignGetUrl(key, Duration.ofHours(1));
                        image.setImagePath(presignedUrl);
                    } catch (Exception e) {
                        System.err.println("Failed to generate presigned URL for: " + image.getImagePath());
                        e.printStackTrace();
                    }
                }
            }
        }

        return posts;
    }

    private String extractKeyFromUrl(String url) {
        // Extract key from: https://welfarenet.s3.ap-southeast-1.amazonaws.com/uploads/...
        // or https://welfarenet.s3.ap-southeast-1.amazonaws.com/newsfeed/...
        if (url.contains(".amazonaws.com/")) {
            return url.substring(url.indexOf(".amazonaws.com/") + 15);
        }
        // If it's already just a key
        return url;
    }

    public Optional<NewsFeed> getPostById(Integer id) {
        return newsFeedRepository.findById(id);
    }

    public List<NewsFeed> getPostsByAuthor(Integer authorId) {
        List<NewsFeed> post = newsFeedRepository.findNewsFeedsByAuthor_MemberID(authorId);

        // Then fetch comments separately to avoid MultipleBagFetchException
        if (!post.isEmpty()) {
            newsFeedRepository.fetchComments(post);
        }

        // Generate presigned URLs for images
        for (NewsFeed posts : post) {
            if (posts.getImages() != null && !posts.getImages().isEmpty()) {
                for (NewsFeedImage image : posts.getImages()) {
                    try {
                        String key = extractKeyFromUrl(image.getImagePath());
                        String presignedUrl = presignerService.presignGetUrl(key, Duration.ofHours(1));
                        image.setImagePath(presignedUrl);
                    } catch (Exception e) {
                        System.err.println("Failed to generate presigned URL for: " + image.getImagePath());
                        e.printStackTrace();
                    }
                }
            }
        }

        return post;
    }

    public void deletePost(Integer id) {
        newsFeedRepository.deleteById(id);
    }

    public List<NewsFeed> getPostsSortedByDateAsc() {
        return newsFeedRepository.findAllByOrderByDatePostedAsc();
    }

    public Like likePost(Member member, NewsFeed post) {
        // Check if member already liked
        boolean alreadyLiked = post.getLikes().stream()
                .anyMatch(l -> l.getMember().getMemberID().equals(member.getMemberID()));
        if (alreadyLiked) {
            throw new RuntimeException("Member already liked this post");
        }

        Like like = new Like();
        like.setMember(member);
        like.setPost(post);
        like.setLikedDate(LocalDate.now());
        like.setLikedTime(LocalTime.now());

        likeRepository.save(like);

        // Increment post like count
        post.setLikeCount(post.getLikeCount() + 1);
        newsFeedRepository.save(post);

        return like;
    }
    @Transactional
    public void unlikePost(Member member, NewsFeed post) {
        Like existingLike = post.getLikes().stream()
                .filter(l -> java.util.Objects.equals(l.getMember().getMemberID(), member.getMemberID()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Member has not liked this post"));

        // Keep in-memory state consistent
        post.getLikes().remove(existingLike);

        // Remove the Like row
        likeRepository.delete(existingLike);

        // Decrement post like count and persist post
        post.setLikeCount(Math.max(0, post.getLikeCount() - 1));
        newsFeedRepository.save(post);
    }

    public Comment commentPost(Member member, NewsFeed post, String commentText) {
        Comment comment = new Comment();
        comment.setMember(member);
        comment.setPost(post);
        comment.setCommentText(commentText);
        comment.setCommentDate(LocalDate.now());
        comment.setCommentTime(LocalTime.now());

        commentRepository.save(comment);

        // Increment post comment count
        post.setCommentCount(post.getCommentCount() + 1);
        newsFeedRepository.save(post);

        return comment;
    }
    @Transactional
    public void deleteComment(NewsFeed post, Integer commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));
        // Ensure the comment belongs to the specified post
        if (!comment.getPost().getPostID().equals(post.getPostID())) {
            throw new RuntimeException("Comment does not belong to the specified post");
        }
        commentRepository.delete(comment);
        // Decrement post comment count
        post.setCommentCount(Math.max(0, post.getCommentCount() - 1));
        newsFeedRepository.save(post);
    }

    public Comment editComment(NewsFeed post, Integer commentId, String newText) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));
        // Ensure the comment belongs to the specified post
        if (!comment.getPost().getPostID().equals(post.getPostID())) {
            throw new RuntimeException("Comment does not belong to the specified post");
        }
        comment.setCommentText(newText);
        return commentRepository.save(comment);
    }

    public void reportPost(Integer memberId, NewsFeed post, String reason) {
        // Fetch the reporting member
        Member reporter = memberService.getMemberById(memberId);
        // Optional: prevent duplicate reports
        boolean alreadyReported = postReportRepository.existsByReporterAndPost(reporter, post);
        if (alreadyReported) {
            throw new RuntimeException("You have already reported this post");
        }
        // Create and save the report
        PostReport report = PostReport.builder()
                .reporter(reporter)
                .post(post)
                .reason(reason)
                .build();
        postReportRepository.save(report);
    }

}

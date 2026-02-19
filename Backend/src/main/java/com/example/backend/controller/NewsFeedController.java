package com.example.backend.controller;

import com.example.backend.entity.Comment;
import com.example.backend.entity.Like;
import com.example.backend.entity.NewsFeed;
import com.example.backend.entity.Member;
import com.example.backend.services.NewsFeedService;
import com.example.backend.services.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/newsfeed")
@RequiredArgsConstructor
public class NewsFeedController {

    private final NewsFeedService newsFeedService;
    private final S3Service s3Service;

    // Create a post with optional image
    @PostMapping("/create")
    public ResponseEntity<NewsFeed> createPost(
            @RequestParam String authorId,
            @RequestParam(required = false) String content,
            @RequestParam(required = false) List<MultipartFile> images
    ) throws IOException {
        Integer authorIdInt;
        try {
            authorIdInt = Integer.valueOf(authorId);
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().build();
        }
        List<String> imagePaths = new ArrayList<>();
        if (images != null && !images.isEmpty()) {
            for (MultipartFile img : images) {
                String url = s3Service.uploadFile(img);
                if (url != null) imagePaths.add(url);
            }
        }
        NewsFeed post = newsFeedService.createPost(authorIdInt, content, imagePaths);
        return ResponseEntity.ok(post);
    }

    @PutMapping("/{postId}/edit")
    public ResponseEntity<NewsFeed> editPost(
            @PathVariable Integer postId,
            @RequestParam(required = false) String content,
            @RequestParam(required = false) List<MultipartFile> images
    ) throws IOException {
        NewsFeed updatedPost = newsFeedService.editPost(postId, content, images);
        return ResponseEntity.ok(updatedPost);
    }

    @GetMapping("/getAll")
    public ResponseEntity<List<NewsFeed>> getAllPosts() {
        return ResponseEntity.ok(newsFeedService.getAllPosts());
    }

    @GetMapping("/{id}")
    public ResponseEntity<NewsFeed> getPost(@PathVariable Integer id) {
        return newsFeedService.getPostById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/getposts/{userId}")
    public ResponseEntity<List<NewsFeed>> getPostsByUser(@PathVariable Integer userId) {
        List<NewsFeed> posts = newsFeedService.getPostsByAuthor(userId);
        return ResponseEntity.ok(posts);
    }

    @GetMapping("/sorted-bydate")
    public ResponseEntity<List<NewsFeed>> getPostsSortedOldest() {
        List<NewsFeed> sortedPosts = newsFeedService.getAllPostsWithCommentsAndAuthors();
        return ResponseEntity.ok(sortedPosts);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePost(@PathVariable Integer id) {
        newsFeedService.deletePost(id);
        return ResponseEntity.ok("Post deleted successfully");
    }

    @PostMapping("/{postId}/like")
    public ResponseEntity<?> likePost(
            @PathVariable Integer postId,
            @RequestParam Integer memberId
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        Member member = new Member();
        member.setMemberID(memberId);
        Like like = newsFeedService.likePost(member, post);
        return ResponseEntity.ok(like);
    }

    @DeleteMapping("/{postId}/unlike")
    public ResponseEntity<?> unlikePost(
            @PathVariable Integer postId,
            @RequestParam Integer memberId
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        Member member = new Member();
        member.setMemberID(memberId);
        newsFeedService.unlikePost(member, post);
        return ResponseEntity.ok("Post unliked successfully");
    }

    @PostMapping("/{postId}/addcomment")
    public ResponseEntity<?> commentPost(
            @PathVariable Integer postId,
            @RequestParam Integer memberId,
            @RequestParam String commentText
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Member member = new Member();
        member.setMemberID(memberId);

        Comment comment = newsFeedService.commentPost(member, post, commentText);

        return ResponseEntity.ok(comment);
    }

    @PutMapping("{postId}/editcomment")
    public ResponseEntity<?> editComment(
            @PathVariable Integer postId,
            @RequestParam Integer commentId,
            @RequestParam String newText
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        Comment updatedComment = newsFeedService.editComment(post, commentId, newText);
        return ResponseEntity.ok(updatedComment);
    }

    @DeleteMapping("{postId}/deletecomment")
    public ResponseEntity<?> deleteComment(
            @PathVariable Integer postId,
            @RequestParam Integer commentId
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        newsFeedService.deleteComment(post, commentId);
        return ResponseEntity.ok("Comment deleted successfully");
    }

    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) throws IOException {
        String url = s3Service.uploadFile(file);
        return ResponseEntity.ok(url);
    }

    @PostMapping("/{postId}/report")
    public ResponseEntity<String> reportPost(
            @PathVariable Integer postId,
            @RequestParam Integer memberId,  // member who reports
            @RequestParam(required = false) String reason
    ) {
        NewsFeed post = newsFeedService.getPostById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        newsFeedService.reportPost(memberId, post, reason);
        return ResponseEntity.ok("Post reported successfully");
    }
}

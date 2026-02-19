package com.example.backend.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.UUID;

@Service
public class S3Service {

    private final S3Client s3;
    private final String bucket;
    private final String region;

    public S3Service(S3Client s3,
                     @Value("${aws.s3.bucket}") String bucket,
                     @Value("${aws.region}") String region) {
        this.s3 = s3;
        this.bucket = bucket;
        this.region = region;
    }

    public String uploadFile(MultipartFile file) {
        try {
            String key = "uploads/" + UUID.randomUUID() + "-" + file.getOriginalFilename();
            PutObjectRequest req = PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .contentType(file.getContentType())
                    .build();

            s3.putObject(req, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

            return String.format("https://%s.s3.%s.amazonaws.com/%s", bucket, region, key);
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file to S3", e);
        }
    }

    public String uploadBytes(byte[] data, String key, String contentType) {

        PutObjectRequest req = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build();

        s3.putObject(req, RequestBody.fromBytes(data));

        return String.format(
                "https://%s.s3.%s.amazonaws.com/%s",
                bucket,
                region,
                key
        );
    }

    public void deleteFile(String fileUrl) {
        try {
            // Extract the key from the URL
            // URL format: https://bucket-name.s3.region.amazonaws.com/key
            String key = extractKeyFromUrl(fileUrl);

            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .build();

            s3.deleteObject(deleteRequest);
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete file from S3: " + fileUrl, e);
        }
    }

    private String extractKeyFromUrl(String fileUrl) {
        // Expected format: https://bucket-name.s3.region.amazonaws.com/key
        String prefix = String.format("https://%s.s3.%s.amazonaws.com/", bucket, region);

        if (fileUrl.startsWith(prefix)) {
            return fileUrl.substring(prefix.length());
        }

        // Alternative format: https://s3.region.amazonaws.com/bucket-name/key
        String altPrefix = String.format("https://s3.%s.amazonaws.com/%s/", region, bucket);
        if (fileUrl.startsWith(altPrefix)) {
            return fileUrl.substring(altPrefix.length());
        }

        throw new IllegalArgumentException("Invalid S3 URL format: " + fileUrl);
    }
}

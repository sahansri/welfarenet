package com.example.backend.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.time.Duration;

@Service
public class S3PresignerService {

    private final S3Presigner presigner;
    private final String bucket;

    public S3PresignerService(S3Presigner presigner,
                              @Value("${aws.s3.bucket}") String bucket) {
        this.presigner = presigner;
        this.bucket = bucket;
    }

    public String presignGetUrl(String key, Duration ttl) {
        GetObjectRequest getReq = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build();

        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                .getObjectRequest(getReq)
                .signatureDuration(ttl)
                .build();

        return presigner.presignGetObject(presignRequest).url().toString();
    }
}

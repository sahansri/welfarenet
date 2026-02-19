package com.example.backend.repository;

import com.example.backend.entity.Member;
import com.example.backend.entity.NewsFeed;
import com.example.backend.entity.PostReport;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostReportRepository extends JpaRepository<PostReport, Integer> {
    boolean existsByReporterAndPost(Member reporter, NewsFeed post);
}

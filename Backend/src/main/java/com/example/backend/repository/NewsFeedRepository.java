package com.example.backend.repository;
import com.example.backend.entity.NewsFeed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NewsFeedRepository extends JpaRepository<NewsFeed, Integer> {
    List<NewsFeed> findAllByOrderByDatePostedAsc();

    @Query("select distinct nf from NewsFeed nf " +
            "left join fetch nf.author a " +
            "left join fetch nf.images i " +
            "order by nf.datePosted desc, nf.timePosted desc")
    List<NewsFeed> findAllWithImagesAndAuthors();

    @Query("select distinct nf from NewsFeed nf " +
            "left join fetch nf.comments c " +
            "left join fetch c.member m " +
            "where nf in :posts")
    List<NewsFeed> fetchComments(@Param("posts") List<NewsFeed> posts);

    List<NewsFeed> findNewsFeedsByAuthor_MemberID(@Param("authorId") Integer authorId);
}

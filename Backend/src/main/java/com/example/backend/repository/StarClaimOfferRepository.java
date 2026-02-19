package com.example.backend.repository;

import com.example.backend.entity.StarClaimOffer;
import com.example.backend.entity.StarClaimRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface StarClaimOfferRepository extends JpaRepository<StarClaimOffer, Integer> {
}

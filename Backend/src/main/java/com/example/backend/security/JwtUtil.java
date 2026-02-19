package com.example.backend.security;

import io.jsonwebtoken.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtUtil {
    private final String SECRET_KEY = "63vdye5qjnxjqo0uxbamars42gsbjeld743bdgtw63bd"; // use env variable in production
    private final long EXPIRATION_TIME = 1000 * 60 * 60 * 24 * 14; // 14 days

    public String generateToken(String username, String role,int userId) {
        return Jwts.builder()
                .setSubject(username)
                .claim("userId", userId)
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    public String extractUsername(String token) {
        return Jwts.parser()
                .setSigningKey(SECRET_KEY)
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    public String extractRole(String token) {
        return Jwts.parser()
                .setSigningKey(SECRET_KEY)
                .parseClaimsJws(token)
                .getBody()
                .get("role", String.class);
    }

    public boolean validateToken(String token, String username) {
        String extractedUsername = extractUsername(token);
        return extractedUsername.equals(username) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        Date expiration = Jwts.parser().setSigningKey(SECRET_KEY)
                .parseClaimsJws(token).getBody().getExpiration();
        return expiration.before(new Date());
    }

    public String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }

    /**
     * Returns the JWT subject (in your app it's the email) from the Authorization header.
     * Returns null if missing/invalid.
     */
    public String extractSubjectFromRequest(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) return null;

        try {
            return extractUsername(token); // subject == username/email
        } catch (JwtException | IllegalArgumentException ex) {
            return null;
        }
    }

    public String extractUsernameFromRequest(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) return null;
        return extractUsername(token);
    }

    public Long extractUserId(String token) {
        if (token == null) return null;
        Claims claims = Jwts.parser()
                .setSigningKey(SECRET_KEY)
                .parseClaimsJws(token)
                .getBody();

        Object idObj = claims.get("userId");
        if (idObj != null) {
            if (idObj instanceof Number) {
                return ((Number) idObj).longValue();
            }
            try {
                return Long.parseLong(idObj.toString());
            } catch (NumberFormatException ignored) {
            }
        }

        String subject = claims.getSubject();
        try {
            return Long.parseLong(subject);
        } catch (NumberFormatException ignored) {
        }

        return null;
    }

    public Long extractUserIdFromRequest(HttpServletRequest request) {
        String token = extractToken(request);
        return extractUserId(token);
    }

}

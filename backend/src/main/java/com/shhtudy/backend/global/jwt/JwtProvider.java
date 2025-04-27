package com.shhtudy.backend.global.jwt;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtProvider {

    private final String secretKey = "shhtudy-secret-key"; // 비밀 키 (환경변수로 관리 추천)
    private final long tokenValidTime = 1000L * 60 * 60; // 1시간

    public String createToken(String uid) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + tokenValidTime);

        return Jwts.builder()
                .setSubject(uid) // 토큰 내용에 사용자 UID 넣기
                .setIssuedAt(now) // 발급 시간
                .setExpiration(expiry) // 만료 시간
                .signWith(SignatureAlgorithm.HS256, secretKey) // 암호화
                .compact();
    }
}

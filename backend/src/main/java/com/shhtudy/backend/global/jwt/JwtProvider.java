package com.shhtudy.backend.global.jwt;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtProvider {

    // 안전한 키 크기(256비트 이상)를 가진 키 생성
    private final SecretKey secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS256);
    private final long tokenValidTime = 1000L * 60 * 60; // 1시간

    public String createToken(String uid) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + tokenValidTime);

        return Jwts.builder()
                .setSubject(uid) // 토큰 내용에 사용자 UID 넣기
                .setIssuedAt(now) // 발급 시간
                .setExpiration(expiry) // 만료 시간
                .signWith(secretKey) // 서명
                .compact();
    }
}

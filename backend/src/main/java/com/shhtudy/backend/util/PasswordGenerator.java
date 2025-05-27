package com.shhtudy.backend.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "444444";
        String encodedPassword = encoder.encode(rawPassword);
        System.out.println("암호화된 비밀번호: " + encodedPassword);
    }
}

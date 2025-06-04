package com.midproject.tripin;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordEncoderUtil {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "1234"; 
        String hashedPassword = encoder.encode(rawPassword);
        System.out.println("Hashed Password for '" + rawPassword + "': " + hashedPassword);
    }
}
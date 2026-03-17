package com.lab.items;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

public class PasswordTest {
    public static void main(String[] args) {
        PasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "123456";
        String encodedPassword = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu";
        
        boolean matches = encoder.matches(rawPassword, encodedPassword);
        System.out.println("Password matches: " + matches);
        
        // 生成一个新的加密密码
        String newEncoded = encoder.encode(rawPassword);
        System.out.println("New encoded password: " + newEncoded);
        System.out.println("New password matches: " + encoder.matches(rawPassword, newEncoded));
    }
}

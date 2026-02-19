package com.example.backend.Utility;

import java.security.SecureRandom;

    public class PasswordGenerator {

        private static final String CHARS =
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&*";

        private static final SecureRandom random = new SecureRandom();

        public static String generate() {
            StringBuilder sb = new StringBuilder(8);   //  8 characters

            for (int i = 0; i < 8; i++) {
                sb.append(CHARS.charAt(random.nextInt(CHARS.length())));
            }
            return sb.toString();
        }
    }

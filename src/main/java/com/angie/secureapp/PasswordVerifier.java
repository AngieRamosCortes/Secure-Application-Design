package com.angie.secureapp;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordVerifier {

    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        String storedPasswordAdmin = "$2a$10$N9qo8uLOickgx2ZMRZoMye7I/7ydK3qzxA5K5Z3CZ2p5rVXJ8qLZy";
        String storedPasswordAngie = "$2a$10$EblZqNptyYdVKY7MjLvI3.jFkFTLCTyN5k3EwXgxgQxNTqRIvXvTO";

        String inputPasswordAdmin = "password123";
        String inputPasswordAngie = "angie123";

        System.out.println("=== Testing Password Verification ===");
        System.out.println();

        boolean matchesAdmin = encoder.matches(inputPasswordAdmin, storedPasswordAdmin);
        System.out.println("Testing admin credentials:");
        System.out.println("  Username: admin");
        System.out.println("  Password: " + inputPasswordAdmin);
        System.out.println("  Stored hash: " + storedPasswordAdmin);
        System.out.println("  ✓ Password matches: " + matchesAdmin);
        System.out.println();

        boolean matchesAngie = encoder.matches(inputPasswordAngie, storedPasswordAngie);
        System.out.println("Testing angie credentials:");
        System.out.println("  Username: angie");
        System.out.println("  Password: " + inputPasswordAngie);
        System.out.println("  Stored hash: " + storedPasswordAngie);
        System.out.println("  ✓ Password matches: " + matchesAngie);
        System.out.println();

        System.out.println("=== Generating Fresh Hashes ===");
        String newHashAdmin = encoder.encode(inputPasswordAdmin);
        String newHashAngie = encoder.encode(inputPasswordAngie);

        System.out.println("New hash for 'password123': " + newHashAdmin);
        System.out.println("New hash for 'angie123': " + newHashAngie);
        System.out.println();

        System.out.println("Verifying new hashes:");
        System.out.println("  New admin hash matches: " + encoder.matches(inputPasswordAdmin, newHashAdmin));
        System.out.println("  New angie hash matches: " + encoder.matches(inputPasswordAngie, newHashAngie));
    }
}
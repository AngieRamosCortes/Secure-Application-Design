package com.angie.secureapp.controller;

import com.angie.secureapp.model.LoginResponse;
import com.angie.secureapp.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ApiController {

    private static final Logger logger = LoggerFactory.getLogger(ApiController.class);

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Map<String, String> users = new HashMap<>();

    public ApiController(@Autowired PasswordEncoder passwordEncoder) {
        String adminHash = passwordEncoder.encode("password123");
        String angieHash = passwordEncoder.encode("angie123");

        users.put("admin", adminHash);
        users.put("angie", angieHash);

        logger.info("ApiController initialized with {} users", users.size());
        logger.info("Admin hash: {}", adminHash);
        logger.info("Angie hash: {}", angieHash);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        try {
            String inputUsername = user.getUsername() == null ? "" : user.getUsername().trim();
            String inputPassword = user.getPassword() == null ? "" : user.getPassword();

            logger.info("========================================");
            logger.info("Login attempt for user: {}", inputUsername);
            logger.info("Password provided: {}", !inputPassword.isEmpty());
            logger.info("Password length: {}", inputPassword.length());

            if (inputUsername.isEmpty() || inputPassword.isEmpty()) {
                logger.warn("Empty username or password");
                return ResponseEntity.ok(
                        new LoginResponse(false, "Usuario y contraseña son requeridos", null));
            }

            if (!users.containsKey(inputUsername)) {
                logger.warn("User not found: {}", inputUsername);
                return ResponseEntity.ok(
                        new LoginResponse(false, "Usuario no encontrado", inputUsername));
            }

            String storedHash = users.get(inputUsername);
            logger.info("Stored hash for user '{}': {}", inputUsername, storedHash);
            logger.info("Input password for verification: [HIDDEN]");

            boolean passwordMatches = passwordEncoder.matches(inputPassword, storedHash);
            logger.info("BCrypt password match result for '{}': {}", inputUsername, passwordMatches);

            if (passwordMatches) {
                logger.info("✅ SUCCESSFUL LOGIN for user: {}", inputUsername);
                logger.info("========================================");
                return ResponseEntity.ok(
                        new LoginResponse(true, "Autenticación exitosa - Bienvenido " + inputUsername, inputUsername));
            } else {
                logger.warn("❌ INVALID PASSWORD for user: {}", inputUsername);
                logger.info("========================================");
                return ResponseEntity.ok(
                        new LoginResponse(false, "Contraseña incorrecta", inputUsername));
            }
        } catch (Exception e) {
            logger.error("❌ ERROR during login", e);
            logger.error("Exception type: {}", e.getClass().getName());
            logger.error("Exception message: {}", e.getMessage());
            logger.info("========================================");
            return ResponseEntity.ok(
                    new LoginResponse(false, "Error en el servidor: " + e.getMessage(), null));
        }
    }

    @GetMapping("/hello")
    public ResponseEntity<?> hello() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "¡Hola desde el servicio REST seguro!");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        logger.info("Hello endpoint called");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    public ResponseEntity<?> status() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("service", "Spring Boot Secure API");
        response.put("users", users.size());
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        logger.info("Status endpoint called");
        return ResponseEntity.ok(response);
    }
}
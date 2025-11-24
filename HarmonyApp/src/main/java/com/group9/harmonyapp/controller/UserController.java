package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.LoginDTO;
import com.group9.harmonyapp.dto.RegisterDTO;
import com.group9.harmonyapp.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "http://localhost:3000", allowCredentials = "true")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class UserController {


    private final AuthService authService;


    @PostMapping("/register")
    public Object register(@RequestBody RegisterDTO dto) {
        return authService.register(dto);
    }


    @PostMapping("/login")
    public Object login(@RequestBody LoginDTO dto) {
        return authService.login(dto);
    }


    @GetMapping("/profile")
    public Object profile(@RequestParam Long userId) {
        return authService.getProfile(userId);
    }
}
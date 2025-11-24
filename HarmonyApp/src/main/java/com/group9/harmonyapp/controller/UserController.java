package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.*;
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
    public Response<TokenDTO> register(@RequestBody RegisterDTO dto) {
        return authService.register(dto);
    }


    @PostMapping("/login")
    public Response<TokenDTO> login(@RequestBody LoginDTO dto) {
        return authService.login(dto);
    }


    @GetMapping("/profile")
    public Response<UserProfileVO> profile(@RequestParam Long userId) {
        return authService.getProfile(userId);
    }
}
package com.group9.harmonyapp.controller;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.group9.harmonyapp.dto.AdminRegisterDTO;
import com.group9.harmonyapp.dto.LoginDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.TokenDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Admin;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.AdminRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
public class AdminAuthController {

    private final AdminRepository adminRepository;
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    private static final long EXPIRE_TIME = 24 * 60 * 60 * 1000L * 7; // 7 days

    @PostMapping("/register")
    public Response<TokenDTO> register(@RequestBody AdminRegisterDTO dto) {
        if (dto.getPassword() == null || dto.getPassword().length() < 6) {
            throw new HarmonyException("密码必须至少6位",1002);
        }
        if (dto.getEmail() == null || dto.getEmail().length() < 6 || !dto.getEmail().contains("@")) {
            throw new HarmonyException("参数校验失败,邮箱格式不正确",1000);
        }

        // ensure username/email not used by admins or users
        if (adminRepository.findByUsername(dto.getUsername()).isPresent() || userRepository.findByUsername(dto.getUsername()).isPresent()) {
            throw new HarmonyException("用户名已被注册",1001);
        }
        if (adminRepository.findByEmail(dto.getEmail()).isPresent() || userRepository.findByEmail(dto.getEmail()).isPresent()) {
            throw new HarmonyException("邮箱已被注册",1001);
        }

        Admin admin = new Admin();
        admin.setUsername(dto.getUsername());
        admin.setPassword(encoder.encode(dto.getPassword()));
        admin.setEmail(dto.getEmail());

        admin = adminRepository.save(admin);

        Date date = new Date(System.currentTimeMillis() + EXPIRE_TIME);
        String token = JWT.create()
                .withAudience(String.valueOf(admin.getId()))
                .withExpiresAt(date)
                .sign(Algorithm.HMAC256(admin.getPassword()));

        return Response.buildSuccess(new TokenDTO(admin.getId(), token, 7200), "注册成功");
    }

    @PostMapping("/login")
    public Response<TokenDTO> login(@RequestBody LoginDTO dto) {
        if (dto.getUsername() == null || dto.getPassword() == null) {
            throw new HarmonyException("参数错误",1000);
        }
        Admin admin = adminRepository.findByUsername(dto.getUsername()).orElse(null);
        if (admin == null) throw new HarmonyException("账号不存在",1101);

        if (!encoder.matches(dto.getPassword(), admin.getPassword())) {
            throw new HarmonyException("密码错误",1102);
        }

        String token = AdminTokenUtil.createToken(admin);
        return Response.buildSuccess(new TokenDTO(admin.getId(), token, 7200), "登录成功");
    }
}

package com.group9.harmonyapp.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.group9.harmonyapp.po.Admin;
import com.group9.harmonyapp.repository.AdminRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class AdminTokenUtil {

    private static final long EXPIRE_TIME = 24 * 60 * 60 * 1000L * 7;

    @Autowired
    private AdminRepository adminRepository;

    public static String createToken(Admin admin) {
        Date date = new Date(System.currentTimeMillis() + EXPIRE_TIME);
        return JWT.create()
                .withAudience(String.valueOf(admin.getId()))
                .withExpiresAt(date)
                .sign(Algorithm.HMAC256(admin.getPassword()));
    }

    public boolean verifyToken(String token) {
        try {
            Long adminId = Long.valueOf(JWT.decode(token).getAudience().getFirst());
            Admin admin = adminRepository.findById(adminId).orElse(null);
            if (admin == null) return false;
            JWTVerifier verifier = JWT.require(Algorithm.HMAC256(admin.getPassword())).build();
            verifier.verify(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Admin getAdmin(String token) {
        Long adminId = Long.valueOf(JWT.decode(token).getAudience().getFirst());
        return adminRepository.findById(adminId).orElse(null);
    }
}

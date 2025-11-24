package com.group9.harmonyapp.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Date;



/**
 * @Author: DingXiaoyu
 * @Date: 0:28 2023/11/26
 * 这是一个token的工具类，
 * 设置了过期时间为1天。
 * getToken方法用来获取token，
 * token中包含了用户的Id、密码信息以及到期时间。
 * verifyToken方法用来检验token是否正确。
 * getUser方法用来从token中获得用户信息。
*/
@Component
public class TokenUtil {
    private static final long EXPIRE_TIME = 24 * 60 * 60 * 1000* 7;

    @Autowired
    UserRepository userRepository;

    public String getToken(User user) {
        Date date = new Date(System.currentTimeMillis() + EXPIRE_TIME);
        return JWT.create()
                .withAudience(String.valueOf(user.getId()))
                .withExpiresAt(date)
                .sign(Algorithm.HMAC256(user.getPassword()));
    }

    public boolean verifyToken(String token) {
        try {
            Long userId=Long.valueOf(JWT.decode(token).getAudience().getFirst());
            User user= userRepository.findById(userId).get();
            JWTVerifier jwtVerifier = JWT.require(Algorithm.HMAC256(user.getPassword())).build();
            jwtVerifier.verify(token);
            return true;
        }catch (Exception e){
            return false;
        }
    }

    public User getUser(String token){
        Long userId=Long.valueOf(JWT.decode(token).getAudience().getFirst());
        return userRepository.findById(userId).get();
    }
}

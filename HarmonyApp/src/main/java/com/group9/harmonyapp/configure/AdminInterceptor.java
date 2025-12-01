package com.group9.harmonyapp.configure;

import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.util.AdminTokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AdminInterceptor implements HandlerInterceptor {

    @Autowired
    private AdminTokenUtil adminTokenUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = request.getHeader("token");
        if (token != null && adminTokenUtil.verifyToken(token)) {
            request.getSession().setAttribute("currentAdmin", adminTokenUtil.getAdmin(token));
            return true;
        } else {
            throw HarmonyException.notLogin();
        }
    }
}

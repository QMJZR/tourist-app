package com.group9.harmonyapp.configure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * @Author: DingXiaoyu
 * @Date: 0:17 2023/11/26
 *
 * 这个类实现了WebMvcConfigurer接口，
 * 表示会被SpringBoot接受，
 * 这个类的作用是配置拦截器。
 * addInterceptors方法配置了拦截器，
 * 添加了loginInterceptor作为拦截器，
 * 并且设置除了register和login的所有接口都需要通过该拦截器。
 */
@Configuration
public class MyWebMvcConfig implements WebMvcConfigurer {
    @Autowired
    LoginInterceptor loginInterceptor;

    @Autowired
    AdminInterceptor adminInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {

        // 普通用户拦截器，排除管理端路径
        registry.addInterceptor(loginInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/favicon.ico")
                .excludePathPatterns("/api/v1/auth/*")
                .excludePathPatterns("/api/v1/zones")
                .excludePathPatterns("/api/v1/spots")
                .excludePathPatterns("/api/v1/spots/*")
                .excludePathPatterns("/admin/**")
                .excludePathPatterns("/error")
                .order(2);

        // 管理端拦截器，仅作用于 /admin/**，排除 /admin/auth/**
        registry.addInterceptor(adminInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/auth/**")
                .order(1);
    }

}

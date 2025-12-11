package com.group9.harmonyapp.configure;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.context.annotation.Configuration;
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

}
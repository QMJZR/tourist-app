package com.group9.harmonyapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class HarmonyAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(HarmonyAppApplication.class, args);
    }

}

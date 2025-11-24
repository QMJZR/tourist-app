package com.group9.harmonyapp.dto;
import lombok.Data;

@Data
public class TokenDTO {
    private Long userId;
    private String token;
    private Integer expiresIn;
    public TokenDTO(Long userId, String token, Integer expiresIn) {
        this.userId = userId;
        this.token = token;
        this.expiresIn = expiresIn;
    }
}

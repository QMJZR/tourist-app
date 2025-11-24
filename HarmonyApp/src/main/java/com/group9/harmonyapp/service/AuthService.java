package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;

public interface AuthService {
    Response<TokenDTO> register(RegisterDTO dto);
    Response<TokenDTO> login(LoginDTO dto);
    Response<UserProfileVO> getProfile(Long userId);
}

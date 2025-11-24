package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;

public interface AuthService {
    public Response<TokenDTO> register(RegisterDTO dto);
    public Response<TokenDTO> login(LoginDTO dto);
    public Response<UserProfileVO> getProfile(Long userId);
}

package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.po.User;

public interface AuthService {
    TokenDTO register(RegisterDTO dto);
    TokenDTO login(LoginDTO dto);
    UserProfileVO getProfile(Long userId);
    User getUserById(Long id);
    com.group9.harmonyapp.dto.UserProfileVO updateProfile(Long userId, com.group9.harmonyapp.dto.UpdateProfileDTO dto);
}

package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.po.User;

public interface AuthService {
    TokenDTO register(RegisterDTO dto);
    TokenDTO login(LoginDTO dto);
    UserProfileVO getProfile(Long userId);
    User getUserById(Long id);
}

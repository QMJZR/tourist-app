package com.group9.harmonyapp.service.serviceImpl;
import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.CheckinRecord;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.service.AuthService;
import com.group9.harmonyapp.service.CheckinService;
import com.group9.harmonyapp.util.TokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {


    private final UserRepository userRepository;
    private final CheckinService checkinService;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();


    public TokenDTO register(RegisterDTO dto) {
        if (dto.getPassword().length() < 6) {
            throw new HarmonyException("密码必须至少6位",1002);
        }
        if(dto.getEmail().length() < 6||!dto.getEmail().contains("@")){
            throw new HarmonyException("参数校验失败,邮箱格式不正确",1000);
        }
        if (userRepository.findByUsername(dto.getUsername()).isPresent()) {
            throw  new HarmonyException("用户名已被注册",1001);
        }


        User user = new User();
        user.setUsername(dto.getUsername());
        user.setPassword(encoder.encode(dto.getPassword()));
        user.setEmail(dto.getEmail());
        user.setNickname(dto.getUsername());


        user = userRepository.save(user);


        String token = TokenUtil.getToken(user);


        return new TokenDTO(user.getId(), token, 7200);
    }


    public TokenDTO login(LoginDTO dto) {
        User user = userRepository.findByUsername(dto.getUsername()).orElse(null);
        if (user == null) throw new HarmonyException("账号不存在",1101);


        if (!encoder.matches(dto.getPassword(), user.getPassword())) {
            throw new HarmonyException("密码错误",1102);
        }


        String token = TokenUtil.getToken(user);
        return new TokenDTO(user.getId(), token, 7200);
    }


    public UserProfileVO getProfile(Long userId) {
        User u = userRepository.findById(userId).orElse(null);
        if (u == null) throw new HarmonyException( "用户不存在",404);


        UserProfileVO vo = new UserProfileVO();
        vo.setUserId(u.getId());
        vo.setUsername(u.getUsername());
        vo.setAvatar(u.getAvatar());
        vo.setPoints(u.getPoints());
        vo.setCheckinCount(u.getCheckinCount());
        vo.setIsMerchant(u.getIsMerchant());
        vo.setNickname(u.getNickname());
        vo.setCheckinSpotIds(checkinService.getCheckinSpotsByUser(u.getId()).stream().map(CheckinRecord::getSpotId).distinct().collect(Collectors.toList()));
        vo.setEmail(u.getEmail());
        return vo;
    }
    public User getUserById(Long userId) {
        return userRepository.findById(userId).orElse(null);
    }

    @Override
    public UserProfileVO updateProfile(Long userId, com.group9.harmonyapp.dto.UpdateProfileDTO dto) {
        User u = userRepository.findById(userId).orElse(null);
        if (u == null) throw new HarmonyException("用户不存在",404);

        if (dto.getNickname() != null) {
            if (dto.getNickname().length() > 20) {
                throw new HarmonyException("昵称长度不能超过20字符",1301);
            }
            u.setNickname(dto.getNickname());
        }

        if (dto.getAvatar() != null) {
            // 简单校验：长度限制（可按需扩展）
            if (dto.getAvatar().length() > 1024) {
                throw new HarmonyException("头像地址长度超出限制",1301);
            }
            u.setAvatar(dto.getAvatar());
        }

        if (dto.getEmail() != null) {
            if (dto.getEmail().length() < 6 || !dto.getEmail().contains("@")) {
                throw new HarmonyException("参数校验失败,邮箱格式不正确",1000);
            }
            u.setEmail(dto.getEmail());
        }

        userRepository.save(u);

        return getProfile(u.getId());
    }
}
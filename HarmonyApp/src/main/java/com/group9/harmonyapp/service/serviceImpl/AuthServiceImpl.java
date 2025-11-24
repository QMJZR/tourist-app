package com.group9.harmonyapp.service.serviceImpl;
import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.service.AuthService;
import com.group9.harmonyapp.util.TokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {


    private final UserRepository userRepository;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();


    public Response<TokenDTO> register(RegisterDTO dto) {
        if (dto.getPassword().length() < 6) {
            return Response.buildFailure("密码必须至少6位",1002);
        }


        if (userRepository.findByUsername(dto.getUsername()).isPresent()) {
            return Response.buildFailure("用户名已被注册",1001);
        }


        User user = new User();
        user.setUsername(dto.getUsername());
        user.setPassword(encoder.encode(dto.getPassword()));
        user.setEmail(dto.getEmail());
        user.setNickname(dto.getUsername());


        user = userRepository.save(user);


        String token = TokenUtil.getToken(user);


        return Response.buildSuccess(new TokenDTO(user.getId(), token, 7200));
    }


    public Response<TokenDTO> login(LoginDTO dto) {
        User user = userRepository.findByUsername(dto.getUsername()).orElse(null);
        if (user == null) return Response.buildFailure("账号不存在",1101);


        if (!encoder.matches(dto.getPassword(), user.getPassword())) {
            return Response.buildFailure("密码错误",1102);
        }


        String token = TokenUtil.getToken(user);
        return Response.buildSuccess(new TokenDTO(user.getId(), token, 7200));
    }


    public Response<UserProfileVO> getProfile(Long userId) {
        User u = userRepository.findById(userId).orElse(null);
        if (u == null) return Response.buildFailure( "用户不存在",404);


        UserProfileVO vo = new UserProfileVO();
        vo.setUserId(u.getId());
        vo.setUsername(u.getUsername());
        vo.setAvatar(u.getAvatar());
        vo.setPoints(u.getPoints());
        vo.setCheckinCount(u.getCheckinCount());
        vo.setIsMerchant(u.getIsMerchant());

        return Response.buildSuccess(vo);
    }
}
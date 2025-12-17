package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.AdminUserListResponseDTO;
import com.group9.harmonyapp.dto.AdminUserResultDTO;
import com.group9.harmonyapp.dto.AdminUserUpdateDTO;
import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.CheckinRecord;
import com.group9.harmonyapp.po.User;
import com.group9.harmonyapp.repository.CheckinRecordRepository;
import com.group9.harmonyapp.repository.UserRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserRepository userRepository;
    private final CheckinRecordRepository checkinRecordRepository;
    private final AdminTokenUtil adminTokenUtil;

    private void validateToken(String authorization, String tokenHeader) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            throw new HarmonyException("未授权，请登录", 401);
        }
    }

    @GetMapping
    public Response<AdminUserListResponseDTO> listUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String isMerchant,
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer pageSize,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        List<User> users = userRepository.findAll();

        // 过滤 keyword（username 或 nickname）
        if (keyword != null && !keyword.isEmpty()) {
            String kw = keyword.toLowerCase();
            users = users.stream().filter(u -> (u.getUsername() != null && u.getUsername().toLowerCase().contains(kw))
                    || (u.getNickname() != null && u.getNickname().toLowerCase().contains(kw)))
                    .collect(Collectors.toList());
        }

        // 过滤 isMerchant
        if (isMerchant != null && !isMerchant.isEmpty()) {
            users = users.stream().filter(u -> isMerchant.equalsIgnoreCase(u.getIsMerchant())).collect(Collectors.toList());
        }

        long total = users.size();

        // 分页
        int p = Math.max(1, page);
        int ps = Math.max(1, pageSize);
        int fromIndex = (p - 1) * ps;
        int toIndex = Math.min(fromIndex + ps, users.size());
        List<User> paged = fromIndex >= users.size() ? List.of() : users.subList(fromIndex, toIndex);

        // 收集用户 id 列表以批量查询打卡点
        List<Long> userIds = paged.stream().map(User::getId).collect(Collectors.toList());

        Map<Long, List<CheckinRecord>> recordsByUser = userIds.isEmpty() ? Map.of() : checkinRecordRepository.findAll().stream()
                .filter(r -> userIds.contains(r.getUserId()))
                .collect(Collectors.groupingBy(CheckinRecord::getUserId));

        List<AdminUserResultDTO> resultUsers = paged.stream().map(u -> {
            AdminUserResultDTO dto = new AdminUserResultDTO();
            dto.setUserId(u.getId());
            dto.setUsername(u.getUsername());
            dto.setNickname(u.getNickname());
            dto.setAvatar(u.getAvatar());
            dto.setEmail(u.getEmail());
            dto.setPoints(u.getPoints());
            long checkinCount = checkinRecordRepository.countByUserId(u.getId());
            dto.setCheckinCount(checkinCount);
            List<CheckinRecord> recs = recordsByUser.getOrDefault(u.getId(), List.of());
            Set<Long> spotIds = recs.stream().map(CheckinRecord::getSpotId).collect(Collectors.toSet());
            dto.setCheckinSpotIds(spotIds.stream().collect(Collectors.toList()));
            dto.setIsMerchant(u.getIsMerchant());
            return dto;
        }).collect(Collectors.toList());

        AdminUserListResponseDTO responseDTO = new AdminUserListResponseDTO();
        responseDTO.setTotal(total);
        responseDTO.setUsers(resultUsers);

        return Response.buildSuccess(responseDTO);
    }

    @GetMapping("/{userId}")
    public Response<AdminUserResultDTO> getUser(
            @PathVariable Long userId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            throw new HarmonyException("用户不存在", 404);
        }

        AdminUserResultDTO dto = new AdminUserResultDTO();
        dto.setUserId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setNickname(user.getNickname());
        dto.setAvatar(user.getAvatar());
        dto.setEmail(user.getEmail());
        dto.setPoints(user.getPoints());
        long checkinCount = checkinRecordRepository.countByUserId(user.getId());
        dto.setCheckinCount(checkinCount);
        List<Long> spotIds = checkinRecordRepository.findByUserId(user.getId()).stream().map(CheckinRecord::getSpotId).distinct().collect(Collectors.toList());
        dto.setCheckinSpotIds(spotIds);
        dto.setIsMerchant(user.getIsMerchant());

        return Response.buildSuccess(dto);
    }

    @PutMapping("/{userId}")
    public Response<Void> updateUser(
            @PathVariable Long userId,
            @RequestBody AdminUserUpdateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        validateToken(authorization, tokenHeader);

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            throw new HarmonyException("用户不存在", 404);
        }

        if (dto.getNickname() != null) {
            user.setNickname(dto.getNickname());
        }
        if (dto.getAvatar() != null) {
            user.setAvatar(dto.getAvatar());
        }
        if (dto.getPoints() != null) {
            user.setPoints(dto.getPoints());
        }
        if (dto.getIsMerchant() != null) {
            user.setIsMerchant(dto.getIsMerchant());
        }

        userRepository.save(user);

        return Response.buildSuccess(null, "更新成功");
    }
}

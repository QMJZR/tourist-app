package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.AdminPointRuleResultDTO;
import com.group9.harmonyapp.dto.AdminPointRuleCreateDTO;
import com.group9.harmonyapp.dto.AdminPointRuleUpdateDTO;
import com.group9.harmonyapp.dto.AdminPointRuleIdResultDTO;
import com.group9.harmonyapp.dto.AdminPointLogResultDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.PointRule;
import com.group9.harmonyapp.po.PointRecord;
import com.group9.harmonyapp.repository.PointRuleRepository;
import com.group9.harmonyapp.repository.PointRecordRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/points")
@RequiredArgsConstructor
public class AdminPointController {

    private final PointRuleRepository pointRuleRepository;
    private final PointRecordRepository pointRecordRepository;
    private final AdminTokenUtil adminTokenUtil;

    // 获取管理员 token 的工具方法
    private String extractAndValidateToken(String authorization, String tokenHeader) {
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            throw new HarmonyException("未授权，请登录", 401);
        }
        return token;
    }

    @GetMapping("/rules")
    public Response<List<AdminPointRuleResultDTO>> getPointRules(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        extractAndValidateToken(authorization, tokenHeader);

        // 查询所有积分规则
        List<PointRule> rules = pointRuleRepository.findAll();

        // 转换为响应格式
        List<AdminPointRuleResultDTO> result = rules.stream().map(r -> {
            AdminPointRuleResultDTO dto = new AdminPointRuleResultDTO();
            dto.setRuleId(r.getId());
            dto.setType(r.getType());
            dto.setDescription(r.getDescription());
            dto.setPoints(r.getPoints());
            dto.setStatus(r.getStatus());
            return dto;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }

    @PostMapping("/rules")
    public Response<AdminPointRuleIdResultDTO> createPointRule(
            @RequestBody AdminPointRuleCreateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        extractAndValidateToken(authorization, tokenHeader);

        // 参数验证
        if (dto.getType() == null || dto.getType().isEmpty()) {
            throw new HarmonyException("积分类型不能为空", 1000);
        }
        if (dto.getDescription() == null || dto.getDescription().isEmpty()) {
            throw new HarmonyException("规则说明不能为空", 1000);
        }
        if (dto.getPoints() == null) {
            throw new HarmonyException("积分不能为空", 1000);
        }
        if (dto.getStatus() == null || dto.getStatus().isEmpty()) {
            throw new HarmonyException("状态不能为空", 1000);
        }

        // 创建积分规则
        PointRule rule = new PointRule();
        rule.setType(dto.getType());
        rule.setDescription(dto.getDescription());
        rule.setPoints(dto.getPoints());
        rule.setStatus(dto.getStatus());

        PointRule savedRule = pointRuleRepository.save(rule);

        AdminPointRuleIdResultDTO result = new AdminPointRuleIdResultDTO();
        result.setRuleId(savedRule.getId());

        return Response.buildSuccess(result, "新增成功");
    }

    @PutMapping("/rules/{ruleId}")
    public Response<Void> updatePointRule(
            @PathVariable Long ruleId,
            @RequestBody AdminPointRuleUpdateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        extractAndValidateToken(authorization, tokenHeader);

        // 查找规则
        PointRule rule = pointRuleRepository.findById(ruleId).orElse(null);
        if (rule == null) {
            throw new HarmonyException("规则不存在", 404);
        }

        // 更新字段（仅更新非 null 字段）
        if (dto.getDescription() != null) {
            rule.setDescription(dto.getDescription());
        }
        if (dto.getPoints() != null) {
            rule.setPoints(dto.getPoints());
        }
        if (dto.getStatus() != null) {
            rule.setStatus(dto.getStatus());
        }

        pointRuleRepository.save(rule);

        return Response.buildSuccess(null, "更新成功");
    }

    @DeleteMapping("/rules/{ruleId}")
    public Response<Void> deletePointRule(
            @PathVariable Long ruleId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        extractAndValidateToken(authorization, tokenHeader);

        // 查找规则
        PointRule rule = pointRuleRepository.findById(ruleId).orElse(null);
        if (rule == null) {
            throw new HarmonyException("规则不存在", 404);
        }

        // 删除规则
        pointRuleRepository.delete(rule);

        return Response.buildSuccess(null, "删除成功");
    }

    @GetMapping("/users/{userId}/logs")
    public Response<List<AdminPointLogResultDTO>> getUserPointLogs(
            @PathVariable Long userId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String type,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        extractAndValidateToken(authorization, tokenHeader);

        // 获取用户积分流水
        List<PointRecord> logs = pointRecordRepository.findByUserIdOrderByCreatedAtDesc(userId);

        // 按日期和类型过滤
        if (startDate != null || endDate != null || type != null) {
            logs = logs.stream().filter(log -> {
                boolean match = true;
                
                if (startDate != null) {
                    LocalDate start = LocalDate.parse(startDate);
                    LocalDateTime startDateTime = start.atStartOfDay();
                    match = match && log.getCreatedAt().isAfter(startDateTime);
                }
                
                if (endDate != null) {
                    LocalDate end = LocalDate.parse(endDate);
                    LocalDateTime endDateTime = end.atTime(LocalTime.MAX);
                    match = match && log.getCreatedAt().isBefore(endDateTime);
                }
                
                if (type != null && !type.isEmpty()) {
                    match = match && log.getType().equals(type);
                }
                
                return match;
            }).collect(Collectors.toList());
        }

        // 转换为响应格式
        List<AdminPointLogResultDTO> result = logs.stream().map(log -> {
            AdminPointLogResultDTO dto = new AdminPointLogResultDTO();
            dto.setLogId(log.getId());
            dto.setUserId(log.getUserId());
            dto.setType(log.getType());
            dto.setPoints(log.getPoints());
            dto.setDescription(log.getSource());
            dto.setTimestamp(log.getCreatedAt());
            return dto;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }
}

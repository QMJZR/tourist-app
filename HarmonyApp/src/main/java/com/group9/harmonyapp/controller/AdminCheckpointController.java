package com.group9.harmonyapp.controller;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.dto.AdminCheckpointResultDTO;
import com.group9.harmonyapp.dto.AdminCheckpointCreateDTO;
import com.group9.harmonyapp.dto.AdminCheckpointUpdateDTO;
import com.group9.harmonyapp.dto.AdminCheckpointStatusDTO;
import com.group9.harmonyapp.dto.AdminCheckpointIdResultDTO;
import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Checkpoint;
import com.group9.harmonyapp.repository.CheckpointRepository;
import com.group9.harmonyapp.util.AdminTokenUtil;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/checkpoints")
@RequiredArgsConstructor
public class AdminCheckpointController {

    private final CheckpointRepository checkpointRepository;
    private final AdminTokenUtil adminTokenUtil;

    @GetMapping
    public Response<List<AdminCheckpointResultDTO>> getCheckpoints(
            @RequestParam(required = false) Long spotId,
            @RequestParam(required = false) String status,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查询打卡点列表（支持 spotId 和 status 筛选）
        List<Checkpoint> checkpoints = checkpointRepository.findAll((root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (spotId != null) {
                predicates.add(cb.equal(root.get("spotId"), spotId));
            }
            if (status != null && !status.isEmpty()) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        });

        // 转换为响应格式
        List<AdminCheckpointResultDTO> result = checkpoints.stream().map(c -> {
            AdminCheckpointResultDTO dto = new AdminCheckpointResultDTO();
            dto.setCheckpointId(c.getId());
            dto.setSpotId(c.getSpotId());
            dto.setName(c.getName());
            dto.setLatitude(c.getLatitude());
            dto.setLongitude(c.getLongitude());
            dto.setRadius(c.getRadius());
            dto.setStatus(c.getStatus());
            return dto;
        }).collect(Collectors.toList());

        return Response.buildSuccess(result);
    }

    @PostMapping
    public Response<AdminCheckpointIdResultDTO> createCheckpoint(
            @RequestBody AdminCheckpointCreateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 参数验证
        if (dto.getSpotId() == null) {
            throw new HarmonyException("关联景点ID不能为空", 1000);
        }
        if (dto.getName() == null || dto.getName().isEmpty()) {
            throw new HarmonyException("打卡点名称不能为空", 1000);
        }
        if (dto.getLatitude() == null) {
            throw new HarmonyException("纬度不能为空", 1000);
        }
        if (dto.getLongitude() == null) {
            throw new HarmonyException("经度不能为空", 1000);
        }
        if (dto.getRadius() == null) {
            throw new HarmonyException("有效打卡半径不能为空", 1000);
        }

        // 创建打卡点
        Checkpoint checkpoint = new Checkpoint();
        checkpoint.setSpotId(dto.getSpotId());
        checkpoint.setName(dto.getName());
        checkpoint.setLatitude(dto.getLatitude());
        checkpoint.setLongitude(dto.getLongitude());
        checkpoint.setRadius(dto.getRadius());
        checkpoint.setStatus("enabled");

        Checkpoint savedCheckpoint = checkpointRepository.save(checkpoint);

        AdminCheckpointIdResultDTO result = new AdminCheckpointIdResultDTO();
        result.setCheckpointId(savedCheckpoint.getId());

        return Response.buildSuccess(result, "新增成功");
    }

    @PutMapping("/{checkpointId}")
    public Response<Void> updateCheckpoint(
            @PathVariable Long checkpointId,
            @RequestBody AdminCheckpointUpdateDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查找打卡点
        Checkpoint checkpoint = checkpointRepository.findById(checkpointId).orElse(null);
        if (checkpoint == null) {
            throw new HarmonyException("打卡点不存在", 404);
        }

        // 更新字段（仅更新非 null 字段）
        if (dto.getName() != null) {
            checkpoint.setName(dto.getName());
        }
        if (dto.getLatitude() != null) {
            checkpoint.setLatitude(dto.getLatitude());
        }
        if (dto.getLongitude() != null) {
            checkpoint.setLongitude(dto.getLongitude());
        }
        if (dto.getRadius() != null) {
            checkpoint.setRadius(dto.getRadius());
        }

        checkpointRepository.save(checkpoint);

        return Response.buildSuccess(null, "更新成功");
    }

    @PatchMapping("/{checkpointId}/status")
    public Response<Void> updateCheckpointStatus(
            @PathVariable Long checkpointId,
            @RequestBody AdminCheckpointStatusDTO dto,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查找打卡点
        Checkpoint checkpoint = checkpointRepository.findById(checkpointId).orElse(null);
        if (checkpoint == null) {
            throw new HarmonyException("打卡点不存在", 404);
        }

        // 更新状态
        if (dto.getStatus() != null) {
            checkpoint.setStatus(dto.getStatus());
        }

        checkpointRepository.save(checkpoint);

        return Response.buildSuccess(null, "状态更新成功");
    }

    @DeleteMapping("/{checkpointId}")
    public Response<Void> deleteCheckpoint(
            @PathVariable Long checkpointId,
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "token", required = false) String tokenHeader
    ) {
        // 验证管理员 token
        String token = null;
        if (authorization != null && authorization.startsWith("Bearer ")) {
            token = authorization.substring(7);
        } else if (tokenHeader != null) {
            token = tokenHeader;
        }
        if (token == null || !adminTokenUtil.verifyToken(token)) {
            return Response.buildFailure("未授权，请登录", 401);
        }

        // 查找打卡点
        Checkpoint checkpoint = checkpointRepository.findById(checkpointId).orElse(null);
        if (checkpoint == null) {
            throw new HarmonyException("打卡点不存在", 404);
        }

        // 删除打卡点
        checkpointRepository.delete(checkpoint);

        return Response.buildSuccess(null, "删除成功");
    }
}


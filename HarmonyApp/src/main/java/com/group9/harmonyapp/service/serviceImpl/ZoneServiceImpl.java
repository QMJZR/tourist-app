package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.po.Zone;
import com.group9.harmonyapp.repository.ZoneRepository;
import com.group9.harmonyapp.service.ZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ZoneServiceImpl implements ZoneService {
    private final ZoneRepository zoneRepository;


    public Response<List<Zone>> getAllZones() {
        try {
            return Response.buildSuccess(zoneRepository.findAll());
        } catch (Exception e) {
            return Response.buildFailure("获取引领区信息失败",2001);
        }
    }
}

package com.group9.harmonyapp.service.serviceImpl;

import com.group9.harmonyapp.exception.HarmonyException;
import com.group9.harmonyapp.po.Zone;
import com.group9.harmonyapp.repository.ZoneRepository;
import com.group9.harmonyapp.service.ZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ZoneServiceImpl implements ZoneService {
    private final ZoneRepository zoneRepository;

    @Override
    @Cacheable(value = "zoneCache", key = "'allZones'")
    public List<Zone> getAllZones() {
        try {
            return zoneRepository.findAll();
        } catch (Exception e) {
            throw new HarmonyException("获取引领区信息失败",2001);
        }
    }
}

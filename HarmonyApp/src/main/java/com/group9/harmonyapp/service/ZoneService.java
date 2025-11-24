package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.Response;
import com.group9.harmonyapp.po.Zone;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface ZoneService {
    Response<List<Zone>> getAllZones();
}
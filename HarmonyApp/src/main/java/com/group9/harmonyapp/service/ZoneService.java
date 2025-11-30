package com.group9.harmonyapp.service;

import com.group9.harmonyapp.po.Zone;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface ZoneService {
    List<Zone> getAllZones();
}
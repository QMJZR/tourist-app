package com.group9.harmonyapp.service;

import com.group9.harmonyapp.dto.AssistantRequestDTO;
import com.group9.harmonyapp.dto.AssistantResponseDTO;
import org.springframework.stereotype.Service;

@Service
public interface AssistantService {
    AssistantResponseDTO handleAsk(AssistantRequestDTO req);
}

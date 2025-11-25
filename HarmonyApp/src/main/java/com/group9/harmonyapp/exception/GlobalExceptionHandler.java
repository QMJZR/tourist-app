package com.group9.harmonyapp.exception;

import com.group9.harmonyapp.dto.Response;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;


@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(value = HarmonyException.class)
    public Response<String> handleAIExternalException(HarmonyException e) {
        e.printStackTrace();
        return Response.buildFailure(e.getMessage(), e.code);
    }
}

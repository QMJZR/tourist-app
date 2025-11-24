package com.group9.harmonyapp.exception;

public class HarmonyException extends RuntimeException{
    Integer code;
    public HarmonyException(String message, Integer code) {
        super(message);
        this.code = code;
    }
    public static HarmonyException notLogin(){
        return new HarmonyException("未授权的访问，请先登录!",1201);
    }
}

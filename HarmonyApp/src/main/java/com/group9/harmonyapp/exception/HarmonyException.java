package com.group9.harmonyapp.exception;

public class HarmonyException extends RuntimeException{
    String code;
    public HarmonyException(String message, String code) {
        super(message);
        this.code = code;
    }
    public static HarmonyException notLogin(){
        return new HarmonyException("未登录!","401");
    }
}

package com.group9.harmonyapp.exception;

public class HarmonyException extends RuntimeException{
    String code;
    public HarmonyException(String message, String code) {
        super(message);
        this.code = code;
    }
    public static HarmonyException phoneAlreadyExists(){
        return new HarmonyException("手机号已经存在!","400");
    }
    public static HarmonyException userNameAlreadyExists(){
        return new HarmonyException("用户名已经存在!","400");
    }
    public static HarmonyException NoSuchUserName(){
        return new HarmonyException("用户名不存在!","400");
    }

    public static HarmonyException notLogin(){
        return new HarmonyException("未登录!","401");
    }


}

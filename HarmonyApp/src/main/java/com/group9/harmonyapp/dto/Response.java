package com.group9.harmonyapp.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Response<T> implements Serializable {

    private Integer code;

    private String msg;

    private T data;

    public static <T> Response<T> buildSuccess(T result) {
        return new Response<>(200, null, result);
    }

    public static <T> Response<T> buildFailure(String msg, Integer code) {
        return new Response<>(code, msg, null);
    }
}

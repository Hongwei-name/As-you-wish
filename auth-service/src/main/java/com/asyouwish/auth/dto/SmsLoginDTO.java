package com.asyouwish.auth.dto;

import lombok.Data;

@Data
public class SmsLoginDTO {
    private String phone;
    private String code;
}

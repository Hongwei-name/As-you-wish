package com.asyouwish.auth.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class SmsRegisterDTO {

    private String phone;
    private String code;
    @NotBlank(message = "密码不能为空")
    private String password;
}

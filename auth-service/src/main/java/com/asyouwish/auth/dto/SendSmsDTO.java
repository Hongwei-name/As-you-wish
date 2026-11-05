package com.asyouwish.auth.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class SendSmsDTO {
    @NotBlank(message = "手机号不能为空")
    private String phone;

    @NotBlank(message = "请先完成滑块验证")
    private String captchaId;
}

package com.asyouwish.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class SendSmsDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @NotBlank(message = "请先完成滑块验证")
    @Size(max = 128, message = "验证码标识过长")
    private String captchaId;

    @NotBlank(message = "短信场景不能为空")
    @Pattern(regexp = "^(register|login|reset-password)$", message = "短信场景不合法")
    private String scene;
}

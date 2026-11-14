package com.asyouwish.auth.dto;

import cloud.tianai.captcha.validator.common.model.dto.ImageCaptchaTrack;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CaptchaCheckDTO {

    @NotBlank(message = "验证码标识不能为空")
    private String id;

    @NotNull(message = "验证码轨迹不能为空")
    private ImageCaptchaTrack data;
}

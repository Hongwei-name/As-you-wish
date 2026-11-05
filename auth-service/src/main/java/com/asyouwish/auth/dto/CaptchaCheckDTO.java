package com.asyouwish.auth.dto;

import cloud.tianai.captcha.validator.common.model.dto.ImageCaptchaTrack;
import lombok.Data;

@Data
public class CaptchaCheckDTO {
    private String id;
    private ImageCaptchaTrack data;
}

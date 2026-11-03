package com.asyouwish.auth.dto;

import lombok.Data;

@Data
public class SendSmsDTO {
    private String phone;
    // 滑块验证码的唯一标识 (由后端生成)
    private String captchaUuid;

    // 用户滑动到的 X 坐标
    private Integer sliderX;
}

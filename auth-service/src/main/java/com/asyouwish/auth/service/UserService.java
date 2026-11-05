package com.asyouwish.auth.service;

import cloud.tianai.captcha.common.response.ApiResponse;
import com.asyouwish.auth.dto.CaptchaCheckDTO;
import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.entity.AuthUser;
import com.baomidou.mybatisplus.extension.service.IService;

public interface UserService extends IService<AuthUser> {

    // 1. 根据手机号获取用户
    AuthUser getUserByPhone(String phone);

    // 2. 获取 TianAI 滑块验证码
    ApiResponse<?> getSliderCaptcha();

    // 3. 校验 TianAI 滑块轨迹并签发短信发送凭证
    ApiResponse<?> verifySliderCaptcha(CaptchaCheckDTO dto);

    // 4. 消费已通过验证的凭证并发送短信
    void sendSmsCode(SendSmsDTO dto);

    // 4. 短信验证码注册
    String registerBySms(SmsRegisterDTO dto);

    // 5. 短信验证码登录 (返回JWT Token)
    String loginBySms(SmsLoginDTO dto);

    // 6. 手机号密码登录 (返回JWT Token)
    String loginByPassword(PasswordLoginDTO dto);
}
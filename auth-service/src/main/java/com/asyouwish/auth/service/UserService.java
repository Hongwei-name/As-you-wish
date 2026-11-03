package com.asyouwish.auth.service;

import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.entity.AuthUser;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.Map;

public interface UserService extends IService<AuthUser> {

    // 1. 根据手机号获取用户
    AuthUser getUserByPhone(String phone);

    // 2. 获取滑块验证码
    Map<String, String> getSliderCaptcha();

    // 3. 校验滑块并发送短信
    void verifySliderAndSendSms(SendSmsDTO dto);

    // 4. 短信验证码注册
    String registerBySms(SmsRegisterDTO dto);

    // 5. 短信验证码登录 (返回JWT Token)
    String loginBySms(SmsLoginDTO dto);

    // 6. 手机号密码登录 (返回JWT Token)
    String loginByPassword(PasswordLoginDTO dto);
}
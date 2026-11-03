package com.asyouwish.auth.controller;

import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.service.UserService;
import com.asyouwish.auth.util.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    // 获取滑块验证码
    @GetMapping("/captcha/slider")
    public Result<Map<String, String>> getSliderCaptcha() {
        return Result.success(userService.getSliderCaptcha());
    }

    // 发送短信验证码（包含滑块校验）
    @PostMapping("/sms/send")
    public Result<Void> sendSms(@RequestBody SendSmsDTO dto) {
        // dto 里面现在应该有 phone, captchaUuid, sliderX 三个字段
        userService.verifySliderAndSendSms(dto);
        return Result.success();
    }

    /**
     * 3. 短信验证码登录
     */
    @PostMapping("/login/sms")
    public Result<Map<String, String>> loginBySms(@RequestBody SmsLoginDTO dto) {
        String token = userService.loginBySms(dto);

        Map<String, String> data = new HashMap<>();
        data.put("token", token);
        return Result.success(data);
    }

    /**
     * 4. 手机号 + 密码登录
     */
    @PostMapping("/login/password")
    public Result<Map<String, String>> loginByPassword(@RequestBody PasswordLoginDTO dto) {
        String token = userService.loginByPassword(dto);

        Map<String, String> data = new HashMap<>();
        data.put("token", token);
        return Result.success(data);
    }
}
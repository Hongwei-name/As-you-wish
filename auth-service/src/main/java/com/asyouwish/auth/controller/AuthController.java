package com.asyouwish.auth.controller;

import cloud.tianai.captcha.common.response.ApiResponse;
import com.asyouwish.auth.dto.CaptchaCheckDTO;
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

    // TianAI 官方协议：TAC Web SDK 直接消费其 ApiResponse。
    @RequestMapping(value = "/captcha/gen", method = {RequestMethod.GET, RequestMethod.POST})
    public ApiResponse<?> getSliderCaptcha() {
        return userService.getSliderCaptcha();
    }

    // TianAI 官方协议：校验成功后 SDK 从 data 中取得验证码 id。
    @PostMapping("/captcha/check")
    public ApiResponse<?> checkSliderCaptcha(@RequestBody CaptchaCheckDTO dto) {
        ApiResponse<?> response = userService.verifySliderCaptcha(dto);
        if (!response.isSuccess()) {
            return response;
        }
        return ApiResponse.ofSuccess(java.util.Collections.singletonMap("id", dto.getId()));
    }

    @PostMapping("/sms/send")
    public Result<Void> sendSms(@Valid @RequestBody SendSmsDTO dto) {
        userService.sendSmsCode(dto);
        return Result.success();
    }

    /**
     * 3. 短信验证码注册
     */
    @PostMapping("/register/sms")
    public Result<Map<String, String>> registerBySms(@Valid @RequestBody SmsRegisterDTO dto) {
        String token = userService.registerBySms(dto);

        Map<String, String> data = new HashMap<>();
        data.put("token", token);
        return Result.success(data);
    }

    /**
     * 4. 短信验证码登录
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
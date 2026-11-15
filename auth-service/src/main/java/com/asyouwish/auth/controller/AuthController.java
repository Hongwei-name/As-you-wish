package com.asyouwish.auth.controller;

import cloud.tianai.captcha.common.response.ApiResponse;
import com.asyouwish.auth.dto.CaptchaCheckDTO;
import com.asyouwish.auth.dto.ChangePasswordDTO;
import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.PasswordResetDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.dto.UpdateProfileDTO;
import com.asyouwish.auth.dto.UserInfoVO;
import com.asyouwish.auth.service.UserService;
import com.asyouwish.auth.util.BusinessException;
import com.asyouwish.auth.util.IpUtil;
import com.asyouwish.auth.util.Result;
import com.asyouwish.auth.util.ResultCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务接口：滑块验证码、短信发送、注册、登录、当前用户、退出登录与密码重置。
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private static final String BEARER_PREFIX = "Bearer ";

    private final UserService userService;

    // TianAI 官方协议：TAC Web SDK 直接消费其 ApiResponse。
    @RequestMapping(value = "/captcha/gen", method = {RequestMethod.GET, RequestMethod.POST})
    public ApiResponse<?> getSliderCaptcha() {
        return userService.getSliderCaptcha();
    }

    // TianAI 官方协议：校验成功后 SDK 从 data 中取得验证码 id。
    @PostMapping("/captcha/check")
    public ApiResponse<?> checkSliderCaptcha(@Valid @RequestBody CaptchaCheckDTO dto) {
        ApiResponse<?> response = userService.verifySliderCaptcha(dto);
        if (!response.isSuccess()) {
            return response;
        }
        return ApiResponse.ofSuccess(java.util.Collections.singletonMap("id", dto.getId()));
    }

    @PostMapping("/sms/send")
    public Result<Void> sendSms(@Valid @RequestBody SendSmsDTO dto, HttpServletRequest request) {
        userService.sendSmsCode(dto, IpUtil.getClientIp(request));
        return Result.success();
    }

    @PostMapping("/register/sms")
    public Result<Map<String, String>> registerBySms(@Valid @RequestBody SmsRegisterDTO dto) {
        String token = userService.registerBySms(dto);
        return Result.success(tokenData(token));
    }

    @PostMapping("/login/sms")
    public Result<Map<String, String>> loginBySms(@Valid @RequestBody SmsLoginDTO dto,
                                                 HttpServletRequest request) {
        String token = userService.loginBySms(dto, IpUtil.getClientIp(request));
        return Result.success(tokenData(token));
    }

    @PostMapping("/login/password")
    public Result<Map<String, String>> loginByPassword(@Valid @RequestBody PasswordLoginDTO dto,
                                                       HttpServletRequest request) {
        String token = userService.loginByPassword(dto, IpUtil.getClientIp(request));
        return Result.success(tokenData(token));
    }

    @GetMapping("/me")
    public Result<UserInfoVO> me(@AuthenticationPrincipal Long userId) {
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        return Result.success(userService.getUserInfo(userId));
    }

    @PutMapping("/profile")
    public Result<UserInfoVO> updateProfile(@AuthenticationPrincipal Long userId,
                                            @Valid @RequestBody UpdateProfileDTO dto) {
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        return Result.success(userService.updateProfile(userId, dto));
    }

    @PostMapping(value = "/profile/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Result<UserInfoVO> uploadAvatar(@AuthenticationPrincipal Long userId,
                                           @RequestParam("file") MultipartFile file) {
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        return Result.success(userService.uploadAvatar(userId, file));
    }

    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String authorization) {
        if (authorization != null && authorization.startsWith(BEARER_PREFIX)) {
            userService.logout(authorization.substring(BEARER_PREFIX.length()).trim());
        }
        return Result.success();
    }

    @PostMapping("/password/reset")
    public Result<Void> resetPassword(@Valid @RequestBody PasswordResetDTO dto) {
        userService.resetPassword(dto);
        return Result.success();
    }

    @PostMapping("/password/change")
    public Result<Void> changePassword(@AuthenticationPrincipal Long userId,
                                       @Valid @RequestBody ChangePasswordDTO dto) {
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        userService.changePassword(userId, dto);
        return Result.success();
    }

    private Map<String, String> tokenData(String token) {
        Map<String, String> data = new HashMap<>();
        data.put("token", token);
        return data;
    }
}

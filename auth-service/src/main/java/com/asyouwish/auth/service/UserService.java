package com.asyouwish.auth.service;

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
import com.asyouwish.auth.entity.AuthUser;
import com.baomidou.mybatisplus.extension.service.IService;
import org.springframework.web.multipart.MultipartFile;

public interface UserService extends IService<AuthUser> {

    AuthUser getUserByPhone(String phone);

    ApiResponse<?> getSliderCaptcha();

    ApiResponse<?> verifySliderCaptcha(CaptchaCheckDTO dto);

    void sendSmsCode(SendSmsDTO dto, String ip);

    String registerBySms(SmsRegisterDTO dto);

    String loginBySms(SmsLoginDTO dto, String ip);

    String loginByPassword(PasswordLoginDTO dto, String ip);

    UserInfoVO updateProfile(Long userId, UpdateProfileDTO dto);

    UserInfoVO uploadAvatar(Long userId, MultipartFile file);

    UserInfoVO getUserInfo(Long userId);

    void logout(String token);

    void resetPassword(PasswordResetDTO dto);

    void changePassword(Long userId, ChangePasswordDTO dto);
}

package com.asyouwish.auth.service;

/**
 * 短信验证码发送/核验抽象。
 * test 使用控制台实现，prod 使用阿里云 PNVS 实现。
 */
public interface SmsCodeService {

    void send(SmsScene scene, String phone);

    boolean verify(SmsScene scene, String phone, String code);
}

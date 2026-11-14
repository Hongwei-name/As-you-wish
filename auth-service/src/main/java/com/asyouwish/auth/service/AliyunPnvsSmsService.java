package com.asyouwish.auth.service;

import com.aliyun.dypnsapi20170525.Client;
import com.aliyun.dypnsapi20170525.models.CheckSmsVerifyCodeRequest;
import com.aliyun.dypnsapi20170525.models.CheckSmsVerifyCodeResponse;
import com.aliyun.dypnsapi20170525.models.CheckSmsVerifyCodeResponseBody;
import com.aliyun.dypnsapi20170525.models.SendSmsVerifyCodeRequest;
import com.aliyun.dypnsapi20170525.models.SendSmsVerifyCodeResponse;
import com.aliyun.dypnsapi20170525.models.SendSmsVerifyCodeResponseBody;
import com.aliyun.tea.TeaException;
import com.aliyun.teaopenapi.models.Config;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 阿里云号码认证 PNVS（短信认证）客户端封装。
 *
 * 只使用 SendSmsVerifyCode / CheckSmsVerifyCode 两个接口；
 * 验证码由阿里云生成和保存，本项目不生成、不存储、不返回验证码。
 */
@Slf4j
@Service
@Profile("prod")
@RequiredArgsConstructor
public class AliyunPnvsSmsService implements SmsCodeService {

    private final AliyunPnvsProperties properties;

    private volatile Client client;

    public void send(SmsScene scene, String phone) {
        ensureConfigured(scene);
        SendSmsVerifyCodeRequest request = new SendSmsVerifyCodeRequest()
                .setPhoneNumber(phone)
                .setCountryCode(properties.getCountryCode())
                .setSignName(properties.getSignName())
                .setTemplateCode(properties.templateCodeFor(scene))
                .setTemplateParam(properties.getTemplateParam())
                .setSchemeName(properties.schemeNameFor(scene))
                .setCodeLength(properties.getCodeLength())
                .setCodeType(properties.getCodeType())
                .setValidTime(properties.getValidTime())
                .setInterval(properties.getInterval())
                .setDuplicatePolicy(properties.getDuplicatePolicy())
                // 绝不把验证码返回给前端或写入日志。
                .setReturnVerifyCode(false);

        log.info("PNVS 发送参数 scene={} phone={} country={} sign={} template={} templateParam={} "
                        + "codeLength={} codeType={} validTime={} interval={} duplicatePolicy={}",
                scene.getCode(), maskPhone(phone), properties.getCountryCode(), properties.getSignName(),
                properties.templateCodeFor(scene), properties.getTemplateParam(), properties.getCodeLength(),
                properties.getCodeType(), properties.getValidTime(), properties.getInterval(),
                properties.getDuplicatePolicy());

        try {
            SendSmsVerifyCodeResponse response = client().sendSmsVerifyCode(request);
            SendSmsVerifyCodeResponseBody body = response == null ? null : response.getBody();
            if (body == null) {
                throw PnvsException.system("短信服务暂时不可用，请稍后重试", "EMPTY_RESPONSE", null);
            }
            if (!"OK".equalsIgnoreCase(body.getCode()) || !Boolean.TRUE.equals(body.getSuccess())) {
                throw PnvsErrorMapper.fromProvider(body.getCode(), body.getMessage());
            }
            String bizId = body.getModel() == null ? null : body.getModel().getBizId();
            log.info("PNVS 短信发送成功 scene={} phone={} bizId={} requestId={}",
                    scene.getCode(), maskPhone(phone), bizId, body.getRequestId());
        } catch (TeaException exception) {
            log.warn("PNVS 短信发送失败 scene={} code={} message={}",
                    scene.getCode(), exception.getCode(), exception.getMessage());
            throw PnvsErrorMapper.fromException(exception);
        } catch (PnvsException exception) {
            throw exception;
        } catch (Exception exception) {
            log.error("PNVS 短信发送调用异常 scene={}", scene.getCode(), exception);
            throw PnvsException.system("短信服务暂时不可用，请稍后重试", "CALL_FAILED", exception);
        }
    }

    public boolean verify(SmsScene scene, String phone, String code) {
        ensureConfigured(scene);
        CheckSmsVerifyCodeRequest request = new CheckSmsVerifyCodeRequest()
                .setPhoneNumber(phone)
                .setCountryCode(properties.getCountryCode())
                .setVerifyCode(code)
                .setSchemeName(properties.schemeNameFor(scene));

        try {
            CheckSmsVerifyCodeResponse response = client().checkSmsVerifyCode(request);
            CheckSmsVerifyCodeResponseBody body = response == null ? null : response.getBody();
            if (body == null) {
                throw PnvsException.system("短信服务暂时不可用，请稍后重试", "EMPTY_RESPONSE", null);
            }
            if (!"OK".equalsIgnoreCase(body.getCode())) {
                throw PnvsErrorMapper.fromProvider(body.getCode(), body.getMessage());
            }
            String result = body.getModel() == null ? null : body.getModel().getVerifyResult();
            if ("PASS".equalsIgnoreCase(result)) {
                return true;
            }
            if ("UNKNOWN".equalsIgnoreCase(result)) {
                return false;
            }
            throw PnvsException.system("短信服务暂时不可用，请稍后重试", "UNKNOWN_VERIFY_RESULT", null);
        } catch (TeaException exception) {
            log.warn("PNVS 验证码核验失败 scene={} code={} message={}",
                    scene.getCode(), exception.getCode(), exception.getMessage());
            throw PnvsErrorMapper.fromException(exception);
        } catch (PnvsException exception) {
            throw exception;
        } catch (Exception exception) {
            log.error("PNVS 验证码核验调用异常 scene={}", scene.getCode(), exception);
            throw PnvsException.system("短信服务暂时不可用，请稍后重试", "CALL_FAILED", exception);
        }
    }

    private void ensureConfigured(SmsScene scene) {
        boolean configured = scene != null
                && StringUtils.hasText(properties.getAccessKeyId())
                && StringUtils.hasText(properties.getAccessKeySecret())
                && StringUtils.hasText(properties.getSignName())
                && StringUtils.hasText(properties.templateCodeFor(scene));
        if (!configured) {
            log.error("PNVS 配置不完整 scene={} akPresent={} secretPresent={} signPresent={} templatePresent={}",
                    scene == null ? null : scene.getCode(),
                    StringUtils.hasText(properties.getAccessKeyId()),
                    StringUtils.hasText(properties.getAccessKeySecret()),
                    StringUtils.hasText(properties.getSignName()),
                    scene != null && StringUtils.hasText(properties.templateCodeFor(scene)));
            throw PnvsException.system("短信服务未配置，请联系管理员", "CONFIG_MISSING", null);
        }
    }

    private Client client() {
        if (client != null) {
            return client;
        }
        synchronized (this) {
            if (client == null) {
                try {
                    Config config = new Config()
                            .setAccessKeyId(properties.getAccessKeyId())
                            .setAccessKeySecret(properties.getAccessKeySecret())
                            .setEndpoint(properties.getEndpoint());
                    client = new Client(config);
                } catch (Exception exception) {
                    log.error("PNVS 客户端初始化失败", exception);
                    throw PnvsException.system("短信服务初始化失败，请联系管理员", "CLIENT_INIT", exception);
                }
            }
        }
        return client;
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return "***";
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}

package com.asyouwish.auth.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
@Data
public class AuthUser {
    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 登录账号，唯一 */
    private String username;

    /** 加密后的密码，不存储明文 */
    private String password;

    /** 用户昵称 */
    private String nickname;

    /** 用户头像地址 */
    private String avatar;

    /** 邮箱，用于登录、找回密码 */
    private String email;

    /** 手机号，用于登录、接收短信验证码 */
    private String phone;

    /** 性别：0未知，1男，2女 */
    private Integer gender;

    /** 生日（用于会员权益） */
    private LocalDate birthday;

    /** 账号状态：0禁用，1正常，2锁定 */
    private Integer status;

    /** 最后登录IP地址 */
    private String lastLoginIp;

    /** 最后登录时间 */
    private LocalDateTime lastLoginTime;

    /** 微信openid，电商快捷登录 */
    private String wxOpenid;

    /** 微信unionid，多端互通 */
    private String wxUnionid;

    /** QQ开放ID，电商快捷登录 */
    private String qqOpenid;

    /** Github第三方ID */
    private String githubId;

    /** 微博第三方ID */
    private String weiboId;

    /** 第三方登录类型：wx/qq/github/weibo */
    private String thirdType;

    /** 通用第三方账号ID，方便扩展其他平台快捷登录 */
    private String thirdId;

    /** 绑定的平台社交账号ID，soc_account.id */
    private Long socAccountId;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;

    /** 创建人auth_user_id */
    private Long createBy;

    /** 更新人auth_user_id */
    private Long updateBy;
}

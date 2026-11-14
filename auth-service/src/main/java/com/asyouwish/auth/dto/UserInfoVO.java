package com.asyouwish.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 当前登录用户的安全信息，不包含密码等敏感字段。
 */
@Data
@AllArgsConstructor
public class UserInfoVO {
    private Long id;
    private String phone;
    private String nickname;
    private String avatar;
}

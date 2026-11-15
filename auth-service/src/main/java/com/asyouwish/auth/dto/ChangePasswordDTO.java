package com.asyouwish.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 更改密码：旧密码校验通过后更新为新密码。
 */
@Data
public class ChangePasswordDTO {

    @NotBlank(message = "旧密码不能为空")
    private String oldPassword;

    @NotBlank(message = "新密码不能为空")
    @Size(min = 8, max = 64, message = "密码长度需为 8-64 位")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d).{8,64}$", message = "密码需为 8-64 位并包含字母和数字")
    private String newPassword;
}
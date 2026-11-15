package com.asyouwish.auth.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 修改个人信息：头像地址与昵称，均为可选，至少传一项。
 */
@Data
public class UpdateProfileDTO {

    @Size(min = 1, max = 30, message = "昵称长度需为 1-30 个字符")
    private String nickname;

    @Size(max = 500, message = "头像地址过长")
    private String avatar;
}
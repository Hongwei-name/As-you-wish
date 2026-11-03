package com.asyouwish.auth.dto;

import lombok.Data;

@Data
public class PasswordLoginDTO {
    private String phone;
    private String password;
}

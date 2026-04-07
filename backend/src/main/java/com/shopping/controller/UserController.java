package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.dto.PasswordUpdateDTO;
import com.shopping.dto.UserLoginDTO;
import com.shopping.dto.UserRegisterDTO;
import com.shopping.dto.UserUpdateDTO;
import com.shopping.entity.User;
import com.shopping.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器
 * 提供用户相关的 REST API 接口
 * 
 * @author 陈洪伟
 */
@Slf4j
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 用户注册接口
     * 
     * @param registerDTO 注册信息
     * @return 注册成功的用户信息
     */
    @PostMapping("/register")
    public Result<User> register(@Valid @RequestBody UserRegisterDTO registerDTO) {
        log.info("用户注册请求，用户名：{}", registerDTO.getUsername());
        User user = userService.register(registerDTO);
        user.setPassword(null);
        return Result.success("注册成功", user);
    }

    /**
     * 用户登录接口
     * 
     * @param loginDTO 登录信息
     * @return JWT Token
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Valid @RequestBody UserLoginDTO loginDTO) {
        log.info("用户登录请求，用户名：{}", loginDTO.getUsername());
        String token = userService.login(loginDTO);
        
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        
        return Result.success("登录成功", data);
    }

    /**
     * 获取用户信息接口
     * 需要 JWT 认证
     * 
     * @param request HTTP 请求
     * @return 用户信息
     */
    @GetMapping("/info")
    public Result<User> getUserInfo(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("获取用户信息请求，用户ID：{}", userId);
        User user = userService.getUserById(userId);
        return Result.success(user);
    }

    /**
     * 更新用户信息接口
     * 需要 JWT 认证
     * 
     * @param updateDTO 更新信息
     * @param request HTTP 请求
     * @return 更新后的用户信息
     */
    @PutMapping("/update")
    public Result<User> updateUser(@Valid @RequestBody UserUpdateDTO updateDTO, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("更新用户信息请求，用户ID：{}", userId);
        User user = userService.updateUser(userId, updateDTO);
        return Result.success("更新成功", user);
    }

    /**
     * 修改密码接口
     * 需要 JWT 认证
     * 
     * @param passwordDTO 密码信息
     * @param request HTTP 请求
     * @return 操作结果
     */
    @PutMapping("/password")
    public Result<Void> updatePassword(@Valid @RequestBody PasswordUpdateDTO passwordDTO, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("修改密码请求，用户ID：{}", userId);
        userService.updatePassword(userId, passwordDTO);
        return Result.success("密码修改成功", null);
    }

}

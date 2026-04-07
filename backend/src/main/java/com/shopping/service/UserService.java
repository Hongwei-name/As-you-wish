package com.shopping.service;

import com.shopping.dto.PasswordUpdateDTO;
import com.shopping.dto.UserLoginDTO;
import com.shopping.dto.UserRegisterDTO;
import com.shopping.dto.UserUpdateDTO;
import com.shopping.entity.User;

/**
 * 用户服务接口
 * 定义用户相关的业务方法
 * 
 * @author 陈洪伟
 */
public interface UserService {

    /**
     * 用户注册
     * 
     * @param registerDTO 注册信息
     * @return 注册成功的用户信息
     */
    User register(UserRegisterDTO registerDTO);

    /**
     * 用户登录
     * 
     * @param loginDTO 登录信息
     * @return JWT Token
     */
    String login(UserLoginDTO loginDTO);

    /**
     * 根据ID查询用户信息
     * 
     * @param userId 用户ID
     * @return 用户信息
     */
    User getUserById(Long userId);

    /**
     * 更新用户信息
     * 
     * @param userId 用户ID
     * @param updateDTO 更新信息
     * @return 更新后的用户信息
     */
    User updateUser(Long userId, UserUpdateDTO updateDTO);

    /**
     * 修改密码
     * 
     * @param userId 用户ID
     * @param passwordDTO 密码信息
     * @return 是否成功
     */
    boolean updatePassword(Long userId, PasswordUpdateDTO passwordDTO);

    /**
     * 根据用户名查询用户
     * 
     * @param username 用户名
     * @return 用户信息
     */
    User getUserByUsername(String username);

    /**
     * 检查密码
     * 
     * @param rawPassword 原始密码
     * @param encodedPassword 加密密码
     * @return 是否匹配
     */
    boolean checkPassword(String rawPassword, String encodedPassword);

    /**
     * 获取用户列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param keyword 关键词
     * @return 用户分页列表
     */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<User> getUserList(Integer page, Integer size, String keyword);

    /**
     * 更新用户状态
     * 
     * @param userId 用户ID
     * @param status 状态
     * @return 是否成功
     */
    boolean updateUserStatus(Long userId, Integer status);

    /**
     * 获取用户统计
     * 
     * @return 统计数据
     */
    java.util.Map<String, Object> getUserStats();

}

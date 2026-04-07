package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.dto.PasswordUpdateDTO;
import com.shopping.dto.UserLoginDTO;
import com.shopping.dto.UserRegisterDTO;
import com.shopping.dto.UserUpdateDTO;
import com.shopping.entity.User;
import com.shopping.mapper.UserMapper;
import com.shopping.service.UserService;
import com.shopping.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import java.time.LocalDateTime;

/**
 * 用户服务实现类
 * 实现用户相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Slf4j
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 用户注册
     * 检查用户名是否已存在，密码加密后保存
     * 
     * @param registerDTO 注册信息
     * @return 注册成功的用户信息
     */
    @Override
    public User register(UserRegisterDTO registerDTO) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, registerDTO.getUsername());
        User existUser = userMapper.selectOne(queryWrapper);
        
        if (existUser != null) {
            throw new RuntimeException("用户名已存在");
        }

        User user = new User();
        user.setUsername(registerDTO.getUsername());
        user.setPassword(passwordEncoder.encode(registerDTO.getPassword()));
        user.setEmail(registerDTO.getEmail());
        user.setPhone(registerDTO.getPhone());
        user.setNickname(registerDTO.getUsername());
        user.setGender(0);

        userMapper.insert(user);
        log.info("用户注册成功，用户名：{}", user.getUsername());
        
        return user;
    }

    /**
     * 用户登录
     * 验证用户名密码，生成JWT Token
     * 
     * @param loginDTO 登录信息
     * @return JWT Token
     */
    @Override
    public String login(UserLoginDTO loginDTO) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, loginDTO.getUsername());
        User user = userMapper.selectOne(queryWrapper);
        
        if (user == null) {
            throw new RuntimeException("用户名或密码错误");
        }

        // 密码验证
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        log.info("用户登录成功，用户名：{}", user.getUsername());
        
        return token;
    }

    /**
     * 根据ID查询用户信息
     * 
     * @param userId 用户ID
     * @return 用户信息
     */
    @Override
    public User getUserById(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setPassword(null);
        return user;
    }

    /**
     * 更新用户信息
     * 
     * @param userId 用户ID
     * @param updateDTO 更新信息
     * @return 更新后的用户信息
     */
    @Override
    public User updateUser(Long userId, UserUpdateDTO updateDTO) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (StringUtils.hasText(updateDTO.getEmail())) {
            user.setEmail(updateDTO.getEmail());
        }
        if (StringUtils.hasText(updateDTO.getPhone())) {
            user.setPhone(updateDTO.getPhone());
        }
        if (StringUtils.hasText(updateDTO.getAvatar())) {
            user.setAvatar(updateDTO.getAvatar());
        }
        if (StringUtils.hasText(updateDTO.getNickname())) {
            user.setNickname(updateDTO.getNickname());
        }
        if (updateDTO.getGender() != null) {
            user.setGender(updateDTO.getGender());
        }
        if (updateDTO.getBirthday() != null) {
            user.setBirthday(updateDTO.getBirthday());
        }

        userMapper.updateById(user);
        log.info("用户信息更新成功，用户ID：{}", userId);
        
        user.setPassword(null);
        return user;
    }

    /**
     * 修改密码
     * 
     * @param userId 用户ID
     * @param passwordDTO 密码信息
     * @return 是否成功
     */
    @Override
    public boolean updatePassword(Long userId, PasswordUpdateDTO passwordDTO) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!passwordEncoder.matches(passwordDTO.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("原密码错误");
        }

        user.setPassword(passwordEncoder.encode(passwordDTO.getNewPassword()));
        userMapper.updateById(user);
        log.info("用户密码修改成功，用户ID：{}", userId);
        
        return true;
    }

    @Override
    public User getUserByUsername(String username) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, username);
        return userMapper.selectOne(queryWrapper);
    }

    @Override
    public boolean checkPassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    @Override
    public Page<User> getUserList(Integer page, Integer size, String keyword) {
        Page<User> userPage = new Page<>(page, size);
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(keyword)) {
            queryWrapper.like(User::getUsername, keyword)
                       .or().like(User::getNickname, keyword)
                       .or().like(User::getPhone, keyword)
                       .or().like(User::getEmail, keyword);
        }
        
        userPage = userMapper.selectPage(userPage, queryWrapper);
        
        // 清除密码
        userPage.getRecords().forEach(user -> user.setPassword(null));
        
        return userPage;
    }

    @Override
    public boolean updateUserStatus(Long userId, Integer status) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        user.setRole(status);
        userMapper.updateById(user);
        log.info("用户状态更新成功，用户ID：{}", userId);
        
        return true;
    }

    @Override
    public java.util.Map<String, Object> getUserStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        
        // 总用户数
        long totalUsers = userMapper.selectCount(null);
        stats.put("totalUsers", totalUsers);
        
        // 管理员数量
        LambdaQueryWrapper<User> adminQuery = new LambdaQueryWrapper<>();
        adminQuery.eq(User::getRole, 1);
        long adminCount = userMapper.selectCount(adminQuery);
        stats.put("adminCount", adminCount);
        
        // 普通用户数量
        stats.put("normalUserCount", totalUsers - adminCount);
        
        // 今日新增用户数
        LocalDateTime today = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LambdaQueryWrapper<User> todayQuery = new LambdaQueryWrapper<>();
        todayQuery.ge(User::getCreatedAt, today);
        long todayUsers = userMapper.selectCount(todayQuery);
        stats.put("todayUsers", todayUsers);
        
        return stats;
    }

}

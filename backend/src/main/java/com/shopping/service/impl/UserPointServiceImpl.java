package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.UserPointMapper;
import com.shopping.mapper.PointRecordMapper;
import com.shopping.entity.UserPoint;
import com.shopping.entity.PointRecord;
import com.shopping.service.UserPointService;
import com.shopping.service.PointRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

/**
 * 用户积分Service实现类
 */
@Service
public class UserPointServiceImpl extends ServiceImpl<UserPointMapper, UserPoint> implements UserPointService {
    
    @Autowired
    private UserPointMapper userPointMapper;
    
    @Autowired
    private PointRecordService pointRecordService;
    
    @Override
    public Integer getPointBalance(Long userId) {
        Integer balance = userPointMapper.selectBalanceByUserId(userId);
        return balance != null ? balance : 0;
    }
    
    @Override
    @Transactional
    public boolean addPoints(Long userId, Integer amount, Integer type, Long relatedId, String description) {
        // 增加用户积分
        int result = userPointMapper.increaseBalance(userId, amount);
        if (result == 0) {
            return false;
        }
        
        // 获取最新余额
        Integer balance = getPointBalance(userId);
        
        // 创建积分记录
        PointRecord record = new PointRecord();
        record.setUserId(userId);
        record.setType(type);
        record.setAmount(amount);
        record.setBalance(balance);
        record.setRelatedId(relatedId);
        record.setDescription(description);
        record.setCreatedAt(LocalDateTime.now());
        
        return pointRecordService.createPointRecord(record);
    }
    
    @Override
    @Transactional
    public boolean deductPoints(Long userId, Integer amount, Integer type, Long relatedId, String description) {
        // 减少用户积分
        int result = userPointMapper.decreaseBalance(userId, amount);
        if (result == 0) {
            return false;
        }
        
        // 获取最新余额
        Integer balance = getPointBalance(userId);
        
        // 创建积分记录
        PointRecord record = new PointRecord();
        record.setUserId(userId);
        record.setType(type);
        record.setAmount(-amount);
        record.setBalance(balance);
        record.setRelatedId(relatedId);
        record.setDescription(description);
        record.setCreatedAt(LocalDateTime.now());
        
        return pointRecordService.createPointRecord(record);
    }
}
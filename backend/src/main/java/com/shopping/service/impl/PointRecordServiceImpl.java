package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.PointRecordMapper;
import com.shopping.entity.PointRecord;
import com.shopping.service.PointRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 积分记录Service实现类
 */
@Service
public class PointRecordServiceImpl extends ServiceImpl<PointRecordMapper, PointRecord> implements PointRecordService {
    
    @Autowired
    private PointRecordMapper pointRecordMapper;
    
    @Override
    public List<PointRecord> getUserPointRecords(Long userId, Integer limit) {
        return pointRecordMapper.selectByUserId(userId, limit);
    }
    
    @Override
    public boolean createPointRecord(PointRecord record) {
        return save(record);
    }
}
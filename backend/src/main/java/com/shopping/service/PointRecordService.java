package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.PointRecord;
import java.util.List;

/**
 * 积分记录Service接口
 */
public interface PointRecordService extends IService<PointRecord> {
    /**
     * 获取用户的积分记录列表
     * @param userId 用户ID
     * @param limit 限制数量
     * @return 积分记录列表
     */
    List<PointRecord> getUserPointRecords(Long userId, Integer limit);
    
    /**
     * 创建积分记录
     * @param record 积分记录信息
     * @return 是否创建成功
     */
    boolean createPointRecord(PointRecord record);
}
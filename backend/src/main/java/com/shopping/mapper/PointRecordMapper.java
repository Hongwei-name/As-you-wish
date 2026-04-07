package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.PointRecord;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 积分记录Mapper接口
 */
public interface PointRecordMapper extends BaseMapper<PointRecord> {
    /**
     * 根据用户ID获取积分记录列表
     * @param userId 用户ID
     * @param limit 限制数量
     * @return 积分记录列表
     */
    List<PointRecord> selectByUserId(@Param("userId") Long userId, @Param("limit") Integer limit);
}
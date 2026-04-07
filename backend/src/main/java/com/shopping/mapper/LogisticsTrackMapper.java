package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.LogisticsTrack;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 物流轨迹Mapper接口
 */
public interface LogisticsTrackMapper extends BaseMapper<LogisticsTrack> {
    /**
     * 根据物流ID获取轨迹列表
     * @param logisticsId 物流ID
     * @return 轨迹列表
     */
    List<LogisticsTrack> selectByLogisticsId(@Param("logisticsId") Long logisticsId);
}
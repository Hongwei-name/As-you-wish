package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.CsSession;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 客服会话Mapper接口
 */
public interface CsSessionMapper extends BaseMapper<CsSession> {
    /**
     * 根据用户ID获取会话列表
     * @param userId 用户ID
     * @return 会话列表
     */
    List<CsSession> selectByUserId(@Param("userId") Long userId);
    
    /**
     * 获取未结束的会话
     * @param userId 用户ID
     * @return 未结束的会话
     */
    CsSession selectUnfinishedByUserId(@Param("userId") Long userId);
}
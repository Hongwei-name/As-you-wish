package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.CsMessage;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 客服消息Mapper接口
 */
public interface CsMessageMapper extends BaseMapper<CsMessage> {
    /**
     * 根据会话ID获取消息列表
     * @param sessionId 会话ID
     * @param limit 限制数量
     * @return 消息列表
     */
    List<CsMessage> selectBySessionId(@Param("sessionId") Long sessionId, @Param("limit") Integer limit);
}
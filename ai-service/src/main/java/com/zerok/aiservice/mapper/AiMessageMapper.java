package com.zerok.aiservice.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.zerok.aiservice.entity.AiMessage;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * ai_message 数据访问。
 */
public interface AiMessageMapper extends BaseMapper<AiMessage> {

    /**
     * 读取会话最近 N 条已完成消息，作为模型上下文（ChatMemory 从 ai_message 读）。
     */
    @Select("""
            SELECT id, conversation_id, role, content, status, created_at, updated_at
            FROM (
                SELECT id, conversation_id, role, content, status, created_at, updated_at
                FROM ai_message
                WHERE conversation_id = #{conversationId}
                  AND role IN ('user', 'assistant')
                  AND status = 'completed'
                ORDER BY created_at DESC, id DESC
                LIMIT #{limit}
            ) AS recent
            ORDER BY created_at ASC, id ASC
            """)
    List<AiMessage> selectRecentCompleted(@Param("conversationId") String conversationId,
                                          @Param("limit") int limit);
}
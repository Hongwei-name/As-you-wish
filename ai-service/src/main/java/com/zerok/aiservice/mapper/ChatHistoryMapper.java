package com.zerok.aiservice.mapper;

import com.zerok.aiservice.entity.AiConversation;
import com.zerok.aiservice.entity.AiMessage;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 历史分页查询（keyset 游标，从新到旧），SQL 见 resources/mapper/ChatHistoryMapper.xml。
 */
public interface ChatHistoryMapper {

    List<AiConversation> pageConversations(@Param("userId") Long userId,
                                           @Param("cursorUpdatedAt") LocalDateTime cursorUpdatedAt,
                                           @Param("cursorId") String cursorId,
                                           @Param("limit") int limit);

    List<AiMessage> pageMessages(@Param("conversationId") String conversationId,
                                 @Param("cursorCreatedAt") LocalDateTime cursorCreatedAt,
                                 @Param("cursorId") String cursorId,
                                 @Param("limit") int limit);
}
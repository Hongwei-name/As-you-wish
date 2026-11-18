package com.zerok.aiservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * AI 会话表 ai_conversation。
 */
@Data
@TableName("ai_conversation")
public class AiConversation {

    /** 会话ID，UUID */
    @TableId(type = IdType.INPUT)
    private String id;

    /** 所属用户ID */
    private Long userId;

    /** 会话标题 */
    private String title;

    /** 创建时间 */
    private LocalDateTime createdAt;

    /** 更新时间 */
    private LocalDateTime updatedAt;
}
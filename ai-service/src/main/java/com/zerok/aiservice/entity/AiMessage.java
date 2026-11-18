package com.zerok.aiservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * AI 消息表 ai_message。
 */
@Data
@TableName("ai_message")
public class AiMessage {

    /** 消息ID，UUID */
    @TableId(type = IdType.INPUT)
    private String id;

    /** 所属会话ID */
    private String conversationId;

    /** 角色：user / assistant / system / tool */
    private String role;

    /** 消息正文 */
    private String content;

    /** 状态：generating / completed / failed / cancelled */
    private String status;

    /** 创建时间 */
    private LocalDateTime createdAt;

    /** 更新时间 */
    private LocalDateTime updatedAt;
}
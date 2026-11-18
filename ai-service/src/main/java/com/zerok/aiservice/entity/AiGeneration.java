package com.zerok.aiservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * AI 模型调用记录表 ai_generation。
 */
@Data
@TableName("ai_generation")
public class AiGeneration {

    /** 调用记录ID，UUID */
    @TableId(type = IdType.INPUT)
    private String id;

    /** 所属会话ID */
    private String conversationId;

    /** 客户端请求UUID，用于幂等 */
    private String requestId;

    /** 本次回答对应的用户消息ID */
    private String userMessageId;

    /** 模型生成的消息ID */
    private String assistantMessageId;

    /** 供应商/来源标识 */
    private String provider;

    /** 实际使用的模型标识 */
    private String model;

    /** 状态：pending / running / completed / failed / cancelled */
    private String status;

    /** 开始调用模型时间 */
    private LocalDateTime startedAt;

    /** 完成/失败/取消时间 */
    private LocalDateTime finishedAt;

    /** 模型调用耗时，毫秒 */
    private Long durationMs;

    /** 首分片耗时，毫秒 */
    private Long firstTokenMs;

    /** 输入 token 数 */
    private Long inputTokens;

    /** 输出 token 数 */
    private Long outputTokens;

    /** 总 token 数 */
    private Long totalTokens;

    /** 内部标准错误码 */
    private String errorCode;

    /** 错误摘要 */
    private String errorMessage;

    /** 创建时间 */
    private LocalDateTime createdAt;

    /** 更新时间 */
    private LocalDateTime updatedAt;
}
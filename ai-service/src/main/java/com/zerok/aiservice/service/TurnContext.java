package com.zerok.aiservice.service;

import java.time.LocalDateTime;

/**
 * 一轮对话的持久化上下文。
 *
 * @param conversationId    会话ID
 * @param userMessageId     用户消息ID
 * @param assistantMessageId 助手消息ID
 * @param generationId      生成记录ID
 * @param requestId         客户端请求ID
 * @param startedAt         开始时间
 * @param startedAtEpochMs  开始时间（毫秒，用于耗时计算）
 */
public record TurnContext(String conversationId,
                          String userMessageId,
                          String assistantMessageId,
                          String generationId,
                          String requestId,
                          LocalDateTime startedAt,
                          long startedAtEpochMs) {
}
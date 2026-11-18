package com.zerok.aiservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 一次对话请求。
 *
 * @param message        用户本轮输入
 * @param conversationId 会话 id（为空由服务端生成）
 * @param requestId      客户端请求 id，用于 ai_generation 幂等（为空由服务端生成）
 */
public record ChatRequest(
        @NotBlank(message = "消息不能为空")
        @Size(max = 2000, message = "消息不能超过 2000 字")
        String message,
        String conversationId,
        String requestId) {
}
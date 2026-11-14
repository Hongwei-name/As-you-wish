package com.zerok.aiservice.dto;

/**
 * 一次对话请求。conversationId 由前端会话生成，用于隔离 ChatMemory。
 */
public record ChatRequest(String message, String conversationId) {
}

package com.zerok.aiservice.service;

import com.zerok.aiservice.dto.ConversationVO;
import com.zerok.aiservice.dto.MessageVO;
import com.zerok.aiservice.dto.PageResult;

/**
 * 对话历史持久化与分页查询。
 */
public interface ChatHistoryService {

    /**
     * 开始一轮对话：获取或创建会话，生成消息/生成记录 ID，但不写消息行，
     * 保证模型上下文读到的只有本轮之前的历史。
     */
    TurnContext startTurn(Long userId, String conversationId, String requestId, String firstMessage);

    /**
     * 正常完成：写 user / assistant / generation 三行。
     */
    void completeTurn(TurnContext context, String userMessage, String assistantContent,
                      long durationMs, Long firstTokenMs);

    /**
     * 服务异常：assistant 记 failed，generation 记 failed。
     */
    void failTurn(TurnContext context, String userMessage, String partialAssistantContent,
                  String errorCode, String errorMessage, long durationMs);

    /**
     * 中断/取消：assistant 记 cancelled，generation 记 cancelled，保留已生成的部分。
     */
    void cancelTurn(TurnContext context, String userMessage, String partialAssistantContent, long durationMs);

    /**
     * 会话列表，从新到旧。
     */
    PageResult<ConversationVO> pageConversations(Long userId, int limit, String cursor);

    /**
     * 消息列表，从新到旧。
     */
    PageResult<MessageVO> pageMessages(Long userId, String conversationId, int limit, String cursor);
}
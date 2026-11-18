package com.zerok.aiservice.repository;

import com.zerok.aiservice.entity.AiMessage;
import com.zerok.aiservice.mapper.AiMessageMapper;
import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 让 Spring AI 的 ChatMemory 从 ai_message 读取上下文。
 *
 * <p>只读：历史写入由 ChatHistoryService 单一负责。MessageWindowChatMemory 的
 * {@code saveAll} 会整体替换并按窗口裁剪，直接写库会删掉更早的历史，因此这里做成空实现。</p>
 */
@Repository
public class MyBatisChatMemoryRepository implements ChatMemoryRepository {

    private final AiMessageMapper aiMessageMapper;
    private final int maxMessages;

    public MyBatisChatMemoryRepository(AiMessageMapper aiMessageMapper,
                                       @Value("${assistant.memory.max-messages:20}") int maxMessages) {
        this.aiMessageMapper = aiMessageMapper;
        this.maxMessages = maxMessages;
    }

    @Override
    public List<String> findConversationIds() {
        return List.of();
    }

    @Override
    public List<Message> findByConversationId(String conversationId) {
        return aiMessageMapper.selectRecentCompleted(conversationId, maxMessages)
                .stream()
                .map(this::toSpringAiMessage)
                .toList();
    }

    @Override
    public void saveAll(String conversationId, List<Message> messages) {
        // 空实现：ai_message 的写入由 ChatHistoryService 统一负责，避免窗口裁剪覆盖完整历史。
    }

    @Override
    public void deleteByConversationId(String conversationId) {
        // 空实现：删除会话属于独立功能，不由记忆窗口触发。
    }

    private Message toSpringAiMessage(AiMessage row) {
        if ("user".equals(row.getRole())) {
            return new UserMessage(row.getContent());
        }
        return new AssistantMessage(row.getContent());
    }
}
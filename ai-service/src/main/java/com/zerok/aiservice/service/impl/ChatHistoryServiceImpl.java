package com.zerok.aiservice.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.zerok.aiservice.dto.ConversationVO;
import com.zerok.aiservice.dto.MessageVO;
import com.zerok.aiservice.dto.PageResult;
import com.zerok.aiservice.entity.AiConversation;
import com.zerok.aiservice.entity.AiGeneration;
import com.zerok.aiservice.entity.AiMessage;
import com.zerok.aiservice.mapper.AiConversationMapper;
import com.zerok.aiservice.mapper.AiGenerationMapper;
import com.zerok.aiservice.mapper.AiMessageMapper;
import com.zerok.aiservice.mapper.ChatHistoryMapper;
import com.zerok.aiservice.service.ChatHistoryService;
import com.zerok.aiservice.service.TurnContext;
import com.zerok.aiservice.util.BusinessException;
import com.zerok.aiservice.util.CursorUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 对话历史持久化实现。
 *
 * <p>写库顺序严格遵守外键：先 user 消息，再 assistant 消息，最后 generation。</p>
 */
@Slf4j
@Service
public class ChatHistoryServiceImpl implements ChatHistoryService {

    private static final int DEFAULT_LIMIT = 20;
    private static final int MAX_LIMIT = 50;
    private static final int MAX_TITLE_LENGTH = 30;
    private static final int MAX_ERROR_MESSAGE_LENGTH = 1000;

    private static final String ROLE_USER = "user";
    private static final String ROLE_ASSISTANT = "assistant";

    private static final String STATUS_COMPLETED = "completed";
    private static final String STATUS_FAILED = "failed";
    private static final String STATUS_CANCELLED = "cancelled";

    private final AiConversationMapper conversationMapper;
    private final AiMessageMapper messageMapper;
    private final AiGenerationMapper generationMapper;
    private final ChatHistoryMapper chatHistoryMapper;
    private final String provider;
    private final String model;

    public ChatHistoryServiceImpl(AiConversationMapper conversationMapper,
                                  AiMessageMapper messageMapper,
                                  AiGenerationMapper generationMapper,
                                  ChatHistoryMapper chatHistoryMapper,
                                  @Value("${assistant.provider:openai-compatible}") String provider,
                                  @Value("${spring.ai.openai.chat.options.model:}") String model) {
        this.conversationMapper = conversationMapper;
        this.messageMapper = messageMapper;
        this.generationMapper = generationMapper;
        this.chatHistoryMapper = chatHistoryMapper;
        this.provider = provider;
        this.model = model;
    }

    @Override
    public TurnContext startTurn(Long userId, String conversationId, String requestId, String firstMessage) {
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }
        String cid = normalizeConversationId(conversationId);
        AiConversation existing = conversationMapper.selectById(cid);
        if (existing != null && !userId.equals(existing.getUserId())) {
            // 浏览器复用了其他账号的旧会话 id（localStorage 未按用户隔离）：
            // 为当前用户新建会话，而不是直接 404 让整轮对话失败。
            cid = UUID.randomUUID().toString();
            existing = null;
        }
        if (existing == null) {
            AiConversation conversation = new AiConversation();
            conversation.setId(cid);
            conversation.setUserId(userId);
            conversation.setTitle(buildTitle(firstMessage));
            conversationMapper.insert(conversation);
        } else {
            // 每轮刷新活跃时间，供会话列表从新到旧排序；用 DB 时间与 created_at 同源。
            conversationMapper.update(null, new LambdaUpdateWrapper<AiConversation>()
                    .eq(AiConversation::getId, cid)
                    .setSql("updated_at = CURRENT_TIMESTAMP(3)"));
        }
        return new TurnContext(
                cid,
                UUID.randomUUID().toString(),
                UUID.randomUUID().toString(),
                UUID.randomUUID().toString(),
                normalizeRequestId(requestId),
                LocalDateTime.now(),
                System.currentTimeMillis());
    }

    @Override
    public void completeTurn(TurnContext context, String userMessage, String assistantContent,
                             long durationMs, Long firstTokenMs) {
        persistTurn(context, userMessage, assistantContent,
                STATUS_COMPLETED, STATUS_COMPLETED, null, null, durationMs, firstTokenMs);
    }

    @Override
    public void failTurn(TurnContext context, String userMessage, String partialAssistantContent,
                         String errorCode, String errorMessage, long durationMs) {
        persistTurn(context, userMessage, partialAssistantContent,
                STATUS_FAILED, STATUS_FAILED, errorCode, errorMessage, durationMs, null);
    }

    @Override
    public void cancelTurn(TurnContext context, String userMessage, String partialAssistantContent, long durationMs) {
        persistTurn(context, userMessage, partialAssistantContent,
                STATUS_CANCELLED, STATUS_CANCELLED, "STREAM_CANCELLED", "对话被中断", durationMs, null);
    }

    private void persistTurn(TurnContext context, String userMessage, String assistantContent,
                             String assistantStatus, String generationStatus,
                             String errorCode, String errorMessage,
                             long durationMs, Long firstTokenMs) {
        try {
            AiMessage userRow = new AiMessage();
            userRow.setId(context.userMessageId());
            userRow.setConversationId(context.conversationId());
            userRow.setRole(ROLE_USER);
            userRow.setContent(userMessage);
            userRow.setStatus(STATUS_COMPLETED);
            messageMapper.insert(userRow);

            AiMessage assistantRow = new AiMessage();
            assistantRow.setId(context.assistantMessageId());
            assistantRow.setConversationId(context.conversationId());
            assistantRow.setRole(ROLE_ASSISTANT);
            assistantRow.setContent(assistantContent == null ? "" : assistantContent);
            assistantRow.setStatus(assistantStatus);
            messageMapper.insert(assistantRow);

            AiGeneration generation = new AiGeneration();
            generation.setId(context.generationId());
            generation.setConversationId(context.conversationId());
            generation.setRequestId(context.requestId());
            generation.setUserMessageId(context.userMessageId());
            generation.setAssistantMessageId(context.assistantMessageId());
            generation.setProvider(provider);
            generation.setModel(model);
            generation.setStatus(generationStatus);
            generation.setStartedAt(context.startedAt());
            generation.setFinishedAt(LocalDateTime.now());
            generation.setDurationMs(durationMs);
            generation.setFirstTokenMs(firstTokenMs);
            generation.setErrorCode(errorCode);
            generation.setErrorMessage(truncate(errorMessage, MAX_ERROR_MESSAGE_LENGTH));
            generationMapper.insert(generation);
        } catch (DuplicateKeyException e) {
            // 同一 (conversationId, requestId) 重复提交：幂等忽略，避免重复写消息。
            log.warn("重复的生成请求，已忽略: conversationId={}, requestId={}",
                    context.conversationId(), context.requestId());
        } catch (Exception e) {
            log.error("对话落库失败: conversationId={}, requestId={}",
                    context.conversationId(), context.requestId(), e);
        }
    }

    @Override
    public PageResult<ConversationVO> pageConversations(Long userId, int limit, String cursor) {
        int safeLimit = normalizeLimit(limit);
        CursorUtil.Cursor decoded = CursorUtil.decode(cursor);
        List<AiConversation> rows = chatHistoryMapper.pageConversations(
                userId,
                decoded == null ? null : decoded.time(),
                decoded == null ? null : decoded.id(),
                safeLimit + 1);

        boolean hasMore = rows.size() > safeLimit;
        if (hasMore) {
            rows = rows.subList(0, safeLimit);
        }
        List<ConversationVO> items = rows.stream().map(this::toConversationVO).toList();
        String nextCursor = hasMore && !rows.isEmpty()
                ? CursorUtil.encode(rows.get(rows.size() - 1).getUpdatedAt(), rows.get(rows.size() - 1).getId())
                : null;
        return new PageResult<>(items, nextCursor, hasMore);
    }

    @Override
    public PageResult<MessageVO> pageMessages(Long userId, String conversationId, int limit, String cursor) {
        AiConversation conversation = conversationId == null ? null : conversationMapper.selectById(conversationId);
        if (conversation == null) {
            // 会话尚未落库（首次打开抽屉），返回空页而不是报错。
            return new PageResult<>(List.of(), null, false);
        }
        if (!userId.equals(conversation.getUserId())) {
            // 他人才会话不返回内容，也不暴露是否存在。
            return new PageResult<>(List.of(), null, false);
        }
        int safeLimit = normalizeLimit(limit);
        CursorUtil.Cursor decoded = CursorUtil.decode(cursor);
        List<AiMessage> rows = chatHistoryMapper.pageMessages(
                conversationId,
                decoded == null ? null : decoded.time(),
                decoded == null ? null : decoded.id(),
                safeLimit + 1);

        boolean hasMore = rows.size() > safeLimit;
        if (hasMore) {
            rows = rows.subList(0, safeLimit);
        }
        List<MessageVO> items = rows.stream().map(this::toMessageVO).toList();
        String nextCursor = hasMore && !rows.isEmpty()
                ? CursorUtil.encode(rows.get(rows.size() - 1).getCreatedAt(), rows.get(rows.size() - 1).getId())
                : null;
        return new PageResult<>(items, nextCursor, hasMore);
    }

    private ConversationVO toConversationVO(AiConversation row) {
        return new ConversationVO(row.getId(), row.getTitle(), row.getCreatedAt(), row.getUpdatedAt());
    }

    private MessageVO toMessageVO(AiMessage row) {
        return new MessageVO(row.getId(), row.getConversationId(), row.getRole(),
                row.getContent(), row.getStatus(), row.getCreatedAt());
    }

    private int normalizeLimit(int limit) {
        if (limit <= 0) {
            return DEFAULT_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }

    private String normalizeConversationId(String conversationId) {
        if (conversationId == null || conversationId.isBlank()) {
            return UUID.randomUUID().toString();
        }
        String trimmed = conversationId.trim();
        if (trimmed.length() != 36) {
            // 非法 id 不再抛错（SSE 端点抛错会变成 406），直接视为新会话。
            return UUID.randomUUID().toString();
        }
        return trimmed;
    }

    private String normalizeRequestId(String requestId) {
        if (requestId == null || requestId.isBlank()) {
            return UUID.randomUUID().toString();
        }
        String trimmed = requestId.trim();
        return trimmed.length() > 36 ? trimmed.substring(0, 36) : trimmed;
    }

    private String buildTitle(String firstMessage) {
        if (firstMessage == null || firstMessage.isBlank()) {
            return "新对话";
        }
        String title = firstMessage.trim();
        return title.length() <= MAX_TITLE_LENGTH ? title : title.substring(0, MAX_TITLE_LENGTH) + "…";
    }

    private String truncate(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
package com.zerok.aiservice.service;

import com.zerok.aiservice.util.TransportErrorClassifier;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

/**
 * 小愿流式对话服务。
 *
 * <p>职责：通过 ChatClient 调用模型，并用 conversationId 绑定 ChatMemory，
 * 保持原有对话记忆逻辑不变；模型返回的 Markdown 原文以 Flux&lt;String&gt; 透传。</p>
 *
 * <p>传输控制标记：{@code [STREAM_INTERRUPT]} 与 {@code [ERROR]服务异常}
 * 只在本类的 onErrorResume 中产生，用于通知前端断流或服务异常；
 * 它们不是提示词的一部分，模型正常输出不会被清洗或改写。</p>
 *
 * <p>可重试的网络异常由 WebClientConfig 的传输层过滤器先重试一次；
 * 重试仍失败或流中途断开时，这里输出标记供前端决定是否重新生成。</p>
 */
@Slf4j
@Service
public class AssistantService {

    private static final String STREAM_INTERRUPT = "[STREAM_INTERRUPT]";
    private static final String STREAM_ERROR = "[ERROR]服务异常";

    private final ChatClient chatClient;

    public AssistantService(ChatClient chatClient) {
        this.chatClient = chatClient;
    }

    /**
     * 流式生成回答。
     *
     * <p>链路：prompt -> user -> advisors(ChatMemory.CONVERSATION_ID) -> stream -> map(content)。</p>
     *
     * @param message        用户本轮输入
     * @param conversationId 对话维度 id，用于复用 ChatMemory
     * @return Markdown 文本分片；异常时返回传输控制标记
     */
    public Flux<String> stream(String message, String conversationId) {
        return chatClient.prompt()
                .user(message)
                .advisors(advisor -> advisor.param(ChatMemory.CONVERSATION_ID, conversationId))
                .stream()
                .chatResponse()
                .map(response -> {
                    if (response == null
                            || response.getResult() == null
                            || response.getResult().getOutput() == null) {
                        return "";
                    }
                    String content = response.getResult().getOutput().getText();
                    return content == null ? "" : content;
                })
                .filter(content -> !content.isEmpty())
                .onErrorResume(error -> {
                    log.error("流式AI请求中断", error);
                    if (TransportErrorClassifier.isRetryable(error)) {
                        return Flux.just(STREAM_INTERRUPT);
                    }
                    return Flux.just(STREAM_ERROR);
                });
    }
}

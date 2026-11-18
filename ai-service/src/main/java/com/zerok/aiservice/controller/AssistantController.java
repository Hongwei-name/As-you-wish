package com.zerok.aiservice.controller;

import com.zerok.aiservice.dto.ChatRequest;
import com.zerok.aiservice.dto.ConversationVO;
import com.zerok.aiservice.dto.MessageVO;
import com.zerok.aiservice.dto.PageResult;
import com.zerok.aiservice.service.AssistantService;
import com.zerok.aiservice.service.ChatHistoryService;
import com.zerok.aiservice.service.TurnContext;
import com.zerok.aiservice.util.Result;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import reactor.core.Disposable;

import java.io.IOException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 小愿对话入口。
 *
 * <p>POST /assistant/chat 使用 fetch-SSE：请求体携带 message / conversationId / requestId，
 * 可带 Authorization；响应仍为 text/event-stream。</p>
 *
 * <p>事件协议保持不变：默认 message 事件为 Markdown 分片；
 * {@code [STREAM_INTERRUPT]} / {@code [ERROR]服务异常} 为后端控制标记；
 * done 表示正常结束；ping 每 3 秒一次用于前端重置空闲计时。</p>
 */
@Slf4j
@RestController
@RequestMapping("/assistant")
@RequiredArgsConstructor
public class AssistantController {

    private static final long SSE_TIMEOUT_MILLIS = 120_000L;
    private static final long HEARTBEAT_INTERVAL_SECONDS = 3L;
    private static final String STREAM_INTERRUPT = "[STREAM_INTERRUPT]";
    private static final String STREAM_ERROR = "[ERROR]服务异常";

    private static final ScheduledExecutorService HEARTBEAT_EXECUTOR =
            Executors.newSingleThreadScheduledExecutor(runnable -> {
                Thread thread = new Thread(runnable, "assistant-sse-heartbeat");
                thread.setDaemon(true);
                return thread;
            });

    private final AssistantService assistantService;
    private final ChatHistoryService chatHistoryService;

    @PostMapping(value = "/chat", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chat(@AuthenticationPrincipal Long userId, @Valid @RequestBody ChatRequest request) {
        String message = request.message().trim();
        TurnContext turn;
        try {
            turn = chatHistoryService.startTurn(userId, request.conversationId(), request.requestId(), message);
        } catch (Exception exception) {
            // SSE 端点的异常不能走 JSON 异常处理器（客户端 Accept 是 text/event-stream，会变成 406）。
            log.warn("开始对话失败: {}", exception.getMessage());
            SseEmitter failed = new SseEmitter(SSE_TIMEOUT_MILLIS);
            sendErrorAndComplete(failed);
            return failed;
        }

        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT_MILLIS);
        // 把最终使用的会话 id 告知前端：旧 id 属于其他账号时服务端会新建会话。
        sendConversationMeta(emitter, turn.conversationId());
        AtomicBoolean finished = new AtomicBoolean(false);
        StringBuilder accumulated = new StringBuilder();
        AtomicLong firstChunkAtMs = new AtomicLong(0L);

        ScheduledFuture<?> heartbeat = HEARTBEAT_EXECUTOR.scheduleAtFixedRate(() -> {
            if (finished.get()) {
                return;
            }
            try {
                emitter.send(SseEmitter.event().name("ping").data("ping"));
            } catch (IOException | IllegalStateException exception) {
                if (finished.compareAndSet(false, true)) {
                    emitter.completeWithError(exception);
                }
            }
        }, HEARTBEAT_INTERVAL_SECONDS, HEARTBEAT_INTERVAL_SECONDS, TimeUnit.SECONDS);

        Disposable subscription = assistantService.stream(message, turn.conversationId())
                .subscribe(
                        chunk -> {
                            if (finished.get()) {
                                return;
                            }
                            if (firstChunkAtMs.compareAndSet(0L, System.currentTimeMillis())) {
                                // 记录首个分片时间，用于 first_token_ms
                            }
                            accumulated.append(chunk);
                            try {
                                emitter.send(SseEmitter.event().data(chunk));
                            } catch (IOException | IllegalStateException exception) {
                                if (finished.compareAndSet(false, true)) {
                                    heartbeat.cancel(true);
                                    chatHistoryService.cancelTurn(turn, message, stripMarkers(accumulated.toString()),
                                            elapsed(turn));
                                    emitter.completeWithError(exception);
                                }
                            }
                        },
                        error -> {
                            if (finished.compareAndSet(false, true)) {
                                heartbeat.cancel(true);
                                chatHistoryService.failTurn(turn, message, stripMarkers(accumulated.toString()),
                                        "STREAM_ERROR", "模型流式请求失败", elapsed(turn));
                                emitter.completeWithError(error);
                            }
                        },
                        () -> {
                            if (finished.compareAndSet(false, true)) {
                                heartbeat.cancel(true);
                                String full = accumulated.toString();
                                long duration = elapsed(turn);
                                Long firstTokenMs = firstChunkAtMs.get() > 0
                                        ? firstChunkAtMs.get() - turn.startedAtEpochMs()
                                        : null;
                                if (full.contains(STREAM_INTERRUPT)) {
                                    chatHistoryService.cancelTurn(turn, message, stripMarkers(full), duration);
                                } else if (full.contains(STREAM_ERROR)) {
                                    chatHistoryService.failTurn(turn, message, stripMarkers(full),
                                            "STREAM_ERROR", "模型服务异常", duration);
                                } else {
                                    chatHistoryService.completeTurn(turn, message, full, duration, firstTokenMs);
                                }
                                try {
                                    emitter.send(SseEmitter.event().name("done").data("done"));
                                    emitter.complete();
                                } catch (IOException | IllegalStateException exception) {
                                    emitter.completeWithError(exception);
                                }
                            }
                        }
                );

        emitter.onCompletion(() -> {
            if (finished.compareAndSet(false, true)) {
                heartbeat.cancel(true);
                subscription.dispose();
                chatHistoryService.cancelTurn(turn, message, stripMarkers(accumulated.toString()), elapsed(turn));
            }
        });
        emitter.onTimeout(() -> {
            if (finished.compareAndSet(false, true)) {
                heartbeat.cancel(true);
                subscription.dispose();
                chatHistoryService.cancelTurn(turn, message, stripMarkers(accumulated.toString()), elapsed(turn));
            }
        });
        return emitter;
    }

    @GetMapping("/conversations")
    public Result<PageResult<ConversationVO>> conversations(@AuthenticationPrincipal Long userId,
                                                            @RequestParam(defaultValue = "20") int limit,
                                                            @RequestParam(required = false) String cursor) {
        return Result.success(chatHistoryService.pageConversations(userId, limit, cursor));
    }

    @GetMapping("/conversations/{conversationId}/messages")
    public Result<PageResult<MessageVO>> messages(@AuthenticationPrincipal Long userId,
                                                  @PathVariable String conversationId,
                                                  @RequestParam(defaultValue = "20") int limit,
                                                  @RequestParam(required = false) String cursor) {
        return Result.success(chatHistoryService.pageMessages(userId, conversationId, limit, cursor));
    }

    /**
     * 告知前端本轮实际使用的会话 id（可能因旧 id 属于其他账号而被服务端重建）。
     */
    private void sendConversationMeta(SseEmitter emitter, String conversationId) {
        try {
            emitter.send(SseEmitter.event().name("meta").data(conversationId));
        } catch (IOException | IllegalStateException exception) {
            log.debug("发送会话元信息失败: {}", exception.getMessage());
        }
    }

    private void sendErrorAndComplete(SseEmitter emitter) {
        try {
            emitter.send(SseEmitter.event().data(STREAM_ERROR));
            emitter.complete();
        } catch (IOException | IllegalStateException exception) {
            emitter.completeWithError(exception);
        }
    }

    private long elapsed(TurnContext turn) {
        return System.currentTimeMillis() - turn.startedAtEpochMs();
    }

    private String stripMarkers(String content) {
        return content.replace(STREAM_INTERRUPT, "").replace(STREAM_ERROR, "").trim();
    }
}
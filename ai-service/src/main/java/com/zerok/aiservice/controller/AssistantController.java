package com.zerok.aiservice.controller;

import com.zerok.aiservice.service.AssistantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import reactor.core.Disposable;

import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 小愿 SSE 对话入口。
 *
 * <p>使用 GET + EventSource，接收 message / conversationId；
 * 订阅 AssistantService.stream 返回的 Flux，并逐片写入 SseEmitter。</p>
 *
 * <p>事件协议：
 * <ul>
 *   <li>默认 message 事件：模型 Markdown 分片，原样透传；</li>
 *   <li>默认 message 事件：{@code [STREAM_INTERRUPT]} / {@code [ERROR]服务异常}
 *       为后端控制标记，由 AssistantService 产生；</li>
 *   <li>命名 done 事件：正常结束，前端收到后主动关闭 EventSource；</li>
 *   <li>命名 ping 事件：每 3 秒一次，仅用于让前端重置 5 秒空闲计时，
 *       避免上游 TLS 握手/重试期间 SSE 被前端误判断流。</li>
 * </ul>
 *
 * <p>连接超时 120 秒，与 WebClient 的 responseTimeout 对齐。</p>
 */
@RestController
@RequestMapping("/assistant")
@RequiredArgsConstructor
public class AssistantController {

    private static final long SSE_TIMEOUT_MILLIS = 120_000L;
    private static final long HEARTBEAT_INTERVAL_SECONDS = 3L;
    private static final String STREAM_ERROR = "[ERROR]服务异常";

    private static final ScheduledExecutorService HEARTBEAT_EXECUTOR =
            Executors.newSingleThreadScheduledExecutor(runnable -> {
                Thread thread = new Thread(runnable, "assistant-sse-heartbeat");
                thread.setDaemon(true);
                return thread;
            });

    private final AssistantService assistantService;

    @GetMapping(value = "/chat", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chat(@RequestParam("message") String message,
                           @RequestParam(value = "conversationId", required = false) String conversationId) {
        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT_MILLIS);

        String normalizedMessage = message == null ? "" : message.trim();
        if (normalizedMessage.isEmpty()) {
            sendErrorAndComplete(emitter);
            return emitter;
        }

        String normalizedConversationId = conversationId == null || conversationId.isBlank()
                ? UUID.randomUUID().toString()
                : conversationId;
        AtomicBoolean finished = new AtomicBoolean(false);

        // 连接建立后立即开始心跳；上游 TLS 握手/重试可能超过 5 秒，心跳可避免前端提前关闭。
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

        Disposable subscription = assistantService.stream(normalizedMessage, normalizedConversationId)
                .subscribe(
                        chunk -> {
                            if (finished.get()) {
                                return;
                            }
                            try {
                                emitter.send(SseEmitter.event().data(chunk));
                            } catch (IOException | IllegalStateException exception) {
                                if (finished.compareAndSet(false, true)) {
                                    emitter.completeWithError(exception);
                                }
                            }
                        },
                        error -> {
                            if (finished.compareAndSet(false, true)) {
                                heartbeat.cancel(true);
                                emitter.completeWithError(error);
                            }
                        },
                        () -> {
                            if (finished.compareAndSet(false, true)) {
                                heartbeat.cancel(true);
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
            finished.set(true);
            heartbeat.cancel(true);
            subscription.dispose();
        });
        emitter.onTimeout(() -> {
            finished.set(true);
            heartbeat.cancel(true);
            subscription.dispose();
        });
        return emitter;
    }

    private void sendErrorAndComplete(SseEmitter emitter) {
        try {
            emitter.send(SseEmitter.event().data(STREAM_ERROR));
            emitter.complete();
        } catch (IOException | IllegalStateException exception) {
            emitter.completeWithError(exception);
        }
    }
}

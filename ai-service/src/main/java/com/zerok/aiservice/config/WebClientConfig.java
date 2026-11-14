package com.zerok.aiservice.config;

import com.zerok.aiservice.util.TransportErrorClassifier;
import io.netty.channel.ChannelOption;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.HttpProtocol;
import reactor.netty.http.client.HttpClient;
import reactor.netty.transport.ProxyProvider;
import reactor.util.retry.Retry;

import javax.net.ssl.SSLException;
import java.time.Duration;

/**
 * 小愿上游模型调用的 WebClient 配置。
 *
 * <p>针对 SslHandshakeTimeoutException 的三层保护：</p>
 * <ol>
 *   <li>把 Reactor Netty 默认 10 秒的 TLS 握手超时提高到可配置值，并延长连接/响应超时；</li>
 *   <li>在 WebClient 传输层对连接/TLS 握手/读取超时做一次有上限的重试
 *       （重试同一个 HTTP 请求，不会再次触发 ChatMemory，避免重复写入记忆）；</li>
 *   <li>支持可选 HTTP 代理，便于在直连 Cloudflare 不稳定时切换稳定出口。</li>
 * </ol>
 *
 * <p>注意：responseTimeout 只覆盖收到响应后的读取阶段，不覆盖 TLS 握手；
 * 握手超时由 SslHandler 独立控制，所以必须显式设置 handshakeTimeout。</p>
 */
@Slf4j
@Configuration
public class WebClientConfig {

    @Value("${assistant.http.connect-timeout:15s}")
    private Duration connectTimeout;

    @Value("${assistant.http.handshake-timeout:20s}")
    private Duration handshakeTimeout;

    @Value("${assistant.http.response-timeout:120s}")
    private Duration responseTimeout;

    @Value("${assistant.http.proxy-host:}")
    private String proxyHost;

    @Value("${assistant.http.proxy-port:0}")
    private int proxyPort;

    @Bean
    public WebClient.Builder webClientBuilder() {
        HttpClient httpClient = buildHttpClient();
        return WebClient.builder()
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .filter(retryOnTransportFailure());
    }

    @Bean
    public WebClient webClient(WebClient.Builder webClientBuilder) {
        return webClientBuilder.build();
    }

    private HttpClient buildHttpClient() {
        SslContext sslContext;
        try {
            sslContext = SslContextBuilder.forClient().build();
        } catch (SSLException exception) {
            throw new IllegalStateException("初始化 AI 上游 TLS 上下文失败", exception);
        }

        HttpClient client = HttpClient.create()
                // 强制 HTTP/1.1，规避部分网关在 HTTP/2 流式场景下的 EOF 问题。
                .protocol(HttpProtocol.HTTP11)
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, (int) connectTimeout.toMillis())
                // 流式响应读取上限；与 SseEmitter 的 120 秒对齐。
                .responseTimeout(responseTimeout)
                // 关键：TLS 握手超时独立于 responseTimeout，默认仅 10 秒。
                .secure(spec -> spec
                        .sslContext(sslContext)
                        .handshakeTimeout(handshakeTimeout));

        if (proxyHost != null && !proxyHost.isBlank() && proxyPort > 0) {
            client = client.proxy(proxy -> proxy
                    .type(ProxyProvider.Proxy.HTTP)
                    .host(proxyHost)
                    .port(proxyPort));
            log.info("AI 上游请求使用 HTTP 代理 {}:{}", proxyHost, proxyPort);
        }
        return client;
    }

    /**
     * 传输层重试：只重试一次，且只针对连接/TLS/读取类临时故障。
     * 重试发生在拿到响应头之前，因此不会重复产生模型分片。
     */
    private ExchangeFilterFunction retryOnTransportFailure() {
        return (request, next) -> next.exchange(request)
                .retryWhen(Retry.backoff(1, Duration.ofMillis(800))
                        .maxBackoff(Duration.ofSeconds(2))
                        .jitter(0.2)
                        .filter(TransportErrorClassifier::isRetryable)
                        .doBeforeRetry(signal -> log.warn(
                                "AI 上游连接失败，准备重试一次: {}",
                                signal.failure().toString())));
    }
}

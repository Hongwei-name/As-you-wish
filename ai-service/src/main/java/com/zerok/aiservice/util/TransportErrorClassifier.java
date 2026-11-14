package com.zerok.aiservice.util;

import io.netty.channel.ConnectTimeoutException;
import io.netty.handler.ssl.SslHandshakeTimeoutException;
import io.netty.handler.timeout.ReadTimeoutException;
import reactor.netty.http.client.PrematureCloseException;

import java.io.EOFException;
import java.net.ConnectException;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;

/**
 * AI 上游传输层异常分类器。
 *
 * <p>只把连接建立、TLS 握手、读取超时、连接重置等临时网络故障判定为可重试；
 * 证书错误、鉴权失败、4xx 业务错误不在此列，避免无效重试和重复计费。</p>
 */
public final class TransportErrorClassifier {

    private TransportErrorClassifier() {
    }

    public static boolean isRetryable(Throwable error) {
        if (error == null) {
            return false;
        }
        Throwable cause = error;
        while (cause.getCause() != null && cause.getCause() != cause) {
            cause = cause.getCause();
        }
        return cause instanceof SslHandshakeTimeoutException
                || cause instanceof ConnectTimeoutException
                || cause instanceof ReadTimeoutException
                || cause instanceof SocketTimeoutException
                || cause instanceof ConnectException
                || cause instanceof SocketException
                || cause instanceof EOFException
                || cause instanceof UnknownHostException
                || cause instanceof PrematureCloseException;
    }
}

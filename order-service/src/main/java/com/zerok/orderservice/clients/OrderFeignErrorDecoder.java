package com.zerok.orderservice.clients;

import com.zerok.orderservice.service.DownstreamServiceException;
import feign.Response;
import feign.codec.ErrorDecoder;
import org.springframework.http.HttpStatus;

/**
 * Maps remote HTTP failures to bounded order-service errors without logging response bodies.
 */
public class OrderFeignErrorDecoder implements ErrorDecoder {

    @Override
    public Exception decode(String methodKey, Response response) {
        if (response.status() == HttpStatus.CONFLICT.value()) {
            return new DownstreamServiceException(HttpStatus.CONFLICT,
                    "The downstream service rejected the requested state transition");
        }
        if (response.status() >= 500) {
            return new DownstreamServiceException(HttpStatus.SERVICE_UNAVAILABLE,
                    "A downstream service is temporarily unavailable");
        }
        return new DownstreamServiceException(HttpStatus.BAD_GATEWAY,
                "A downstream service rejected the request");
    }
}

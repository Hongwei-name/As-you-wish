package com.asyouwish.auth.util;

import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * IP 工具类
 */
public class IpUtil {

    /**
     * 获取当前请求的真实 IP 地址 (基于 Spring 的 RequestContextHolder)
     */
    public static String getClientIp() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return "unknown";
        }
        return getClientIp(attributes.getRequest());
    }

    /**
     * 从 HttpServletRequest 中获取真实 IP 地址
     */
    public static String getClientIp(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }

        // 如果是多级代理，X-Forwarded-For 会有多个 IP，取第一个非 unknown 的
        if (ip != null && ip.contains(",")) {
            String[] ips = ip.split(",");
            for (String strIp : ips) {
                if (!"unknown".equalsIgnoreCase(strIp.trim())) {
                    ip = strIp.trim();
                    break;
                }
            }
        }

        // 本机访问时，IPv6 地址转为 IPv4 方便查看
        return "0:0:0:0:0:0:0:1".equals(ip) ? "127.0.0.1" : ip;
    }
}
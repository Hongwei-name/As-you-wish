package com.shopping.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shopping.common.Result;
import com.shopping.common.ResultCode;
import com.shopping.config.JwtConfig;
import com.shopping.utils.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 拦截器
 * 验证请求头中的 Token
 * 
 * @author 陈洪伟
 */
@Slf4j
@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private JwtConfig jwtConfig;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 请求预处理
     * 验证请求头中的 Token 是否有效
     * 
     * @param request HTTP 请求
     * @param response HTTP 响应
     * @param handler 处理器
     * @return 是否继续执行
     * @throws Exception 异常
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equals(request.getMethod())) {
            return true;
        }

        String token = request.getHeader(jwtConfig.getHeader());
        
        if (!StringUtils.hasText(token)) {
            log.warn("请求缺少 Token，URI: {}", request.getRequestURI());
            writeErrorResponse(response, ResultCode.TOKEN_INVALID);
            return false;
        }

        if (token.startsWith(jwtConfig.getPrefix())) {
            token = token.substring(jwtConfig.getPrefix().length()).trim();
        }

        if (!jwtUtil.validateToken(token)) {
            log.warn("Token 无效或已过期，URI: {}", request.getRequestURI());
            writeErrorResponse(response, ResultCode.TOKEN_INVALID);
            return false;
        }

        Long userId = jwtUtil.getUserIdFromToken(token);
        String username = jwtUtil.getUsernameFromToken(token);
        Integer role = jwtUtil.getRoleFromToken(token);
        
        request.setAttribute("userId", userId);
        request.setAttribute("username", username);
        request.setAttribute("role", role);
        
        log.debug("Token 验证成功，用户ID: {}, 用户名: {}", userId, username);
        return true;
    }

    /**
     * 写入错误响应
     * 
     * @param response HTTP 响应
     * @param resultCode 错误状态码
     * @throws Exception 异常
     */
    private void writeErrorResponse(HttpServletResponse response, ResultCode resultCode) throws Exception {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        Result<Void> result = Result.error(resultCode);
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }

}

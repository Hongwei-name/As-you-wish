package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.CsSession;
import com.shopping.entity.CsMessage;
import java.util.List;

/**
 * 客服会话Service接口
 */
public interface CsSessionService extends IService<CsSession> {
    /**
     * 获取用户的会话列表
     * @param userId 用户ID
     * @return 会话列表
     */
    List<CsSession> getUserSessions(Long userId);
    
    /**
     * 获取用户未结束的会话
     * @param userId 用户ID
     * @return 未结束的会话
     */
    CsSession getUnfinishedSession(Long userId);
    
    /**
     * 创建会话
     * @param userId 用户ID
     * @return 创建的会话
     */
    CsSession createSession(Long userId);
    
    /**
     * 结束会话
     * @param sessionId 会话ID
     * @return 是否结束成功
     */
    boolean endSession(Long sessionId);
    
    /**
     * 发送消息
     * @param sessionId 会话ID
     * @param senderType 发送者类型：0-用户，1-客服
     * @param content 消息内容
     * @return 消息ID
     */
    Long sendMessage(Long sessionId, Integer senderType, String content);
    
    /**
     * 获取会话消息
     * @param sessionId 会话ID
     * @param limit 限制数量
     * @return 消息列表
     */
    List<CsMessage> getSessionMessages(Long sessionId, Integer limit);
}
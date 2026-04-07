package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.CsSessionMapper;
import com.shopping.mapper.CsMessageMapper;
import com.shopping.entity.CsSession;
import com.shopping.entity.CsMessage;
import com.shopping.service.CsSessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 客服会话Service实现类
 */
@Service
public class CsSessionServiceImpl extends ServiceImpl<CsSessionMapper, CsSession> implements CsSessionService {
    
    @Autowired
    private CsSessionMapper csSessionMapper;
    
    @Autowired
    private CsMessageMapper csMessageMapper;
    
    @Override
    public List<CsSession> getUserSessions(Long userId) {
        return csSessionMapper.selectByUserId(userId);
    }
    
    @Override
    public CsSession getUnfinishedSession(Long userId) {
        return csSessionMapper.selectUnfinishedByUserId(userId);
    }
    
    @Override
    public CsSession createSession(Long userId) {
        // 检查是否已有未结束的会话
        CsSession existingSession = csSessionMapper.selectUnfinishedByUserId(userId);
        if (existingSession != null) {
            return existingSession;
        }
        
        // 创建新会话
        CsSession session = new CsSession();
        session.setUserId(userId);
        session.setStatus(0); // 待处理
        session.setStartTime(LocalDateTime.now());
        save(session);
        
        return session;
    }
    
    @Override
    public boolean endSession(Long sessionId) {
        CsSession session = getById(sessionId);
        if (session == null) {
            return false;
        }
        
        session.setStatus(2); // 已结束
        session.setEndTime(LocalDateTime.now());
        return updateById(session);
    }
    
    @Override
    @Transactional
    public Long sendMessage(Long sessionId, Integer senderType, String content) {
        // 检查会话是否存在
        CsSession session = getById(sessionId);
        if (session == null) {
            return null;
        }
        
        // 如果会话状态是待处理，更新为处理中
        if (session.getStatus() == 0) {
            session.setStatus(1);
            updateById(session);
        }
        
        // 创建消息
        CsMessage message = new CsMessage();
        message.setSessionId(sessionId);
        message.setSenderType(senderType);
        message.setContent(content);
        message.setCreatedAt(LocalDateTime.now());
        csMessageMapper.insert(message);
        
        return message.getId();
    }
    
    @Override
    public List<CsMessage> getSessionMessages(Long sessionId, Integer limit) {
        return csMessageMapper.selectBySessionId(sessionId, limit);
    }
}
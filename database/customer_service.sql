-- 创建客服会话表
CREATE TABLE IF NOT EXISTS t_cs_session (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    status INT NOT NULL DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-已结束',
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    end_time TIMESTAMP NULL COMMENT '结束时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) COMMENT '客服会话表';

-- 创建客服消息表
CREATE TABLE IF NOT EXISTS t_cs_message (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    session_id BIGINT NOT NULL COMMENT '会话ID',
    sender_type INT NOT NULL COMMENT '发送者类型：0-用户，1-客服',
    content TEXT NOT NULL COMMENT '消息内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (session_id) REFERENCES t_cs_session(id) ON DELETE CASCADE
) COMMENT '客服消息表';

-- 创建索引
CREATE INDEX idx_cs_session_user ON t_cs_session(user_id);
CREATE INDEX idx_cs_session_status ON t_cs_session(status);
CREATE INDEX idx_cs_message_session ON t_cs_message(session_id);
CREATE INDEX idx_cs_message_created ON t_cs_message(created_at);
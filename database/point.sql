-- 创建积分记录表
CREATE TABLE IF NOT EXISTS t_point_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type INT NOT NULL COMMENT '类型：1-购物获得，2-使用积分，3-其他',
    amount INT NOT NULL COMMENT '积分数量：正数为增加，负数为减少',
    balance INT NOT NULL COMMENT '操作后余额',
    related_id BIGINT COMMENT '相关ID：如订单ID',
    description VARCHAR(255) COMMENT '描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) COMMENT '积分记录表';

-- 创建用户积分汇总表
CREATE TABLE IF NOT EXISTS t_user_point (
    user_id BIGINT PRIMARY KEY COMMENT '用户ID',
    balance INT NOT NULL DEFAULT 0 COMMENT '积分余额',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) COMMENT '用户积分汇总表';

-- 创建索引
CREATE INDEX idx_point_user ON t_point_record(user_id);
CREATE INDEX idx_point_type ON t_point_record(type);
CREATE INDEX idx_point_created ON t_point_record(created_at);
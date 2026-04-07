-- 创建优惠券表
CREATE TABLE IF NOT EXISTS t_coupon (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '优惠券ID',
    name VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    type INT NOT NULL COMMENT '优惠券类型：1-满减券，2-折扣券',
    value DECIMAL(10,2) NOT NULL COMMENT '优惠券价值：满减券为金额，折扣券为折扣率（如0.8表示8折）',
    min_amount DECIMAL(10,2) NOT NULL COMMENT '最低使用金额',
    start_time TIMESTAMP NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP NOT NULL COMMENT '结束时间',
    total_quantity INT NOT NULL COMMENT '总数量',
    remaining_quantity INT NOT NULL COMMENT '剩余数量',
    status INT NOT NULL DEFAULT 1 COMMENT '状态：1-有效，0-无效',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '优惠券表';

-- 创建优惠券领取记录表
CREATE TABLE IF NOT EXISTS t_coupon_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    status INT NOT NULL DEFAULT 1 COMMENT '状态：1-未使用，2-已使用，3-已过期',
    receive_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    use_time TIMESTAMP NULL COMMENT '使用时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES t_coupon(id) ON DELETE CASCADE
) COMMENT '优惠券领取记录表';

-- 创建索引
CREATE INDEX idx_coupon_type ON t_coupon(type);
CREATE INDEX idx_coupon_status ON t_coupon(status);
CREATE INDEX idx_coupon_user ON t_coupon_user(user_id);
CREATE INDEX idx_coupon_coupon ON t_coupon_user(coupon_id);
CREATE INDEX idx_coupon_user_status ON t_coupon_user(status);
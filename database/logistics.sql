-- 创建物流信息表
CREATE TABLE IF NOT EXISTS t_logistics (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物流ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    logistics_company VARCHAR(100) COMMENT '物流公司',
    logistics_no VARCHAR(100) COMMENT '物流单号',
    status INT NOT NULL DEFAULT 0 COMMENT '物流状态：0-待发货，1-已发货，2-运输中，3-已送达',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (order_id) REFERENCES t_order(id) ON DELETE CASCADE
) COMMENT '物流信息表';

-- 创建物流轨迹表
CREATE TABLE IF NOT EXISTS t_logistics_track (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '轨迹ID',
    logistics_id BIGINT NOT NULL COMMENT '物流ID',
    status INT NOT NULL COMMENT '状态：0-待发货，1-已发货，2-运输中，3-已送达',
    description VARCHAR(255) COMMENT '描述',
    location VARCHAR(100) COMMENT '地点',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (logistics_id) REFERENCES t_logistics(id) ON DELETE CASCADE
) COMMENT '物流轨迹表';

-- 创建索引
CREATE INDEX idx_logistics_order ON t_logistics(order_id);
CREATE INDEX idx_logistics_status ON t_logistics(status);
CREATE INDEX idx_logistics_track_logistics ON t_logistics_track(logistics_id);
CREATE INDEX idx_logistics_track_created ON t_logistics_track(created_at);
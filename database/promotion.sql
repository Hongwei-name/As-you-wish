-- 创建促销活动表
CREATE TABLE IF NOT EXISTS t_promotion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '促销活动ID',
    name VARCHAR(100) NOT NULL COMMENT '活动名称',
    type INT NOT NULL COMMENT '活动类型：1-限时折扣，2-满减活动，3-秒杀活动',
    description TEXT COMMENT '活动描述',
    start_time TIMESTAMP NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP NOT NULL COMMENT '结束时间',
    status INT NOT NULL DEFAULT 1 COMMENT '状态：1-进行中，0-已结束',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '促销活动表';

-- 创建促销活动商品表
CREATE TABLE IF NOT EXISTS t_promotion_product (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    promotion_id BIGINT NOT NULL COMMENT '促销活动ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    discount DECIMAL(10,2) NOT NULL COMMENT '折扣率（如0.8表示8折）',
    price DECIMAL(10,2) NOT NULL COMMENT '促销价格',
    stock INT NOT NULL COMMENT '促销库存',
    FOREIGN KEY (promotion_id) REFERENCES t_promotion(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE CASCADE
) COMMENT '促销活动商品表';

-- 创建索引
CREATE INDEX idx_promotion_type ON t_promotion(type);
CREATE INDEX idx_promotion_status ON t_promotion(status);
CREATE INDEX idx_promotion_product_promotion ON t_promotion_product(promotion_id);
CREATE INDEX idx_promotion_product_product ON t_promotion_product(product_id);
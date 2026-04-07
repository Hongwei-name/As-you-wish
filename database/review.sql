-- 创建商品评价表
CREATE TABLE IF NOT EXISTS t_review (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    rating INT NOT NULL COMMENT '评分（1-5星）',
    content TEXT COMMENT '评价内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
) COMMENT '商品评价表';

-- 创建评价索引
CREATE INDEX idx_product_id ON t_review(product_id);
CREATE INDEX idx_user_id ON t_review(user_id);
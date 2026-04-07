-- 创建商品收藏表
CREATE TABLE IF NOT EXISTS t_favorite (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_product (user_id, product_id) COMMENT '用户对商品的收藏唯一'
) COMMENT '商品收藏表';

-- 创建收藏索引
CREATE INDEX idx_user_id ON t_favorite(user_id);
CREATE INDEX idx_product_id ON t_favorite(product_id);
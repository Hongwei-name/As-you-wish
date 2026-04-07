-- 创建浏览历史表
CREATE TABLE IF NOT EXISTS t_browse_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '浏览记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    browse_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE CASCADE
) COMMENT '浏览历史表';

-- 创建浏览历史索引
CREATE INDEX idx_user_id ON t_browse_history(user_id);
CREATE INDEX idx_product_id ON t_browse_history(product_id);
CREATE INDEX idx_browse_time ON t_browse_history(browse_time);
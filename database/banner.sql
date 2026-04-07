-- 选择数据库
USE shopping_db;

-- 创建轮播图表
CREATE TABLE IF NOT EXISTS t_banner (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL COMMENT '轮播图标题',
    description VARCHAR(255) COMMENT '轮播图描述',
    image VARCHAR(500) NOT NULL COMMENT '轮播图图片URL',
    link VARCHAR(255) COMMENT '跳转链接',
    sort INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '轮播图表';

-- 插入测试数据
INSERT INTO t_banner (title, description, image, link, sort, status) VALUES
('春季新品上市', '限时8折，全场满199减20', 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=1200&h=400&fit=crop', '/product/list', 1, 1),
('数码产品特惠', '新品手机，下单送配件', 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=1200&h=400&fit=crop', '/product/list?categoryId=1', 2, 1),
('美食盛宴', '精选美食，满99减10', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&h=400&fit=crop', '/product/list?categoryId=3', 3, 1);

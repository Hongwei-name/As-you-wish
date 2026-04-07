-- =============================================
-- 项目名称：如你所愿电商平台
-- 文件名称：init.sql
-- 功能描述：数据库初始化脚本
-- 作者：陈洪伟
-- 邮箱：3485581538@qq.com
-- 创建时间：2026-04-03
-- =============================================

-- 创建数据库
DROP DATABASE IF EXISTS shopping_db;
CREATE DATABASE shopping_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE shopping_db;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 用户表
-- =============================================
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码',
    email VARCHAR(100) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    avatar VARCHAR(255) COMMENT '头像URL',
    nickname VARCHAR(50) COMMENT '昵称',
    gender TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
    birthday DATE COMMENT '生日',
    role TINYINT DEFAULT 0 COMMENT '角色：0-普通用户，1-管理员',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_phone (phone),
    KEY idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =============================================
-- 商品分类表
-- =============================================
DROP TABLE IF EXISTS t_category;
CREATE TABLE t_category (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    parent_id BIGINT DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
    sort INT DEFAULT 0 COMMENT '排序序号',
    icon VARCHAR(255) COMMENT '分类图标',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id),
    KEY idx_sort (sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- =============================================
-- 商品表
-- =============================================
DROP TABLE IF EXISTS t_product;
CREATE TABLE t_product (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '商品ID',
    name VARCHAR(100) NOT NULL COMMENT '商品名称',
    category_id BIGINT NOT NULL COMMENT '分类ID',
    price DECIMAL(10, 2) NOT NULL COMMENT '销售价格',
    original_price DECIMAL(10, 2) COMMENT '原价',
    stock INT DEFAULT 0 COMMENT '库存数量',
    image VARCHAR(255) COMMENT '主图URL',
    images TEXT COMMENT '商品图片列表，JSON格式',
    description VARCHAR(500) COMMENT '商品简介',
    detail TEXT COMMENT '商品详情',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    sales INT DEFAULT 0 COMMENT '销量',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_category_id (category_id),
    KEY idx_status (status),
    KEY idx_sales (sales),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES t_category(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- =============================================
-- 收货地址表
-- =============================================
DROP TABLE IF EXISTS t_address;
CREATE TABLE t_address (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '地址ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    receiver VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    phone VARCHAR(20) NOT NULL COMMENT '联系电话',
    province VARCHAR(50) NOT NULL COMMENT '省份',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    district VARCHAR(50) NOT NULL COMMENT '区/县',
    detail VARCHAR(200) NOT NULL COMMENT '详细地址',
    is_default TINYINT DEFAULT 0 COMMENT '是否默认：0-否，1-是',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_user_id (user_id),
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- =============================================
-- 购物车表
-- =============================================
DROP TABLE IF EXISTS t_cart;
CREATE TABLE t_cart (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '购物车ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    quantity INT DEFAULT 1 COMMENT '商品数量',
    selected TINYINT DEFAULT 1 COMMENT '是否选中：0-否，1-是',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_product (user_id, product_id),
    KEY idx_user_id (user_id),
    KEY idx_product_id (product_id),
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- =============================================
-- 订单表
-- =============================================
DROP TABLE IF EXISTS t_order;
CREATE TABLE t_order (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    order_no VARCHAR(50) NOT NULL COMMENT '订单编号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    address_id BIGINT NOT NULL COMMENT '收货地址ID',
    total_amount DECIMAL(10, 2) NOT NULL COMMENT '订单总金额',
    pay_amount DECIMAL(10, 2) NOT NULL COMMENT '实付金额',
    freight_amount DECIMAL(10, 2) DEFAULT 0 COMMENT '运费金额',
    status TINYINT DEFAULT 0 COMMENT '订单状态：0-待支付，1-已支付，2-已发货，3-已完成，4-已取消，5-已退款',
    payment_time DATETIME COMMENT '支付时间',
    delivery_time DATETIME COMMENT '发货时间',
    receive_time DATETIME COMMENT '收货时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_order_no (order_no),
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at),
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES t_address(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- =============================================
-- 订单项表
-- =============================================
DROP TABLE IF EXISTS t_order_item;
CREATE TABLE t_order_item (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单项ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(100) NOT NULL COMMENT '商品名称',
    product_image VARCHAR(255) COMMENT '商品图片',
    price DECIMAL(10, 2) NOT NULL COMMENT '商品单价',
    quantity INT NOT NULL COMMENT '购买数量',
    total_amount DECIMAL(10, 2) NOT NULL COMMENT '小计金额',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    KEY idx_order_id (order_id),
    KEY idx_product_id (product_id),
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES t_order(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES t_product(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单项表';

-- =============================================
-- 支付记录表
-- =============================================
DROP TABLE IF EXISTS t_payment;
CREATE TABLE t_payment (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '支付记录ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    payment_no VARCHAR(50) NOT NULL COMMENT '支付流水号',
    amount DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    payment_type TINYINT DEFAULT 1 COMMENT '支付方式：1-支付宝，2-微信，3-银行卡',
    status TINYINT DEFAULT 0 COMMENT '支付状态：0-待支付，1-支付成功，2-支付失败',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_payment_no (payment_no),
    KEY idx_order_id (order_id),
    KEY idx_status (status),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES t_order(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- =============================================
-- 插入测试数据
-- =============================================

-- 插入测试用户
INSERT INTO t_user (username, password, email, phone, avatar, nickname, gender, birthday, role) VALUES
('chenhongwei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '3485581538@qq.com', '18929749359', 'https://i.cetsteam.com/imgs/2026/04/01/f37915722ac27d20.jpg', '陈洪伟', 1, '2000-01-01', 0),
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'admin@example.com', '13800138000', 'https://i.cetsteam.com/imgs/2026/04/01/f37915722ac27d20.jpg', '管理员', 0, NULL, 1);

-- 插入商品分类
INSERT INTO t_category (name, parent_id, sort, icon) VALUES
('数码电子', 0, 1, 'https://example.com/icons/digital.png'),
('服装鞋帽', 0, 2, 'https://example.com/icons/clothing.png'),
('食品饮料', 0, 3, 'https://example.com/icons/food.png'),
('手机通讯', 1, 1, 'https://example.com/icons/phone.png'),
('电脑办公', 1, 2, 'https://example.com/icons/computer.png'),
('男装', 2, 1, 'https://example.com/icons/men.png'),
('女装', 2, 2, 'https://example.com/icons/women.png');

-- 插入商品数据
INSERT INTO t_product (name, category_id, price, original_price, stock, image, description, detail, status, sales) VALUES
-- 数码电子类商品
('iPhone 15 Pro Max 256GB', 4, 9999.00, 10999.00, 100, 'https://example.com/products/iphone15.jpg', '苹果最新旗舰手机，A17 Pro芯片，钛金属设计', '<p>iPhone 15 Pro Max 采用钛金属设计，搭载 A17 Pro 芯片，配备 4800 万像素主摄，支持 5 倍光学变焦。</p>', 1, 1500),
('华为 Mate 60 Pro 256GB', 4, 6999.00, 7999.00, 150, 'https://example.com/products/mate60.jpg', '华为旗舰手机，麒麟9000S芯片，卫星通信', '<p>华为 Mate 60 Pro 搭载麒麟 9000S 芯片，支持卫星通话功能，配备 5000 万像素超感知摄像头。</p>', 1, 2000),
('MacBook Pro 14英寸 M3 Pro', 5, 16999.00, 18999.00, 50, 'https://example.com/products/macbook.jpg', '苹果专业笔记本，M3 Pro芯片，18小时续航', '<p>MacBook Pro 14 英寸搭载 M3 Pro 芯片，配备 Liquid Retina XDR 显示屏，支持 18 小时续航。</p>', 1, 800),
('ThinkPad X1 Carbon 2024', 5, 12999.00, 14999.00, 80, 'https://example.com/products/thinkpad.jpg', '联想商务旗舰笔记本，轻薄便携，性能强劲', '<p>ThinkPad X1 Carbon 2024 款搭载第 13 代英特尔酷睿处理器，重量仅 1.12kg，支持 4G 全网通。</p>', 1, 600),

-- 服装鞋帽类商品
('男士商务休闲西装', 6, 899.00, 1299.00, 200, 'https://example.com/products/suit.jpg', '修身版型，优质面料，商务休闲两相宜', '<p>男士商务休闲西装，采用优质羊毛混纺面料，修身版型设计，适合商务会议和日常穿着。</p>', 1, 350),
('男士纯棉圆领T恤', 6, 99.00, 159.00, 500, 'https://example.com/products/tshirt.jpg', '纯棉材质，舒适透气，多色可选', '<p>男士纯棉圆领 T 恤，采用 100% 纯棉面料，舒适透气，多色可选，适合日常休闲穿着。</p>', 1, 2000),
('女士连衣裙', 7, 299.00, 499.00, 300, 'https://example.com/products/dress.jpg', '优雅气质，修身显瘦，四季百搭', '<p>女士连衣裙，采用优质雪纺面料，优雅气质设计，修身显瘦，适合各种场合穿着。</p>', 1, 1800),
('女士羊毛大衣', 7, 1299.00, 1999.00, 150, 'https://example.com/products/coat.jpg', '优质羊毛面料，保暖舒适，经典款式', '<p>女士羊毛大衣，采用 80% 羊毛面料，保暖舒适，经典双排扣设计，优雅大气。</p>', 1, 900),

-- 食品饮料类商品
('进口红酒礼盒装', 3, 599.00, 899.00, 120, 'https://example.com/products/wine.jpg', '法国原装进口，醇厚口感，送礼佳品', '<p>法国原装进口红酒礼盒装，采用优质葡萄酿造，醇厚口感，适合送礼和收藏。</p>', 1, 700),
('有机坚果礼盒', 3, 199.00, 299.00, 200, 'https://example.com/products/nuts.jpg', '精选多种坚果，营养丰富，健康美味', '<p>有机坚果礼盒，包含核桃、杏仁、腰果等多种坚果，营养丰富，健康美味。</p>', 1, 1500);

-- 插入收货地址
INSERT INTO t_address (user_id, receiver, phone, province, city, district, detail, is_default) VALUES
(1, '陈洪伟', '18929749359', '广西壮族自治区', '桂林市', '七星区', '桂林电子科技大学花江校区', 1);

-- 插入购物车数据
INSERT INTO t_cart (user_id, product_id, quantity, selected) VALUES
(1, 1, 1, 1),
(1, 5, 2, 1),
(1, 10, 1, 0);

-- 插入订单数据
INSERT INTO t_order (order_no, user_id, address_id, total_amount, pay_amount, freight_amount, status, payment_time) VALUES
('ORD202604030001', 1, 1, 10298.00, 10298.00, 0.00, 1, '2026-04-03 10:30:00');

-- 插入订单项数据
INSERT INTO t_order_item (order_id, product_id, product_name, product_image, price, quantity, total_amount) VALUES
(1, 1, 'iPhone 15 Pro Max 256GB', 'https://example.com/products/iphone15.jpg', 9999.00, 1, 9999.00),
(1, 5, '男士商务休闲西装', 'https://example.com/products/suit.jpg', 899.00, 2, 1798.00);

-- 插入支付记录
INSERT INTO t_payment (order_id, payment_no, amount, payment_type, status, created_at) VALUES
(1, 'PAY202604030001', 10298.00, 1, 1, '2026-04-03 10:30:00');

-- 启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 数据库初始化完成
-- =============================================

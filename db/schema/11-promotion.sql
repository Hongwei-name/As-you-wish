-- 优惠券基础模型；营销活动规则由服务层校验并保留下单时的优惠快照。
-- 优惠券定义和领取记录；模板状态及适用范围由营销服务校验。
CREATE TABLE IF NOT EXISTS mkt_coupon_template (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '优惠券模板主键ID',
  template_code VARCHAR(64) NOT NULL COMMENT '优惠券模板业务编码',
  name VARCHAR(128) NOT NULL COMMENT '优惠券名称',
  coupon_type TINYINT UNSIGNED NOT NULL COMMENT '优惠类型：1满减，2折扣，3无门槛金额券',
  threshold_amount DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '使用门槛金额，人民币元',
  discount_amount DECIMAL(12,2) NULL COMMENT '满减/金额券优惠金额，人民币元',
  discount_rate DECIMAL(6,4) NULL COMMENT '折扣比例，例如0.9000表示九折',
  max_discount_amount DECIMAL(12,2) NULL COMMENT '折扣券最高优惠金额，人民币元',
  total_quantity BIGINT UNSIGNED NULL COMMENT '可发放总数量，空表示不限制',
  issued_quantity BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已发放数量',
  per_user_limit INT UNSIGNED NOT NULL DEFAULT 1 COMMENT '每位用户最多领取数量',
  scope_type TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '适用范围：1全场，2指定分类，3指定商品',
  starts_at DATETIME(3) NOT NULL COMMENT '领取/使用开始时间',
  ends_at DATETIME(3) NOT NULL COMMENT '领取/使用截止时间',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0草稿，1启用，2停用，3结束',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_mkt_coupon_template_code (template_code),
  KEY idx_mkt_coupon_template_status_time (status, starts_at, ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='优惠券模板表';

CREATE TABLE IF NOT EXISTS mkt_user_coupon (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户优惠券主键ID',
  coupon_no VARCHAR(64) NOT NULL COMMENT '用户优惠券唯一编号',
  template_id BIGINT UNSIGNED NOT NULL COMMENT '优惠券模板ID，逻辑引用mkt_coupon_template.id',
  user_id BIGINT NOT NULL COMMENT '持有人用户ID，逻辑引用auth_user.id',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0未使用，1已锁定，2已使用，3已过期，4已作废',
  received_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '领取时间',
  expires_at DATETIME(3) NOT NULL COMMENT '此券有效截止时间',
  used_at DATETIME(3) NULL COMMENT '核销时间',
  order_id BIGINT NULL COMMENT '核销订单ID，逻辑引用ord_order.id',
  order_no VARCHAR(64) NULL COMMENT '核销业务订单编号',
  PRIMARY KEY (id),
  UNIQUE KEY uk_mkt_user_coupon_no (coupon_no),
  KEY idx_mkt_user_coupon_owner_status (user_id, status, expires_at),
  KEY idx_mkt_user_coupon_template (template_id, user_id, received_at),
  KEY idx_mkt_user_coupon_order (order_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户领取优惠券表';

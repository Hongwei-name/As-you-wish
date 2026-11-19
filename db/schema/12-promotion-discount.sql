-- 订单优惠分摊记录，支撑退款按商品行还原实际优惠。
CREATE TABLE IF NOT EXISTS ord_order_discount (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单优惠分摊主键ID',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id',
  order_no VARCHAR(64) NOT NULL COMMENT '业务订单编号',
  order_item_id BIGINT UNSIGNED NULL COMMENT '分摊到的订单明细ID，整单优惠可空',
  discount_type TINYINT UNSIGNED NOT NULL COMMENT '优惠来源：1优惠券，2促销活动，3积分',
  source_id BIGINT UNSIGNED NULL COMMENT '优惠券、活动或积分记录ID',
  description VARCHAR(200) NOT NULL COMMENT '优惠名称及规则说明快照',
  discount_amount DECIMAL(12,2) NOT NULL COMMENT '实际优惠金额，人民币元',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '记录创建时间',
  PRIMARY KEY (id),
  KEY idx_ord_discount_order (order_id, order_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单优惠分摊记录表';
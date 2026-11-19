-- 订单商品行快照：保留下单时名称、规格、图片和价格，历史订单不依赖商品当前资料。
CREATE TABLE IF NOT EXISTS ord_item (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单明细主键ID',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id，字段类型保持一致',
  order_no VARCHAR(64) NOT NULL COMMENT '业务订单编号，冗余用于检索',
  sku_id BIGINT UNSIGNED NOT NULL COMMENT '下单时SKU ID，逻辑引用gds_sku.id',
  spu_id BIGINT UNSIGNED NULL COMMENT '下单时SPU ID，逻辑引用gds_spu.id',
  sku_code VARCHAR(64) NOT NULL COMMENT '下单时SKU编码快照',
  product_name VARCHAR(200) NOT NULL COMMENT '下单时商品名称快照',
  sku_name VARCHAR(200) NOT NULL COMMENT '下单时SKU名称快照',
  spec_json JSON NOT NULL COMMENT '下单时商品规格快照',
  image_url VARCHAR(512) NULL COMMENT '下单时商品图片快照',
  unit_price DECIMAL(12,2) NOT NULL COMMENT '下单时商品单价，人民币元',
  quantity DECIMAL(12,3) NOT NULL COMMENT '购买数量',
  line_amount DECIMAL(12,2) NOT NULL COMMENT '商品行金额，优惠前',
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '分摊到本商品行的优惠金额',
  pay_amount DECIMAL(12,2) NOT NULL COMMENT '本商品行实付金额',
  after_sale_quantity DECIMAL(12,3) NOT NULL DEFAULT 0 COMMENT '已成功售后的数量',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '明细创建时间',
  PRIMARY KEY (id),
  KEY idx_ord_item_order (order_id, id),
  KEY idx_ord_item_order_no (order_no),
  KEY idx_ord_item_sku (sku_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单商品明细与下单快照表';
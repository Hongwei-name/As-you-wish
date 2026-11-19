-- 购物车域：价格始终以商品服务当前价格为准，不信任购物车价格。
CREATE TABLE IF NOT EXISTS cart_item (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '购物车项主键ID',
  user_id BIGINT NOT NULL COMMENT '用户ID，逻辑引用auth_user.id',
  sku_id BIGINT UNSIGNED NOT NULL COMMENT '商品SKU ID，逻辑引用gds_sku.id',
  quantity DECIMAL(12,3) NOT NULL COMMENT '加入购物车的商品数量',
  selected TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '是否选中结算：0否，1是',
  added_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '加入购物车时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '最后修改时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cart_user_sku (user_id, sku_id),
  KEY idx_cart_user_selected (user_id, selected, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户购物车商品表';
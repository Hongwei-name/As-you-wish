-- 库存域：所有数量变更必须在库存服务事务内完成并写库存流水。
CREATE TABLE IF NOT EXISTS wms_warehouse (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '仓库主键ID',
  warehouse_code VARCHAR(64) NOT NULL COMMENT '仓库业务编码',
  name VARCHAR(128) NOT NULL COMMENT '仓库名称',
  province_code VARCHAR(12) NULL COMMENT '省级行政区划代码',
  city_code VARCHAR(12) NULL COMMENT '市级行政区划代码',
  address VARCHAR(255) NULL COMMENT '仓库地址',
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用，1启用',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_wms_warehouse_code (warehouse_code),
  KEY idx_wms_warehouse_status (status, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库信息表';

CREATE TABLE IF NOT EXISTS wms_stock (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '库存记录主键ID',
  warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID，逻辑引用wms_warehouse.id',
  sku_id BIGINT UNSIGNED NOT NULL COMMENT '商品SKU ID，逻辑引用gds_sku.id',
  total_quantity DECIMAL(12,3) NOT NULL DEFAULT 0 COMMENT '现有总库存数量',
  reserved_quantity DECIMAL(12,3) NOT NULL DEFAULT 0 COMMENT '已预占未扣减数量',
  available_quantity DECIMAL(12,3) GENERATED ALWAYS AS (total_quantity - reserved_quantity) STORED COMMENT '可用库存，由总库存减预占库存计算',
  version BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '最后更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_wms_stock_warehouse_sku (warehouse_id, sku_id),
  KEY idx_wms_stock_sku_available (sku_id, available_quantity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='SKU仓库库存表';

CREATE TABLE IF NOT EXISTS wms_reservation (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '库存预占主键ID',
  reservation_no VARCHAR(64) NOT NULL COMMENT '库存预占业务编号',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id，逻辑引用',
  order_no VARCHAR(64) NOT NULL COMMENT '关联业务订单编号',
  sku_id BIGINT UNSIGNED NOT NULL COMMENT '预占SKU ID',
  warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '预占仓库ID',
  quantity DECIMAL(12,3) NOT NULL COMMENT '预占数量',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0预占中，1已确认扣减，2已释放，3已过期',
  expire_at DATETIME(3) NOT NULL COMMENT '预占到期时间',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_wms_reservation_no (reservation_no),
  UNIQUE KEY uk_wms_reservation_order_sku (order_no, sku_id, warehouse_id),
  KEY idx_wms_reservation_expire (status, expire_at),
  KEY idx_wms_reservation_order (order_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单库存预占表';

CREATE TABLE IF NOT EXISTS wms_stock_ledger (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '库存流水主键ID',
  sku_id BIGINT UNSIGNED NOT NULL COMMENT '商品SKU ID',
  warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
  business_type TINYINT UNSIGNED NOT NULL COMMENT '业务类型：1入库，2出库，3预占，4释放，5盘点调整，6退货入库',
  business_no VARCHAR(64) NOT NULL COMMENT '来源业务单号，用于追溯和幂等',
  quantity_delta DECIMAL(12,3) NOT NULL COMMENT '库存变更量，增加为正，减少为负',
  total_after DECIMAL(12,3) NOT NULL COMMENT '变更后总库存',
  reserved_after DECIMAL(12,3) NOT NULL COMMENT '变更后预占库存',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '流水创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_wms_ledger_business (business_type, business_no, sku_id, warehouse_id),
  KEY idx_wms_ledger_sku_time (sku_id, warehouse_id, created_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存变更流水表';
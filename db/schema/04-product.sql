-- 商品域新增表：不修改现存表。
CREATE TABLE IF NOT EXISTS gds_category (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分类主键ID',
  parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '父级分类ID，根节点为0',
  category_code VARCHAR(64) NOT NULL COMMENT '分类业务编码',
  name VARCHAR(100) NOT NULL COMMENT '分类名称',
  level TINYINT UNSIGNED NOT NULL COMMENT '分类层级，从1开始',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '同级排序值，越小越靠前',
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用，1启用',
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '软删除标记：0正常，1删除',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_gds_category_code (category_code),
  KEY idx_gds_category_parent_sort (parent_id, status, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';

CREATE TABLE IF NOT EXISTS gds_spu (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'SPU主键ID',
  category_id BIGINT UNSIGNED NOT NULL COMMENT '末级分类ID，逻辑引用gds_category.id',
  spu_code VARCHAR(64) NOT NULL COMMENT '商品SPU业务编码',
  name VARCHAR(200) NOT NULL COMMENT '商品名称',
  subtitle VARCHAR(500) NULL COMMENT '商品副标题',
  brand_name VARCHAR(100) NULL COMMENT '品牌名称快照',
  main_image VARCHAR(512) NULL COMMENT '商品主图URL',
  detail_content MEDIUMTEXT NULL COMMENT '商品详情内容，建议保存受控HTML',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0草稿，1上架，2下架',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '列表排序值',
  published_at DATETIME(3) NULL COMMENT '首次上架时间',
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '软删除标记：0正常，1删除',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_gds_spu_code (spu_code),
  KEY idx_gds_spu_category_status (category_id, status, is_deleted, sort_order),
  KEY idx_gds_spu_updated (status, updated_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品SPU表';

CREATE TABLE IF NOT EXISTS gds_sku (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'SKU主键ID',
  spu_id BIGINT UNSIGNED NOT NULL COMMENT '所属SPU ID，逻辑引用gds_spu.id',
  sku_code VARCHAR(64) NOT NULL COMMENT 'SKU业务编码/商家货号',
  barcode VARCHAR(64) NULL COMMENT '商品条码',
  name VARCHAR(200) NOT NULL COMMENT 'SKU销售名称',
  spec_json JSON NOT NULL COMMENT '销售规格快照，例如颜色和尺码',
  sale_price DECIMAL(12,2) NOT NULL COMMENT '销售单价，人民币元',
  market_price DECIMAL(12,2) NULL COMMENT '市场展示价，人民币元',
  cost_price DECIMAL(12,2) NULL COMMENT '成本参考价，人民币元',
  weight_gram INT UNSIGNED NULL COMMENT '单件重量，克',
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用，1可售',
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '软删除标记：0正常，1删除',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_gds_sku_code (sku_code),
  UNIQUE KEY uk_gds_sku_barcode (barcode),
  KEY idx_gds_sku_spu_status (spu_id, status, is_deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品SKU销售单元表';

CREATE TABLE IF NOT EXISTS gds_product_image (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '图片记录主键ID',
  spu_id BIGINT UNSIGNED NOT NULL COMMENT '所属SPU ID',
  sku_id BIGINT UNSIGNED NULL COMMENT '所属SKU ID，空表示SPU级图片',
  image_url VARCHAR(512) NOT NULL COMMENT '图片URL',
  image_type TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '图片类型：1主图，2详情图，3规格图',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '图片排序值',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_gds_image_spu (spu_id, image_type, sort_order),
  KEY idx_gds_image_sku (sku_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品图片表';
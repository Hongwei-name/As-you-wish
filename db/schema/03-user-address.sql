-- 新增用户收货地址；user_id 逻辑引用现有 auth_user.id，不修改认证表。
CREATE TABLE IF NOT EXISTS usr_address (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '收货地址主键ID',
  user_id BIGINT NOT NULL COMMENT '所属用户ID，逻辑引用auth_user.id',
  recipient_name VARCHAR(64) NOT NULL COMMENT '收货人姓名',
  recipient_phone VARCHAR(20) NOT NULL COMMENT '收货人手机号',
  province_code VARCHAR(12) NOT NULL COMMENT '省级行政区划代码',
  province_name VARCHAR(64) NOT NULL COMMENT '省份名称快照',
  city_code VARCHAR(12) NOT NULL COMMENT '市级行政区划代码',
  city_name VARCHAR(64) NOT NULL COMMENT '城市名称快照',
  district_code VARCHAR(12) NOT NULL COMMENT '区县行政区划代码',
  district_name VARCHAR(64) NOT NULL COMMENT '区县名称快照',
  street_name VARCHAR(128) NULL COMMENT '街道或乡镇名称',
  detail_address VARCHAR(255) NOT NULL COMMENT '门牌及详细地址',
  postal_code VARCHAR(16) NULL COMMENT '邮政编码',
  is_default TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否默认地址：0否，1是',
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '软删除标记：0正常，1删除',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_usr_address_user (user_id, is_deleted, is_default, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户收货地址表';
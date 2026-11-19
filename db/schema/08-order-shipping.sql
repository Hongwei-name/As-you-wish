-- 订单物流：现有ord_order仅存收货信息，物流轨迹需单独记录。
CREATE TABLE IF NOT EXISTS ord_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单状态轨迹主键ID',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id',
  order_no VARCHAR(64) NOT NULL COMMENT '业务订单编号',
  from_status TINYINT NULL COMMENT '变更前订单状态，创建时为空',
  to_status TINYINT NOT NULL COMMENT '变更后状态，与ord_order.order_status枚举一致',
  operator_type TINYINT UNSIGNED NOT NULL COMMENT '操作方：1用户，2系统，3运营人员，4支付渠道',
  operator_id BIGINT NULL COMMENT '操作人ID，系统操作时为空',
  remark VARCHAR(500) NULL COMMENT '状态变更说明',
  request_id VARCHAR(64) NULL COMMENT '触发变更的请求或事件ID',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '状态变更时间',
  PRIMARY KEY (id),
  KEY idx_ord_status_order_time (order_id, created_at, id),
  KEY idx_ord_status_order_no (order_no, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单状态变更轨迹表';
CREATE TABLE IF NOT EXISTS ord_shipment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '发货单主键ID',
  shipment_no VARCHAR(64) NOT NULL COMMENT '发货单业务编号',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id',
  order_no VARCHAR(64) NOT NULL COMMENT '业务订单编号',
  carrier_code VARCHAR(32) NULL COMMENT '物流公司编码',
  carrier_name VARCHAR(64) NULL COMMENT '物流公司名称快照',
  tracking_no VARCHAR(100) NULL COMMENT '物流运单号',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待发货，1已发货，2运输中，3签收，4异常，5取消',
  shipped_at DATETIME(3) NULL COMMENT '实际发货时间',
  signed_at DATETIME(3) NULL COMMENT '签收时间',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '发货单创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_ord_shipment_no (shipment_no),
  KEY idx_ord_shipment_order (order_id, created_at),
  KEY idx_ord_shipment_tracking (carrier_code, tracking_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单发货单表';

CREATE TABLE IF NOT EXISTS ord_shipment_track (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '物流轨迹主键ID',
  shipment_id BIGINT UNSIGNED NOT NULL COMMENT '发货单ID，逻辑引用ord_shipment.id',
  tracking_no VARCHAR(100) NOT NULL COMMENT '物流运单号',
  event_code VARCHAR(64) NULL COMMENT '物流事件标准编码',
  event_description VARCHAR(500) NOT NULL COMMENT '物流事件描述',
  occurred_at DATETIME(3) NULL COMMENT '物流事件发生时间',
  location VARCHAR(200) NULL COMMENT '物流事件地点',
  raw_event_id VARCHAR(128) NULL COMMENT '物流商原始事件ID，用于回调去重',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '记录接收时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_ord_track_raw_event (shipment_id, raw_event_id),
  KEY idx_ord_track_shipment_time (shipment_id, occurred_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单物流轨迹表';
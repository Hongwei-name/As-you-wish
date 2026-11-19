-- 支付域：记录多次支付尝试；支付渠道密钥不存数据库。
CREATE TABLE IF NOT EXISTS pay_payment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '支付单主键ID',
  payment_no VARCHAR(64) NOT NULL COMMENT '平台支付单号',
  order_id BIGINT NOT NULL COMMENT '关联现有ord_order.id',
  order_no VARCHAR(64) NOT NULL COMMENT '业务订单编号',
  user_id BIGINT NOT NULL COMMENT '支付用户ID，逻辑引用auth_user.id',
  channel TINYINT UNSIGNED NOT NULL COMMENT '支付渠道：1微信，2支付宝，3余额，4其他',
  amount DECIMAL(12,2) NOT NULL COMMENT '本次支付金额，人民币元',
  currency CHAR(3) NOT NULL DEFAULT 'CNY' COMMENT 'ISO 4217币种代码',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待支付，1处理中，2成功，3失败，4关闭，5已退款',
  channel_trade_no VARCHAR(128) NULL COMMENT '支付渠道交易流水号',
  idempotency_key VARCHAR(128) NOT NULL COMMENT '平台请求幂等键',
  expires_at DATETIME(3) NULL COMMENT '支付单有效期',
  paid_at DATETIME(3) NULL COMMENT '支付成功时间',
  closed_at DATETIME(3) NULL COMMENT '支付单关闭时间',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '支付单创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '支付单更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_pay_payment_no (payment_no),
  UNIQUE KEY uk_pay_payment_idempotency (idempotency_key),
  UNIQUE KEY uk_pay_channel_trade (channel, channel_trade_no),
  KEY idx_pay_order (order_id, created_at),
  KEY idx_pay_status_expire (status, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台支付单表';

CREATE TABLE IF NOT EXISTS pay_callback_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '支付回调记录主键ID',
  channel TINYINT UNSIGNED NOT NULL COMMENT '支付渠道类型',
  channel_event_id VARCHAR(128) NOT NULL COMMENT '渠道回调事件唯一ID',
  payment_no VARCHAR(64) NULL COMMENT '平台支付单号',
  channel_trade_no VARCHAR(128) NULL COMMENT '渠道交易流水号',
  verify_status TINYINT UNSIGNED NOT NULL COMMENT '验签结果：0未通过，1通过',
  process_status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '处理结果：0待处理，1成功，2失败，3重复忽略',
  payload_digest CHAR(64) NOT NULL COMMENT '回调正文SHA-256摘要，不保存敏感原文',
  received_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '回调接收时间',
  processed_at DATETIME(3) NULL COMMENT '处理完成时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_pay_callback_event (channel, channel_event_id),
  KEY idx_pay_callback_payment (payment_no, received_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付渠道回调幂等日志表';
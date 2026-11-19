-- 服务可靠性基础设施：outbox与接口幂等记录；业务服务只操作本服务记录。
-- Outbox与请求幂等表应由各服务本地库各自持有，不构成跨库共享表。
CREATE TABLE IF NOT EXISTS sys_outbox_event (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '待发送事件主键ID',
  event_id CHAR(36) NOT NULL COMMENT '全局唯一事件ID',
  aggregate_type VARCHAR(64) NOT NULL COMMENT '聚合根类型，例如ORDER或STOCK',
  aggregate_id VARCHAR(64) NOT NULL COMMENT '聚合根业务ID',
  event_type VARCHAR(128) NOT NULL COMMENT '事件类型，例如OrderCreated',
  payload JSON NOT NULL COMMENT '事件负载，禁止放凭据和不必要个人信息',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待发送，1发送中，2已发送，3待重试，4死信',
  retry_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已重试次数',
  next_retry_at DATETIME(3) NULL COMMENT '下一次允许重试时间',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '事件创建时间',
  published_at DATETIME(3) NULL COMMENT '成功发布事件时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_outbox_event_id (event_id),
  KEY idx_sys_outbox_poll (status, next_retry_at, id),
  KEY idx_sys_outbox_aggregate (aggregate_type, aggregate_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='事务发件箱事件表';

CREATE TABLE IF NOT EXISTS sys_idempotency_record (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '幂等记录主键ID',
  service_name VARCHAR(64) NOT NULL COMMENT '幂等键所属服务名',
  operation VARCHAR(128) NOT NULL COMMENT '幂等操作名，例如CreateOrder或ReserveStock',
  idempotency_key VARCHAR(128) NOT NULL COMMENT '调用方生成并在重试时复用的幂等键',
  request_digest CHAR(64) NOT NULL COMMENT '规范化请求体SHA-256摘要，用于检测同键异参',
  status TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '处理状态：0处理中，1成功，2失败可重试',
  response_code VARCHAR(64) NULL COMMENT '已完成请求的业务响应码',
  response_body JSON NULL COMMENT '可安全重放的响应摘要，不存敏感数据',
  expires_at DATETIME(3) NOT NULL COMMENT '幂等记录保留截止时间',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '记录创建时间',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '记录更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_idempotency_scope (service_name, operation, idempotency_key),
  KEY idx_sys_idempotency_expire (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='服务接口幂等请求记录表';
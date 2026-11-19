# 商城数据库增量补表设计

基准：`E:/im_platform.sql`（MySQL 8.4.3）。导出包含10张表：`ai_conversation`、`ai_generation`、`ai_message`、`auth_user`、`ord_order`、`order_info`、`soc_account`、`sys_user`、`user_info`、`usr_profile`。

## 盘点结论

- 保留现有 AI、认证、社交、用户资料表。本次不修改这些表。
- `ord_order` 已存在并包含订单头、金额、支付摘要、状态和收件信息，保留表及数据，不重复创建订单主表。`order_info` 是旧 IM/社交系统的另一套订单，亦不合并、不删除。
- 缺少商城地址、分类/SPU/SKU/图片、库存仓库/预占/流水、购物车、订单明细/状态轨迹/物流、支付/回调/退款/售后、优惠券、outbox 和幂等表。
- `auth_user` 实际字段与当前 Java `AuthUser` 映射不完全一致，另需单独核对迁移；补表脚本不会碰它。

## 增量脚本顺序

1. `03-user-address.sql`：收货地址。
2. `04-product.sql`：分类、SPU、SKU、商品图。
3. `05-stock.sql`：仓库、SKU库存、库存预占、流水。
4. `06-cart.sql`：购物车。
5. `07-order-detail.sql`：订单商品明细。
6. `08-order-shipping.sql`：订单状态轨迹、发货单和物流轨迹。
7. `09-payment.sql`：支付单和回调。
8. `10-after-sale.sql`：售后申请和退款。
9. `11-promotion.sql`：优惠券及用户领券。
10. `12-promotion-discount.sql`：订单优惠分摊。
11. `13-outbox-idempotency.sql`：事务 outbox 和接口幂等记录。

依赖顺序：先执行 03–08，再执行 09–13；脚本通过逻辑 ID 关联，不建立跨域物理外键。

所有脚本仅 `CREATE TABLE IF NOT EXISTS`，不含 `DROP` 或 `ALTER` 现有表；MySQL DDL 会隐式提交，执行前仍应备份并先在开发库验证。表名和列名为英文 snake_case；所有新表和字段都有中文 `COMMENT`。适用于 MySQL 8.0+、InnoDB、utf8mb4。

## 关键约束

- 新领域表按服务前缀：用户 `usr_`、商品 `gds_`、仓储库存 `wms_`、购物车 `cart_`、订单售后 `ord_`、支付 `pay_`、营销 `mkt_`、可靠性 `sys_`。旧 `order_info`、`sys_user` 不作为新表范式。
- 新主键采用 `BIGINT UNSIGNED AUTO_INCREMENT`。现有 `ord_order.id` 是有符号 `BIGINT`，所以引用它的新增列使用有符号 `BIGINT`。没有新增跨域物理外键；本次目标是日后可拆分服务边界。
- 金额使用 `DECIMAL(12,2)`，库存数量用 `DECIMAL(12,3)`；不能用浮点数计算金额。订单明细存商品/SKU/规格/图片/价格快照。
- `wms_stock.available_quantity` 是生成列 `total_quantity - reserved_quantity`。写库存时需在同一事务内条件扣减并记 `wms_stock_ledger`，确保不超卖；预占用唯一业务键避免重复预占。
- 现有订单表使用 `create_time/update_time`、`auth_user_id`；新表按新规范使用 `created_at/updated_at`、`user_id`。应用映射时显式维护差异，避免为统一命名而改已有数据表。
- 生产执行前检查同名表是否已在数据库存在；`IF NOT EXISTS` 不会验证已有同名表结构是否兼容。
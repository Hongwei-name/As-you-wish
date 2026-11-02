## 后续扩展表命名示例（保持统一标准）

user-service：

- `usr_address` 用户收货地址

order-service：

- `ord_item` 订单明细
- `ord_refund` 售后退款单

goods-service：

- `gds_spu` 商品 SPU
- `gds_sku` 商品 SKU
- `gds_category` 商品分类

social-service：

- `soc_friend` 好友关系
- `soc_conversation` 会话列表
- `soc_message` 聊天消息

## 代码层映射（DO 实体类）

表 `auth_user` → `AuthUser.java`
表 `usr_profile` → `UsrProfile.java`
表 `soc_account` → `SocAccount.java`
表 `ord_order` → `OrdOrder.java`
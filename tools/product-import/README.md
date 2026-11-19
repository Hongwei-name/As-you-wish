# DummyJSON 商品 SQL 导入工具

工具读取 DummyJSON 原始响应 JSON 与人工翻译后的中文 JSON，生成适配 `db/schema/04-product.sql` 和 `db/schema/05-stock.sql` 的 SQL：商品分类、SPU、SKU、商品图，以及专供联调的模拟仓、库存和初始化流水。价格和库存数量沿用样例 API，仅供开发演示，不代表真实业务数据。翻译无需 API key 或本地翻译服务。

## 前置条件

- JDK 17+
- Maven 3.9+
- 运行 MySQL 8.0+，并先执行项目的 `db/schema/04-product.sql` 和 `db/schema/05-stock.sql`
- 中文数据文件 `dummyjson-products-zh.json`（已包含人工翻译字段）。

## 构建

在 `tools/product-import` 目录运行：

```powershell
mvn -q package
```

## 运行并生成 SQL

```powershell
java -jar target/dummyjson-product-import-1.0.0.jar dummyjson-products-zh.json dummyjson-products-zh.sql
```

检查生成 SQL 后再导入：

```powershell
mysql --default-character-set=utf8mb4 -u <数据库用户> -p im_platform < dummyjson-products-zh.sql
```

运行命令的第一个参数是已翻译 JSON 输入，第二个参数是 SQL 输出路径。当前生成文件包含 194 个商品；每次导入使用固定 `DUMMY-SPU-*` / `DUMMY-SKU-*` 编码，以唯一键更新商品。分类编码依据原始类别生成，中文分类名写入数据库。脚本在 `DUMMYJSON-WH` 联调模拟仓中，以 DummyJSON 的 `stock` 数值作为测试总库存并写入盘点调整流水；只初始化缺失库存，不覆盖已有库存或预占量。再次运行可安全重试。此库存仅供联调，不能用于生产。SQL 开启事务并设置 `utf8mb4`。请先执行 `db/schema/04-product.sql`、`db/schema/05-stock.sql`，审查 SQL 后再自行导入；工具不会连接数据库。PowerShell 导入可用：`cmd /c "mysql --default-character-set=utf8mb4 -u <数据库用户> -p im_platform < tools\\product-import\\dummyjson-products-zh.sql"`。

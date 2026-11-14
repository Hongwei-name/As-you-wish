# Auth 服务 Boot 3 迁移

基线继承父模块：Java 17、Spring Boot 3.5.7、Spring Cloud Alibaba 2025.0.0.0、MyBatis-Plus 3.5.12。

## 依赖与接口

- MyBatis-Plus 改用 `mybatis-plus-spring-boot3-starter`，版本由父模块管理。
- Knife4j 改用 `knife4j-openapi3-jakarta-spring-boot-starter:4.5.0`。
- 显式引入 `springdoc-openapi-starter-webmvc-ui:2.8.14`，避免 Knife4j 传递的旧版 springdoc 与 Spring 6.2 不兼容。两个文档组件版本暂在本模块固定，可后续统一到父 POM。
- Springfox Docket 改为 OpenAPI / GroupedOpenApi，文档 JSON 地址迁为 `/v3/api-docs/auth`；Knife4j 页面仍为 `/doc.html`。
- `API_DOCS_ENABLED=true` 时开启文档，默认关闭。
- Servlet 与 Bean Validation 导入改为 Jakarta，Security 改为 6.x Lambda DSL 与 requestMatchers。

## 外部配置

必填：`DB_USERNAME`、`DB_PASSWORD`、`JWT_SECRET`。JWT 密钥按 UTF-8 编码，至少 32 字节；未提供、为空或过短会启动失败。

可选：

| 环境变量 | 默认值 |
| --- | --- |
| DB_URL | 本机 MySQL 3306 / im_platform |
| JWT_EXPIRE_MILLIS | 604800000 |
| NACOS_SERVER_ADDR | 127.0.0.1:8848 |
| NACOS_USERNAME / NACOS_PASSWORD / NACOS_NAMESPACE | 空 |
| NACOS_GROUP | DEFAULT_GROUP |
| REDIS_HOST / REDIS_PORT / REDIS_DATABASE | 127.0.0.1 / 6379 / 0 |
| REDIS_PASSWORD | 空 |
| SERVER_PORT | 2003 |

Redis 使用 Boot 3 的 `spring.data.redis` 配置前缀。运行需提供 MySQL、Redis、Nacos。原源码密钥被替换后，已有 JWT 会随部署密钥变更而失效；历史泄漏凭据仍须由持有方轮换。

## TianAI 1.5.6 检查

保留原版 starter 与现有 API。实际 Maven Central 1.5.6 starter JAR 包含 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`，导入 `CacheStoreAutoConfiguration` 和 `ImageCaptchaAutoConfiguration`。逐个 class 常量检查未发现 `javax/servlet`、`javax/validation`、`javax/annotation` 引用，无需自行补注册自动配置。该静态检查不代表 Redis 验证码业务已完成联调。

调研检索词：`github tianai captcha 1.5.6 spring boot 3 AutoConfiguration.imports`、`github knife4j spring boot 3.5 springdoc 2.8`。复用已有官方组件，未引入自制验证码适配层。

来源：
- https://github.com/dromara/tianai-captcha
- https://gitee.com/tianai/tianai-captcha-springboot-starter
- https://repo.maven.apache.org/maven2/cloud/tianai/captcha/tianai-captcha-springboot-starter/1.5.6/
- https://github.com/xiaoymin/knife4j
- https://springdoc.org/v2/#what-is-the-compatibility-matrix-of-springdoc-openapi-with-spring-boot

## 检查记录

- `git diff --check -- auth-service` 通过。
- 源码搜索确认无旧 servlet/validation 导入、Springfox 或 antMatchers；`javax.imageio` 属于 JDK API，保留。
- 本机 Maven 3.8.8 / Java 17.0.11。
- 默认仓库依赖解析失败，无法创建 `D:\software\maven\repository` 下的新版本 POM lock。
- `mvn -Dmaven.repo.local=auth-service/target/maven-repository -pl auth-service -am verify` 在仓库初始化阶段报 LocalRepositoryNotAccessibleException，尚未进入编译。需在可写 Maven 仓库环境重跑验证。
- 主线程随后使用工作区仓库在授权环境执行完整 `clean verify` 成功，认证模块以 release 17 编译并打包；使用测试凭据启动成功，现有 Nacos 2.5.5 返回认证服务 2003 实例 healthy=true。此前仓库失败属于受限环境问题。
- JWT 认证过滤器仍属原有待实现项，本次仅迁移现有安全配置，受保护接口仍无法凭 JWT 建立认证上下文。

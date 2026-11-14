# Java 17 技术栈与本机运行

两个服务统一继承根 Maven 父项目，不再独立声明 Spring Boot / Cloud 版本。

| 组件 | 版本 |
| --- | --- |
| Java / 编译 release | 17 |
| Spring Boot | 3.5.7 |
| Spring Cloud | 2025.0.0 |
| Spring Cloud Alibaba | 2025.0.0.0 |
| Spring AI | 1.1.8 |
| MyBatis-Plus Boot 3 starter | 3.5.12 |
| 本机 Nacos Server | 2.5.5，保留现有安装 |

原认证模块使用 Boot 2.7，AI 模块使用独立 Boot 4 父项目。为保留 Spring AI 的 ChatClient 和会话记忆，并遵循用户选定的 Java 17 + Boot 3.5 方案，认证模块同步迁移 Jakarta、Security 6、OpenAPI 3。项目规范已同步更新。

## 构建

使用 JDK 17，在仓库根目录执行：

```powershell
java -version
mvn -version
mvn clean verify
```

若默认 Maven 缓存目录不可写，可指定工作区缓存（已加入忽略规则）：

```powershell
mvn -B -ntp '-Dmaven.repo.local=.maven-repository' clean verify
```

未修改系统 JAVA_HOME。两个服务生成 `*-1.0-SNAPSHOT.jar`，AI 模块原 `0.0.1-SNAPSHOT` 部署脚本需同步调整。

## Nacos

现有安装在 `D:\software\nacos`，服务地址 `127.0.0.1:8848`，客户端 gRPC 使用 9848，9849 为服务端通信端口。两个服务都已引入 Nacos discovery starter；原 AI 模块仅有配置但没有依赖的问题已补齐。

通用环境变量：`NACOS_SERVER_ADDR`（默认 `127.0.0.1:8848`）、`NACOS_USERNAME`、`NACOS_PASSWORD`、`NACOS_NAMESPACE`（填写命名空间 ID；默认空表示 public）、`NACOS_GROUP`（默认 `DEFAULT_GROUP`）。本机当前关闭 Nacos 鉴权，无需填账号密码。没有新增 Nacos 配置中心依赖，也无需新增 config import。

本机已有 Nacos 实例时直接复用，避免再次运行启动脚本占用同一个 Derby 数据目录。确认未运行时可执行：

```powershell
& 'D:\software\nacos\bin\startup.cmd' -m standalone
```

## 根目录环境文件

真实配置统一填写在后端根目录 `.env`，该文件被 Git 忽略；`.env.example` 是可提交模板。首次使用复制模板并填写真实值。使用 `KEY=value`，不加引号，不加 `export`。两个模块通过 Spring Boot 原生 `spring.config.import` 将 `.env` 按 properties 加载，支持从后端根目录或服务模块目录启动，无需启用 local profile；系统环境变量仍可覆盖文件值。JWT 密钥至少 32 个 UTF-8 字节，过期时间键名为 `JWT_EXPIRE_MILLIS`。

下面示例中的环境变量也可直接写进根目录 `.env`，无需每次在终端设置。

## AI 服务

```powershell
$env:OPENAI_API_KEY='<填入新密钥>'
# 以下可选，base-url 不要重复带 /v1；Spring AI 默认追加 /v1/chat/completions。
$env:OPENAI_BASE_URL='https://openoneapi.com'
$env:OPENAI_MODEL='gpt-6.1-sol'
java -jar ai-service/target/ai-service-1.0-SNAPSHOT.jar
```

端口默认 2002，可用 `AI_SERVER_PORT` 覆盖。模型配置改为正确的 `spring.ai.openai.chat.options.model`。真实模型调用需要有效凭据，本次注册验证使用无调用能力的测试值，没有调用收费接口。

## 认证服务

必填 `DB_USERNAME`、`DB_PASSWORD`、`JWT_SECRET`（至少 32 个 UTF-8 字节）；数据库地址由 `DB_URL` 覆盖，默认本机 3306 的 im_platform。Redis 默认本机 6379，可使用 `REDIS_HOST`、`REDIS_PORT`、`REDIS_PASSWORD`、`REDIS_DATABASE`。

```powershell
$env:DB_USERNAME='<数据库用户>'
$env:DB_PASSWORD='<数据库密码>'
$env:JWT_SECRET='<至少32字节的随机密钥>'
java -jar auth-service/target/auth-service-1.0-SNAPSHOT.jar
```

端口默认 2003，可用 `SERVER_PORT` 覆盖。开发文档需显式设置 `API_DOCS_ENABLED=true`；文档页面 `/doc.html`，JSON `/v3/api-docs/auth`。更多迁移细节见 [认证迁移说明](auth-service/BOOT3-MIGRATION.md)。原源码中的数据库凭据、AI 密钥和 JWT 固定密钥已外置，历史暴露的凭据需要持有方轮换；JWT 密钥改变后旧 Token 失效。

## 选型依据

检索关键词：`github spring cloud alibaba 2025.0.0.0 Spring Boot 3.5 nacos`、`Spring AI 1.1 Spring Boot 3.5 compatibility`。复用现有官方 starter 和 BOM，没有自行实现注册客户端或替换 AI 能力。

- [Spring Cloud Alibaba 官方版本矩阵](https://sca.aliyun.com/en/docs/2025.x/overview/version-explain/)：2025.0.x 对应 Boot 3.5 / Cloud 2025.0；BOM 默认 Nacos client 3.0.3，与本机 2.5.5 的服务发现兼容性通过实际注册验证。
- [Spring AI 1.1 官方说明](https://docs.spring.io/spring-ai/reference/1.1/getting-started.html)：支持 Boot 3.4 / 3.5。
- [Spring Cloud Alibaba 仓库](https://github.com/alibaba/spring-cloud-alibaba)
- [Spring AI 仓库](https://github.com/spring-projects/spring-ai)

## 验证记录

- JDK 17.0.11 / Maven 3.8.8。
- 完整 `clean verify` 成功：父项目、认证服务、AI 服务均 SUCCESS；AI 上下文测试 1 项通过，认证服务当前无测试。
- 编译器日志确认两个模块均 `release 17`，两个可执行 JAR 打包成功。
- 本机 Nacos 状态接口返回 2.5.5；AI 服务（2002）和认证服务（2003）均在 DEFAULT_GROUP 注册，状态接口返回 `healthy=true`、`enabled=true`；9848 gRPC 连接建立。
- 两个服务均以测试凭据完成启动和注册，验证后停止测试进程；现有 Nacos 保持运行。受限执行环境存在客户端日志目录写入告警，未影响注册结果。
- 认证业务仍需要实际 MySQL / Redis 凭据联调；现有缺失 JWT 过滤器的问题未在本次版本统一中扩展实现。

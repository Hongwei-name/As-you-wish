# AGENTS.md

## 1. 项目定位

本项目是一个基于 Spring Boot 的 Java 多模块后端项目，当前包含认证服务 `auth-service`。项目采用 Maven 聚合构建，目标是逐步扩展为按业务域拆分的微服务系统。

当前技术基线：

- Java 8
- Spring Boot 2.7.18
- Spring Cloud 2021.0.7
- Spring Cloud Alibaba 2021.0.1.0
- MyBatis-Plus 3.5.3.1
- MySQL
- Redis
- Nacos 服务发现
- Spring Security
- JWT（jjwt 0.11.5）
- Argon2 密码哈希
- Knife4j 接口文档
- Maven 多模块构建

所有新增实现都应先遵守本文档；如果代码现状与本文档冲突，以本文档定义的目标架构为准，并在提交说明中注明迁移原因。

## 2. 构建与运行

项目根目录是 Maven 聚合项目，模块定义在根目录 `pom.xml` 中。当前模块：

```text
As-you-wish/
├── pom.xml
└── auth-service/
    ├── pom.xml
    └── src/main/
```

常用命令：

```bash
# 编译全部模块
mvn clean verify

# 跳过测试打包
mvn clean package -DskipTests

# 只构建认证服务及其依赖
mvn -pl auth-service -am clean package

# 启动认证服务
mvn -pl auth-service spring-boot:run
```

提交代码前至少执行 `mvn clean verify`。如果本地依赖、MySQL、Redis 或 Nacos 不可用，应记录阻塞原因，不得用删除功能或屏蔽检查的方式让构建“通过”。

## 3. 目录职责

每个服务模块使用以下分层方式：

```text
auth-service/src/main/java/com/asyouwish/auth/
├── AuthServiceApplication.java
├── controller/       # HTTP 接口、参数接收、响应组装
├── service/          # 业务接口
├── service/impl/     # 业务流程编排与事务边界
├── mapper/           # MyBatis-Plus 数据访问接口
├── entity/           # 数据库表对应的持久化实体
├── dto/              # 请求对象和外部输入模型
├── config/           # Spring、Security、文档和全局异常配置
└── util/             # 跨业务通用的小型工具、统一响应和异常类型
```

资源目录：

```text
auth-service/src/main/resources/
├── application.yml       # 通用配置和服务标识
├── application-{env}.yml # 环境差异配置
├── mapper/               # 复杂 SQL 的 XML 映射
└── banner.txt
```

目录边界：

- `controller` 只能依赖 DTO、Service 和统一响应模型，不得直接调用 Mapper、Redis 或拼接 SQL。
- `service` 定义业务能力和业务契约；复杂实现放在 `service/impl`。
- `service/impl` 负责业务流程、事务、缓存和领域校验，不把 HTTP 请求对象向下层传递。
- `mapper` 只负责持久化访问，不承载登录、验证码、权限等业务判断。
- `entity` 只表示持久化数据，不直接作为对外接口请求或响应模型。
- `dto` 按用途命名，例如 `PasswordLoginDTO`、`SmsRegisterDTO`；敏感字段不得写日志。
- `config` 只放配置和基础设施装配，禁止把业务流程塞进配置类。
- `util` 不得变成杂物包；有明确业务归属的代码应放入对应服务或组件中。

单一职责原则（强制）：

- Controller 只负责接收参数、触发参数校验、调用 Service 和返回结果；不得承担业务判断、流程编排、事务、数据访问或缓存操作。
- 涉及多个业务步骤的调用顺序、条件分支、事务和失败处理统一由 Service 编排，Controller 不得通过连续调用多个 Service 方法拼装业务流程。
- 常用且可复用的方法应优先复用现有库；确需自行抽象时，将无业务归属、无状态的通用逻辑提取为职责明确的工具类，避免在多个 Controller 或 Service 中重复实现。
- 依赖数据库、Redis、外部服务或承载业务规则的复用逻辑，应抽取为可注入的 Service 或专用组件，不得为了复用而塞入静态工具类。
- 工具类按单一用途命名并保持职责集中，避免创建包含无关方法的通用大类；抽取逻辑时同步遵守开源组件调研与复用要求。

## 4. 认证服务架构

认证服务的请求链路应保持为：

```text
HTTP 请求
  -> Controller
  -> Service
  -> Mapper / Redis / 外部短信服务
  -> 统一 Result 响应
```

认证相关职责：

- `/auth/captcha/gen`（兼容 GET/POST）与 `/auth/captcha/check`：使用 TianAI Captcha 1.5.6 官方 `ImageCaptchaApplication` 生成和校验滑块验证码；这两个端点直接返回 TianAI `ApiResponse` 以兼容官方 Web SDK。启用 Redis `ResourceStore` 时必须注册至少一张 `SLIDER` 背景资源；默认模板只提供拼图形状，不提供可随机选择的背景图。
- `/auth/sms/send`：只接受一次性消费的、已通过 TianAI 校验的 `captchaId`，再校验手机号、执行手机号和 IP 限流、生成验证码、调用短信供应商、写入 Redis。
- `/auth/register/sms`：校验一次性验证码、检查手机号唯一性、使用 Argon2 保存密码、创建用户并签发 JWT。
- `/auth/login/sms`：校验一次性验证码、查询用户状态并签发 JWT。
- `/auth/login/password`：查询用户、校验密码和账号状态并签发 JWT。
- 受保护接口：由 JWT 过滤器解析 `Authorization: Bearer <token>`，校验签名、有效期和用户身份后写入 Spring Security 上下文。

JWT 生成、解析和校验集中在 `JwtUtil` 或专用认证组件中。Controller 和普通业务代码不得自行解析 Token。JWT 密钥、过期时间等必须来自外部配置或密钥管理系统，禁止写死在 Java 源码中。

短信验证码必须满足：

- Redis Key 使用统一前缀和明确的业务维度。
- 验证码有明确过期时间，成功校验或失败达到策略阈值后失效。
- 手机号限流与 IP 限流都要有原子计数和过期时间。
- 生产环境不得通过日志输出真实验证码。
- 供应商调用应抽象为独立组件，Service 只依赖接口。
- 手机号、IP、验证码等输入必须校验格式和长度。

## 5. 接口与数据规范

统一使用 `Result<T>` 返回接口结果。成功、业务失败、参数失败、未认证和无权限应使用统一状态码，不要在 Controller 中重复创建不一致的响应结构。

请求 DTO 必须使用 Bean Validation：

- 手机号、验证码、密码等必填字段使用 `@NotBlank`。
- 手机号和验证码增加格式及长度校验。
- 密码增加最小长度和复杂度策略。
- Controller 的请求体使用 `@Valid` 或 `@Validated`。

持久化实体与数据库表遵循项目现有命名规则：

- 认证表使用 `auth_` 前缀，例如 `auth_user`。
- 用户域使用 `usr_` 前缀，例如 `usr_address`。
- 订单域使用 `ord_` 前缀，例如 `ord_item`、`ord_refund`。
- 商品域使用 `gds_` 前缀，例如 `gds_spu`、`gds_sku`、`gds_category`。
- 社交域使用 `soc_` 前缀，例如 `soc_friend`、`soc_conversation`、`soc_message`。
- 表字段使用 snake_case，Java 属性使用 camelCase。
- 表实体类使用领域前缀对应的 PascalCase，例如 `auth_user` 对应 `AuthUser`。

数据库查询优先使用 MyBatis-Plus 的类型安全写法。复杂查询才新增 XML，并把 XML 放在 `src/main/resources/mapper/` 下与 Mapper 对应。任何新增唯一性、索引、状态字段都要同步说明数据库变更。

## 6. 安全与配置

当前配置中存在数据库连接凭据，当前 `JwtUtil` 中存在硬编码签名密钥。继续开发前必须完成以下整改：

1. 从源码和提交历史可见配置中移除真实数据库密码、JWT 密钥及第三方服务密钥。
2. 使用环境变量、外部配置中心或密钥管理服务注入敏感配置。
3. `application.yml` 只保留非敏感默认值和配置键名；不同环境使用 profile 文件或部署环境变量。
4. 如果凭据曾经提交到版本库，应立即轮换凭据，单纯修改文件不能使旧凭据失效。
5. 日志中不得输出密码、JWT、验证码、完整手机号或完整 IP 的敏感组合。
6. 生产环境关闭 SQL 明文日志和 Swagger/Knife4j，除非有明确访问控制。
7. 密码只保存 Argon2 哈希，禁止可逆加密或明文保存。
8. 所有受保护接口必须接入 JWT 过滤器；仅配置 `anyRequest().authenticated()` 不等于已经完成 Token 鉴权。

## 7. 异常、事务与日志

业务可预期错误使用 `BusinessException`，由 `GlobalExceptionHandler` 转换为统一响应。系统异常记录服务端堆栈并返回通用错误信息，不得把 SQL、密钥、堆栈或内部路径返回给客户端。

涉及用户创建、状态变更、登录信息更新的 Service 方法应明确事务边界，使用 `@Transactional`。Redis 与数据库无法自动组成事务时，必须设计幂等、补偿或失败重试策略。

日志要求：

- 使用参数化日志，不使用字符串拼接。
- 关键业务日志包含 requestId、业务动作和结果。
- 认证失败日志避免记录完整凭据。
- 限流、验证码和外部服务异常要有可检索的结构化上下文。

## 8. 新增服务的规则

新增业务服务时：

1. 在根 `pom.xml` 注册 Maven module。
2. 创建独立模块 `xxx-service` 和独立启动类。
3. 使用独立包名 `com.asyouwish.xxx`，不要跨服务直接引用实现类。
4. 通过 HTTP、RPC、消息或明确的共享契约通信。
5. 每个服务拥有自己的配置、Controller、Service、Mapper 和 Entity 边界。
6. 数据库表按业务域前缀命名，避免多个服务直接修改同一业务表。
7. 先定义 DTO 和接口契约，再实现业务流程和持久化。

## 9. 当前待修复项

以下问题已经在现有代码中发现，修复时应优先处理：

- `AuthController` 当前调用 `sendSmsCode` 时缺少 IP 参数，而 `UserService` 已定义为 `sendSmsCode(String phone, String ip)`；应统一由请求层解析可信客户端 IP 后传入。
- `UserServiceImpl` 存在未完成的字段声明，当前实现需要先恢复可编译状态。
- `SmsRegisterDTO` 只有密码做校验，手机号和验证码也必须补充校验。
- `SmsLoginDTO`、`PasswordLoginDTO`、`SendSmsDTO` 的输入校验尚不完整。
- JWT 过滤器和用户认证上下文尚未实现，应补齐后再开放受保护业务接口。
- `application-dev.yml` 为空，环境配置应明确区分开发、测试和生产，并避免把真实凭据写入版本库。

修复这些项目时保持小步提交，每次变更只解决一个清晰问题，并在提交说明中注明验证命令和外部依赖条件。

## 10. 代码风格

- 保持现有 Java 8 兼容性，不使用更高版本语法或 API。
- 类、方法和变量使用清晰的英文命名；注释说明原因和业务规则，不重复代码表面含义。
- 一个方法只负责一个清晰的业务步骤，复杂流程拆成可测试的私有方法或组件。
- 优先使用构造器注入；可以使用 Lombok `@RequiredArgsConstructor`，但不要注入可变静态状态。
- 不随意引入新依赖；先检查根 `dependencyManagement`，统一版本后再添加依赖。
- 不提交 `target/`、IDE 配置、日志、数据库导出文件和任何密钥。
- 修改接口时同步更新 Knife4j 注解或接口文档，并说明兼容性影响。

## 11. 开源组件调研与复用（强制）

禁止重复造轮子。实现任何功能之前，必须先检查项目已有能力和依赖，再检索 GitHub 是否存在成熟、适配的开源组件；完成调研后再开始功能实现。

- 优先复用项目已有组件，以及成熟开源项目提供的能力，通过配置、组合或薄适配层满足需求，避免自行重写已有能力。
- 评估候选组件时，核查官方文档、维护状态、发布记录、实际使用情况、许可证、安全记录和测试质量，不能仅凭 Star 数判断成熟度。
- 核查组件与本项目 Java 8、Spring Boot 2.7.x、Spring Cloud 及现有依赖的兼容性，同时评估依赖体积、接入成本和长期维护成本。
- 在任务说明、设计记录或提交说明中简要记录检索关键词、候选 GitHub 仓库链接、适配情况和最终选择理由，保证选型可追溯。
- 只有在未找到适用的成熟组件，或候选组件存在明确的兼容性、许可证、维护或功能缺口时，才自行实现相应能力，并记录调研证据和自行实现的原因。
- 引入组件时优先使用正式发布版本和官方推荐接入方式，遵守根 `dependencyManagement` 的版本管理约定，不复制整套开源源码到业务模块。
- GitHub 检索不可用时，应明确记录调研尚未完成；恢复检索后再完成选型，不得声称已检索或未经核实就断言没有可用组件。

## 12. Git 提交规范（强制）

使用 Conventional Commits 风格；类型和范围使用小写英文，摘要和正文可以使用中文。

### 12.1 格式

```text
<type>(<scope>): <简洁说明>

<可选正文：变更原因、实现要点、验证结果和兼容性影响>

<可选页脚：关联事项或不兼容变更说明>
```

- 本项目要求填写 scope，优先使用 `auth`、`captcha`、`sms`、`security`、`db`、`deps`、`docs`、`build`、`ci` 等明确范围；跨模块的统一变更可以使用 `repo`。
- 摘要说明“做了什么”，使用“新增、修复、移除、统一”等明确动词，不以句号结尾，建议不超过 72 个字符。
- 禁止使用 `update`、`修改代码`、`修复问题`、`提交一下` 等无法表达具体意图的摘要。

### 12.2 提交类型

| type | 用途 | 示例 |
| --- | --- | --- |
| `feat` | 新增对外功能或业务能力 | `feat(auth): 新增短信验证码登录` |
| `fix` | 修复已有功能、逻辑或安全缺陷 | `fix(auth): 拒绝禁用账号登录` |
| `refactor` | 不改变对外行为的内部结构调整 | `refactor(auth): 将验证码编排移入 Service` |
| `perf` | 保持功能语义的性能优化 | `perf(db): 优化用户查询索引` |
| `docs` | 仅修改文档、注释或开发规范 | `docs(docs): 补充 Git 提交规范` |
| `test` | 新增或调整测试代码 | `test(auth): 覆盖验证码并发消费场景` |
| `build` | 构建脚本、打包配置或依赖调整 | `build(deps): 升级短信供应商 SDK` |
| `ci` | 持续集成、检查或发布流水线 | `ci(ci): 增加 Maven 验证任务` |
| `style` | 不影响行为的格式、空白和排版调整 | `style(auth): 统一 Java 代码缩进` |
| `chore` | 不属于以上类型的日常维护 | `chore(repo): 调整忽略规则` |
| `revert` | 回退已有提交 | `revert(auth): 回退短信登录变更` |

按变更目的选择类型：安全缺陷修复使用 `fix`，不要归入 `chore`；行为改变不能伪装为 `refactor`；功能实现附带必要测试时仍按 `feat` 或 `fix` 提交，不必机械拆分。

### 12.3 正文、验证与关联事项

非纯文档或格式变更，应在正文说明原因和验证情况；涉及数据库、接口、配置项或开源组件选型时，同步说明迁移影响、仓库链接或设计记录位置。

```text
fix(sms): 原子消费验证码以防止并发重复使用

原因：独立读取和删除允许并发请求读取同一验证码。
变更：使用原子操作完成校验与消费，并补充并发测试。
验证：mvn -pl auth-service -am verify（通过）
影响：接口字段保持不变。

Closes #123
```

- 示例中的结果仅展示格式，实际提交必须填写真实执行的命令和结果；未执行或被环境阻塞时必须如实说明。
- 只有真实存在且确实被本次提交解决的事项才使用 `Closes #编号`；仅关联时使用 `Refs #编号`，没有事项编号则省略。
- 回退提交应在正文记录被回退提交的哈希和回退原因。

### 12.4 不兼容变更

破坏接口、配置或数据兼容性时，在类型/范围后加 `!`，并使用 `BREAKING CHANGE:` 页脚说明影响和迁移方法。

```text
feat(auth)!: 统一登录响应字段

BREAKING CHANGE: 登录响应由 token 改为 accessToken，调用方需同步更新字段读取逻辑。
```

### 12.5 提交边界与安全

- 一次提交只解决一个清晰问题，不夹带无关重构、格式化或其他功能；确保必要实现、配置和测试构成可理解的完整变更。
- 提交前审查暂存区差异，避免将其他人的改动、密钥、验证码、Token、日志、构建产物或 IDE 文件意外提交。
- 不在提交信息中写入真实凭据或个人敏感数据；密钥泄露修复还需轮换密钥，单次删除不能消除历史泄露。
- 修改数据库结构需同时提供可审查的迁移说明或迁移脚本，注明兼容性和回滚限制。
- 编写规范不代表授权执行 Git 操作；未经用户明确要求，不自动提交、推送、修改历史或创建标签。

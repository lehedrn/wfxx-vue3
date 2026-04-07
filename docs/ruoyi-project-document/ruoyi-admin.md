# RuoYi-Admin Web 服务入口模块

## 概述

`ruoyi-admin` 是若依框架的 Web 服务入口模块，负责整合所有功能子模块并提供 RESTful API 接口。

**源码位置**: `ruoyi-admin/src/main/java/com/ruoyi/`

## 依赖关系

```
ruoyi-admin
├── ruoyi-framework    # 核心框架（安全、拦截器）
├── ruoyi-quartz       # 定时任务
├── ruoyi-generator    # 代码生成器
└── ruoyi-demo         # 演示模块
```

## 技术栈

| 技术 | 说明 |
|------|------|
| Spring Boot | Web 框架 |
| Spring Security | 安全认证 |
| MyBatis + PageHelper | ORM + 分页 |
| Redis | 缓存/Token 存储 |
| MySQL | 主数据库 |
| Druid | 连接池监控 |
| Springdoc/Swagger | API 文档 |
| Kaptcha | 验证码生成 |

## 目录结构

```
ruoyi-admin/
├── src/main/
│   ├── java/com/ruoyi/
│   │   ├── RuoYiApplication.java          # 主启动类
│   │   ├── RuoYiServletInitializer.java   # Servlet 初始化
│   │   └── web/
│   │       ├── controller/                # 控制器层
│   │       │   ├── common/                # 公共控制器
│   │       │   ├── system/                # 系统管理控制器
│   │       │   ├── monitor/               # 监控控制器
│   │       │   └── tool/                  # 工具测试控制器
│   │       └── core/
│   │           └── config/
│   │               └── SwaggerConfig.java # Swagger 配置
│   └── resources/
│       ├── application.yml                # 主配置文件
│       ├── application-druid.yml          # 数据源配置
│       ├── logback.xml                    # 日志配置
│       └── mybatis/mybatis-config.xml     # MyBatis 配置
```

---

## 快速入门

### 1. 环境要求

- JDK 17+
- MySQL 5.7+ / 8.0+
- Redis 6.0+
- Maven 3.6+

### 2. 配置说明

**application.yml** 主要配置项：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| server.port | 18080 | 服务端口 |
| ruoyi.profile | /home/workspace/com/wfxx-vue3/upload_path | 文件上传路径 |
| ruoyi.captchaType | math | 验证码类型（math/char） |
| spring.redis.host | localhost | Redis 地址 |
| spring.redis.password | lihaidong | Redis 密码 |
| token.expireTime | 30 | Token 有效期（分钟） |

### 3. 启动项目

```bash
cd ruoyi-admin
mvn clean install
mvn spring-boot:run
```

启动成功后看到：
```
(♥◠‿◠) ﾉﾞ  若依启动成功   ლ(´ڡ`ლ)ﾞ
```

### 4. 访问接口

- 服务地址：http://localhost:18080
- Swagger 文档：http://localhost:18080/swagger-ui.html
- API 文档：http://localhost:18080/v3/api-docs

---

## API 接口总览

### 公共接口 (common/)

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| CaptchaController | `/captchaImage` | GET | 生成验证码 |
| CommonController | 通用 | - | 通用下载、健康检查 |

### 系统管理接口 (system/)

| 接口 | 路径 | 说明 |
|------|------|------|
| SysLoginController | `/login`, `/getInfo`, `/getRouters` | 登录认证、获取用户信息、路由信息 |
| SysRegisterController | `/register` | 用户注册 |
| SysUserController | `/system/user/*` | 用户 CRUD、导入导出、授权、重置密码 |
| SysRoleController | `/system/role/*` | 角色管理、权限分配 |
| SysMenuController | `/system/menu/*` | 菜单树管理 |
| SysDeptController | `/system/dept/*` | 部门树管理 |
| SysPostController | `/system/post/*` | 岗位管理 |
| SysConfigController | `/system/config/*` | 系统参数配置 |
| SysDictTypeController | `/system/dict/type/*` | 字典类型管理 |
| SysDictDataController | `/system/dict/data/*` | 字典数据管理 |
| SysNoticeController | `/system/notice/*` | 通知公告管理 |
| SysProfileController | `/system/user/profile/*` | 个人中心（头像、密码修改） |
| SysIndexController | `/` | 首页入口 |

### 系统监控接口 (monitor/)

| 接口 | 路径 | 说明 |
|------|------|------|
| CacheController | `/monitor/cache/*` | Redis 缓存监控、清理 |
| ServerController | `/monitor/server` | 服务器信息（CPU、内存、磁盘） |
| SysLogininforController | `/monitor/logininfor/*` | 登录日志查询、解锁 |
| SysOperlogController | `/monitor/operlog/*` | 操作日志查询 |
| SysUserOnlineController | `/monitor/online/*` | 在线用户管理、强退 |

### 工具测试接口 (tool/)

| 接口 | 路径 | 说明 |
|------|------|------|
| TestController | `/test/user/*` | Swagger API 测试示例 |

---

## 核心功能

### 1. 登录认证流程

```
1. 客户端请求 /captchaImage 获取验证码
2. 客户端发送账号密码 + 验证码到 /login
3. SysLoginService 验证 credentials
4. 生成 Token 存入 Redis（30 分钟有效期）
5. 客户端携带 Token 访问受保护接口
6. JwtAuthenticationTokenFilter 拦截验证
7. 通过 @PreAuthorize 进行权限校验
```

详细流程见：[核心流程/登录认证流程.md](ruoyi-admin/03-登录认证流程.md)

### 2. 权限控制

- **功能权限**：`@PreAuthorize("@ss.hasPermi('system:user:list')")`
- **角色权限**：`@PreAuthorize("@ss.hasRole('admin')")`
- **数据权限**：通过 `@DataScope` 注解实现部门数据范围控制

### 3. 日志记录

```java
@Log(title = "用户管理", businessType = BusinessType.ADD)
@PostMapping
public AjaxResult add(@Validated @RequestBody SysUser user)
```

自动记录操作日志到 `sys_oper_log` 表。

---

## 子模块文档

| 文档 | 说明 |
|------|------|
| [config.md](ruoyi-admin/config.md) | 配置类详解（SwaggerConfig、application.yml 等） |
| [controller.md](ruoyi-admin/controller.md) | 控制器层 API 接口文档（所有 REST 接口） |
| [03-登录认证流程.md](ruoyi-admin/03-登录认证流程.md) | 登录认证完整流程解析（验证码、Token、JWT） |
| [04-权限验证流程.md](ruoyi-admin/04-权限验证流程.md) | 权限验证机制详解（@PreAuthorize、数据权限） |
| [curl-登录认证脚本.md](ruoyi-admin/curl-登录认证脚本.md) | 登录认证流程 curl 测试脚本（Postman 集合） |

---

## 配置项详解

### token 配置

```yaml
token:
  header: Authorization      # Token 请求头
  secret: abcdefghijklmnopqrstuvwxyz  # 密钥
  expireTime: 30             # 有效期（分钟）
```

### 用户密码配置

```yaml
user:
  password:
    maxRetryCount: 5         # 密码最大错误次数
    lockTime: 10             # 锁定时间（分钟）
```

### XSS 过滤配置

```yaml
xss:
  enabled: true              # 过滤开关
  excludes: /system/notice   # 排除链接
  urlPatterns: /system/*,/monitor/*,/tool/*  # 匹配链接
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-08  
**基于版本**: RuoYi v3.9.2

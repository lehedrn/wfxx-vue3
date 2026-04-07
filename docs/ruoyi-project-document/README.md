# RuoYi-Vue 项目文档索引

**文档版本**: 1.0  
**最后更新**: 2026-04-08  
**项目版本**: RuoYi-Vue 3.9.2

---

## 文档导航

本文档是 RuoYi-Vue 项目文档的总索引，提供按模块分类的完整文档导航。

### 快速链接

| 模块 | 说明 | 文档 |
|------|------|------|
| 🖥️ **ruoyi-admin** | Web 服务入口模块 | [详情](./ruoyi-admin.md) |
| 🔧 **ruoyi-common** | 通用工具模块 | [详情](./ruoyi-common.md) |
| 🏗️ **ruoyi-framework** | 核心框架模块 | [详情](./ruoyi-framework.md) |
| 📋 **ruoyi-system** | 系统管理模块 | [详情](./ruoyi-system.md) |
| ⏰ **ruoyi-quartz** | 定时任务模块 | [详情](./ruoyi-quartz.md) |
| 🎨 **ruoyi-generator** | 代码生成器模块 | [详情](./ruoyi-generator.md) |
| 🔨 **ruoyi-gen-cli** | CLI 代码生成工具 | [详情](./ruoyi-gen-cli.md) |
| 📚 **新建子模块指南** | 后端子模块创建流程 | [详情](./新建子模块指南.md) |
| 🎯 **ruoyi-ui** | Vue 3 前端 | [详情](./ruoyi-ui.md) |

---

## 后端模块文档

### 1. ruoyi-admin - Web 服务入口模块

**定位**: 若依框架的 Web 服务入口，负责整合所有功能子模块并提供 RESTful API 接口。

**技术栈**: Spring Boot, Spring Security, MyBatis, Redis, MySQL

**子文档**:

| 文档 | 说明 |
|------|------|
| [config.md](./ruoyi-admin/config.md) | 配置类（Swagger、CORS、文件上传等） |
| [controller.md](./ruoyi-admin/controller.md) | 控制器（公共、系统、监控、工具） |
| [03-登录认证流程.md](./ruoyi-admin/03-登录认证流程.md) | 登录认证完整流程 |
| [04-权限验证流程.md](./ruoyi-admin/04-权限验证流程.md) | 权限验证完整流程 |
| [curl-登录认证脚本.md](./ruoyi-admin/curl-登录认证脚本.md) | 登录认证 cURL 脚本示例 |

---

### 2. ruoyi-common - 通用工具模块

**定位**: 整个框架的基础依赖模块，提供共用的工具类、注解、常量、异常处理等组件。

**模块结构**:
```
ruoyi-common/
├── annotation/        # 自定义注解
├── config/            # 配置类
├── constant/          # 常量定义
├── core/              # 核心域模型
├── enums/             # 枚举类型
├── exception/         # 异常体系
├── filter/            # 过滤器链
├── utils/             # 工具类集合
└── xss/               # XSS 防护
```

**子文档**:

| 文档 | 说明 |
|------|------|
| [annotation.md](./ruoyi-common/annotation.md) | 自定义注解（@Log、@DataScope、@Excel 等） |
| [config.md](./ruoyi-common/config.md) | 配置类（RuoYiConfig、序列化器等） |
| [constant.md](./ruoyi-common/constant.md) | 常量定义（Constants、HttpStatus 等） |
| [core.md](./ruoyi-common/core.md) | 核心域模型（实体、响应、分页等） |
| [enums.md](./ruoyi-common/enums.md) | 枚举类型（BusinessType、UserStatus 等） |
| [exception.md](./ruoyi-common/exception.md) | 异常体系（ServiceException、UserException 等） |
| [filter.md](./ruoyi-common/filter.md) | 过滤器链（XSS 防护、防盗链等） |
| [utils.md](./ruoyi-common/utils.md) | 工具类集合（上）- 核心工具类 |
| [utils-part2.md](./ruoyi-common/utils-part2.md) | 工具类集合（下）- 功能工具类 |

---

### 3. ruoyi-framework - 核心框架模块

**定位**: 核心集成模块，提供 Spring Boot 应用的运行时基础设施。

**模块结构**:
```
ruoyi-framework/
├── config/                     # 配置类
├── security/                   # 安全认证
├── aspectj/                    # AOP 切面
├── interceptor/                # 拦截器
├── datasource/                 # 动态数据源
├── manager/                    # 异步任务管理
└── web/                        # Web 服务
```

**子文档**:

| 文档 | 说明 |
|------|------|
| [config.md](./ruoyi-framework/config.md) | 配置类（Druid、Redis、MyBatis、Security 等） |
| [security.md](./ruoyi-framework/security.md) | 安全认证（JWT 过滤器、认证入口等） |
| [aspectj.md](./ruoyi-framework/aspectj.md) | AOP 切面（日志、数据权限、数据源、限流） |
| [interceptor.md](./ruoyi-framework/interceptor.md) | 拦截器（防重复提交、同 URL 拦截） |
| [datasource.md](./ruoyi-framework/datasource.md) | 动态数据源切换 |
| [manager.md](./ruoyi-framework/manager.md) | 异步任务管理器 |
| [web-service.md](./ruoyi-framework/web-service.md) | Web 服务（登录、注册、Token、权限服务） |
| [server-monitoring.md](./ruoyi-framework/server-monitoring.md) | 服务监控 |

---

### 4. ruoyi-system - 系统管理模块

**定位**: 核心业务模块，提供系统管理功能的基础实现。

**核心功能**: 用户管理、角色管理、菜单管理、部门管理、岗位管理、字典管理、参数管理、公告管理、日志管理

**模块结构**:
```
ruoyi-system/
├── domain/      # 实体类层
├── mapper/      # MyBatis Mapper 接口
└── service/     # 业务服务层
```

**子文档**:

| 文档 | 说明 |
|------|------|
| [domain.md](./ruoyi-system/domain.md) | 系统实体类和视图对象 |
| [mapper.md](./ruoyi-system/mapper.md) | MyBatis Mapper 接口 |
| [service.md](./ruoyi-system/service.md) | 业务服务接口和实现 |

---

### 5. ruoyi-quartz - 定时任务模块

**定位**: 基于 Quartz 调度器的定时任务模块。

**功能特性**: 定时任务 CRUD、任务暂停/恢复/立即执行、Cron 表达式校验、Misfire 补偿策略、并发控制、日志记录

**子文档**:

| 文档 | 说明 |
|------|------|
| [domain.md](./ruoyi-quartz/domain.md) | 实体类（SysJob, SysJobLog） |
| [mapper.md](./ruoyi-quartz/mapper.md) | 数据访问层 |
| [service.md](./ruoyi-quartz/service.md) | 服务层（任务管理、调度操作） |
| [controller.md](./ruoyi-quartz/controller.md) | API 接口层 |
| [task-core.md](./ruoyi-quartz/task-core.md) | 任务调度核心逻辑 |

---

### 6. ruoyi-generator - 代码生成器模块

**定位**: 基于 Velocity 模板引擎的代码生成器模块。

**功能特性**: 单表 CRUD、树表 CRUD、主子表 CRUD、多前端支持、数据库类型自动映射、代码预览、ZIP 下载

**子文档**:

| 文档 | 说明 |
|------|------|
| [config.md](./ruoyi-generator/config.md) | 配置类（GenConfig, generator.yml） |
| [domain.md](./ruoyi-generator/domain.md) | 实体类（GenTable, GenTableColumn） |
| [mapper.md](./ruoyi-generator/mapper.md) | 数据访问层 |
| [controller.md](./ruoyi-generator/controller.md) | API 接口层 |
| [service.md](./ruoyi-generator/service.md) | 服务层（代码生成核心逻辑） |
| [generator-core.md](./ruoyi-generator/generator-core.md) | 代码生成核心（模板、类型映射、流程） |

---

### 7. ruoyi-gen-cli - CLI 代码生成工具

**定位**: 基于 ruoyi-generator 二次封装的独立可运行 JAR 包，提供 CLI 命令行方式的代码生成能力。

**核心特点**: 独立运行、DDL 驱动、配置灵活、批量生成

**文档列表**:

| 文档 | 说明 |
|------|------|
| **[操作手册](./ruoyi-gen-cli_操作手册.md)** | **团队标准操作规范（SOP）** |
| [01-概述.md](./ruoyi-gen-cli/01-概述.md) | 项目简介、特点、使用场景 |
| [02-快速开始.md](./ruoyi-gen-cli/02-快速开始.md) | 安装、配置、第一个生成示例 |
| [03-配置说明.md](./ruoyi-gen-cli/03-配置说明.md) | YAML 配置文件详解 |
| [04-命令参考.md](./ruoyi-gen-cli/04-命令参考.md) | CLI 命令参数说明 |
| [05-核心模块.md](./ruoyi-gen-cli/05-核心模块.md) | 核心模块源码分析 |
| [06-最佳实践.md](./ruoyi-gen-cli/06-最佳实践.md) | 使用技巧、常见问题 |
| [07-SQL_配置详解.md](./ruoyi-gen-cli/07-SQL_配置详解.md) | DDL SQL 语法规范、完整示例 |
| [08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) | 三种模板类型的 YAML 配置模板 |

---

## 前端模块文档

### 8. ruoyi-ui - Vue 3 前端管理系统

**定位**: 基于 Vue 3 + Vite + Element Plus 技术栈的企业级中后台管理系统前端解决方案。

**技术栈**: Vue 3.5.26, Vite 6.4.1, Element Plus 2.13.1, Pinia 3.0.4, Vue Router 4.6.4, Axios 1.13.2, ECharts 5.6.0

**特性**: 动态路由、按钮级权限控制、多主题支持、多布局模式、标签页导航、丰富的通用组件

**文档列表**:

| 文档 | 说明 |
|------|------|
| [01-工程概述.md](./ruoyi-ui/01-工程概述.md) | 项目简介、技术栈、目录结构 |
| [02-核心配置.md](./ruoyi-ui/02-核心配置.md) | Vite、环境变量、主题配置 |
| [03-路由系统.md](./ruoyi-ui/03-路由系统.md) | 路由配置、动态路由、路由守卫 |
| [04-状态管理.md](./ruoyi-ui/04-状态管理.md) | Pinia、用户状态、权限状态、标签状态 |
| [05-API 接口层.md](./ruoyi-ui/05-API 接口层.md) | Axios 封装、API 管理、请求拦截 |
| [06-通用组件.md](./ruoyi-ui/06-通用组件.md) | 22+ 个通用组件说明 |
| [07-页面模块.md](./ruoyi-ui/07-页面模块.md) | 系统管理、系统监控页面 |
| [08-工具函数.md](./ruoyi-ui/08-工具函数.md) | 通用工具函数、权限判断函数 |
| [09-自定义指令.md](./ruoyi-ui/09-自定义指令.md) | 权限指令、复制指令等 |
| [10-插件扩展.md](./ruoyi-ui/10-插件扩展.md) | 下载、导出、打印插件 |

---

## 附录

### A. 文档组织结构

```
docs/ruoyi-project-document/
├── README.md                      # 本索引文件
├── ruoyi-admin.md                 # Admin 模块入口
├── ruoyi-admin/
│   ├── config.md
│   ├── controller.md
│   ├── 03-登录认证流程.md
│   ├── 04-权限验证流程.md
│   └── curl-登录认证脚本.md
├── ruoyi-common.md                # Common 模块入口
├── ruoyi-common/
│   ├── annotation.md
│   ├── config.md
│   ├── constant.md
│   ├── core.md
│   ├── enums.md
│   ├── exception.md
│   ├── filter.md
│   ├── utils.md
│   └── utils-part2.md
├── ruoyi-framework.md             # Framework 模块入口
├── ruoyi-framework/
│   ├── config.md
│   ├── security.md
│   ├── aspectj.md
│   ├── interceptor.md
│   ├── datasource.md
│   ├── manager.md
│   ├── web-service.md
│   └── server-monitoring.md
├── ruoyi-system.md                # System 模块入口
├── ruoyi-system/
│   ├── domain.md
│   ├── mapper.md
│   └── service.md
├── ruoyi-quartz.md                # Quartz 模块入口
├── ruoyi-quartz/
│   ├── domain.md
│   ├── mapper.md
│   ├── service.md
│   ├── controller.md
│   └── task-core.md
├── ruoyi-generator.md             # Generator 模块入口
├── ruoyi-generator/
│   ├── config.md
│   ├── domain.md
│   ├── mapper.md
│   ├── controller.md
│   ├── service.md
│   └── generator-core.md
├── ruoyi-gen-cli.md               # Gen-CLI 入口
├── ruoyi-gen-cli/
│   ├── 01-概述.md
│   ├── 02-快速开始.md
│   ├── 03-配置说明.md
│   ├── 04-命令参考.md
│   ├── 05-核心模块.md
│   ├── 06-最佳实践.md
│   ├── 07-SQL_配置详解.md
│   └── 08-配置模板.md
├── ruoyi-gen-cli_操作手册.md       # Gen-CLI 操作手册
├── 新建子模块指南.md               # 后端子模块创建流程
├── ruoyi-ui.md                    # UI 前端入口
└── ruoyi-ui/
    ├── 01-工程概述.md
    ├── 02-核心配置.md
    ├── 03-路由系统.md
    ├── 04-状态管理.md
    ├── 05-API 接口层.md
    ├── 06-通用组件.md
    ├── 07-页面模块.md
    ├── 08-工具函数.md
    ├── 09-自定义指令.md
    └── 10-插件扩展.md
```

### B. 文档统计

| 模块 | 文档数量 |
|------|---------|
| ruoyi-admin | 4 篇 |
| ruoyi-common | 9 篇 |
| ruoyi-framework | 8 篇 |
| ruoyi-system | 3 篇 |
| ruoyi-quartz | 5 篇 |
| ruoyi-generator | 6 篇 |
| ruoyi-gen-cli | 9 篇 + 操作手册 |
| ruoyi-ui | 10 篇 |
| **总计** | **56 篇** |

---

**文档维护**: 请确保文档与代码保持同步更新。  
**贡献指南**: 如发现文档错误或需要补充，请提交 PR 或直接联系维护者。

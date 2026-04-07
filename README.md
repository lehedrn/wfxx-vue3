<p align="center">
		<img alt="logo" src="https://oscimg.oschina.net/oscnet/up-d3d0a9303e11d522a06cd263f3079027715.png">
</p>
<h1 align="center" style="margin: 30px 0 30px; font-weight: bold;">wfxx-vue3</h1>
<h4 align="center">基于 RuoYi-Vue 3.9.2 的定制化快速开发框架</h4>
<p align="center">
	<a href="https://gitee.com/y_project/RuoYi-Vue"><img src="https://img.shields.io/badge/RuoYi-v3.9.2-brightgreen.svg"></a>
	<a href="https://gitee.com/y_project/RuoYi-Vue/blob/master/LICENSE"><img src="https://img.shields.io/github/license/mashape/apistatus.svg"></a>
</p>

---

## 项目简介

本项目基于 **RuoYi-Vue 3.9.2** 进行定制化开发，针对官方版本进行了以下增强：

- **后端**: Spring Boot 4.0.3 + JDK 17+
- **前端**: Vue 3.5.26 + Vite 6.4.1 + Element Plus 2.13.1 + Pinia
- **特色功能**: 代码生成器 CLI 工具、E2E 自动化测试、完善的项目文档体系

---

## 快速开始

### 环境要求

| 环境 | 版本 | 说明 |
|------|------|------|
| JDK | 17+ | Spring Boot 4.x 要求 |
| MySQL | 5.7+ | 数据库 |
| Redis | 最新稳定版 | 缓存 |
| Node.js | 18+ | 前端运行环境 |
| pnpm | 8+ | 前端包管理器 |

### 一键启动

```bash
# 1. 启动 MySQL 和 Redis（Docker）
docker restart mysql8
docker restart redis8

# 2. 启动后端服务（端口 18080）
scripts/run-backend.sh -d

# 3. 启动前端服务（端口 3888）
scripts/run-frontend.sh -d

# 4. 访问系统
# 浏览器打开：http://localhost:3888
# 默认账号：admin / admin123
```

详细环境配置请参考 [开发环境配置文档](docs/ruoyi-project-document/00-开发环境配置.md)。

---

## 内置功能

| 功能模块 | 说明 |
|----------|------|
| 用户管理 | 系统用户配置 |
| 部门管理 | 组织机构配置（树形结构 + 数据权限） |
| 岗位管理 | 用户职务配置 |
| 菜单管理 | 菜单 + 操作权限 + 按钮权限 |
| 角色管理 | 角色权限分配 + 数据范围权限 |
| 字典管理 | 系统常量数据维护 |
| 参数管理 | 动态配置系统参数 |
| 通知公告 | 系统公告发布维护 |
| 操作日志 | 操作日志记录查询 |
| 登录日志 | 登录日志记录查询 |
| 在线用户 | 活跃用户监控 |
| 定时任务 | 任务调度 + 执行日志 |
| 代码生成 | 一键生成前后端代码 |
| 系统接口 | 自动生成 API 文档 |
| 服务监控 | CPU/内存/磁盘/连接池监控 |
| 缓存监控 | 缓存信息查询统计 |

---

## 项目特色

### 1. 代码生成器 CLI

使用 CLI 工具快速生成前后端代码：

```bash
# 列出生成的代码配置
scripts/gen-code.sh --list

# 生成代码（模块名 + 子模块名）
scripts/gen-code.sh demo student
```

详细使用请参考 [ruoyi-gen-cli 操作手册](docs/ruoyi-project-document/ruoyi-gen-cli_操作手册.md)。

### 2. E2E 自动化测试

使用 Playwright 进行前后端联调测试：

```bash
# 运行所有 E2E 测试
cd scripts/test/e2e && pnpm test

# 运行指定模块测试
pnpm test:student    # 学生管理测试
pnpm test:customer   # 客户管理测试
pnpm test:product    # 产品管理测试
```

详细规范请参考 [E2E 联调测试规范](docs/standards/test/e2e-testing.md)。

### 3. 后端接口测试

使用 curl 进行后端 API 测试：

```bash
# 运行后端 API 测试
scripts/test/curl/test-demo-api.sh
```

详细规范请参考 [后端接口测试规范](docs/standards/test/backend-api.md)。

### 4. 完善的项目文档

| 文档类型 | 位置 |
|----------|------|
| 环境配置 | [docs/ruoyi-project-document/00-开发环境配置.md](docs/ruoyi-project-document/00-开发环境配置.md) |
| 技术文档 | [docs/ruoyi-project-document/](docs/ruoyi-project-document/README.md) |
| 开发规范 | [docs/standards/](docs/standards/README.md) |
| 脚本指南 | [scripts/README.md](scripts/README.md) |

---

## 目录结构

```
wfxx-vue3/
├── ruoyi-admin/          # 入口服务模块
├── ruoyi-common/         # 通用工具模块
├── ruoyi-framework/      # 框架配置模块
├── ruoyi-system/         # 系统业务模块
├── ruoyi-quartz/         # 定时任务模块
├── ruoyi-generator/      # 代码生成器模块
├── ruoyi-gen-cli/        # 命令行代码生成工具
├── ruoyi-demo/           # 示例模块
├── ruoyi-ui/             # 前端项目（Vue 3 + Vite）
├── scripts/              # 项目脚本工具
│   ├── build.sh          # 构建脚本
│   ├── run-backend.sh    # 运行后端
│   ├── run-frontend.sh   # 运行前端
│   ├── clean.sh          # 清理脚本
│   └── gen-code.sh       # 代码生成
└── docs/                 # 项目文档
    ├── standards/        # 开发规范
    └── ruoyi-project-document/  # 技术文档
```

---

## 开发规范

| 规范类型 | 文档 |
|----------|------|
| 后端编码规范 | [standards/coding/backend.md](docs/standards/coding/backend.md) |
| 前端编码规范 | [standards/coding/frontend.md](docs/standards/coding/frontend.md) |
| API 设计规范 | [standards/api-design.md](docs/standards/api-design.md) |
| 提交规范 | [standards/commit.md](docs/standards/commit.md) |
| 后端接口测试 | [standards/test/backend-api.md](docs/standards/test/backend-api.md) |
| E2E 联调测试 | [standards/test/e2e-testing.md](docs/standards/test/e2e-testing.md) |

---

## 演示图

<table>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/cd1f90be5f2684f4560c9519c0f2a232ee8.jpg"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/1cbcf0e6f257c7d3a063c0e3f2ff989e4b3.jpg"/></td>
    </tr>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-8074972883b5ba0622e13246738ebba237a.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-9f88719cdfca9af2e58b352a20e23d43b12.png"/></td>
    </tr>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-39bf2584ec3a529b0d5a3b70d15c9b37646.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-936ec82d1f4872e1bc980927654b6007307.png"/></td>
    </tr>
</table>

---

## 相关资源

| 资源 | 链接 |
|------|------|
| 若依官方文档 | http://doc.ruoyi.vip |
| 若依演示地址 | http://vue.ruoyi.vip |
| 若依 Gitee 仓库 | https://gitee.com/y_project/RuoYi-Vue |

---

## 许可证

本项目的代码遵循 [MIT License](https://gitee.com/y_project/RuoYi-Vue/blob/master/LICENSE) 开源协议。

---

**最后更新**: 2026-04-08

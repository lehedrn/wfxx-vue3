# 项目上下文 (Project Context)

本文档帮助 AI 快速理解项目上下文，详细技术文档请参考 [文档总索引](./docs/ruoyi-project-document/README.md)。

---

## 1. 项目概述

RuoYi-Vue 3.9.2 - 基于 Spring Boot 4.x + Vue 3 的前后端分离快速开发框架

- **后端**: Spring Boot 4.x, JDK 17+, MyBatis, Redis, MySQL
- **前端**: Vue 3.5.26, Vite 6.4.1, Element Plus 2.13.1, Pinia
- **模块**: 8 个后端模块 + 1 个前端模块

---

## 2. 快速命令

详细脚本请参考 `scripts/` 目录。

### 后端
```bash
scripts/build.sh          # 构建后端
scripts/run-backend.sh    # 运行后端（端口 18080）
scripts/test.sh           # 运行测试
```

### 前端
```bash
scripts/run-frontend.sh   # 运行前端（端口 3888，使用 pnpm）
```

### 代码生成
```bash
java -jar ruoyi-gen-cli.jar --sql=xxx.sql --config=xxx.yml --output=xxx.zip
```

---

## 3. AI 行为偏好

### 修改代码前
- 先解释变更内容，确认后执行

### 修改完成后
- **不要主动提交 git**
- 等待用户确认修改无误
- 收到明确指令后再提交 git 并推送到远程

### 错误修复
- 优先修复当前任务相关的错误
- 发现无关 bug 时先记录，等当前任务完成后询问是否修复

### 输出语言
- 回复：中文
- 代码注释：中文

### 文档更新
- 修改代码时同步更新相关文档

### 交互记录
- 每次 AI 交互记录到 `docs/changelogs/` 目录
- 按日期命名文件（如 `2026-04-07.md`）

### 文档写入规范
- 单次写入超过 200 行时，分段完成（每次 100-200 行）
- 文档内容过大时，进行文档拆分（按主题或章节）
- 拆分后的文档通过索引文档组织

---

## 4. 代码生成流程

### 步骤 1：使用代码生成器
- 参考 [ruoyi-gen-cli 操作手册](./docs/ruoyi-project-document/ruoyi-gen-cli_操作手册.md)
- 编写 DDL SQL 和 YAML 配置
- 执行生成命令生成基础代码

### 步骤 2：集成基础代码
- 将生成的代码复制到项目对应目录
- 执行菜单 SQL 注册功能

### 步骤 3：编写业务逻辑
- 在生成的 Service 层添加业务规则
- 在生成的 Controller 层添加自定义接口
- 在生成的 Vue 页面添加业务组件

### 步骤 4：更新文档
- 同步更新相关文档
- 记录到 docs/changelogs/

---

## 5. 开发规范

详细规范文档请参考以下文档（待创建）：

| 规范类型 | 文档链接 | 状态 |
|---------|---------|------|
| 规范文档索引 | [standards/README.md](./docs/standards/README.md) | 待创建 |
| 编码规范 | [standards/coding.md](./docs/standards/coding.md) | 待创建 |
| 需求文档规范 | [standards/requirement.md](./docs/standards/requirement.md) | 待创建 |
| 提交规范 | [standards/commit.md](./docs/standards/commit.md) | 待创建 |
| 自动化测试规范 | [standards/testing.md](./docs/standards/testing.md) | 待创建 |
| API 设计规范 | [standards/api-design.md](./docs/standards/api-design.md) | 待创建 |

---

## 6. 文档索引

### 技术文档
- [文档总索引](./docs/ruoyi-project-document/README.md)
- [ruoyi-gen-cli 操作手册](./docs/ruoyi-project-document/ruoyi-gen-cli_操作手册.md)
- [前端 ruoyi-ui](./docs/ruoyi-project-document/ruoyi-ui.md)

### 规范文档
- [规范文档索引](./docs/standards/README.md) *(待创建)*

### 变更记录
- [交互记录](./docs/changelogs/) *(待创建)*
- [经验总结](./docs/lessons/) *(待创建)*

---

## 7. 特殊说明

- 端口：后端 18080，前端 3888
- 日志目录：`logs/backend/` 和 `logs/frontend/`
- 包管理器：前端使用 pnpm
- 已知问题：暂无

---

**最后更新**: 2026-04-07

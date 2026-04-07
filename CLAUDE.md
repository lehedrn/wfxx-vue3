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

详细脚本请参考 `scripts/` 目录，完整使用指南见 [scripts/README.md](scripts/README.md)。

### 后端
```bash
scripts/build.sh          # 构建后端（完整构建）
scripts/build.sh -q       # 快速构建（清理 + 跳过测试）
scripts/build.sh -i       # 安装到本地 Maven 仓库
scripts/build.sh -m ruoyi-admin  # 构建指定模块
scripts/build.sh --help   # 查看帮助
scripts/run-backend.sh    # 运行后端（端口 18080）
scripts/run-backend.sh -d # 后台运行（等待启动完成）
scripts/run-backend.sh -s # 停止服务
scripts/run-backend.sh -r # 重启服务
scripts/run-backend.sh --health  # 健康检查
scripts/run-backend.sh --status  # 查看状态
scripts/test.sh           # 运行测试
scripts/clean.sh          # 清理构建产物
scripts/clean.sh --dry-run  # 预览清理内容
```

### 前端
```bash
scripts/run-frontend.sh   # 运行前端（端口 3888，使用 pnpm）
scripts/run-frontend.sh -d  # 后台运行（等待启动完成）
scripts/run-frontend.sh -i  # 安装依赖
scripts/run-frontend.sh -s  # 停止服务
scripts/run-frontend.sh --health  # 健康检查
scripts/run-frontend.sh --status  # 查看状态
```

### 代码生成
```bash
# 用法：scripts/gen-code.sh <module> <submodule> [配置文件名]
scripts/gen-code.sh demo student
scripts/gen-code.sh demo student student  # 指定配置文件名（不含后缀）
scripts/gen-code.sh --list                # 列出可用配置
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
- 文档内容过大时，先根据当前情况拆分并创建分文档，然后依次写入分文档
- 拆分策略：按主题拆分或按模块拆分
- 拆分后的文档通过索引文档组织
- 避免上下文丢失

### 命名规范
- 文件名、目录名使用小写字母
- 单词间使用下划线 `_` 连接
- **不要使用空格**
- 中文文件名允许（如 `01-概述.md`）

---

## 4. 代码生成流程

### 步骤 1：使用代码生成器
- 参考 [ruoyi-gen-cli 操作手册](./docs/ruoyi-project-document/ruoyi-gen-cli_操作手册.md)
- 编写 DDL SQL 和 YAML 配置
- 使用 `scripts/gen-code.sh` 脚本生成基础代码

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
- [交互记录](./docs/changelogs/) - 记录每次 AI 交互内容
- [经验总结](./docs/lessons/) - 技术实践和经验总结

---

## 7. 特殊说明

- 端口：后端 18080，前端 3888
- 日志目录：`logs/backend/` 和 `logs/frontend/`
- 包管理器：前端使用 pnpm
- 已知问题：暂无

---

## 8. 项目配置

### 8.1 项目根目录

**多人在发时，请在 CLAUDE.md 中配置项目根目录绝对路径**：

```bash
# 项目根目录绝对路径（请根据实际位置修改）
PROJECT_ROOT="/home/workspace/com/wfxx-vue3"
```

### 8.2 代码生成目录结构

```
${PROJECT_ROOT}/
├── generate/
│   ├── config/          # 代码生成配置文件
│   │   └── {module}/
│   │       └── {submodule}/
│   │           ├── *.sql
│   │           └── *.yml
│   └── output/          # 代码生成输出
│       └── {module}/
│           └── {submodule}/
│               └── *.zip
└── ruoyi-gen-cli/
    └── target/
        └── ruoyi-gen-cli.jar   # 代码生成器 JAR
```

---

**最后更新**: 2026-04-07

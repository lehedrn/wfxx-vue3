# 项目脚本使用指南

本文档详细介绍项目中所有脚本的用法和示例。

---

## 快速索引

| 脚本 | 用途 | 常用命令 |
|------|------|----------|
| [build.sh](#buildsh) | 构建后端项目 | `scripts/build.sh -q` |
| [run-backend.sh](#run-backendsh) | 运行后端服务 | `scripts/run-backend.sh -d` |
| [run-frontend.sh](#run-frontendsh) | 运行前端服务 | `scripts/run-frontend.sh -d` |
| [test.sh](#testsh) | 运行测试 | `scripts/test.sh` |
| [clean.sh](#cleansh) | 清理构建产物 | `scripts/clean.sh` |
| [gen-code.sh](#gen-codesh) | 代码生成器 | `scripts/gen-code.sh demo student` |

---

## build.sh

构建后端项目脚本。

### 用法

```bash
scripts/build.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--skip-tests` | `-st` | 跳过测试 |
| `--clean` | `-c` | 清理后构建 |
| `--quick` | `-q` | 快速构建（清理 + 跳过测试） |
| `--install` | `-i` | 安装到本地 Maven 仓库 |
| `--module` | `-m` | 构建指定模块 |
| `--help` | `-h` | 显示帮助 |

### 示例

```bash
# 完整构建（包含测试）
scripts/build.sh

# 快速构建（清理 + 跳过测试）
scripts/build.sh -q

# 快速构建并安装到本地 Maven 仓库
scripts/build.sh -q -i

# 构建指定模块（如 ruoyi-gen-cli）
scripts/build.sh -m ruoyi-gen-cli -q

# 构建指定模块并安装
scripts/build.sh -m ruoyi-admin -q -i

# 查看帮助
scripts/build.sh --help
```

### 构建模式说明

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| 完整构建 | 包含所有测试 | 正式发布前 |
| 跳过测试 | 不运行测试 | 开发调试 |
| 快速构建 | 清理 + 跳过测试 | 日常开发最常用 |
| 指定模块 | 只构建指定模块及其依赖 | 修改单个模块时 |

### 输出

- 构建日志：`logs/backend/build-YYYYMMDD-HHMMSS.log`
- JAR 文件：各模块 `target/` 目录下

---

## run-backend.sh

运行后端服务脚本。

### 用法

```bash
scripts/run-backend.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--daemon` | `-d` | 后台运行（守护进程） |
| `--stop` | `-s` | 停止服务 |
| `--restart` | `-r` | 重启服务 |
| `--status` | - | 显示服务状态 |
| `--health` | - | 检查服务健康状态 |
| `--help` | `-h` | 显示帮助 |

### 示例

```bash
# 后台启动服务（等待启动完成）
scripts/run-backend.sh -d

# 前台启动服务
scripts/run-backend.sh

# 停止服务
scripts/run-backend.sh -s

# 重启服务
scripts/run-backend.sh -r

# 查看服务状态
scripts/run-backend.sh --status

# 健康检查
scripts/run-backend.sh --health
```

### 服务配置

| 配置项 | 值 |
|--------|-----|
| 服务端口 | 18080 |
| 日志文件 | `logs/backend/ruoyi-YYYYMMDD.log` |
| JVM 参数 | `-Xms512m -Xmx1024m -XX:+UseG1GC` |
| PID 文件 | `.pid/backend.pid` |

### 启动等待

后台启动时会自动等待服务启动完成（最多 30 秒），检测日志中 `若依启动成功` 关键字。

### 健康检查

通过 HTTP 请求 `/actuator/health` 检查服务状态：
- 返回 `HTTP 200` 表示服务正常
- 返回其他状态码表示服务异常

---

## run-frontend.sh

运行前端服务脚本（使用 pnpm）。

### 用法

```bash
scripts/run-frontend.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--daemon` | `-d` | 后台运行（守护进程） |
| `--stop` | `-s` | 停止服务 |
| `--restart` | `-r` | 重启服务 |
| `--status` | - | 显示服务状态 |
| `--health` | - | 检查服务健康状态 |
| `--install` | `-i` | 安装依赖 |
| `--help` | `-h` | 显示帮助 |

### 示例

```bash
# 后台启动服务（等待启动完成）
scripts/run-frontend.sh -d

# 前台启动服务
scripts/run-frontend.sh

# 停止服务
scripts/run-frontend.sh -s

# 重启服务
scripts/run-frontend.sh -r

# 查看服务状态
scripts/run-frontend.sh --status

# 健康检查
scripts/run-frontend.sh --health

# 安装依赖
scripts/run-frontend.sh -i
```

### 服务配置

| 配置项 | 值 |
|--------|-----|
| 服务端口 | 3888 |
| 日志文件 | `logs/frontend/frontend-YYYYMMDD.log` |
| 前端目录 | `ruoyi-ui/` |
| 包管理器 | pnpm |

### 启动等待

后台启动时会自动等待服务启动完成（最多 30 秒），检测 Vite 启动成功标志（`ready in` 或 `Local:`）。

### 健康检查

通过 HTTP 请求 `http://localhost:3888/` 检查服务状态：
- 返回 `HTTP 200` 表示服务正常
- 返回其他状态码表示服务异常

### 自动安装依赖

如果 `node_modules` 不存在，启动时会自动运行 `pnpm install` 安装依赖。

---

## test.sh

运行测试脚本。

### 用法

```bash
scripts/test.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--unit` | `-u` | 运行单元测试 |
| `--integration` | `-i` | 运行集成测试 |
| `--file` | `-f` | 运行指定测试类 |
| `--help` | `-h` | 显示帮助 |

### 示例

```bash
# 运行所有测试
scripts/test.sh

# 运行单元测试
scripts/test.sh -u

# 运行集成测试
scripts/test.sh -i

# 运行指定测试类
scripts/test.sh -f UserServiceTest

# 查看帮助
scripts/test.sh --help
```

### 测试类型

| 类型 | 匹配模式 | 说明 |
|------|----------|------|
| 所有测试 | - | 运行所有测试 |
| 单元测试 | `**/*Test.java` | 单元测试文件 |
| 集成测试 | `**/*IT.java` | 集成测试文件 |
| 指定测试 | 用户指定 | 指定的测试类 |

### 输出

- 测试日志：`logs/backend/test-YYYYMMDD-HHMMSS.log`

---

## clean.sh

清理构建产物脚本。

### 用法

```bash
scripts/clean.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--maven` | `-m` | 仅清理 Maven 构建产物 |
| `--logs` | `-l` | 仅清理日志文件 |
| `--node` | `-n` | 仅清理前端 node_modules |
| `--dist` | - | 仅清理前端构建产物 |
| `--generate` | - | 仅清理代码生成输出 |
| `--dry-run` | - | 仅显示，不实际删除 |
| `--help` | `-h` | 显示帮助 |

### 示例

```bash
# 清理所有（默认行为）
scripts/clean.sh

# 仅清理 Maven 构建产物
scripts/clean.sh -m

# 仅清理日志
scripts/clean.sh -l

# 清理 Maven 和日志
scripts/clean.sh -m -l

# 预览清理内容（不实际删除）
scripts/clean.sh --dry-run

# 清理前端构建产物
scripts/clean.sh --dist

# 清理代码生成输出
scripts/clean.sh --generate

# 查看帮助
scripts/clean.sh --help
```

### 清理范围

| 类型 | 清理内容 |
|------|----------|
| Maven | 所有模块的 `target/` 目录 |
| 日志 | 整个 `logs/` 目录 |
| node | `ruoyi-ui/node_modules`、`package-lock.json`、`pnpm-lock.yaml` |
| dist | `ruoyi-ui/dist/` |
| generate | `generate/output/` 下所有内容 |
| 临时文件 | `.pid/` 目录 |

### 重建目录

清理后会自动重建空目录：
- `logs/backend/`
- `logs/frontend/`
- `generate/output/`

---

## gen-code.sh

代码生成脚本（基于 ruoyi-gen-cli）。

### 用法

```bash
scripts/gen-code.sh <module> <submodule> [配置文件名]
scripts/gen-code.sh [选项]
```

### 选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--help` | `-h` | 显示帮助 |
| `--list` | `-l` | 列出可用的代码生成配置 |

### 参数

| 参数 | 必填 | 说明 |
|------|------|------|
| `module` | 是 | 模块名（如 `demo`） |
| `submodule` | 是 | 子模块名（如 `student`） |
| `配置文件名` | 否 | 默认与 submodule 同名 |

### 示例

```bash
# 列出所有可用配置
scripts/gen-code.sh --list

# 生成代码（使用默认配置名）
scripts/gen-code.sh demo student

# 生成代码（指定配置名）
scripts/gen-code.sh demo customer customer

# 查看帮助
scripts/gen-code.sh --help
```

### 目录结构

```
generate/
├── config/          # 配置文件目录
│   └── {module}/
│       └── {submodule}/
│           ├── *.sql
│           └── *.yml
└── output/          # 输出目录
    └── {module}/
        └── {submodule}/
            ├── *.zip           # 生成的 ZIP 文件
            └── {name}/         # 自动解压后的代码
```

### 代码生成流程

1. 编写 DDL SQL 和 YAML 配置
2. 运行 `scripts/gen-code.sh` 生成代码
3. 查看生成的代码（自动解压）
4. 将后端代码复制到项目对应目录
5. 将前端代码复制到 `ruoyi-ui` 对应目录
6. 执行菜单 SQL 注册功能
7. 编写业务逻辑

### 输出

- ZIP 文件：`generate/output/{module}/{submodule}/{name}.zip`
- 解压目录：`generate/output/{module}/{submodule}/{name}/`

---

## 常用组合命令

### 开发流程

```bash
# 1. 清理并重新构建
scripts/clean.sh -m
scripts/build.sh -q

# 2. 启动后端服务（后台）
scripts/run-backend.sh -d

# 3. 启动前端服务（后台）
scripts/run-frontend.sh -d

# 4. 检查服务状态
scripts/run-backend.sh --health
scripts/run-frontend.sh --health

# 5. 停止服务
scripts/run-backend.sh -s
scripts/run-frontend.sh -s
```

### 代码生成流程

```bash
# 1. 查看可用配置
scripts/gen-code.sh --list

# 2. 生成代码
scripts/gen-code.sh demo student

# 3. 查看生成的代码
ls -la generate/output/demo/student/
```

---

## 日志文件位置

| 类型 | 路径 |
|------|------|
| 构建日志 | `logs/backend/build-YYYYMMDD-HHMMSS.log` |
| 后端服务日志 | `logs/backend/ruoyi-YYYYMMDD.log` |
| 前端服务日志 | `logs/frontend/frontend-YYYYMMDD.log` |
| 测试日志 | `logs/backend/test-YYYYMMDD-HHMMSS.log` |

---

## 常见问题

### Q: 端口被占用怎么办？

A: `run-backend.sh` 和 `run-frontend.sh` 会自动检测并终止占用端口的进程，无需手动处理。

### Q: 如何查看服务启动日志？

A: 后台启动后，使用 `tail -f logs/backend/ruoyi-YYYYMMDD.log` 或 `tail -f logs/frontend/frontend-YYYYMMDD.log` 查看实时日志。

### Q: 如何跳过测试快速构建？

A: 使用 `scripts/build.sh -q` 进行快速构建。

### Q: 如何只构建某个模块？

A: 使用 `scripts/build.sh -m ruoyi-admin -q` 构建指定模块。

### Q: 代码生成后如何查看生成的代码？

A: 生成完成后会自动解压到 `generate/output/{module}/{submodule}/{name}/` 目录。

---

**最后更新**: 2026-04-07

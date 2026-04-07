# ruoyi-gen-cli 代码生成工具

## 概述

**ruoyi-gen-cli** 是基于 RuoYi-Vue 代码生成器（ruoyi-generator）二次封装的独立可运行 JAR 包，提供 CLI 命令行方式的代码生成能力。

### 核心特点

- **独立运行**：无需 MySQL、Redis 等外部依赖
- **CLI 工具**：通过命令行参数或配置文件控制代码生成
- **DDL 驱动**：直接解析 CREATE TABLE 语句生成代码
- **配置灵活**：支持命令行参数和 YAML 配置文件两种方式

### 快速示例

```bash
# 简单模式
java -jar ruoyi-gen-cli.jar \
  --sql=create_tables.sql \
  --output=./generated.zip \
  --author=dev \
  --package=com.example.system \
  --prefix=sys_ \
  --web=element-plus

# 配置文件模式
java -jar ruoyi-gen-cli.jar \
  --sql=create_tables.sql \
  --config=gen-config.yml \
  --output=./generated.zip
```

## 文档导航

| 文档 | 说明 |
|------|------|
| **[操作手册](./ruoyi-gen-cli_操作手册.md)** | **团队标准操作规范（SOP）** |
| [概述](./ruoyi-gen-cli/01-概述.md) | 项目简介、特点、使用场景 |
| [快速开始](./ruoyi-gen-cli/02-快速开始.md) | 安装、配置、第一个生成示例 |
| [配置说明](./ruoyi-gen-cli/03-配置说明.md) | YAML 配置文件详解 |
| [命令参考](./ruoyi-gen-cli/04-命令参考.md) | CLI 命令参数说明 |
| [核心模块](./ruoyi-gen-cli/05-核心模块.md) | 核心模块源码分析 |
| [最佳实践](./ruoyi-gen-cli/06-最佳实践.md) | 使用技巧、常见问题 |
| [SQL 配置详解](./ruoyi-gen-cli/07-SQL_配置详解.md) | DDL SQL 语法规范、完整示例 |
| [配置模板](./ruoyi-gen-cli/08-配置模板.md) | 三种模板类型的 YAML 配置模板 |

## 支持的模板类型

| 模板类型 | 说明 | 示例 |
|---------|------|------|
| `crud` | 单表 CRUD | 用户管理、部门管理 |
| `tree` | 树表结构 | 部门管理（树形）、菜单管理 |
| `sub` | 主子表 | 订单 - 订单明细、客户 - 商品 |

## 生成的代码结构

```
generated.zip/
├── domain/                 # 实体类
├── controller/             # Controller
├── service/                # Service 接口和实现
├── mapper/                 # Mapper 接口
└── mapper/xml/             # MyBatis XML 映射文件
```

## 配置示例

```yaml
# gen-config.yml
global:
  author: dev
  packageName: com.example.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: crud
  tplWebType: element-plus
  parentMenuId: 4

tables:
  demo_student:
    className: Student
    functionName: 学生管理
    columns:
      sex:
        dictType: sys_user_sex
        htmlType: select
      status:
        dictType: sys_common_status
        htmlType: radio
```

## 相关项目

- **ruoyi-generator**: RuoYi-Vue 代码生成器模块
- **ruoyi-demo**: 通过 ruoyi-gen-cli 生成的示例代码
- **generate/config/demo**: 配置文件示例

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: ruoyi-gen-cli 1.0

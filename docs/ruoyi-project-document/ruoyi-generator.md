# RuoYi-Generator 代码生成器模块

## 概述

`ruoyi-generator` 是基于 Velocity 模板引擎的代码生成器模块，能够根据数据库表结构自动生成完整的 CRUD 代码。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/`

## 功能特性

- ✅ 单表增删改查（crud）
- ✅ 树表增删改查（tree）
- ✅ 主子表增删改查（sub）
- ✅ 支持多种前端（Element UI / Element Plus / TypeScript）
- ✅ 数据库类型自动映射
- ✅ 代码预览功能
- ✅ ZIP 打包下载
- ✅ 自定义路径生成
- ✅ 数据库表结构同步

## 目录结构

```
ruoyi-generator/
├── config/         # 配置类（GenConfig.java）
├── controller/     # 控制器层（GenController.java）
├── domain/         # 实体类（GenTable, GenTableColumn）
├── mapper/         # 数据访问层
├── service/        # 服务层 + 实现
└── util/           # 工具类（代码生成核心逻辑）
```

## 子模块文档

| 文档 | 说明 |
|------|------|
| [config.md](ruoyi-generator/config.md) | 配置类详解（GenConfig, generator.yml） |
| [domain.md](ruoyi-generator/domain.md) | 实体类详解（GenTable, GenTableColumn） |
| [mapper.md](ruoyi-generator/mapper.md) | 数据访问层（Mapper 接口 + XML） |
| [controller.md](ruoyi-generator/controller.md) | API 接口层 |
| [service.md](ruoyi-generator/service.md) | 服务层（代码生成核心逻辑） |
| [generator-core.md](ruoyi-generator/generator-core.md) | 代码生成核心（模板、类型映射、流程） |

---

## 快速入门

### 1. 导入数据库表

**方式一：页面导入**
1. 访问 `/tool/gen` 页面
2. 点击"导入"按钮
3. 选择数据库表
4. 填写生成配置

**方式二：API 导入**

```bash
POST /tool/gen/importTable
Content-Type: application/json

{
  "tables": "sys_user,sys_role"
}
```

### 2. 配置生成信息

| 配置项 | 说明 | 示例 |
|--------|------|------|
| 包路径 | 生成的包名 | `com.ruoyi.system` |
| 模块名 | 模块名称 | `system` |
| 业务名 | 业务名称 | `user` |
| 功能名 | 功能描述 | `用户管理` |
| 生成作者 | 作者名 | `ruoyi` |
| 模板类型 | crud/tree/sub | `crud` |
| 前端类型 | element-ui/element-plus/element-plus-ts | `element-plus` |

### 3. 预览代码

**API**: `GET /tool/gen/preview/{tableId}`

```bash
GET /tool/gen/preview/1
```

响应包含生成的所有文件内容。

### 4. 下载或生成代码

**下载 ZIP**:
```bash
GET /tool/gen/download/sys_user
```

**生成到自定义路径**:
```bash
GET /tool/gen/genCode/sys_user
```

---

## 模板类型说明

### 后端模板

| 模板 | 生成文件 |
|------|----------|
| domain.java.vm | 实体类 |
| mapper.java.vm | Mapper 接口 |
| service.java.vm | Service 接口 |
| serviceImpl.java.vm | Service 实现 |
| controller.java.vm | Controller |
| mapper.xml.vm | MyBatis XML |
| sql.vm | 菜单权限 SQL |

### 前端模板

| 模板 | 生成文件 |
|------|----------|
| api.js.vm | JavaScript API |
| api.ts.vm | TypeScript API |
| type.ts.vm | TypeScript 类型定义 |
| index.vue.vm | 列表页面 |
| index-tree.vue.vm | 树形列表页面 |

---

## 核心配置

### generator.yml

```yaml
gen:
  author: ruoyi                    # 生成代码的作者
  packageName: com.ruoyi.system    # 默认包路径
  autoRemovePre: false             # 是否自动去除表前缀
  tablePrefix: sys_                # 表前缀
  allowOverwrite: false            # 是否允许覆盖本地文件
```

### 模板类型

| 模板 | 说明 | 适用场景 |
|------|------|----------|
| crud | 单表增删改查 | 简单业务表 |
| tree | 树表增删改查 | 部门、菜单等树形结构 |
| sub | 主子表增删改查 | 订单 - 订单明细等一对多关系 |

### 前端类型

| 类型 | 框架 | 语言 |
|------|------|------|
| element-ui | Vue 2 + Element UI | JavaScript |
| element-plus | Vue 3 + Element Plus | JavaScript |
| element-plus-typescript | Vue 3 + Element Plus | TypeScript |

---

## 数据库表

| 表名 | 说明 | 源码 |
|------|------|------|
| gen_table | 代码生成业务表配置 | [`GenTableMapper.xml`](../../ruoyi-generator/src/main/resources/mapper/generator/GenTableMapper.xml) |
| gen_table_column | 代码生成业务表字段配置 | [`GenTableColumnMapper.xml`](../../ruoyi-generator/src/main/resources/mapper/generator/GenTableColumnMapper.xml) |

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

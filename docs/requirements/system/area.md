# 区划管理 - 需求文档

## 1. 模块基本信息

| 项目 | 内容 |
|------|------|
| 模块名称 | 区划管理 |
| 模块编码 | system.area |
| 表名 | sys_area |
| 模板类型 | Tree |
| 文档版本 | 1.0 |
| 创建日期 | 2026-04-14 |
| 负责人 | coderleehd |
| 优先级 | P0-高 |
| 上级菜单 | 系统管理 |

## 2. 核心字段

| 字段名 | 类型 | 必填 | 说明 | 表单类型 | 字典 |
|--------|------|------|------|----------|------|
| name | VARCHAR(100) | 是 | 区划名称 | input | - |
| code | VARCHAR(12) | 是 | 区划编码（2/4/6/9/12位） | input | - |
| parent_code | VARCHAR(12) | 否 | 父区域编码（0 为根节点） | treeselect | - |
| ancestors | VARCHAR(128) | 否 | 祖级列表（如 11/1101/110105） | - | - |
| area_level | CHAR(1) | 是 | 层级 | radio | sys_area_level |
| sort | INT | 否 | 排序号（默认 1） | input | - |

## 3. 字典设计

| 字段名 | 字典类型 | 字典名称 | 选项 | 是否内置 |
|--------|---------|---------|------|---------|
| area_level | sys_area_level | 区划层级 | 1-省/自治区/直辖市, 2-地级市, 3-县/区, 4-乡镇/街道, 5-村/社区 | 否（需新建） |

## 4. 功能清单

| 功能 | 方法 | 路径 | 权限标识 |
|------|------|------|---------|
| 查询列表（树形） | GET | /system/area/list | system:area:list |
| 查询详情 | GET | /system/area/{id} | system:area:query |
| 新增 | POST | /system/area | system:area:add |
| 修改 | PUT | /system/area | system:area:edit |
| 删除 | DELETE | /system/area/{ids} | system:area:remove |
| 导出 | POST | /system/area/export | system:area:export |

## 5. 生成的文件

- DDL SQL: `generate/config/system/area/area.sql`
- YAML 配置：`generate/config/system/area/area.yml`

## 6. 页面字段说明

**树形列表页展示**：name, code, area_level, sort

**新增/编辑表单**：name(input), code(input), parent_code(treeselect), area_level(radio), sort(input数字)

**查询条件**：name(LIKE 模糊), code(LIKE 模糊), area_level(EQ 下拉筛选)

## 7. 下一步

- [ ] 进入阶段 2：代码生成与集成

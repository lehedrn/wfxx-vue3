# 设备型号管理 - 需求文档

## 1. 模块基本信息

| 项目 | 内容 |
|------|------|
| 模块名称 | 设备型号管理 |
| 模块编码 | base.deviceModel |
| 表名 | base_device_model |
| 模板类型 | CRUD |
| 文档版本 | 1.0 |
| 创建日期 | 2026-04-10 |
| 负责人 | coderleehd |
| 优先级 | P0-高 |
| 上级菜单 | 基础信息（新建） |

## 2. 核心字段

| 字段名 | 类型 | 必填 | 说明 | 表单类型 | 字典 |
|--------|------|------|------|----------|------|
| name | VARCHAR(100) | 是 | 设备型号名称 | input | - |
| device_type | CHAR(1) | 是 | 设备类型 | select | sys_device_type |
| memory | INT | 是 | 内存(GB) | input | - |
| disk | INT | 否 | 硬盘容量(GB) | input | - |
| os | CHAR(1) | 否 | 操作系统 | select | sys_device_os |
| motherboard_manufacturer | VARCHAR(100) | 否 | 主板厂家 | input | - |
| cpu_model | VARCHAR(50) | 否 | CPU型号 | select | sys_cpu_model |
| cpu_cores | INT | 否 | CPU核心数 | input | - |
| cpu_frequency | DECIMAL(10,2) | 否 | 主频(GHz) | input | - |
| cpu_count | INT | 否 | CPU数量 | input | - |
| gpu_model | VARCHAR(100) | 否 | GPU型号 | select | sys_gpu_model |
| gpu_compute_power | VARCHAR(50) | 否 | GPU算力 | input | - |
| gpu_memory | INT | 否 | 显存(GB) | input | - |
| gpu_count | INT | 否 | GPU数量 | input | - |
| status | CHAR(1) | 是 | 状态 | radio | sys_common_status |

## 3. 字典设计

| 字段名 | 字典类型 | 字典名称 | 选项 | 是否内置 |
|--------|---------|---------|------|---------|
| device_type | sys_device_type | 设备类型 | 0 边缘计算盒子/1 服务器 | 否-需新建 |
| os | sys_device_os | 操作系统 | 0 Linux/1 Windows/2 其他 | 否-需新建 |
| cpu_model | sys_cpu_model | CPU型号 | RK3588/Intel Xeon E5-2665 等 | 否-需新建 |
| gpu_model | sys_gpu_model | GPU型号 | jetson_nano_jepck4.6/NVIDIA RTX-3090Ti 等 | 否-需新建 |
| status | sys_common_status | 通用状态 | 0 正常/1 停用 | 是 |

## 4. 功能清单

| 功能 | 方法 | 路径 | 权限标识 |
|------|------|------|---------|
| 查询列表 | GET | /base/deviceModel/list | base:deviceModel:list |
| 查询详情 | GET | /base/deviceModel/{id} | base:deviceModel:query |
| 新增 | POST | /base/deviceModel | base:deviceModel:add |
| 修改 | PUT | /base/deviceModel | base:deviceModel:edit |
| 删除 | DELETE | /base/deviceModel/{ids} | base:deviceModel:remove |
| 导出 | POST | /base/deviceModel/export | base:deviceModel:export |
| 导入 | POST | /base/deviceModel/importData | base:deviceModel:import |

## 5. 生成的文件

- DDL SQL: `generate/config/base/deviceModel/deviceModel.sql`
- YAML 配置：`generate/config/base/deviceModel/deviceModel.yml`

## 6. 下一步

- [ ] 进入阶段 2：代码生成与集成

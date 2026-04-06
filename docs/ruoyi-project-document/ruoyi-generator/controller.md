# Controller 控制器层

## 概述

`ruoyi-generator/controller` 包提供代码生成相关的 HTTP API 接口。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/controller/`

## 模块结构

```
controller/
└── GenController.java    # 代码生成控制器
```

---

## GenController - 代码生成控制器

**源码**: [`GenController.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/controller/GenController.java)

**请求路径**: `/tool/gen`

### API 接口列表

| 方法 | 路径 | 权限 | 说明 |
|------|------|------|------|
| GET | `/list` | tool:gen:list | 查询代码生成列表 |
| GET | `/db/list` | tool:gen:list | 查询数据库表列表 |
| GET | `/{tableId}` | tool:gen:query | 获取代码生成详细信息 |
| GET | `/column/{tableId}` | tool:gen:list | 查询表字段列表 |
| POST | `/importTable` | tool:gen:import | 导入表结构 |
| POST | `/createTable` | admin 角色 | 通过 SQL 创建表 |
| PUT | `/` | tool:gen:edit | 修改保存代码生成配置 |
| DELETE | `/{tableIds}` | tool:gen:remove | 删除代码生成配置 |
| GET | `/preview/{tableId}` | tool:gen:preview | 预览生成的代码 |
| GET | `/download/{tableName}` | tool:gen:code | 下载生成的 ZIP 包 |
| GET | `/genCode/{tableName}` | tool:gen:code | 生成代码到本地路径 |
| GET | `/synchDb/{tableName}` | tool:gen:edit | 同步数据库表结构 |
| GET | `/batchGenCode` | tool:gen:code | 批量生成代码并下载 |

---

## 接口详解

### 1. 查询代码生成列表

**请求**: `GET /tool/gen/list`

**参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tableName | String | 否 | 表名称 |
| tableComment | String | 否 | 表描述 |
| pageNum | Integer | 否 | 页码 |
| pageSize | Integer | 否 | 每页条数 |

**响应示例**:

```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 10,
  "rows": [
    {
      "tableId": 1,
      "tableName": "sys_user",
      "tableComment": "用户信息表",
      "className": "SysUser",
      "tplCategory": "crud",
      "packageName": "com.ruoyi.system"
    }
  ]
}
```

### 2. 查询数据库表列表

**请求**: `GET /tool/gen/db/list`

**说明**: 查询数据库中未导入的表列表

**响应示例**:

```json
{
  "code": 200,
  "total": 5,
  "rows": [
    {
      "tableName": "sys_role",
      "tableComment": "角色信息表",
      "createTime": "2026-04-01 10:00:00"
    }
  ]
}
```

### 3. 获取代码生成详细信息

**请求**: `GET /tool/gen/{tableId}`

**响应示例**:

```json
{
  "code": 200,
  "data": {
    "info": {
      "tableId": 1,
      "tableName": "sys_user",
      "className": "SysUser",
      "packageName": "com.ruoyi.system"
    },
    "rows": [
      {
        "columnName": "user_id",
        "columnComment": "用户 ID",
        "javaType": "Long",
        "isPk": "1"
      }
    ],
    "tables": [...]
  }
}
```

### 4. 导入表结构

**请求**: `POST /tool/gen/importTable`

**参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| tables | String | 表名列表，逗号分隔 |
| tplWebType | String | 前端类型 |

**示例**:
```bash
POST /tool/gen/importTable?tables=sys_user,sys_role&tplWebType=element-plus
```

### 5. 通过 SQL 创建表

**请求**: `POST /tool/gen/createTable`

**权限**: 需要 admin 角色

**参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| sql | String | CREATE TABLE 语句 |
| tblWebType | String | 前端类型 |

**示例**:
```sql
CREATE TABLE `sys_demo` (
  `demo_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  PRIMARY KEY (`demo_id`)
) COMMENT='演示表';
```

### 6. 修改保存配置

**请求**: `PUT /tool/gen/*`

**参数**: GenTable 对象

```json
{
  "tableId": 1,
  "tableName": "sys_user",
  "className": "SysUser",
  "packageName": "com.ruoyi.system",
  "moduleName": "system",
  "businessName": "user",
  "functionName": "用户管理",
  "functionAuthor": "张三",
  "tplCategory": "crud",
  "tplWebType": "element-plus"
}
```

### 7. 预览代码

**请求**: `GET /tool/gen/preview/{tableId}`

**响应**: 返回生成的所有文件内容

```json
{
  "code": 200,
  "data": {
    "SysUser.java": "package com.ruoyi.system.domain...",
    "SysUserMapper.java": "package com.ruoyi.system.mapper...",
    "SysUserController.java": "...",
    "SysUserMapper.xml": "...",
    "index.vue": "..."
  }
}
```

### 8. 下载代码

**请求**: `GET /tool/gen/download/{tableName}`

**响应**: ZIP 文件下载

```bash
GET /tool/gen/download/sys_user
```

### 9. 生成代码到本地

**请求**: `GET /tool/gen/genCode/{tableName}`

**说明**: 代码生成到自定义路径（需配置 allowOverwrite=true）

### 10. 同步数据库表

**请求**: `GET /tool/gen/synchDb/{tableName}`

**说明**: 根据数据库表结构更新代码生成配置

### 11. 批量生成代码

**请求**: `GET /tool/gen/batchGenCode`

**参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| tables | String | 表名列表，逗号分隔 |

**示例**:
```bash
GET /tool/gen/batchGenCode?tables=sys_user,sys_role,sys_menu
```

---

## 权限说明

| 权限标识 | 说明 | 接口 |
|----------|------|------|
| tool:gen:list | 查询代码生成 | 列表、数据库列表、字段列表 |
| tool:gen:query | 查询代码生成详情 | 获取详情 |
| tool:gen:import | 导入表结构 | 导入 |
| tool:gen:edit | 修改配置 | 修改、同步 |
| tool:gen:remove | 删除配置 | 删除 |
| tool:gen:preview | 预览代码 | 预览 |
| tool:gen:code | 生成代码 | 下载、本地生成、批量生成 |

---

## 前端调用示例（Vue）

```javascript
// 查询代码生成列表
listGen(queryParam).then(response => {
  console.log(response.rows)
})

// 获取详情
getGenDetail(tableId).then(response => {
  console.log(response.data)
})

// 导入表
importTable({ tables: 'sys_user,sys_role', tplWebType: 'element-plus' }).then(response => {
  this.$modal.msgSuccess("导入成功")
})

// 修改保存
updateGen(form).then(response => {
  this.$modal.msgSuccess("保存成功")
})

// 预览代码
previewCode(tableId).then(response => {
  console.log(response.data)
})

// 下载代码
downloadCode(tableName).then(response => {
  // 浏览器自动下载 ZIP
})
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

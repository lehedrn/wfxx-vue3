# Domain 实体模块

## 概述

`ruoyi-generator/domain` 包提供代码生成器相关的实体类，用于存储代码生成配置信息。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/domain/`

## 模块结构

```
domain/
├── GenTable.java          # 业务表配置实体
└── GenTableColumn.java    # 业务表字段配置实体
```

---

## GenTable - 业务表配置实体

**源码**: [`GenTable.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/domain/GenTable.java)

**表名**: `gen_table`

**继承**: `BaseEntity`

### 核心字段

| 字段 | 类型 | 说明 |
|------|------|------|
| tableId | Long | 编号（主键） |
| tableName | String | 表名称 |
| tableComment | String | 表描述 |
| className | String | 实体类名称（首字母大写） |
| tplCategory | String | 模板类型（crud/tree/sub） |
| tplWebType | String | 前端类型（element-ui/element-plus/element-plus-typescript） |
| packageName | String | 生成包路径 |
| moduleName | String | 生成模块名 |
| businessName | String | 生成业务名 |
| functionName | String | 生成功能名 |
| functionAuthor | String | 生成作者 |
| formColNum | Integer | 表单布局（单列/双列/三列） |
| genType | String | 生成方式（0=ZIP 包 1=自定义路径） |
| genPath | String | 生成路径（不填默认项目路径） |

### 关联字段

| 字段 | 类型 | 说明 |
|------|------|------|
| subTableName | String | 关联子表的表名 |
| subTableFkName | String | 本表关联父表的外键名 |
| subTable | GenTable | 子表信息 |
| pkColumn | GenTableColumn | 主键列信息 |
| columns | List<GenTableColumn> | 表列信息 |

### 树形结构字段

| 字段 | 类型 | 说明 |
|------|------|------|
| treeCode | String | 树编码字段 |
| treeParentCode | String | 树父编码字段 |
| treeName | String | 树名称字段 |
| parentMenuId | Long | 上级菜单 ID 字段 |
| parentMenuName | String | 上级菜单名称字段 |

### 其他字段

| 字段 | 类型 | 说明 |
|------|------|------|
| options | String | 其它生成选项（JSON 格式） |

### 判断方法

| 方法 | 说明 |
|------|------|
| `isSub()` | 是否为主子表模板 |
| `isTree()` | 是否为树表模板 |
| `isCrud()` | 是否为单表模板 |
| `isSuperColumn(String javaField)` | 是否为父类属性（BaseEntity/TreeEntity） |

### 使用示例

```java
// 创建表配置
GenTable table = new GenTable();
table.setTableName("sys_user");
table.setTableComment("用户信息表");
table.setClassName("SysUser");
table.setTplCategory("crud");
table.setTplWebType("element-plus");
table.setPackageName("com.ruoyi.system");
table.setModuleName("system");
table.setBusinessName("user");
table.setFunctionName("用户管理");
table.setFunctionAuthor("ruoyi");
table.setGenType("0"); // ZIP 下载

// 判断模板类型
if (table.isCrud()) {
    // 单表逻辑
} else if (tree.isTree()) {
    // 树表逻辑
} else if (table.isSub()) {
    // 主子表逻辑
}
```

---

## GenTableColumn - 业务表字段配置实体

**源码**: [`GenTableColumn.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/domain/GenTableColumn.java)

**表名**: `gen_table_column`

**继承**: `BaseEntity`

### 核心字段

| 字段 | 类型 | 说明 |
|------|------|------|
| columnId | Long | 编号（主键） |
| tableId | Long | 归属表编号 |
| columnName | String | 列名称 |
| columnComment | String | 列描述 |
| columnType | String | 列类型（数据库类型） |
| javaType | String | Java 类型 |
| javaField | String | Java 字段名 |
| sort | Integer | 排序 |

### 业务标识字段

| 字段 | 类型 | 说明 |
|------|------|------|
| isPk | String | 是否主键（1 是） |
| isIncrement | String | 是否自增（1 是） |
| isRequired | String | 是否必填（1 是） |
| isInsert | String | 是否插入字段（1 是） |
| isEdit | String | 是否编辑字段（1 是） |
| isList | String | 是否列表字段（1 是） |
| isQuery | String | 是否查询字段（1 是） |
| queryType | String | 查询方式（EQ/NE/GT/LT/LIKE/BETWEEN） |
| htmlType | String | 显示类型（input/textarea/select/checkbox/radio/datetime 等） |
| dictType | String | 字典类型 |

### 判断方法

> **注意**: 源码中 `isEdit()` 方法存在 bug（第 238 行调用了 `isInsert()` 而非 `isEdit()`），使用时建议直接调用静态方法 `isEdit(String isEdit)`。

| 方法 | 说明 |
|------|------|
| `isPk()` | 是否主键 |
| `isIncrement()` | 是否自增 |
| `isRequired()` | 是否必填 |
| `isInsert()` | 是否插入字段 |
| `isEdit()` | 是否编辑字段 ⚠️ |
| `isList()` | 是否列表字段 |
| `isQuery()` | 是否查询字段 |
| `isSuperColumn()` | 是否为父类属性 |
| `isUsableColumn()` | 是否为可用字段（白名单） |

### 辅助方法

| 方法 | 说明 |
|------|------|
| `getCapJavaField()` | 获取首字母大写的 Java 字段名 |
| `readConverterExp()` | 解析列注释中的字典值（如 "0=男 1=女"） |

### 使用示例

```java
// 创建字段配置
GenTableColumn column = new GenTableColumn();
column.setColumnName("user_name");
column.setColumnComment("用户姓名");
column.setColumnType("varchar(30)");
column.setJavaType("String");
column.setJavaField("userName");
column.setIsPk("0");
column.setIsIncrement("0");
column.setIsRequired("1");
column.setIsInsert("1");
column.setIsEdit("1");
column.setIsList("1");
column.setIsQuery("1");
column.setQueryType("EQ");
column.setHtmlType("input");
column.setDictType("");

// 判断字段属性
if (column.isRequired()) {
    // 必填字段
}

if (column.isQuery()) {
    // 查询字段
}

// 获取首字母大写的字段名
String capField = column.getCapJavaField(); // UserName
```

---

## 数据库字段到 Java 类型映射

| 数据库类型 | Java 类型 | HTML 类型 |
|-----------|-----------|-----------|
| char/varchar | String | input/textarea |
| text | String | textarea |
| datetime/time/date | Date | datetime |
| timestamp | Date | datetime |
| int/integer | Integer | input |
| bigint | Long | input |
| float/double/decimal | Double/BigDecimal | input |
| tinyint(0/1) | Boolean | radio/checkbox |

---

## 模板类型说明

### tplCategory - 后端模板类型

| 值 | 说明 | 适用场景 |
|----|------|----------|
| crud | 单表增删改查 | 简单业务表（如用户、岗位） |
| tree | 树表增删改查 | 树形结构表（如部门、菜单） |
| sub | 主子表增删改查 | 一对多关系表（如订单 - 订单明细） |

### tplWebType - 前端模板类型

| 值 | 框架 | 语言 |
|----|------|------|
| element-ui | Vue 2 + Element UI | JavaScript |
| element-plus | Vue 3 + Element Plus | JavaScript |
| element-plus-typescript | Vue 3 + Element Plus | TypeScript |

---

## 查询方式说明

| 值 | 说明 | SQL 示例 |
|----|------|----------|
| EQ | 等于 | `WHERE column = ?` |
| NE | 不等于 | `WHERE column != ?` |
| GT | 大于 | `WHERE column > ?` |
| LT | 小于 | `WHERE column < ?` |
| LIKE | 模糊查询 | `WHERE column LIKE ?` |
| BETWEEN | 范围查询 | `WHERE column BETWEEN ? AND ?` |

---

## 显示类型说明

| 值 | 说明 | 前端组件 |
|----|------|----------|
| input | 文本框 | `<el-input>` |
| textarea | 文本域 | `<el-input type="textarea">` |
| select | 下拉框 | `<el-select>` |
| checkbox | 复选框 | `<el-checkbox-group>` |
| radio | 单选框 | `<el-radio-group>` |
| datetime | 日期控件 | `<el-date-picker>` |
| image | 图片上传 | `<el-upload>` |
| upload | 文件上传 | `<el-upload>` |
| editor | 富文本 | 富文本编辑器 |

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

# 代码生成核心逻辑

## 概述

`ruoyi-generator/util` 包包含代码生成器的核心工具类，负责代码生成的模板渲染、类型映射、字段处理等逻辑。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/util/`

## 模块结构

```
util/
├── GenUtils.java              # 代码生成器工具类（初始化、类型映射）
├── VelocityInitializer.java   # Velocity 引擎初始化
├── VelocityUtils.java         # 模板处理工具类
└── GenConstants.java          # 常量定义（ruoyi-common）
```

---

## 代码生成流程

```
1. 用户导入数据库表
   ↓
2. GenUtils.initTable() 初始化表配置
   ↓
3. GenUtils.initColumnField() 初始化字段配置
   ↓
4. 保存到 gen_table 和 gen_table_column
   ↓
5. 用户点击"生成代码"
   ↓
6. VelocityInitializer.initVelocity() 初始化引擎
   ↓
7. VelocityUtils.prepareContext() 准备模板上下文
   ↓
8. VelocityUtils.getTemplateList() 获取模板列表
   ↓
9. 渲染模板并输出（ZIP 下载或写入文件）
```

---

## GenUtils - 代码生成器工具类

**源码**: [`GenUtils.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/GenUtils.java)

### 核心方法

| 方法 | 说明 |
|------|------|
| `initTable(GenTable, String)` | 初始化表配置（类名、包名、模块名等） |
| `initColumnField(GenTableColumn, GenTable)` | 初始化字段配置（Java 类型、HTML 类型等） |
| `convertClassName(String)` | 转换类名（表名→类名） |
| `getModuleName(String)` | 获取模块名 |
| `getBusinessName(String)` | 获取业务名 |
| `replaceText(String)` | 替换注释中的特殊字符 |

### 初始化表配置

[`GenUtils:21-30`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/GenUtils.java)

```java
public static void initTable(GenTable genTable, String operName) {
    // 1. 转换类名（sys_user → SysUser）
    genTable.setClassName(convertClassName(genTable.getTableName()));
    
    // 2. 设置包路径（从配置读取）
    genTable.setPackageName(GenConfig.getPackageName());
    
    // 3. 设置模块名（从包路径提取）
    genTable.setModuleName(getModuleName(GenConfig.getPackageName()));
    
    // 4. 设置业务名（从表名提取）
    genTable.setBusinessName(getBusinessName(genTable.getTableName()));
    
    // 5. 设置功能名（从表注释提取）
    genTable.setFunctionName(replaceText(genTable.getTableComment()));
    
    // 6. 设置作者（从配置读取）
    genTable.setFunctionAuthor(GenConfig.getAuthor());
    
    // 7. 设置操作人
    genTable.setCreateBy(operName);
}
```

### 初始化字段配置

[`GenUtils:35-133`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/GenUtils.java)

```java
public static void initColumnField(GenTableColumn column, GenTable table) {
    String dataType = getDbType(column.getColumnType());
    String columnName = column.getColumnName();
    
    // 设置基本属性
    column.setTableId(table.getTableId());
    column.setCreateBy(table.getCreateBy());
    column.setJavaField(StringUtils.toCamelCase(columnName)); // 驼峰转换
    column.setJavaType(GenConstants.TYPE_STRING); // 默认 String
    column.setQueryType(GenConstants.QUERY_EQ); // 默认 EQ 查询
    column.setDictType(""); // 默认无字典
    
    // 根据数据库类型设置 Java 类型和 HTML 类型
    if (arraysContains(GenConstants.COLUMNTYPE_STR, dataType)) {
        // 字符串类型
        Integer columnLength = getColumnLength(column.getColumnType());
        String htmlType = columnLength >= 500 ? GenConstants.HTML_TEXTAREA : GenConstants.HTML_INPUT;
        column.setHtmlType(htmlType);
    }
    else if (arraysContains(GenConstants.COLUMNTYPE_TIME, dataType)) {
        // 时间类型
        column.setJavaType(GenConstants.TYPE_DATE);
        column.setHtmlType(GenConstants.HTML_DATETIME);
    }
    else if (arraysContains(GenConstants.COLUMNTYPE_NUMBER, dataType)) {
        // 数字类型
        column.setHtmlType(GenConstants.HTML_INPUT);
        // 根据精度选择具体类型
        String[] str = StringUtils.split(StringUtils.substringBetween(column.getColumnType(), "(", ")"), ",");
        if (str != null && str.length == 2 && Integer.parseInt(str[1]) > 0) {
            column.setJavaType(GenConstants.TYPE_BIGDECIMAL); // 浮点型
        } else if (str != null && str.length == 1 && Integer.parseInt(str[0]) <= 10) {
            column.setJavaType(GenConstants.TYPE_INTEGER); // 整型
        } else {
            column.setJavaType(GenConstants.TYPE_LONG); // 长整型
        }
    }
    
    // 默认所有字段都需要插入
    column.setIsInsert(GenConstants.REQUIRE);
    
    // 编辑字段（排除主键和特定字段）
    if (!arraysContains(GenConstants.COLUMNNAME_NOT_EDIT, columnName) && !column.isPk()) {
        column.setIsEdit(GenConstants.REQUIRE);
    }
    
    // 列表字段
    if (!arraysContains(GenConstants.COLUMNNAME_NOT_LIST, columnName) && !column.isPk()) {
        column.setIsList(GenConstants.REQUIRE);
    }
    
    // 查询字段
    if (!arraysContains(GenConstants.COLUMNNAME_NOT_QUERY, columnName) && !column.isPk()) {
        column.setIsQuery(GenConstants.REQUIRE);
    }
    
    // 智能设置查询类型和显示类型
    if (StringUtils.endsWithIgnoreCase(columnName, "name")) {
        column.setQueryType(GenConstants.QUERY_LIKE); // 名称字段模糊查询
    }
    if (StringUtils.endsWithIgnoreCase(columnName, "status")) {
        column.setHtmlType(GenConstants.HTML_RADIO); // 状态字段单选框
    }
    else if (StringUtils.endsWithIgnoreCase(columnName, "type") || StringUtils.endsWithIgnoreCase(columnName, "sex")) {
        column.setHtmlType(GenConstants.HTML_SELECT); // 类型/性别字段下拉框
    }
    else if (StringUtils.endsWithIgnoreCase(columnName, "image")) {
        column.setHtmlType(GenConstants.HTML_IMAGE_UPLOAD); // 图片上传
    }
    else if (StringUtils.endsWithIgnoreCase(columnName, "file")) {
        column.setHtmlType(GenConstants.HTML_FILE_UPLOAD); // 文件上传
    }
    else if (StringUtils.endsWithIgnoreCase(columnName, "content")) {
        column.setHtmlType(GenConstants.HTML_EDITOR); // 富文本编辑器
    }
}
```

---

## 数据库字段到 Java 类型映射

### 字符串类型

| 数据库类型 | Java 类型 | HTML 类型 |
|-----------|-----------|-----------|
| char(n<500) | String | input |
| varchar(n<500) | String | input |
| char(n≥500) | String | textarea |
| varchar(n≥500) | String | textarea |
| text | String | textarea |
| json | String | textarea |

### 时间类型

| 数据库类型 | Java 类型 | HTML 类型 |
|-----------|-----------|-----------|
| datetime | Date | datetime |
| date | Date | datetime |
| time | Date | datetime |
| timestamp | Date | datetime |

### 数字类型

| 数据库类型 | Java 类型 | HTML 类型 |
|-----------|-----------|-----------|
| tinyint(n≤10) | Integer | input |
| smallint | Integer | input |
| mediumint | Integer | input |
| int | Integer | input |
| integer | Integer | input |
| bigint | Long | input |
| float(n,0) | Integer | input |
| float(n,m>0) | BigDecimal | input |
| double | BigDecimal | input |
| decimal | BigDecimal | input |

### 特殊规则

| 字段名后缀 | 查询类型 | HTML 类型 |
|-----------|----------|-----------|
| name | LIKE | input |
| status | EQ | radio |
| type/sex | EQ | select |
| image | EQ | image upload |
| file | EQ | file upload |
| content | EQ | editor |

---

## VelocityUtils - 模板处理工具类

**源码**: [`VelocityUtils.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/VelocityUtils.java)

### 核心方法

| 方法 | 说明 |
|------|------|
| `prepareContext(GenTable)` | 准备 Velocity 模板上下文 |
| `setMenuVelocityContext()` | 设置菜单相关变量 |
| `setTreeVelocityContext()` | 设置树表相关变量 |
| `setSubVelocityContext()` | 设置主子表相关变量 |
| `getTemplateList(tplCategory, tplWebType)` | 获取模板列表（需模板类型和前端类型参数） |
| `getFileName(template, genTable)` | 生成文件名 |

### 模板上下文变量

[`VelocityUtils:43-81`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/VelocityUtils.java)

```java
VelocityContext velocityContext = new VelocityContext();

// 基础信息
velocityContext.put("tplCategory", genTable.getTplCategory());
velocityContext.put("tableName", genTable.getTableName());
velocityContext.put("functionName", genTable.getFunctionName());
velocityContext.put("ClassName", genTable.getClassName());
velocityContext.put("className", StringUtils.uncapitalize(genTable.getClassName()));
velocityContext.put("moduleName", genTable.getModuleName());
velocityContext.put("BusinessName", StringUtils.capitalize(genTable.getBusinessName()));
velocityContext.put("businessName", genTable.getBusinessName());
velocityContext.put("basePackage", getPackagePrefix(packageName));
velocityContext.put("packageName", packageName);
velocityContext.put("author", genTable.getFunctionAuthor());
velocityContext.put("datetime", DateUtils.getDate());

// 字段信息
velocityContext.put("pkColumn", genTable.getPkColumn());
velocityContext.put("columns", genTable.getColumns());
velocityContext.put("importList", getImportList(genTable));
velocityContext.put("permissionPrefix", getPermissionPrefix(moduleName, businessName));
velocityContext.put("dicts", getDicts(genTable));

// 特殊模板类型
if (GenConstants.TPL_TREE.equals(tplCategory)) {
    setTreeVelocityContext(velocityContext, genTable);
}
if (GenConstants.TPL_SUB.equals(tplCategory)) {
    setSubVelocityContext(velocityContext, genTable);
}
```

### 模板列表

[`VelocityUtils:137-200`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/util/VelocityUtils.java)

根据模板类型和前端类型返回不同的模板列表：

**后端模板（所有类型通用）**:
- `vm/java/domain.java.vm` - 实体类
- `vm/java/mapper.java.vm` - Mapper 接口
- `vm/java/service.java.vm` - Service 接口
- `vm/java/serviceImpl.java.vm` - Service 实现
- `vm/java/controller.java.vm` - Controller
- `vm/xml/mapper.xml.vm` - MyBatis XML
- `vm/sql/sql.vm` - 菜单 SQL

**前端模板（根据 tplWebType 选择）**:

| tplWebType | API 模板 | 页面模板 |
|------------|----------|----------|
| element-ui | vm/js/api.js.vm | vm/vue/index.vue.vm |
| element-plus | vm/js/api.js.vm | vm/vue/v3/index.vue.vm |
| element-plus-typescript | vm/ts/api.ts.vm | vm/vue/v3ts/index.vue.vm |
| - | vm/ts/type.ts.vm | - |

**树表额外模板**:
- `vm/vue/index-tree.vue.vm` - 树形列表页面

---

## 常量定义（GenConstants）

**源码**: `ruoyi-common/src/main/java/com/ruoyi/common/constant/GenConstants.java`

### 数据库类型分组

```java
// 字符串类型
public static final String[] COLUMNTYPE_STR = { "char", "varchar", "nvarchar", "varchar2" };

// 文本类型
public static final String[] COLUMNTYPE_TEXT = { "tinytext", "text", "mediumtext", "longtext" };

// 时间类型
public static final String[] COLUMNTYPE_TIME = { "datetime", "time", "date", "timestamp" };

// 数字类型
public static final String[] COLUMNTYPE_NUMBER = { "tinyint", "smallint", "mediumint", "int", "number", "integer", "bit", "bigint", "float", "double", "decimal" };
```

### Java 类型常量

```java
public static final String TYPE_STRING = "String";
public static final String TYPE_INTEGER = "Integer";
public static final String TYPE_LONG = "Long";
public static final String TYPE_DOUBLE = "Double";
public static final String TYPE_BIGDECIMAL = "BigDecimal";
public static final String TYPE_DATE = "Date";
```

### HTML 类型常量

```java
public static final String HTML_INPUT = "input";
public static final String HTML_TEXTAREA = "textarea";
public static final String HTML_SELECT = "select";
public static final String HTML_CHECKBOX = "checkbox";
public static final String HTML_RADIO = "radio";
public static final String HTML_DATETIME = "datetime";
public static final String HTML_IMAGE_UPLOAD = "imageUpload";
public static final String HTML_FILE_UPLOAD = "fileUpload";
public static final String HTML_EDITOR = "editor";
```

### 查询类型常量

```java
public static final String QUERY_EQ = "EQ";      // 等于
public static final String QUERY_NE = "NE";      // 不等于
public static final String QUERY_GT = "GT";      // 大于
public static final String QUERY_LT = "LT";      // 小于
public static final String QUERY_LIKE = "LIKE";  // 模糊
public static final String QUERY_BETWEEN = "BETWEEN"; // 范围
```

### 字段名黑名单

```java
// 不需要编辑的字段
public static final String[] COLUMNNAME_NOT_EDIT = { "id", "create_by", "create_time", "del_flag" };

// 不需要列表的字段
public static final String[] COLUMNNAME_NOT_LIST = { "id", "create_by", "create_time", "del_flag", "update_by", "update_time" };

// 不需要查询的字段
public static final String[] COLUMNNAME_NOT_QUERY = { "id", "create_by", "create_time", "del_flag", "update_by", "update_time", "remark" };
```

### 树表常量

```java
public static final String TREE_CODE = "treeCode";
public static final String TREE_PARENT_CODE = "treeParentCode";
public static final String TREE_NAME = "treeName";
public static final String[] TREE_ENTITY = { "parentName", "parentId", "orderNum", "ancestors", "children" };
```

---

## 使用示例

### 手动触发生成代码

```java
// 1. 查询表配置
GenTable table = genTableMapper.selectGenTableByName("sys_user");

// 2. 初始化 Velocity 引擎
VelocityInitializer.initVelocity();

// 3. 准备模板上下文
VelocityContext context = VelocityUtils.prepareContext(table);

// 4. 获取模板列表
List<String> templates = VelocityUtils.getTemplateList(table);

// 5. 渲染模板
for (String template : templates) {
    Template tpl = VelocityContextUtil.getTemplate(template);
    StringWriter sw = new StringWriter();
    tpl.merge(context, sw);
    String code = sw.toString();
    
    // 6. 保存或下载代码
    // ...
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

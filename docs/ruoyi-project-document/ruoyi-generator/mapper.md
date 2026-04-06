# Mapper 数据访问层

## 概述

`ruoyi-generator/mapper` 包提供代码生成器相关的 MyBatis 数据访问接口。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/mapper/`  
**XML 位置**: `ruoyi-generator/src/main/resources/mapper/generator/`

## 模块结构

```
mapper/
├── GenTableMapper.java          # 业务表数据访问
└── GenTableColumnMapper.java    # 业务表字段数据访问
```

## Mapper 接口总览

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| GenTableMapper | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/mapper/GenTableMapper.java) | [`🔗`](../../ruoyi-generator/src/main/resources/mapper/generator/GenTableMapper.xml) | 代码生成业务表 CRUD、查询数据库表 |
| GenTableColumnMapper | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/mapper/GenTableColumnMapper.java) | [`🔗`](../../ruoyi-generator/src/main/resources/mapper/generator/GenTableColumnMapper.xml) | 代码生成业务表字段 CRUD |

---

## GenTableMapper - 业务表数据访问

### 核心方法

| 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `selectGenTableList` | GenTable | List<GenTable> | 查询业务表列表（带条件） |
| `selectDbTableList` | GenTable | List<GenTable> | 查询数据库表列表 |
| `selectDbTableListByNames` | String[] | List<GenTable> | 根据表名查询数据库表 |
| `selectGenTableAll` | - | List<GenTable> | 查询所有业务表 |
| `selectGenTableById` | Long | GenTable | 根据 ID 查询业务表 |
| `selectGenTableByName` | String | GenTable | 根据表名查询业务表 |
| `insertGenTable` | GenTable | int | 新增业务表 |
| `updateGenTable` | GenTable | int | 修改业务表 |
| `deleteGenTableByIds` | Long[] | int | 批量删除业务表 |
| `createTable` | String | int | 执行 SQL 创建表 |

### 使用示例

```java
@Autowired
private GenTableMapper genTableMapper;

// 查询业务表列表
GenTable condition = new GenTable();
condition.setTableName("sys_user");
List<GenTable> list = genTableMapper.selectGenTableList(condition);

// 查询数据库表列表
List<GenTable> dbTables = genTableMapper.selectDbTableList(condition);

// 根据表名查询
List<GenTable> tables = genTableMapper.selectDbTableListByNames(
    new String[] {"sys_user", "sys_role"}
);

// 查询所有业务表
List<GenTable> allTables = genTableMapper.selectGenTableAll();

// 根据 ID 查询
GenTable table = genTableMapper.selectGenTableById(1L);

// 根据表名查询
GenTable table = genTableMapper.selectGenTableByName("sys_user");

// 新增业务表
int rows = genTableMapper.insertGenTable(table);

// 修改业务表
table.setFunctionName("用户管理");
rows = genTableMapper.updateGenTable(table);

// 批量删除
Long[] ids = {1L, 2L, 3L};
rows = genTableMapper.deleteGenTableByIds(ids);

// 创建表
String createTableSql = "CREATE TABLE `sys_demo` (...)";
rows = genTableMapper.createTable(createTableSql);
```

---

## GenTableColumnMapper - 业务表字段数据访问

### 核心方法

| 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `selectDbTableColumnsByName` | String | List<GenTableColumn> | 根据表名查询数据库列 |
| `selectGenTableColumnListByTableId` | Long | List<GenTableColumn> | 根据表 ID 查询字段列表 |
| `insertGenTableColumn` | GenTableColumn | int | 新增业务字段 |
| `updateGenTableColumn` | GenTableColumn | int | 修改业务字段 |
| `deleteGenTableColumns` | List<GenTableColumn> | int | 删除业务字段 |
| `deleteGenTableColumnByIds` | Long[] | int | 批量删除业务字段 |

### 使用示例

```java
@Autowired
private GenTableColumnMapper columnMapper;

// 查询数据库列信息
List<GenTableColumn> columns = columnMapper.selectDbTableColumnsByName("sys_user");

// 根据表 ID 查询字段列表
List<GenTableColumn> fields = columnMapper.selectGenTableColumnListByTableId(1L);

// 新增字段
GenTableColumn column = new GenTableColumn();
column.setTableId(1L);
column.setColumnName("user_name");
column.setColumnComment("用户姓名");
column.setJavaType("String");
column.setJavaField("userName");
int rows = columnMapper.insertGenTableColumn(column);

// 修改字段
column.setIsQuery("1");
column.setQueryType("EQ");
rows = columnMapper.updateGenTableColumn(column);

// 批量删除
Long[] ids = {1L, 2L, 3L};
rows = columnMapper.deleteGenTableColumnByIds(ids);
```

---

## XML 映射示例

### GenTableMapper.xml 片段

```xml
<mapper namespace="com.ruoyi.generator.mapper.GenTableMapper">
    
    <resultMap type="GenTable" id="GenTableResult">
        <id     property="tableId"       column="table_id"      />
        <result property="tableName"     column="table_name"    />
        <result property="tableComment"  column="table_comment" />
        <result property="className"     column="class_name"    />
        <result property="tplCategory"   column="tpl_category"  />
        <result property="packageName"   column="package_name"  />
        <!-- 其他字段映射 -->
    </resultMap>
    
    <select id="selectGenTableList" parameterType="GenTable" resultMap="GenTableResult">
        select table_id, table_name, table_comment, class_name, tpl_category, package_name
        from gen_table
        <where>
            <if test="tableName != null and tableName != ''">
                and table_name like concat('%', #{tableName}, '%')
            </if>
            <if test="tableComment != null and tableComment != ''">
                and table_comment like concat('%', #{tableComment}, '%')
            </if>
        </where>
    </select>
    
    <select id="selectDbTableList" parameterType="GenTable" resultType="GenTable">
        select table_name table_name, table_comment table_comment, create_time, update_time 
        from information_schema.tables
        where table_schema = (select database())
        <if test="tableName != null and tableName != ''">
            and table_name like concat('%', #{tableName}, '%')
        </if>
        <if test="tableComment != null and tableComment != ''">
            and table_comment like concat('%', #{tableComment}, '%')
        </if>
    </select>
    
</mapper>
```

### GenTableColumnMapper.xml 片段

```xml
<mapper namespace="com.ruoyi.generator.mapper.GenTableColumnMapper">
    
    <resultMap type="GenTableColumn" id="GenTableColumnResult">
        <id     property="columnId"       column="column_id"      />
        <result property="tableId"        column="table_id"       />
        <result property="columnName"     column="column_name"    />
        <result property="columnComment"  column="column_comment" />
        <result property="columnType"     column="column_type"    />
        <result property="javaType"       column="java_type"      />
        <result property="javaField"      column="java_field"     />
        <!-- 其他字段映射 -->
    </resultMap>
    
    <select id="selectDbTableColumnsByName" resultType="GenTableColumn">
        select column_name columnName, 
               (case when (is_nullable = 'no' <![CDATA[ && ]]> column_key != 'PRI') then '1' else null end) as isRequired,
               (case when column_key = 'PRI' then '1' else '0' end) as isPk,
               ordinal_position as sort,
               column_comment columnComment,
               (case when extra = 'auto_increment' then '1' else '0' end) as isIncrement,
               column_type columnType
        from information_schema.columns where table_name = #{tableName} order by ordinal_position
    </select>
    
</mapper>
```

---

## 数据库表查询说明

### 查询数据库表信息

使用 `information_schema.tables` 表查询：

```sql
SELECT table_name, table_comment, create_time, update_time 
FROM information_schema.tables 
WHERE table_schema = DATABASE()
```

### 查询数据库列信息

使用 `information_schema.columns` 表查询：

```sql
SELECT column_name, column_type, column_comment, is_nullable, column_key, extra
FROM information_schema.columns 
WHERE table_name = 'sys_user'
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

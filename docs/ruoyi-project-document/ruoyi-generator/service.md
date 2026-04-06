# Service 业务逻辑层

## 概述

`ruoyi-generator/service` 包提供代码生成器相关的业务逻辑处理。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/service/`  
**实现位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/`

## 模块结构

```
service/
├── IGenTableService.java          # 业务表服务接口
├── IGenTableColumnService.java    # 业务表字段服务接口
└── impl/
    ├── GenTableServiceImpl.java       # 业务表服务实现
    └── GenTableColumnServiceImpl.java # 业务表字段服务实现
```

## 服务接口总览

| 服务接口 | 源码 | 实现类 | 主要功能 |
|----------|------|--------|----------|
| IGenTableService | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/IGenTableService.java) | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableServiceImpl.java) | 表管理、代码生成、预览、下载、同步 |
| IGenTableColumnService | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/IGenTableColumnService.java) | [`🔗`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableColumnServiceImpl.java) | 字段管理 |

---

## IGenTableService - 业务表服务

### 核心方法

| 方法 | 说明 |
|------|------|
| `selectGenTableList` | 查询业务表列表（带条件） |
| `selectDbTableList` | 查询数据库表列表 |
| `selectDbTableListByNames` | 根据表名查询数据库表 |
| `selectGenTableAll` | 查询所有业务表 |
| `selectGenTableById` | 根据 ID 查询业务表 |
| `updateGenTable` | 修改业务表 |
| `deleteGenTableByIds` | 批量删除业务表 |
| `createTable` | 执行 SQL 创建表 |
| `importGenTable` | 导入表结构 |
| `previewCode` | 预览代码 |
| `downloadCode` | 下载代码（ZIP） |
| `generatorCode` | 生成代码到本地路径 |
| `synchDb` | 同步数据库表结构 |
| `validateEdit` | 修改保存参数校验 |

---

## 核心业务逻辑

### 1. 导入表结构

[`GenTableServiceImpl:importGenTable()`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void importGenTable(List<GenTable> tableList, String tplWebType, String operName) {
    for (GenTable table : tableList) {
        // 1. 初始化表配置
        GenUtils.initTable(table, operName);
        
        // 2. 设置前端类型
        table.setTplWebType(tplWebType);
        
        // 3. 保存表信息
        int rows = genTableMapper.insertGenTable(table);
        
        if (rows > 0) {
            // 4. 查询列信息
            List<GenTableColumn> columns = genTableColumnMapper.selectDbTableColumnsByName(table.getTableName());
            
            // 5. 初始化列配置并保存
            for (GenTableColumn column : columns) {
                GenUtils.initColumnField(column, table);
                genTableColumnMapper.insertGenTableColumn(column);
            }
        }
    }
}
```

**流程**:
1. 初始化表配置（类名、包名、模块名等）
2. 设置前端类型
3. 保存到 gen_table 表
4. 查询数据库列信息
5. 初始化列配置并保存到 gen_table_column 表

### 2. 预览代码

[`GenTableServiceImpl:previewCode()`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableServiceImpl.java)

```java
@Override
public Map<String, String> previewCode(Long tableId) {
    Map<String, String> dataMap = new LinkedHashMap<>();
    
    // 1. 查询表信息
    GenTable table = genTableMapper.selectGenTableById(tableId);
    
    // 2. 设置主键和子表信息
    setPkColumn(table);
    setSubTable(table);
    
    // 3. 初始化 Velocity 引擎
    VelocityInitializer.initVelocity();
    
    // 4. 准备模板上下文
    VelocityContext context = VelocityUtils.prepareContext(table);
    
    // 5. 获取模板列表
    List<String> templates = VelocityUtils.getTemplateList(table);
    
    // 6. 渲染模板
    for (String template : templates) {
        Template tpl = VelocityContextUtil.getTemplate(template);
        StringWriter sw = new StringWriter();
        tpl.merge(context, sw);
        dataMap.put(template.replace(".vm", ""), sw.toString());
    }
    
    return dataMap;
}
```

### 3. 下载代码

[`GenTableServiceImpl:downloadCode()`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableServiceImpl.java)

```java
@Override
public byte[] downloadCode(String tableName) {
    ByteArrayOutputStream os = new ByteArrayOutputStream();
    ZipInputStream zis = new ZipInputStream(os);
    
    // 1. 查询表信息
    GenTable table = genTableMapper.selectGenTableByName(tableName);
    
    // 2. 设置主键和子表信息
    setPkColumn(table);
    setSubTable(table);
    
    // 3. 初始化 Velocity 引擎
    VelocityInitializer.initVelocity();
    
    // 4. 准备模板上下文
    VelocityContext context = VelocityUtils.prepareContext(table);
    
    // 5. 获取模板列表
    List<String> templates = VelocityUtils.getTemplateList(table);
    
    // 6. 生成 ZIP 包
    for (String template : templates) {
        StringWriter sw = new StringWriter();
        tpl.merge(context, sw);
        zis.putNextEntry(new ZipEntry(getFileName(template, table)));
        zis.write(sw.toByteArray());
        zis.closeEntry();
    }
    
    zis.close();
    return os.toByteArray();
}
```

### 4. 同步数据库表

[`GenTableServiceImpl:synchDb()`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/service/impl/GenTableServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void synchDb(String tableName) {
    // 1. 查询现有表配置
    GenTable table = genTableMapper.selectGenTableByName(tableName);
    
    // 2. 查询数据库列信息
    List<GenTableColumn> dbColumns = genTableColumnMapper.selectDbTableColumnsByName(tableName);
    
    // 3. 查询已保存的字段
    List<GenTableColumn> savedColumns = genTableColumnMapper.selectGenTableColumnListByTableId(table.getTableId());
    
    // 4. 对比并更新/新增/删除字段
    for (GenTableColumn dbColumn : dbColumns) {
        GenUtils.initColumnField(dbColumn, table);
        
        // 查找已保存的对应字段
        GenTableColumn savedColumn = findColumn(savedColumns, dbColumn.getColumnName());
        
        if (savedColumn != null) {
            // 更新现有字段
            dbColumn.setColumnId(savedColumn.getColumnId());
            genTableColumnMapper.updateGenTableColumn(dbColumn);
        } else {
            // 新增字段
            dbColumn.setTableId(table.getTableId());
            genTableColumnMapper.insertGenTableColumn(dbColumn);
        }
    }
}
```

---

## IGenTableColumnService - 业务表字段服务

### 核心方法

| 方法 | 说明 |
|------|------|
| `selectGenTableColumnListByTableId` | 根据表 ID 查询字段列表 |
| `insertGenTableColumn` | 新增业务字段 |
| `updateGenTableColumn` | 修改业务字段 |
| `deleteGenTableColumnByIds` | 批量删除业务字段 |

---

## 使用示例

### 在 Controller 中使用

```java
@RestController
@RequestMapping("/tool/gen")
public class GenController {
    
    @Autowired
    private IGenTableService genTableService;
    
    /**
     * 查询代码生成列表
     */
    @GetMapping("/list")
    public TableDataInfo list(GenTable genTable) {
        startPage();
        List<GenTable> list = genTableService.selectGenTableList(genTable);
        return getDataTable(list);
    }
    
    /**
     * 预览代码
     */
    @GetMapping("/preview/{tableId}")
    public AjaxResult preview(@PathVariable Long tableId) {
        Map<String, String> previewData = genTableService.previewCode(tableId);
        return success(previewData);
    }
    
    /**
     * 下载代码
     */
    @GetMapping("/download/{tableName}")
    public void download(HttpServletResponse response, @PathVariable String tableName) throws IOException {
        byte[] data = genTableService.downloadCode(tableName);
        response.reset();
        response.setHeader("Content-Disposition", "attachment; filename=\"" + tableName + ".zip\"");
        response.addHeader("Content-Length", String.valueOf(data.length));
        response.setContentType("application/octet-stream; charset=UTF-8");
        IOUtils.write(data, response.getOutputStream());
    }
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

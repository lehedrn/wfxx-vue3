# 配置类

## 概述

`ruoyi-generator/config` 包包含代码生成器的配置类，负责读取和管理代码生成相关配置。

**源码位置**: `ruoyi-generator/src/main/java/com/ruoyi/generator/config/`

## 模块结构

```
config/
└── GenConfig.java    # 代码生成配置类
```

---

## GenConfig - 代码生成配置类

**源码**: [`GenConfig.java`](../../ruoyi-generator/src/main/java/com/ruoyi/generator/config/GenConfig.java)

### 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| author | String | ruoyi | 生成代码的作者 |
| packageName | String | com.ruoyi.system | 默认生成包路径 |
| autoRemovePre | boolean | false | 是否自动去除表前缀 |
| tablePrefix | String | sys_ | 表前缀（多个用逗号分隔） |
| allowOverwrite | boolean | false | 是否允许覆盖本地文件 |

### 配置来源

配置从 `generator.yml` 文件加载：

**源码**: [`generator.yml`](../../ruoyi-generator/src/main/resources/generator.yml)

```yaml
gen:
  author: ruoyi                    # 作者
  packageName: com.ruoyi.system    # 默认包路径
  autoRemovePre: false             # 是否自动去除表前缀
  tablePrefix: sys_                # 表前缀
  allowOverwrite: false            # 是否允许覆盖本地文件
```

---

## 配置项详解

### 1. author - 作者

生成的代码文件头部注释中的作者信息。

**示例**:
```java
/**
 * 用户管理
 * 
 * @author ruoyi
 */
```

### 2. packageName - 默认包路径

生成代码的默认包路径，需要根据实际模块名称修改。

| 模块 | 包路径 |
|------|--------|
| system | com.ruoyi.system |
| monitor | com.ruoyi.monitor |
| tool | com.ruoyi.tool |

### 3. autoRemovePre - 自动去除表前缀

设置为 `true` 时，生成的类名会自动去除表前缀。

**示例**:
- 表名：`sys_user`
- `autoRemovePre = false` → 类名：`SysUser`
- `autoRemovePre = true` → 类名：`User`

### 4. tablePrefix - 表前缀

用于指定要去除的表前缀，多个前缀用逗号分隔。

**示例**:
```yaml
tablePrefix: sys_,tool_,test_
```

### 5. allowOverwrite - 允许覆盖本地文件

设置为 `true` 时，允许生成的代码覆盖本地已存在的文件。

> **安全建议**: 默认设置为 `false`，防止意外覆盖已修改的代码。

---

## 使用示例

### 在代码中获取配置

```java
// 获取作者
String author = GenConfig.getAuthor();

// 获取包路径
String packageName = GenConfig.getPackageName();

// 检查是否自动去除表前缀
boolean autoRemove = GenConfig.getAutoRemovePre();

// 获取表前缀
String tablePrefix = GenConfig.getTablePrefix();

// 检查是否允许覆盖
boolean allowOverwrite = GenConfig.isAllowOverwrite();
```

### 自定义配置示例

**generator.yml**:
```yaml
gen:
  author: 张三
  packageName: com.example.system
  autoRemovePre: true
  tablePrefix: t_,sys_
  allowOverwrite: true
```

**效果**:
- 表名 `sys_user` → 类名 `User`
- 作者显示为 `张三`
- 允许覆盖本地已存在的文件

---

## 配置修改建议

### 开发环境

```yaml
gen:
  author: 你的姓名
  packageName: com.yourcompany.module
  autoRemovePre: true
  tablePrefix: sys_
  allowOverwrite: true  # 开发时可以覆盖
```

### 生产环境

```yaml
gen:
  author: 你的姓名
  packageName: com.yourcompany.module
  autoRemovePre: true
  tablePrefix: sys_
  allowOverwrite: false  # 生产环境禁止覆盖
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

# ruoyi-gen-cli 操作手册

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: ruoyi-gen-cli 1.0

---

### 文档定位

本操作手册是 ruoyi-gen-cli 代码生成工具的**标准操作规范（SOP）**，旨在为团队提供从需求分析到代码集成的完整工作流程指导。

### 与详细文档的关系

本手册整合了现有 8 个详细文档的核心内容，按操作流程重新组织。深度技术细节请参考：

| 文档 | 说明 |
|------|------|
| [01-概述.md](./ruoyi-gen-cli/01-概述.md) | 项目简介、特点、使用场景 |
| [02-快速开始.md](./ruoyi-gen-cli/02-快速开始.md) | 安装、配置、第一个生成示例 |
| [03-配置说明.md](./ruoyi-gen-cli/03-配置说明.md) | YAML 配置文件详解 |
| [04-命令参考.md](./ruoyi-gen-cli/04-命令参考.md) | CLI 命令参数说明 |
| [05-核心模块.md](./ruoyi-gen-cli/05-核心模块.md) | 核心模块源码分析 |
| [06-最佳实践.md](./ruoyi-gen-cli/06-最佳实践.md) | 使用技巧、常见问题 |
| [07-SQL_配置详解.md](./ruoyi-gen-cli/07-SQL_配置详解.md) | DDL SQL 语法规范、完整示例 |
| [08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) | 三种模板类型的 YAML 配置模板 |

---

# 目录

1. [概述](#第 1 章-概述)
2. [前置条件](#第 2 章-前置条件)
3. [快速入门](#第 3 章-快速入门)
4. [标准操作流程](#第 4 章-标准操作流程)
5. [三种模板类型详解](#第 5 章-三种模板类型详解)
6. [SQL 编写规范](#第 6 章-SQL 编写规范)
7. [YAML 配置规范](#第 7 章-YAML 配置规范)
8. [常见问题排查](#第 8 章-常见问题排查)
9. [最佳实践](#第 9 章-最佳实践)
10. [附录](#附录)

---

# 第 1 章 概述

## 1.1 工具简介

**ruoyi-gen-cli** 是基于 RuoYi-Vue 代码生成器（ruoyi-generator）二次封装的独立可运行 JAR 包，提供 CLI 命令行方式的代码生成能力。

## 1.2 核心特点

| 特点 | 说明 |
|------|------|
| **独立运行** | 无需 MySQL、Redis 等外部依赖，仅需 JDK 17+ |
| **CLI 工具** | 通过命令行参数或配置文件控制代码生成 |
| **DDL 驱动** | 直接解析 CREATE TABLE 语句生成代码 |
| **配置灵活** | 支持命令行参数和 YAML 配置文件两种方式 |
| **批量生成** | 支持多个表一次性生成 |
| **完整代码** | 生成后端 + 前端 + 菜单 SQL 完整代码 |

## 1.3 与 ruoyi-generator 的区别

| 特性 | ruoyi-generator | ruoyi-gen-cli |
|------|-----------------|---------------|
| 运行方式 | 内嵌于 RuoYi 应用 | 独立可运行 JAR |
| 数据源 | 需要连接 MySQL | 解析 DDL SQL 语句 |
| 依赖 | 需要 Redis、数据库等 | 仅需 JDK 17+ |
| 使用场景 | 在线代码生成 | 本地批量生成、CI/CD 集成 |
| 配置方式 | 数据库表配置 | 命令行参数 + YAML 配置文件 |

## 1.4 生成的代码结构

```
{moduleName}.zip/
├── main/java/{package}/{module}/        # 后端 Java 代码
│   ├── controller/                      # 控制器层
│   ├── domain/                          # 实体类层
│   ├── service/                         # Service 层
│   └── mapper/                          # Mapper 层
├── main/resources/mapper/{moduleName}/  # MyBatis XML 映射文件
├── vue/api/{module}/                    # 前端 API 接口
├── vue/views/{module}/                  # 前端页面组件
└── {businessName}Menu.sql               # 菜单 SQL 脚本
```

## 1.5 支持的模板类型

| 模板类型 | 说明 | 示例 |
|---------|------|------|
| `crud` | 单表 CRUD | 用户管理、部门管理、学生管理 |
| `tree` | 树表结构 | 部门管理（树形）、菜单管理、商品分类 |
| `sub` | 主子表 | 订单 - 订单明细、客户 - 商品 |

---

# 第 2 章 前置条件

## 2.1 环境准备

### 2.1.1 JDK 安装

```bash
# 检查 JDK 版本（要求 17+）
java -version

# 如未安装，下载 OpenJDK 17 或更高版本
```

**要求**：JDK 17 或更高版本

### 2.1.2 Maven 安装（可选）

如需要自行构建 ruoyi-gen-cli 项目，需要 Maven：

```bash
# 检查 Maven 版本
mvn -version

# 构建项目
cd ruoyi-gen-cli
mvn clean package
```

### 2.1.3 获取 ruoyi-gen-cli.jar

- 从团队共享仓库下载已构建的 JAR 包
- 或自行从源码构建

## 2.2 需求分析

### 2.2.1 确定功能模块

根据需求文档或原型设计，确定：

- [ ] 需要哪些功能模块（如学生管理、课程管理）
- [ ] 每个模块包含哪些字段
- [ ] 字段的数据类型和约束
- [ ] 是否需要树形结构
- [ ] 是否存在主子表关系

### 2.2.2 表结构设计示例

**单表示例（学生管理）**：
- 表名：`demo_student`
- 字段：
  - `id` - 主键
  - `name` - 学生姓名
  - `age` - 年龄
  - `sex` - 性别
  - `status` - 状态

**树表示例（商品分类）**：
- 表名：`demo_category`
- 必选字段：
  - `id` - 主键
  - `parent_id` - 父节点 ID
  - `ancestors` - 祖级列表
  - `category_name` - 分类名称

**主子表示例（客户 - 商品）**：
- 主表：`demo_customer`（客户信息）
- 子表：`demo_goods`（商品信息，包含 `customer_id` 外键）

## 2.3 数据字典检查

### 2.3.1 检查现有字典类型

在生成代码前，确认系统中已存在的字典类型：

```sql
-- 查询系统中已有的字典类型
SELECT dict_type, dict_name FROM sys_dict_type;
```

### 2.3.2 常用字典类型

| 字典类型 | 说明 | 选项值 |
|---------|------|--------|
| `sys_user_sex` | 用户性别 | 0 男 / 1 女 / 2 未知 |
| `sys_common_status` | 通用状态 | 0 正常 / 1 停用 |
| `sys_normal_disable` | 通用开关 | 0 正常 / 1 停用 |
| `sys_yes_no` | 是否 | 0 是 / 1 否 |

### 2.3.3 新增字典类型

如需使用新的字典类型，有两种方式：

**方式一**：先在系统中添加字典，再生成代码

```sql
-- 1. 插入字典类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time) 
VALUES ('用户爱好', 'user_hobby', '0', 'admin', NOW());

-- 2. 插入字典数据
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, status, create_by, create_time) 
VALUES 
(1, '钓鱼', '1', 'user_hobby', '0', 'admin', NOW()),
(2, '写作', '2', 'user_hobby', '0', 'admin', NOW()),
(3, '运动', '3', 'user_hobby', '0', 'admin', NOW());
```

**方式二**：先生成代码，后补字典
- 生成代码时字典不生效（显示为普通输入框）
- 后续在系统中添加字典
- 刷新缓存后字典生效

## 2.4 项目结构确认

### 2.4.1 确定包路径

确认目标项目的包结构：

```
# 示例包路径
com.ruoyi.demo    # 主包
com.ruoyi.demo.controller
com.ruoyi.demo.domain
com.ruoyi.demo.service
com.ruoyi.demo.mapper
```

### 2.4.2 确定模块名

根据功能划分模块：

| 模块 | 包路径示例 | 说明 |
|------|-----------|------|
| 系统模块 | `com.ruoyi.system` | 用户、角色、菜单等 |
| 业务模块 | `com.ruoyi.business` | 核心业务功能 |
| 示例模块 | `com.ruoyi.demo` | 演示功能 |

### 2.4.3 确定上级菜单 ID

在若依系统中查询菜单 ID：

```sql
-- 查询现有菜单
SELECT menu_id, menu_name, parent_id FROM sys_menu ORDER BY parent_id, order_num;
```

常用上级菜单 ID：
- `3` - 系统管理
- `4` - 系统监控（或其他一级菜单）

---

# 第 3 章 快速入门

本章节提供一个完整的 5 分钟快速上手示例。

## 3.1 步骤一：编写 DDL SQL

创建 `student.sql` 文件：

```sql
-- 学生信息表
CREATE TABLE demo_student (
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '编号',
  name            VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
  age             INT(3)          DEFAULT 0     COMMENT '年龄',
  sex             CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  birthday        DATETIME                    COMMENT '生日',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生信息表';
```

## 3.2 步骤二：编写 YAML 配置

创建 `student.yml` 文件：

```yaml
# ==================== 全局默认配置 ====================
global:
  author: dev
  packageName: com.ruoyi.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: crud
  tplWebType: element-plus
  parentMenuId: 4

# ==================== 表级配置 ====================
tables:
  demo_student:
    className: Student
    functionAuthor: dev
    functionName: 学生管理
    businessName: student
    formColNum: 1
    
    columns:
      sex:
        dictType: sys_user_sex
        htmlType: select
      status:
        dictType: sys_common_status
        htmlType: radio
```

## 3.3 步骤三：执行生成命令

```bash
java -jar ruoyi-gen-cli.jar \
  --sql=student.sql \
  --config=student.yml \
  --output=./student.zip
```

## 3.4 步骤四：解压 ZIP 文件

```bash
# 解压生成的 ZIP 文件
unzip student.zip -d student_output/
```

解压后的文件结构：

```
student_output/
├── main/java/com/ruoyi/demo/
│   ├── controller/StudentController.java
│   ├── domain/Student.java
│   ├── service/IStudentService.java
│   ├── service/impl/StudentServiceImpl.java
│   └── mapper/StudentMapper.java
├── main/resources/mapper/demo/StudentMapper.xml
├── vue/api/demo/student.js
├── vue/views/demo/student/index.vue
└── studentMenu.sql
```

## 3.5 步骤五：集成到项目

### 后端代码

1. 复制 `main/java/` 到项目的对应目录
2. 复制 `main/resources/mapper/` 到项目的 `src/main/resources/mapper/`

### 前端代码

1. 复制 `vue/api/` 到项目的 `src/api/`
2. 复制 `vue/views/` 到项目的 `src/views/`

### 菜单注册

```bash
# 在 MySQL 中执行菜单 SQL
mysql -u root -p your_database < studentMenu.sql
```

### 验证功能

1. 重启若依应用
2. 刷新菜单缓存
3. 访问新增的菜单
4. 测试增删改查功能

---

# 第 4 章 标准操作流程

## 4.1 步骤一：编写 DDL SQL

### 4.1.1 表命名规范

```sql
-- 推荐格式：{模块前缀}_{业务名}
CREATE TABLE demo_student (        -- demo 模块的学生表
  -- ...
) COMMENT = '学生信息表';

CREATE TABLE sys_user (            -- 系统模块的用户表
  -- ...
) COMMENT = '用户信息表';
```

**注意事项**：
- 表名使用小写字母和下划线（snake_case）
- 避免使用 MySQL 保留字
- 如有前缀，需在 YAML 中配置 `tablePrefix`

### 4.1.2 列命名规范

```sql
CREATE TABLE demo_student (
  id              BIGINT,          -- 主键统一使用 id
  name            VARCHAR(30),     -- 使用有意义的列名
  create_time     DATETIME,        -- 审计字段规范命名
  update_time     DATETIME,
  -- ...
);
```

**注意事项**：
- 列名使用小写字母和下划线
- 主键列推荐使用 `id`
- 审计字段使用 `create_time`、`update_time`、`create_by`、`update_by`

### 4.1.3 注释规范

**表注释（必填）**：
```sql
CREATE TABLE demo_student (...) COMMENT = '学生信息表';
```

**列注释（必填）**：
```sql
name    VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
sex     CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
status  CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
```

**字典字段注释格式**：
```
字段说明（值 1 说明 值 2 说明 值 3 说明）
```

### 4.1.4 主键和索引

**主键定义**：
```sql
-- 方式 1：列级定义
id  BIGINT  NOT NULL  AUTO_INCREMENT COMMENT '编号',
PRIMARY KEY (id)

-- 方式 2：表级定义
CREATE TABLE demo_student (
  id  BIGINT  NOT NULL  AUTO_INCREMENT COMMENT '编号',
  -- ...
  PRIMARY KEY (id)
) COMMENT = '学生信息表';
```

**索引定义**：
```sql
CREATE TABLE demo_student (
  -- ...
  PRIMARY KEY (id),
  KEY idx_name (name),           -- 普通索引
  KEY idx_status (status),       -- 状态字段索引
  KEY idx_create_time (create_time)  -- 时间字段索引
);
```

## 4.2 步骤二：编写 YAML 配置

### 4.2.1 配置文件结构

YAML 配置文件采用三层结构：

```yaml
# 第一层：全局默认配置
global:
  author: dev
  packageName: com.ruoyi.demo
  # ...

# 第二层：表级配置（按表名）
tables:
  demo_student:
    className: Student
    # ...
    
    # 第三层：列级配置（按列名）
    columns:
      name:
        columnComment: 学生姓名
        # ...
```

### 4.2.2 全局配置项

```yaml
global:
  author: dev                              # 作者名
  packageName: com.ruoyi.demo              # 包路径
  moduleName: demo                         # 模块名
  autoRemovePre: true                      # 自动去除表前缀
  tablePrefix: demo_                       # 表前缀
  tplCategory: crud                        # 模板类型
  tplWebType: element-plus                 # 前端类型
  parentMenuId: 4                          # 上级菜单 ID
  formColNum: 1                            # 表单布局（1 单列 2 双列 3 三列）
```

### 4.2.3 表级配置项

```yaml
tables:
  demo_student:
    # 基本信息
    className: Student                     # 实体类名
    functionName: 学生管理                  # 功能名称
    functionAuthor: dev                    # 功能作者
    remark: 学生管理模块                   # 备注
    businessName: student                  # 业务名
    
    # 生成信息
    tplCategory: crud                      # 模板类型
    tplWebType: element-plus               # 前端类型
    packageName: com.ruoyi.demo            # 包路径
    moduleName: demo                       # 模块名
    parentMenuId: 4                        # 上级菜单 ID
    formColNum: 1                          # 表单布局
```

### 4.2.4 列级配置项

```yaml
columns:
  name:
    columnComment: 学生姓名         # 字段描述
    javaType: String               # Java 类型
    javaField: name                # Java 属性名
    isInsert: true                 # 是否插入
    isEdit: true                   # 是否编辑
    isList: true                   # 是否列表
    isQuery: true                  # 是否查询
    isRequired: true               # 是否必填
    queryType: LIKE                # 查询方式
    htmlType: input                # 表单类型
```

### 4.2.5 配置优先级

```
YAML 表级/列级配置（最高优先级）
        ↓
命令行参数
        ↓
YAML 全局配置
        ↓
generator.yml 默认值（最低优先级）
```

## 4.3 步骤三：执行生成命令

### 4.3.1 基本命令格式

```bash
java -jar ruoyi-gen-cli.jar \
  --sql=<SQL 文件路径> \
  --config=<YAML 配置文件路径> \
  --output=<输出 ZIP 路径>
```

### 4.3.2 必填参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `--sql` | DDL SQL 文件路径 | `--sql=student.sql` |
| `--config` | YAML 配置文件路径 | `--config=student.yml` |

### 4.3.3 可选参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--output` | `./generated.zip` | 输出 ZIP 文件路径 |
| `--author` | `ruoyi` | 作者名（覆盖 YAML） |
| `--package` | `com.ruoyi.system` | 包路径（覆盖 YAML） |
| `--prefix` | - | 表前缀（覆盖 YAML） |
| `--web` | `element-plus` | 前端类型（覆盖 YAML） |

### 4.3.4 日志解读

成功生成后的日志示例：

```
2026-04-07 10:00:00 INFO  加载配置文件：/path/to/student.yml
2026-04-07 10:00:01 INFO  正在解析 DDL 文件：/path/to/student.sql
2026-04-07 10:00:01 INFO  解析到 1 张表
2026-04-07 10:00:02 INFO  代码生成完成！输出文件：/path/to/student.zip
2026-04-07 10:00:02 INFO  生成表清单：
2026-04-07 10:00:02 INFO    - demo_student (学生信息表) → Student [tpl=crud, web=element-plus, pkg=com.ruoyi.demo]
```

## 4.4 步骤四：解压与拷贝

### 4.4.1 解压 ZIP 文件

```bash
# 解压到指定目录
unzip student.zip -d student_output/

# 或在 Windows 上使用资源管理器解压
```

### 4.4.2 后端代码拷贝

```
# 源目录（解压后）
student_output/main/java/com/ruoyi/demo/
student_output/main/resources/mapper/demo/

# 目标目录（你的项目）
your-project/src/main/java/com/ruoyi/demo/
your-project/src/main/resources/mapper/demo/
```

**拷贝操作**：
```bash
# Linux/Mac
cp -r student_output/main/java/com/ruoyi/demo/* your-project/src/main/java/com/ruoyi/demo/
cp -r student_output/main/resources/mapper/demo/* your-project/src/main/resources/mapper/demo/

# Windows（PowerShell）
Copy-Item -Recurse student_output\main\java\com\ruoyi\demo\* your-project\src\main\java\com\ruoyi\demo\
Copy-Item -Recurse student_output\main\resources\mapper\demo\* your-project\src\main\resources\mapper\demo\
```

### 4.4.3 前端代码拷贝

```
# 源目录（解压后）
student_output/vue/api/demo/
student_output/vue/views/demo/

# 目标目录（你的项目）
your-project/src/api/demo/
your-project/src/views/demo/
```

**拷贝操作**：
```bash
# Linux/Mac
cp -r student_output/vue/api/demo/* your-project/src/api/demo/
cp -r student_output/vue/views/demo/* your-project/src/views/demo/
```

### 4.4.4 菜单 SQL 执行

```bash
# 执行菜单 SQL
mysql -u root -p your_database < student_output/studentMenu.sql
```

或在 MySQL 客户端中手动执行：
```sql
source student_output/studentMenu.sql;
```

## 4.5 步骤五：集成与验证

### 4.5.1 后端代码集成

1. **检查依赖**：确保项目中已包含必要的依赖
2. **编译检查**：运行 `mvn compile` 检查是否有编译错误
3. **修复导入**：如有缺失的 import，手动添加

### 4.5.2 前端代码集成

1. **检查依赖**：确保 `package.json` 包含必要的依赖
2. **安装依赖**：运行 `npm install`
3. **路由配置**：如需要，在路由文件中添加新页面

### 4.5.3 菜单权限配置

1. **刷新缓存**：在若依系统管理 → 系统监控 → 缓存中刷新菜单缓存
2. **角色授权**：在系统管理 → 角色管理中为新菜单授权
3. **验证显示**：登录系统验证菜单是否正确显示

### 4.5.4 功能测试

测试清单：

- [ ] 列表页面正常显示
- [ ] 查询功能正常
- [ ] 新增功能正常
- [ ] 修改功能正常
- [ ] 删除功能正常
- [ ] 导出功能正常（如有）
- [ ] 字典项正确显示
- [ ] 表单验证生效

---

**（文档续）**

---

# 第 5 章 三种模板类型详解

## 5.1 CRUD 模板（单表）

### 5.1.1 SQL 要求

```sql
CREATE TABLE demo_student (
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '编号',
  name            VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
  age             INT(3)          DEFAULT 0     COMMENT '年龄',
  sex             CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  birthday        DATETIME                    COMMENT '生日',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生信息表';
```

### 5.1.2 配置要点

```yaml
global:
  tplCategory: crud          # 模板类型：crud

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

### 5.1.3 适用场景

- 简单的单表增删改查
- 无层级关系
- 无主子表关联

### 5.1.4 完整示例

参考：[08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) - 模板 1：单表 CRUD 配置模板

---

## 5.2 树表模板

### 5.2.1 SQL 要求

**必须包含的字段**：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `id` | BIGINT | 主键（树编码） |
| `parent_id` | BIGINT | 父节点 ID（树父编码） |
| `ancestors` | VARCHAR(500) | 祖级列表 |
| `{name 字段}` | VARCHAR | 树名称字段 |

```sql
CREATE TABLE demo_category (
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '类别 ID',
  parent_id       BIGINT          DEFAULT 0     COMMENT '父类别 ID',
  ancestors       VARCHAR(500)    DEFAULT ''    COMMENT '祖级列表',
  category_name   VARCHAR(30)     NOT NULL      COMMENT '类别名称',
  sort            INT             DEFAULT 0     COMMENT '排序',
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='产品类别表';
```

### 5.2.2 配置要点

```yaml
global:
  tplCategory: tree          # 模板类型：tree

tables:
  demo_category:
    className: Category
    functionName: 类别管理
    
    # 树表配置（必须）
    treeCode: id                 # 树编码字段（主键）
    treeParentCode: parent_id    # 树父编码字段
    treeName: category_name      # 树名称字段
```

### 5.2.3 适用场景

- 具有层级关系的数据
- 部门管理、菜单管理、商品分类

### 5.2.4 完整示例

参考：[08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) - 模板 2：树表结构配置模板

---

## 5.3 主子表模板

### 5.3.1 SQL 要求

**主表**：
```sql
CREATE TABLE demo_customer (
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '客户 ID',
  customer_name   VARCHAR(100)    NOT NULL      COMMENT '客户名称',
  phone           VARCHAR(20)                   COMMENT '联系电话',
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='客户表';
```

**子表（必须包含外键字段）**：
```sql
CREATE TABLE demo_goods (
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '商品 ID',
  customer_id     BIGINT          NOT NULL      COMMENT '客户 ID',  -- 外键字段
  goods_name      VARCHAR(100)    NOT NULL      COMMENT '商品名称',
  price           DECIMAL(10,2)   DEFAULT 0     COMMENT '价格',
  PRIMARY KEY (id),
  KEY idx_customer_id (customer_id)  -- 建议添加外键索引
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='商品表';
```

### 5.3.2 配置要点

```yaml
global:
  tplCategory: sub           # 模板类型：sub

tables:
  demo_customer:
    className: Customer
    functionName: 客户管理
    
    # 主子表配置（必须）
    subTableName: demo_goods     # 子表表名
    subTableFkName: customer_id  # 子表关联外键字段
    
  demo_goods:
    className: Goods
    functionName: 商品管理
```

### 5.3.3 注意事项

1. **子表不生成独立代码**：子表的代码作为主表的一部分生成在同一个 ZIP 中
2. **外键字段命名**：子表的外键字段名必须与 `subTableFkName` 完全一致
3. **外键索引**：建议为子表的外键字段添加索引

### 5.3.4 适用场景

- 一对多关系
- 订单 - 订单明细、客户 - 商品、文章 - 评论

### 5.3.5 完整示例

参考：[08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) - 模板 3：主子表配置模板

---

# 第 6 章 SQL 编写规范

## 6.1 表命名规范

```sql
-- 推荐格式：{模块前缀}_{业务名}
CREATE TABLE demo_student (        -- demo 模块的学生表
  -- ...
) COMMENT = '学生信息表';
```

**注意事项**：
- 表名使用小写字母和下划线（snake_case）
- 避免使用 MySQL 保留字
- 如有前缀，需在 YAML 中配置 `tablePrefix`

## 6.2 字段命名规范

```sql
CREATE TABLE demo_student (
  id              BIGINT,          -- 主键统一使用 id
  name            VARCHAR(30),     -- 使用有意义的列名
  create_time     DATETIME,        -- 审计字段规范命名
  update_time     DATETIME,
  -- ...
);
```

**注意事项**：
- 列名使用小写字母和下划线
- 主键列推荐使用 `id`
- 审计字段使用 `create_time`、`update_time`、`create_by`、`update_by`

## 6.3 注释规范

**表注释（必填）**：
```sql
CREATE TABLE demo_student (...) COMMENT = '学生信息表';
```

**列注释（必填）**：
```sql
name    VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
sex     CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
status  CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
```

**字典字段注释格式**：
```
字段说明（值 1 说明 值 2 说明 值 3 说明）
示例：性别（0 男 1 女 2 未知）
```

## 6.4 数据类型选择

| 数据库类型 | Java 类型 | 说明 | 示例 |
|-----------|----------|------|------|
| `CHAR(n)` | `String` | 定长字符串 | `CHAR(1)` 用于性别、状态 |
| `VARCHAR(n)` | `String` | 变长字符串 | `VARCHAR(30)` 用于名称 |
| `TEXT` | `String` | 长文本 | `TEXT` 用于描述、内容 |
| `TINYINT(1)` | `Boolean` | 布尔值 | `TINYINT(1)` 用于是否标志 |
| `INT`, `INTEGER` | `Integer` | 整数 | `INT(3)` 用于年龄、数量 |
| `BIGINT` | `Long` | 长整数 | `BIGINT` 用于主键 ID |
| `DECIMAL(p,s)`, `NUMERIC(p,s)` | `BigDecimal` | 精确数值 | `DECIMAL(10,2)` 用于金额 |
| `DOUBLE`, `FLOAT` | `Double` | 浮点数 | `DOUBLE` 用于单价 |
| `DATE` | `Date` | 日期 | `DATE` 用于生日 |
| `TIME` | `Date` | 时间 | `TIME` 用于时分秒 |
| `DATETIME`, `TIMESTAMP` | `Date` | 日期时间 | `DATETIME` 用于创建时间 |

## 6.5 约束和索引

**主键定义**：
```sql
id  BIGINT  NOT NULL  AUTO_INCREMENT COMMENT '编号',
PRIMARY KEY (id)
```

**NOT NULL（非空）**：
```sql
name    VARCHAR(30)     NOT NULL      COMMENT '学生姓名'
```

**DEFAULT（默认值）**：
```sql
age     INT(3)          DEFAULT 0     COMMENT '年龄'
status  CHAR(1)         DEFAULT '0'   COMMENT '状态'
```

**索引定义**：
```sql
CREATE TABLE demo_student (
  -- ...
  PRIMARY KEY (id),
  KEY idx_name (name),           -- 普通索引
  KEY idx_status (status),       -- 状态字段索引
  KEY idx_create_time (create_time)  -- 时间字段索引
);
```

---

# 第 7 章 YAML 配置规范

## 7.1 全局配置项说明

```yaml
global:
  author: dev                              # 作者名
  packageName: com.ruoyi.demo              # 包路径
  moduleName: demo                         # 模块名
  autoRemovePre: true                      # 自动去除表前缀
  tablePrefix: demo_                       # 表前缀
  tplCategory: crud                        # 模板类型：crud / tree / sub
  tplWebType: element-plus                 # 前端类型：element-ui / element-plus
  parentMenuId: 4                          # 上级菜单 ID
  formColNum: 1                            # 表单布局：1 单列 / 2 双列 / 3 三列
```

## 7.2 表级配置项说明

```yaml
tables:
  demo_student:
    # 基本信息
    className: Student                     # 实体类名
    functionName: 学生管理                  # 功能名称
    functionAuthor: dev                    # 功能作者
    remark: 学生管理模块                   # 备注
    businessName: student                  # 业务名
    
    # 生成信息
    tplCategory: crud                      # 模板类型
    tplWebType: element-plus               # 前端类型
    packageName: com.ruoyi.demo            # 包路径
    moduleName: demo                       # 模块名
    parentMenuId: 4                        # 上级菜单 ID
    formColNum: 1                          # 表单布局
    
    # 树表配置（仅 tree 模板需要）
    treeCode: id
    treeParentCode: parent_id
    treeName: name
    
    # 主子表配置（仅 sub 模板需要）
    subTableName: demo_goods
    subTableFkName: customer_id
```

## 7.3 列级配置项说明

```yaml
columns:
  name:
    columnComment: 学生姓名         # 字段描述
    javaType: String               # Java 类型
    javaField: name                # Java 属性名
    isInsert: true                 # 是否插入
    isEdit: true                   # 是否编辑
    isList: true                   # 是否列表
    isQuery: true                  # 是否查询
    isRequired: true               # 是否必填
    queryType: LIKE                # 查询方式：EQ / LIKE / BETWEEN 等
    htmlType: input                # 表单类型：input / select / radio 等
    dictType: sys_user_sex         # 字典类型
```

## 7.4 配置优先级规则

```
YAML 表级/列级配置（最高优先级）
        ↓
命令行参数
        ↓
YAML 全局配置
        ↓
generator.yml 默认值（最低优先级）
```

## 7.5 配置复用技巧

**使用全局配置减少重复**：
```yaml
global:
  author: dev
  packageName: com.ruoyi.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: crud
  tplWebType: element-plus

tables:
  demo_student:
    className: Student
    functionName: 学生管理
    # 继承全局配置
    
  demo_teacher:
    className: Teacher
    functionName: 教师管理
    # 继承全局配置
```

---

# 第 8 章 常见问题排查

## 8.1 生成失败类问题

### 8.1.1 SQL 解析失败

**错误信息**：
```
错误：SQL 解析失败：syntax error
```

**原因**：
- SQL 语法不符合 MySQL 规范
- 使用了不支持的语法

**解决方法**：
1. 检查 SQL 语法是否正确
2. 确保使用标准的 CREATE TABLE 语法
3. 确保表注释和列注释完整

### 8.1.2 配置文件格式错误

**错误信息**：
```
错误：YAML 配置文件格式错误
```

**原因**：
- YAML 缩进不正确
- 使用了中文冒号或引号

**解决方法**：
1. 检查 YAML 缩进（使用空格，不要用 Tab）
2. 确保使用英文冒号和引号
3. 使用 YAML 验证工具检查

### 8.1.3 缺少必填参数

**错误信息**：
```
错误：请指定 --sql 和 --config 参数
```

**解决方法**：
```bash
java -jar ruoyi-gen-cli.jar \
  --sql=student.sql \
  --config=student.yml \
  --output=./student.zip
```

## 8.2 代码结构问题

### 8.2.1 包名/模块名不正确

**问题**：生成的代码包名与预期不符

**解决方法**：
1. 检查全局 `packageName` 配置
2. 检查 `moduleName` 配置
3. 表级配置可以覆盖全局配置

```yaml
global:
  packageName: com.example.system
  
tables:
  demo_student:
    packageName: com.example.demo  # 覆盖全局
```

### 8.2.2 类名/字段名不符合规范

**问题**：生成的类名或字段名不符合 Java 命名规范

**解决方法**：
1. 在 YAML 中显式指定 `className` 和 `javaField`
2. 确保命名符合大驼峰（类名）或小驼峰（字段名）规范

## 8.3 功能问题

### 8.3.1 字典不生效

**问题**：下拉选择显示不出字典值

**原因**：
1. 系统中不存在该字典类型
2. `dictType` 配置错误
3. `htmlType` 不是 select/radio/checkbox

**解决方法**：
1. 确认系统中已存在该字典类型
2. 检查 `dictType` 配置是否正确
3. 检查 `htmlType` 是否为 select/radio/checkbox

```yaml
columns:
  sex:
    htmlType: select
    dictType: sys_user_sex  # 必须是存在的字典
```

### 8.3.2 主子表不关联

**问题**：生成的代码没有主子表关联

**解决方法**：
1. 确保主表配置了 `subTableName` 和 `subTableFkName`
2. 确保子表在 `tables` 列表中
3. 检查子表的外键字段名是否与 `subTableFkName` 一致

```yaml
tables:
  demo_customer:
    subTableName: demo_goods
    subTableFkName: customer_id  # 必须与子表的外键字段名一致
    
  demo_goods:
    # 子表需要有 customer_id 字段
```

### 8.3.3 树表无法展开

**问题**：树形结构无法正确展示

**解决方法**：
1. 确保 `tplCategory` 设置为 `tree`
2. 确保配置了 `treeCode`、`treeParentCode`、`treeName`
3. 确保 DDL 中有对应的字段

```yaml
tables:
  demo_category:
    tplCategory: tree
    treeCode: id           # 主键字段
    treeParentCode: parent_id  # 父 ID 字段
    treeName: category_name    # 显示名称字段
```

### 8.3.4 生成字段缺失

**问题**：某些字段没有在生成的代码中出现

**解决方法**：
1. 检查 DDL 中该字段是否有注释
2. 检查列级配置中的 `isInsert`/`isEdit`/`isList`/`isQuery` 是否设置
3. 确保 `javaType` 配置正确

```yaml
columns:
  description:
    isInsert: true
    isEdit: true
    isList: true
    isQuery: false
    javaType: String
```

## 8.4 集成问题

### 8.4.1 菜单不显示

**问题**：执行菜单 SQL 后，菜单不显示

**解决方法**：
1. 在若依系统管理中刷新菜单缓存
2. 退出重新登录
3. 检查角色是否有菜单权限

### 8.4.2 权限不生效

**问题**：按钮权限不生效

**解决方法**：
1. 在角色管理中分配相应权限
2. 刷新缓存
3. 退出重新登录

### 8.4.3 前端页面报错

**问题**：前端页面打开后报错

**可能原因**：
1. API 路径不正确
2. 字典未加载
3. 后端接口报错

**解决方法**：
1. 检查前端 API 文件中的路径是否正确
2. 检查字典是否在系统中存在
3. 查看浏览器控制台的错误信息

---

# 第 9 章 最佳实践

## 9.1 命名规范建议

**表命名**：
- 使用小写字母和下划线
- 格式：`{模块前缀}_{业务名}`
- 示例：`demo_student`、`sys_user`

**字段命名**：
- 主键统一使用 `id`
- 审计字段：`create_time`、`update_time`、`create_by`、`update_by`
- 外键字段：`{关联表}_id`

**类命名**：
- 实体类：大驼峰，如 `Student`、`Customer`
- Controller：`{ClassName}Controller`
- Service：`I{ClassName}Service`、`{ClassName}ServiceImpl`

## 9.2 配置管理建议

**使用配置文件**：
- 推荐使用 YAML 配置文件，而不是仅用命令行参数
- 将常用配置保存为模板，方便复用

**配置版本控制**：
- 将 SQL 和 YAML 配置文件纳入 Git 管理
- 提交信息注明变更内容

## 9.3 批量生成技巧

**多表批量生成**：
```sql
-- all_tables.sql
-- 学生表
CREATE TABLE demo_student (...);

-- 教师表
CREATE TABLE demo_teacher (...);

-- 课程表
CREATE TABLE demo_course (...);
```

```bash
java -jar ruoyi-gen-cli.jar \
  --sql=all_tables.sql \
  --config=gen-config.yml \
  --output=./all.zip
```

## 9.4 版本控制建议

**Git 分支管理**：
```bash
# 创建新分支
git checkout -b feature/auto-generated

# 添加生成的代码
git add ruoyi-demo/

# 提交
git commit -m "feat: 代码生成器生成学生管理模块"

# 合并到开发分支
git merge --no-ff feature/auto-generated
```

---

# 附录

## 附录 A：配置项速查表

### 全局配置项

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `author` | String | `ruoyi` | 作者名 |
| `packageName` | String | `com.ruoyi.system` | 生成包路径 |
| `moduleName` | String | 从 packageName 提取 | 模块名 |
| `autoRemovePre` | Boolean | `false` | 自动去除表前缀 |
| `tablePrefix` | String | - | 表前缀（多个逗号分隔） |
| `tplCategory` | String | `crud` | 模板类型：crud / tree / sub |
| `tplWebType` | String | `element-plus` | 前端类型：element-ui / element-plus |
| `parentMenuId` | Long | `3` | 上级菜单 ID |
| `formColNum` | Integer | `1` | 表单布局：1 单列 / 2 双列 / 3 三列 |

### 表级配置项

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `className` | String | 实体类名 |
| `functionName` | String | 功能名称 |
| `functionAuthor` | String | 功能作者 |
| `remark` | String | 备注 |
| `businessName` | String | 业务名 |
| `treeCode` | String | 树编码字段 |
| `treeParentCode` | String | 树父编码字段 |
| `treeName` | String | 树名称字段 |
| `subTableName` | String | 子表表名 |
| `subTableFkName` | String | 子表关联外键字段 |

### 列级配置项

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `columnComment` | String | 字段描述 |
| `javaType` | String | Java 类型 |
| `javaField` | String | Java 属性名 |
| `isInsert` | Boolean | 是否插入 |
| `isEdit` | Boolean | 是否编辑 |
| `isList` | Boolean | 是否列表 |
| `isQuery` | Boolean | 是否查询 |
| `isRequired` | Boolean | 是否必填 |
| `queryType` | String | 查询方式 |
| `htmlType` | String | 表单类型 |
| `dictType` | String | 字典类型 |

## 附录 B：字典类型参考表

| 字典类型 | 说明 | 选项值 |
|---------|------|--------|
| `sys_user_sex` | 用户性别 | 0 男 / 1 女 / 2 未知 |
| `sys_common_status` | 通用状态 | 0 正常 / 1 停用 |
| `sys_normal_disable` | 通用开关 | 0 正常 / 1 停用 |
| `sys_yes_no` | 是否 | 0 是 / 1 否 |

## 附录 C：表单类型参考表

| 表单类型 | 说明 | 适用场景 |
|---------|------|---------|
| `input` | 单行文本框 | 短文本输入 |
| `textarea` | 多行文本框 | 长文本输入 |
| `select` | 下拉选择 | 字典项选择 |
| `radio` | 单选框 | 少量选项单选 |
| `checkbox` | 复选框 | 多选项多选 |
| `datetime` | 日期时间选择 | 日期时间输入 |
| `switch` | 开关 | 布尔值切换 |
| `imageUpload` | 图片上传 | 图片上传 |
| `fileUpload` | 文件上传 | 文件上传 |
| `editor` | 富文本编辑器 | 富文本内容 |

## 附录 D：查询方式参考表

| 查询方式 | 说明 | 适用场景 |
|---------|------|---------|
| `EQ` | 等于 | 精确匹配 |
| `NE` | 不等于 | 排除匹配 |
| `GT` | 大于 | 数值范围 |
| `GTE` | 大于等于 | 数值范围 |
| `LT` | 小于 | 数值范围 |
| `LTE` | 小于等于 | 数值范围 |
| `LIKE` | 模糊匹配 | 文本搜索 |
| `BETWEEN` | 范围查询 | 日期/数值范围 |

## 附录 E：Java 类型映射表

| 数据库类型 | Java 类型 |
|-----------|----------|
| `VARCHAR`, `TEXT`, `CHAR` | `String` |
| `INT`, `INTEGER`, `SMALLINT` | `Integer` |
| `BIGINT` | `Long` |
| `DECIMAL`, `NUMERIC` | `BigDecimal` |
| `DOUBLE`, `FLOAT` | `Double` |
| `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` | `Date` |
| `TINYINT(1)`, `BIT` | `Boolean` |

## 附录 F：文档参考链接

| 文档 | 说明 | 链接 |
|------|------|------|
| [01-概述.md](./ruoyi-gen-cli/01-概述.md) | 项目简介、特点、使用场景 |
| [02-快速开始.md](./ruoyi-gen-cli/02-快速开始.md) | 安装、配置、第一个生成示例 |
| [03-配置说明.md](./ruoyi-gen-cli/03-配置说明.md) | YAML 配置文件详解 |
| [04-命令参考.md](./ruoyi-gen-cli/04-命令参考.md) | CLI 命令参数说明 |
| [05-核心模块.md](./ruoyi-gen-cli/05-核心模块.md) | 核心模块源码分析 |
| [06-最佳实践.md](./ruoyi-gen-cli/06-最佳实践.md) | 使用技巧、常见问题 |
| [07-SQL_配置详解.md](./ruoyi-gen-cli/07-SQL_配置详解.md) | DDL SQL 语法规范、完整示例 |
| [08-配置模板.md](./ruoyi-gen-cli/08-配置模板.md) | 三种模板类型的 YAML 配置模板 |

---

**文档结束**

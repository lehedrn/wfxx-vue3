# ruoyi-gen-cli SQL 配置详解

本文档详细说明如何编写用于代码生成的 DDL SQL 文件。ruoyi-gen-cli 使用 Alibaba Druid SQL Parser 解析 MySQL CREATE TABLE 语句，因此 SQL 语法必须符合 MySQL 规范。

## 1. SQL 文件基本结构

### 1.1 文件编码

- **编码格式**：UTF-8
- **换行符**：LF（Unix/Linux）或 CRLF（Windows）均可
- **文件扩展名**：`.sql`

### 1.2 基本语法

```sql
-- 单行注释（推荐）
CREATE TABLE table_name (
  column_name   DATA_TYPE     [CONSTRAINTS]     COMMENT '列注释',
  PRIMARY KEY (column_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表注释';
```

## 2. 表定义规范

### 2.1 表命名

**推荐规范**：
```sql
-- 格式：{模块前缀}_{业务名}_{实体名}
CREATE TABLE demo_student (          -- 示例：demo 模块的学生表
  -- ...
) COMMENT = '学生信息表';

CREATE TABLE sys_user (              -- 示例：系统模块的用户表
  -- ...
) COMMENT = '用户信息表';

CREATE TABLE t_order (               -- 示例：使用 t_ 前缀
  -- ...
) COMMENT = '订单表';
```

**注意事项**：
- 表名使用小写字母和下划线（snake_case）
- 避免使用 MySQL 保留字作为表名
- 如有前缀，需在 YAML 配置或 CLI 参数中指定 `tablePrefix` 或 `--prefix`

### 2.2 表注释

表注释是**必填**的，用于生成实体类的类注释和菜单名称：

```sql
-- 方式 1：标准 MySQL 语法（推荐）
CREATE TABLE demo_student (
  id  BIGINT  NOT NULL  COMMENT '编号',
  PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT = '学生信息表';

-- 方式 2：MySQL 8.0+ 语法
CREATE TABLE demo_student COMMENT '学生信息表' (
  id  BIGINT  NOT NULL  COMMENT '编号',
  PRIMARY KEY (id)
) ENGINE=InnoDB;
```

## 3. 列定义规范

### 3.1 列命名

**推荐规范**：
```sql
CREATE TABLE demo_student (
  user_name       VARCHAR(30),     -- 小写 + 下划线
  create_time     DATETIME,
  update_by       VARCHAR(30),
  -- ...
);
```

**注意事项**：
- 列名使用小写字母和下划线（snake_case）
- 避免使用 MySQL 保留字（如 `order`, `group`, `desc` 等）
- 主键列推荐使用 `id` 或 `{表名}_id`（如 `user_id`）

### 3.2 列注释

列注释是**必填**的，用于生成实体类的字段注释和前端标签：

```sql
CREATE TABLE demo_student (
  name        VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
  age         INT(3)          DEFAULT 0     COMMENT '年龄',
  sex         CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
  status      CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  balance     DECIMAL(10,2)   DEFAULT 0     COMMENT '账户余额',
  birthday    DATETIME                      COMMENT '生日',
  -- ...
);
```

**注释格式建议**：
- 字典字段：`字段说明（0 值 1 说明 2 说明）`
- 布尔字段：`字段说明（0 否 1 是）`
- 普通字段：直接写说明

### 3.3 主键定义

主键**必须**定义，有两种方式：

**方式 1：列级定义**（推荐）
```sql
CREATE TABLE demo_student (
  id          BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '编号',
  name        VARCHAR(30)     DEFAULT ''    COMMENT '学生姓名',
  PRIMARY KEY (id)
) COMMENT = '学生信息表';
```

**方式 2：表级定义**
```sql
CREATE TABLE demo_student (
  id          BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '编号',
  name        VARCHAR(30)     DEFAULT ''    COMMENT '学生姓名',
  CONSTRAINT pk_demo_student PRIMARY KEY (id)
) COMMENT = '学生信息表';
```

### 3.4 自增列

主键通常使用自增：

```sql
id  BIGINT  NOT NULL  AUTO_INCREMENT  COMMENT '编号'
```

**注意**：
- 自增列必须是主键或唯一索引
- 一个表只能有一个自增列

## 4. 数据类型映射

ruoyi-gen-cli 根据数据库数据类型自动推断 Java 类型：

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

### 4.1 常用数据类型示例

```sql
CREATE TABLE demo_product (
  -- 字符串类型
  name            VARCHAR(100)    DEFAULT ''    COMMENT '产品名称',
  description     TEXT                        COMMENT '产品描述',
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态',
  
  -- 数值类型
  price           DECIMAL(10,2)   DEFAULT 0     COMMENT '价格',
  stock           INT             DEFAULT 0     COMMENT '库存',
  sort            INT             DEFAULT 0     COMMENT '排序',
  
  -- 日期时间类型
  sale_date       DATE                        COMMENT '销售日期',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  -- 布尔类型
  is_hot          TINYINT(1)      DEFAULT 0     COMMENT '是否热门（0 否 1 是）',
  is_delete       TINYINT(1)      DEFAULT 0     COMMENT '是否删除（0 否 1 是）',
  
  PRIMARY KEY (id)
) COMMENT = '产品信息表';
```

## 5. 约束定义

### 5.1 NOT NULL（非空）

```sql
name    VARCHAR(30)     NOT NULL      COMMENT '学生姓名'
```

生成代码时，NOT NULL 列会被标记为必填字段。

### 5.2 DEFAULT（默认值）

```sql
age     INT(3)          DEFAULT 0     COMMENT '年龄'
status  CHAR(1)         DEFAULT '0'   COMMENT '状态'
```

### 5.3 UNIQUE（唯一约束）

```sql
CREATE TABLE sys_user (
  user_id     BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '用户 ID',
  user_name   VARCHAR(30)     NOT NULL                  COMMENT '用户账号',
  email       VARCHAR(100)    NOT NULL                  COMMENT '邮箱',
  phone       VARCHAR(11)                               COMMENT '手机号',
  PRIMARY KEY (user_id),
  UNIQUE KEY uk_user_name (user_name),
  UNIQUE KEY uk_email (email)
) COMMENT = '用户信息表';
```

## 6. 索引定义

### 6.1 普通索引

```sql
CREATE TABLE demo_order (
  order_id      BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '订单 ID',
  order_no      VARCHAR(30)     NOT NULL                  COMMENT '订单号',
  user_id       BIGINT          NOT NULL                  COMMENT '用户 ID',
  status        CHAR(1)         DEFAULT '0'               COMMENT '状态',
  create_time   DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (order_id),
  KEY idx_order_no (order_no),
  KEY idx_user_id (user_id),
  KEY idx_status (status),
  KEY idx_create_time (create_time)
) COMMENT = '订单表';
```

### 6.2 复合索引

```sql
CREATE TABLE demo_order_item (
  item_id       BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '明细 ID',
  order_id      BIGINT          NOT NULL                  COMMENT '订单 ID',
  product_id    BIGINT          NOT NULL                  COMMENT '产品 ID',
  quantity      INT             DEFAULT 0                 COMMENT '数量',
  PRIMARY KEY (item_id),
  KEY idx_order_product (order_id, product_id)
) COMMENT = '订单明细表';
```

## 7. 完整 SQL 模板

### 7.1 单表 CRUD 模板

```sql
-- 学生信息表（单表 CRUD）
-- 使用场景：简单的单表增删改查，无树形结构、无主子关联
CREATE TABLE demo_student (
  -- ===== 主键字段 =====
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '编号',
  
  -- ===== 基本信息 =====
  name            VARCHAR(30)     NOT NULL      COMMENT '学生姓名',
  age             INT(3)          DEFAULT 0     COMMENT '年龄',
  sex             CHAR(1)         DEFAULT '0'   COMMENT '性别（0 男 1 女 2 未知）',
  
  -- ===== 业务字段 =====
  student_hobby   VARCHAR(50)     DEFAULT ''    COMMENT '爱好（1 钓鱼 2 写作 3 运动 4 冥想 5 音乐 6 电影）',
  balance         DECIMAL(10,2)   DEFAULT 0     COMMENT '账户余额',
  birthday        DATETIME                    COMMENT '生日',
  
  -- ===== 状态字段 =====
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  del_flag        TINYINT(1)      DEFAULT 0     COMMENT '删除标志（0 代表存在 1 代表删除）',
  
  -- ===== 审计字段 =====
  create_by       VARCHAR(30)                   COMMENT '创建者',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by       VARCHAR(30)                   COMMENT '更新者',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark          VARCHAR(500)                  COMMENT '备注',
  
  -- ===== 索引定义 =====
  PRIMARY KEY (id),
  KEY idx_name (name),
  KEY idx_status (status),
  KEY idx_create_time (create_time)
  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生信息表';
```

**YAML 配置示例**：
```yaml
global:
  author: dev
  packageName: com.ruoyi.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: crud
  tplWebType: element-plus
  parentMenuId: 4

tables:
  demo_student:
    className: Student
    functionName: 学生管理
    functionAuthor: dev
    remark: 学生管理模块，支持批量导入导出
    businessName: student
    formColNum: 2
    
    columns:
      # 主键 - 不插入不编辑
      id:
        isInsert: false
        isEdit: false
        isList: true
        
      # 姓名 - 必填、可查询
      name:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        isRequired: true
        queryType: LIKE
        
      # 性别 - 字典选择
      sex:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        htmlType: select
        dictType: sys_user_sex
        
      # 状态 - 单选框
      status:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        htmlType: radio
        dictType: sys_common_status
        
      # 爱好 - 多选框
      student_hobby:
        isInsert: true
        isEdit: true
        isList: true
        htmlType: checkbox
        dictType: user_hobby
        
      # 生日 - 日期选择
      birthday:
        isInsert: true
        isEdit: true
        isList: true
        htmlType: datetime
        
      # 余额 - 范围查询
      balance:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        queryType: BETWEEN
```

### 7.2 树表结构模板

```sql
-- 产品类别表（树形结构）
-- 使用场景：具有层级关系的树形结构，如部门管理、菜单管理、商品分类
CREATE TABLE demo_category (
  -- ===== 主键字段 =====
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '类别 ID',
  
  -- ===== 树形结构字段（必须）=====
  parent_id       BIGINT          DEFAULT 0     COMMENT '父类别 ID',
  ancestors       VARCHAR(500)    DEFAULT ''    COMMENT '祖级列表',
  
  -- ===== 基本信息 =====
  category_name   VARCHAR(30)     NOT NULL      COMMENT '类别名称',
  
  -- ===== 业务字段 =====
  sort            INT             DEFAULT 0     COMMENT '排序',
  
  -- ===== 状态字段 =====
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  del_flag        TINYINT(1)      DEFAULT 0     COMMENT '删除标志（0 代表存在 1 代表删除）',
  
  -- ===== 审计字段 =====
  create_by       VARCHAR(30)                   COMMENT '创建者',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by       VARCHAR(30)                   COMMENT '更新者',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  -- ===== 索引定义 =====
  PRIMARY KEY (id),
  KEY idx_parent_id (parent_id),
  KEY idx_status (status)
  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='产品类别表';
```

**YAML 配置示例**：
```yaml
global:
  author: dev
  packageName: com.ruoyi.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: tree              # 树表模板
  tplWebType: element-plus
  parentMenuId: 4

tables:
  demo_category:
    className: Category
    functionName: 类别管理
    functionAuthor: dev
    remark: 产品类别管理，支持树形结构展示
    
    # 树表配置（必须）
    treeCode: id                 # 树编码字段（主键）
    treeParentCode: parent_id    # 树父编码字段
    treeName: category_name      # 树名称字段
    
    columns:
      # 主键
      id:
        isInsert: false
        isEdit: false
        isList: true
        
      # 父类别 ID - 隐藏字段
      parent_id:
        isInsert: true
        isEdit: true
        isList: false
        isQuery: false
        
      # 祖级列表 - 隐藏字段
      ancestors:
        isInsert: false
        isEdit: false
        isList: false
        isQuery: false
        
      # 类别名称 - 必填
      category_name:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        isRequired: true
        queryType: LIKE
        
      # 排序
      sort:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: false
```

### 7.3 主子表结构模板

```sql
-- ===== 主表：客户表 =====
-- 使用场景：一对多关系，如订单 - 订单明细、客户 - 商品、文章 - 评论
CREATE TABLE demo_customer (
  -- ===== 主键字段 =====
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '客户 ID',
  
  -- ===== 基本信息 =====
  customer_name   VARCHAR(100)    NOT NULL      COMMENT '客户名称',
  customer_type   CHAR(1)         DEFAULT '0'   COMMENT '客户类型（0 个人 1 企业）',
  contact_person  VARCHAR(30)                   COMMENT '联系人',
  phone           VARCHAR(20)                   COMMENT '联系电话',
  email           VARCHAR(100)                  COMMENT '邮箱',
  
  -- ===== 地址信息 =====
  province        VARCHAR(30)                   COMMENT '省份',
  city            VARCHAR(30)                   COMMENT '城市',
  district        VARCHAR(30)                   COMMENT '区县',
  address         VARCHAR(500)                  COMMENT '详细地址',
  
  -- ===== 状态字段 =====
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  del_flag        TINYINT(1)      DEFAULT 0     COMMENT '删除标志（0 代表存在 1 代表删除）',
  
  -- ===== 审计字段 =====
  create_by       VARCHAR(30)                   COMMENT '创建者',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by       VARCHAR(30)                   COMMENT '更新者',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark          VARCHAR(500)                  COMMENT '备注',
  
  -- ===== 索引定义 =====
  PRIMARY KEY (id),
  KEY idx_customer_name (customer_name),
  KEY idx_phone (phone),
  KEY idx_status (status)
  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='客户表';

-- ===== 子表：商品表 =====
CREATE TABLE demo_goods (
  -- ===== 主键字段 =====
  id              BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '商品 ID',
  
  -- ===== 外键字段（必须与 subTableFkName 一致）=====
  customer_id     BIGINT          NOT NULL      COMMENT '客户 ID',
  
  -- ===== 基本信息 =====
  goods_name      VARCHAR(100)    NOT NULL      COMMENT '商品名称',
  
  -- ===== 业务字段 =====
  category        VARCHAR(30)                   COMMENT '商品分类',
  price           DECIMAL(10,2)   DEFAULT 0     COMMENT '价格',
  stock           INT             DEFAULT 0     COMMENT '库存',
  description     VARCHAR(500)                  COMMENT '商品描述',
  
  -- ===== 状态字段 =====
  status          CHAR(1)         DEFAULT '0'   COMMENT '状态（0 正常 1 停用）',
  del_flag        TINYINT(1)      DEFAULT 0     COMMENT '删除标志（0 代表存在 1 代表删除）',
  
  -- ===== 审计字段 =====
  create_by       VARCHAR(30)                   COMMENT '创建者',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by       VARCHAR(30)                   COMMENT '更新者',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  -- ===== 索引定义 =====
  PRIMARY KEY (id),
  KEY idx_customer_id (customer_id),  -- 外键索引（重要）
  KEY idx_goods_name (goods_name),
  KEY idx_status (status)
  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='商品表';
```

**YAML 配置示例**：
```yaml
global:
  author: dev
  packageName: com.ruoyi.demo
  moduleName: demo
  autoRemovePre: true
  tablePrefix: demo_
  tplCategory: sub               # 主子表模板
  tplWebType: element-plus
  parentMenuId: 4

tables:
  # 主表配置
  demo_customer:
    className: Customer
    functionName: 客户管理
    functionAuthor: dev
    remark: 客户管理模块，包含客户基本信息和关联商品
    businessName: customer
    
    # 主子表配置（必须）
    subTableName: demo_goods     # 子表表名
    subTableFkName: customer_id  # 子表关联外键字段
    
    columns:
      # 主键
      id:
        isInsert: false
        isEdit: false
        isList: true
        
      # 客户名称 - 必填、可查询
      customer_name:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        isRequired: true
        queryType: LIKE
        
      # 客户类型 - 单选
      customer_type:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        htmlType: radio
        dictType: sys_yes_no
        
      # 状态 - 开关
      status:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        htmlType: switch
        dictType: sys_normal_disable
        
      # 联系电话
      phone:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        queryType: EQ
        
  # 子表配置（不需要特殊配置，但必须在 tables 列表中）
  demo_goods:
    className: Goods
    functionName: 商品管理
    
    columns:
      # 主键
      id:
        isInsert: false
        isEdit: false
        isList: true
        
      # 外键字段 - 自动关联，不需要手动插入
      customer_id:
        isInsert: false
        isEdit: false
        isList: false
        isQuery: false
        
      # 商品名称 - 必填
      goods_name:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        isRequired: true
        queryType: LIKE
        
      # 价格 - 范围查询
      price:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: true
        queryType: BETWEEN
        
      # 库存
      stock:
        isInsert: true
        isEdit: true
        isList: true
        isQuery: false
```

## 8. SQL 编写注意事项

### 8.1 必须遵守的规则

1. **表注释必须填写**
   ```sql
   -- 正确
   CREATE TABLE demo_student (...) COMMENT = '学生信息表';
   
   -- 错误：缺少表注释
   CREATE TABLE demo_student (...);
   ```

2. **列注释必须填写**
   ```sql
   -- 正确
   name VARCHAR(30) NOT NULL COMMENT '学生姓名',
   
   -- 错误：缺少列注释
   name VARCHAR(30) NOT NULL,
   ```

3. **主键必须定义**
   ```sql
   -- 正确
   id BIGINT NOT NULL AUTO_INCREMENT COMMENT '编号',
   PRIMARY KEY (id)
   
   -- 错误：缺少主键
   id BIGINT NOT NULL AUTO_INCREMENT COMMENT '编号',
   ```

### 8.2 推荐遵守的规范

1. **使用标准数据类型**
   ```sql
   -- 推荐
   status CHAR(1) DEFAULT '0' COMMENT '状态',
   age INT(3) DEFAULT 0 COMMENT '年龄',
   price DECIMAL(10,2) DEFAULT 0 COMMENT '价格',
   
   -- 不推荐：使用不常见的类型
   status TINYINT UNSIGNED DEFAULT 0 COMMENT '状态',
   ```

2. **使用有意义的列名**
   ```sql
   -- 推荐：清晰明确
   customer_name VARCHAR(100) COMMENT '客户名称',
   create_time DATETIME COMMENT '创建时间',
   
   -- 不推荐：缩写或拼音
   cust_nm VARCHAR(100) COMMENT '客户名称',
   cj_sj DATETIME COMMENT '创建时间',
   ```

3. **为查询字段添加索引**
   ```sql
   -- 推荐：为常用查询字段添加索引
   KEY idx_status (status),
   KEY idx_create_time (create_time),
   ```

### 8.3 多表批量生成

将多个表的 DDL 放在同一个 SQL 文件中，可以批量生成：

```sql
-- all_tables.sql

-- 用户表
CREATE TABLE sys_user (
  user_id     BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '用户 ID',
  user_name   VARCHAR(30)     NOT NULL      COMMENT '用户账号',
  PRIMARY KEY (user_id)
) COMMENT = '用户信息表';

-- 角色表
CREATE TABLE sys_role (
  role_id     BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '角色 ID',
  role_name   VARCHAR(30)     NOT NULL      COMMENT '角色名称',
  PRIMARY KEY (role_id)
) COMMENT = '角色信息表';

-- 菜单表
CREATE TABLE sys_menu (
  menu_id     BIGINT          NOT NULL      AUTO_INCREMENT COMMENT '菜单 ID',
  menu_name   VARCHAR(50)     NOT NULL      COMMENT '菜单名称',
  PRIMARY KEY (menu_id)
) COMMENT = '菜单信息表';
```

```bash
# 一条命令批量生成
java -jar ruoyi-gen-cli.jar \
  --sql=all_tables.sql \
  --config=gen-config.yml \
  --output=./all.zip
```

## 9. 常见问题

### Q1: 生成的 Java 类型不正确

**问题**：DECIMAL 字段生成了 Double 类型

**解决**：显式指定 Java 类型
```yaml
columns:
  price:
    javaType: BigDecimal  # 强制指定为 BigDecimal
```

### Q2: 日期字段生成错误

**问题**：DATE/DATETIME 字段没有生成日期选择器

**解决**：检查 htmlType 配置
```yaml
columns:
  birthday:
    htmlType: datetime  # 确保配置为 datetime
```

### Q3: 主子表没有关联

**问题**：生成的代码没有主子表关联

**解决**：
1. 确保主表配置了 `subTableName` 和 `subTableFkName`
2. 确保子表在 `tables` 列表中
3. 确保子表有对应的外键字段

### Q4: 树表无法展开

**问题**：树形结构无法正确展示

**解决**：
1. 确保 `tplCategory` 设置为 `tree`
2. 确保配置了 `treeCode`、`treeParentCode`、`treeName`
3. 确保 DDL 中有对应的字段

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: ruoyi-gen-cli 1.0

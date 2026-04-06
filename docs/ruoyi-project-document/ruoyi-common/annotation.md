# Annotation 注解模块

## 概述

`ruoyi-common/annotation` 包提供了 RuoYi 框架的自定义注解，用于简化开发中的常见功能配置。

## 注解列表

### 1. @Anonymous - 匿名访问注解

**作用**: 标记不需要的权限验证的方法或类

**使用场景**: 登录接口、注册接口、公开 API 等

**示例**:
```java
@Anonymous
@PostMapping("/login")
public AjaxResult login(@RequestBody LoginBody loginBody) {
    // 登录逻辑，无需权限验证
}
```

---

### 2. @DataScope - 数据权限注解

**作用**: 实现数据范围权限过滤，根据角色权限自动过滤查询数据

**属性**:
| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| userAlias | String | "" | 用户表别名 |
| deptAlias | String | "" | 部门表别名 |
| userField | String | "user_id" | 用户字段名 |
| deptField | String | "dept_id" | 部门字段名 |
| permission | String | "" | 权限字符 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/DataScope.java`

**使用场景**: 需要根据部门权限过滤数据的查询方法

**示例**:
```java
@DataScope(deptAlias = "d", userAlias = "u")
public List<SysUser> selectUserList(SysUser user) {
    // SQL 会自动添加数据权限过滤条件
}
```

**SQL 示例**:
```sql
-- 自动追加权限过滤 SQL
AND (u.user_id = #{currentUser.userId} OR d.dept_id IN (...) )
```

---

### 3. @DataSource - 多数据源切换注解

**作用**: 切换数据源（主库/从库）

**属性**:
| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| value | DataSourceType | MASTER | 数据源类型 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/DataSource.java`

**数据源类型**:
- `DataSourceType.MASTER` - 主库
- `DataSourceType.SLAVE` - 从库

**优先级**: 方法级 > 类级

**示例**:
```java
// 类级别
@DataSource(DataSourceType.SLAVE)
@Service
public class UserServiceImpl implements UserService {
    // 默认使用从库
    
    // 方法级别覆盖
    @DataSource(DataSourceType.MASTER)
    public void insertUser(SysUser user) {
        // 写入操作使用主库
    }
}
```

---

### 4. @Log - 操作日志注解

**作用**: 记录操作日志到数据库

**属性**:
| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | String | "" | 模块标题 |
| businessType | BusinessType | OTHER | 业务类型 |
| operatorType | OperatorType | MANAGE | 操作人类别 |
| isSaveRequestData | boolean | true | 是否保存请求参数 |
| isSaveResponseData | boolean | true | 是否保存响应参数 |
| excludeParamNames | String[] | {} | 排除的参数名 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Log.java`

**BusinessType 枚举**: 详见 `ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/BusinessType.java`
- `OTHER` - 其他 | `INSERT` - 新增 | `UPDATE` - 修改 | `DELETE` - 删除
- `GRANT` - 授权 | `EXPORT` - 导出 | `IMPORT` - 导入 | `FORCE` - 强退
- `GENCODE` - 生成代码 | `CLEAN` - 清空

**OperatorType 枚举**: 详见 `ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/OperatorType.java`
- `OTHER` - 其他 | `MANAGE` - 后台用户 | `MOBILE` - 手机端用户

**示例**:
```java
@Log(title = "用户管理", businessType = BusinessType.INSERT)
@DataSource(DataSourceType.MASTER)
@PostMapping
public AjaxResult add(@RequestBody SysUser user) {
    return toAjax(userService.insertUser(user));
}
```

---

### 5. @RateLimiter - 限流注解

**作用**: 基于 Redis 的接口限流

**属性**:
| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| key | String | "rate_limit:" | 限流 key |
| time | int | 60 | 限流时间 (秒) |
| count | int | 100 | 限流次数 |
| limitType | LimitType | DEFAULT | 限流类型 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/RateLimiter.java`

**LimitType 枚举**: 详见 `ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/LimitType.java`
- `DEFAULT` - 全局限流 | `IP` - 按 IP 限流

**示例**:
```java
// 60 秒内最多请求 10 次
@RateLimiter(time = 60, count = 10, limitType = LimitType.IP)
@PostMapping("/sendSms")
public AjaxResult sendSms(@RequestParam String phone) {
    // 发送短信逻辑
}
```

---

### 6. @RepeatSubmit - 防重复提交注解

**作用**: 防止表单重复提交

**属性**:
| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| interval | int | 5000 | 间隔时间 (ms) |
| message | String | "不允许重复提交" | 提示信息 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/RepeatSubmit.java`

**原理**: 使用 Redis 缓存请求标识，在指定时间间隔内相同请求会被拦截

**示例**:
```java
@RepeatSubmit(interval = 5000, message = "请勿重复提交")
@DataSource(DataSourceType.MASTER)
@Log(title = "订单管理", businessType = BusinessType.INSERT)
@PostMapping
public AjaxResult add(@RequestBody Order order) {
    return toAjax(orderService.insertOrder(order));
}
```

---

### 7. @Sensitive - 数据脱敏注解

**作用**: 对敏感数据进行脱敏处理后返回

**属性**:
| 属性 | 类型 | 说明 |
|------|------|--------|
| desensitizedType | DesensitizedType | 脱敏类型 |

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Sensitive.java`

**DesensitizedType 枚举**:
| 类型 | 说明 | 脱敏效果 |
|------|------|----------|
| `USERNAME` | 姓名 | 张*三 |
| `PASSWORD` | 密码 | ******** |
| `ID_CARD` | 身份证 | 1101** **** ****1234 |
| `PHONE` | 手机号 | 138****1234 |
| `EMAIL` | 邮箱 | z****@example.com |
| `BANK_CARD` | 银行卡号 | **** **** **** **** 1234 |
| `CAR_LICENSE` | 车牌 | 京 A****8 |
| `ADDRESS` | 地址 | 北京市朝阳区*** |

> 脱敏实现见源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/DesensitizedType.java`

**示例**:
```java
public class UserVO {
    @Sensitive(desensitizedType = DesensitizedType.PHONE)
    private String phone;
    
    @Sensitive(desensitizedType = DesensitizedType.EMAIL)
    private String email;
}
```

---

### 8. @Excel / @Excels - Excel 导入导出注解

**作用**: 控制 Excel 导入导出行为

**@Excel 属性** (完整属性见源码 `ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Excel.java`):
| 属性 | 说明 | 默认值 |
|------|------|--------|
| name | 列名 | "" |
| sort | 排序 | MAX_VALUE |
| dateFormat | 日期格式 | "" |
| dictType | 字典类型 | "" |
| readConverterExp | 读取转换表达式 | "" |
| cellType | 单元格类型 (NUMERIC/STRING/IMAGE/TEXT) | STRING |
| type | 导出导入类型 (ALL/EXPORT/IMPORT) | ALL |
| width/height | 列宽/高度 | 16/14 |
| align | 对齐方式 | CENTER |
| isExport | 是否导出 | true |

其他属性包括：scale、roundingMode、suffix、defaultValue、prompt、wrapText、combo、needMerge、targetAttr、isStatistics、handler、args 等

**Type 枚举**: 详见 `ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Excel.java`
- `ALL(0)` - 导出导入 | `EXPORT(1)` - 仅导出 | `IMPORT(2)` - 仅导入

**ColumnType 枚举**:
- `NUMERIC(0)` - 数字 | `STRING(1)` - 字符串 | `IMAGE(2)` - 图片 | `TEXT(3)` - 文本

**@Excels**: 多个@Excel 注解的集合

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Excels.java`

**示例**:
```java
public class UserExportVO {
    @Excel(name = "用户 ID", cellType = ColumnType.NUMERIC)
    private Long userId;
    
    @Excel(name = "用户名")
    private String userName;
    
    @Excel(name = "性别", readConverterExp = "0=男，1=女，2=未知")
    private String sex;
    
    @Excel(name = "手机号", cellType = ColumnType.TEXT)
    @Sensitive(desensitizedType = DesensitizedType.PHONE)
    private String phonenumber;
    
    @Excel(name = "创建时间", dateFormat = "yyyy-MM-dd HH:mm:ss", width = 30)
    private Date createTime;
}

// 使用 ExcelUtil 导出
ExcelUtil<UserExportVO> util = new ExcelUtil<>(UserExportVO.class);
util.exportExcel(userList, "用户数据");

// 导入
List<UserExportVO> dataList = util.importExcel(inputStream);
```

---

## 最佳实践

1. **权限控制**: 使用 `@Anonymous` 标记公开接口，其余接口默认需要鉴权
2. **数据权限**: 在查询方法上使用 `@DataScope` 实现行级权限控制
3. **日志记录**: 在写操作方法上添加 `@Log` 注解
4. **限流保护**: 对短信发送、登录等接口使用 `@RateLimiter` 限流
5. **防重复提交**: 表单提交操作添加 `@RepeatSubmit` 注解
6. **敏感数据**: 返回值中使用 `@Sensitive` 脱敏
7. **Excel 处理**: 导入导出 DTO 使用 `@Excel` 注解配置

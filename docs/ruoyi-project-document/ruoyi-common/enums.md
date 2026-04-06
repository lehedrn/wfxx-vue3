# Enums 枚举模块

## 概述

`ruoyi-common/enums` 包提供了 RuoYi 框架中使用的各种枚举类型定义，用于统一状态、类型等的管理。

## 枚举列表

### 1. BusinessType - 业务操作类型

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/BusinessType.java`

**用途**: 用于操作日志记录业务操作类型

| 枚举值 | 说明 | 使用场景 |
|--------|------|----------|
| `OTHER` | 其他 | 默认值，未分类的操作 |
| `INSERT` | 新增 | 创建新记录 |
| `UPDATE` | 修改 | 更新现有记录 |
| `DELETE` | 删除 | 删除记录 |
| `GRANT` | 授权 | 分配权限、角色等 |
| `EXPORT` | 导出 | 导出数据到文件 |
| `IMPORT` | 导入 | 从文件导入数据 |
| `FORCE` | 强退 | 强制用户下线 |
| `GENCODE` | 生成代码 | 代码生成器生成代码 |
| `CLEAN` | 清空 | 清空数据 |

**使用示例**:
```java
@Log(title = "用户管理", businessType = BusinessType.INSERT)
@PostMapping
public AjaxResult add(@RequestBody SysUser user) {
    return toAjax(userService.insertUser(user));
}

@Log(title = "用户管理", businessType = BusinessType.UPDATE)
@PutMapping
public AjaxResult edit(@RequestBody SysUser user) {
    return toAjax(userService.updateUser(user));
}

@Log(title = "用户管理", businessType = BusinessType.DELETE)
@DeleteMapping("/{userIds}")
public AjaxResult remove(@PathVariable Long[] userIds) {
    return toAjax(userService.deleteUserByIds(userIds));
}
```

---

### 2. BusinessStatus - 业务操作状态

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/BusinessStatus.java`

| 枚举值 | 说明 |
|--------|------|
| `SUCCESS` | 成功 |
| `FAIL` | 失败 |

---

### 3. OperatorType - 操作人类别

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/OperatorType.java`

| 枚举值 | 说明 |
|--------|------|
| `OTHER` | 其他 |
| `MANAGE` | 后台用户（PC 端管理后台） |
| `MOBILE` | 手机端用户 |

---

### 4. DataSourceType - 数据源类型

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/DataSourceType.java`

| 枚举值 | 说明 |
|--------|------|
| `MASTER` | 主库（用于写操作） |
| `SLAVE` | 从库（用于读操作） |

---

### 5. LimitType - 限流类型

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/LimitType.java`

| 枚举值 | 说明 | 限流维度 |
|--------|------|----------|
| `DEFAULT` | 默认策略全局限流 | 所有用户共享配额 |
| `IP` | 根据请求者 IP 限流 | 每个 IP 独立配额 |

---

### 6. DesensitizedType - 数据脱敏类型

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/DesensitizedType.java`

| 枚举值 | 说明 | 脱敏效果 |
|--------|------|----------|
| `USERNAME` | 姓名 | 张*三 |
| `PASSWORD` | 密码 | ******** |
| `ID_CARD` | 身份证 | 1101** **** ****1234 |
| `PHONE` | 手机号 | 138****1234 |
| `EMAIL` | 邮箱 | z****@example.com |
| `BANK_CARD` | 银行卡号 | **** **** **** **** 1234 |
| `CAR_LICENSE` | 车牌 | 京 A****8 |
| `ADDRESS` | 地址 | 北京市朝阳区*** |

**使用示例**:
```java
public class UserVO {
    
    @Sensitive(desensitizedType = DesensitizedType.USERNAME)
    private String realName;  // 张三 → 张*三
    
    @Sensitive(desensitizedType = DesensitizedType.PHONE)
    private String phone;     // 13812341234 → 138****1234
    
    @Sensitive(desensitizedType = DesensitizedType.EMAIL)
    private String email;     // test@example.com → t****@example.com
    
    @Sensitive(desensitizedType = DesensitizedType.ID_CARD)
    private String idCard;    // 110101199001011234 → 1101** **** ****1234
    
    @Sensitive(desensitizedType = DesensitizedType.BANK_CARD)
    private String bankCard;  // 6222021234567890123 → **** **** **** **** 0123
}
```

---

### 7. UserStatus - 用户状态

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/UserStatus.java`

| 枚举值 | 代码 | 说明 |
|--------|------|------|
| `OK` | "0" | 正常 |
| `DISABLE` | "1" | 停用 |
| `DELETED` | "2" | 删除 |

---

### 8. HttpMethod - HTTP 请求方法

> 源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/HttpMethod.java`

**枚举值**: `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `TRACE`

---

## 最佳实践

1. **日志记录**: 使用 `BusinessType` + `OperatorType` 完整记录操作日志
2. **数据源切换**: 写操作使用 `MASTER`，读操作使用 `SLAVE`
3. **限流策略**: 公开接口使用 `IP` 限流，内部接口使用 `DEFAULT` 限流
4. **敏感数据**: 返回用户数据时使用 `DesensitizedType` 脱敏
5. **状态管理**: 使用 `UserStatus` 统一管理用户状态，避免硬编码
6. **枚举匹配**: 使用 `matches()` 方法进行字符串比较，更安全

## 扩展指南

添加新枚举时遵循以下规范：

1. **命名规范**: 使用有意义的名称，以 Type/Status 结尾
2. **文档注释**: 为枚举值和枚举类添加 JavaDoc
3. **代码规范**: 
   - 简单枚举直接使用枚举值
   - 需要附加信息的枚举添加属性和构造方法
   - 提供 `getCode()` 和 `getInfo()` 方法

> 完整示例见源码：`ruoyi-common/enums/src/main/java/com/ruoyi/common/enums/UserStatus.java`

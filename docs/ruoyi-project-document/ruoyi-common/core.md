# Core 核心模块

## 概述

`ruoyi-common/core` 包提供了 RuoYi 框架的核心基础组件，包括域模型、控制器、分页、响应等核心功能。

## 模块结构

```
core/
├── controller/      # 基础控制器
├── domain/          # 域对象
│   ├── entity/      # 实体类
│   └── model/       # 数据模型
├── page/            # 分页相关
├── redis/           # Redis 缓存
└── text/            # 文本处理
```

---

## 1. 响应对象

### AjaxResult - 操作消息提醒

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/AjaxResult.java`

**用途**: Web 接口响应数据封装，继承自 `HashMap<String, Object>`

**标签**: `code` (状态码), `msg` (消息内容), `data` (数据对象)

**静态方法**:
| 方法 | 说明 |
|------|------|
| `success()` / `success(String msg)` | 返回成功 |
| `success(Object data)` / `success(String msg, Object data)` | 返回成功和数据 |
| `warn(String msg)` / `warn(String msg, Object data)` | 返回警告 |
| `error()` / `error(String msg)` | 返回错误 |
| `error(String msg, Object data)` / `error(int code, String msg)` | 返回错误和数据/错误码 |
| `isSuccess()` / `isWarn()` / `isError()` | 判断类型 |
| `put(String key, Object value)` | 链式调用 |

**响应格式**:
```json
// 成功响应
{ "code": 200, "msg": "操作成功", "data": { ... } }

// 错误响应
{ "code": 500, "msg": "操作失败" }

// 警告响应
{ "code": 601, "msg": "警告信息", "data": { ... } }
```

---

### R<T> - 通用响应体

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/R.java`

**用途**: 更通用的响应数据封装，支持泛型

**属性**: `code` (状态码), `msg` (消息), `data` (数据)

**静态方法**:
| 方法 | 说明 |
|------|------|
| `ok()` / `ok(T data)` / `ok(T data, String msg)` | 成功响应 |
| `fail()` / `fail(String msg)` / `fail(T data)` | 失败响应 |
| `fail(T data, String msg)` / `fail(int code, String msg)` | 失败响应带详细信息 |
| `isSuccess(R<T> ret)` / `isError(R<T> ret)` | 判断结果 |

**使用示例**:
```java
// 返回成功
R<SysUser> ok = R.ok(user);

// 返回错误
R<Void> fail = R.fail("操作失败");

// 判断结果
if (R.isSuccess(result)) {
    // 处理成功逻辑
}
```

---

## 2. 实体类

### BaseEntity - 实体基类

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/BaseEntity.java`

**用途**: 所有实体类的基类，提供通用字段

**属性**: `searchValue`, `createBy`, `createTime`, `updateBy`, `updateTime`, `remark`, `params`

**JSON 注解**:
- `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")` - 时间格式化
- `@JsonIgnore` - 忽略字段序列化 (searchValue)

---

### TreeEntity - 树型实体基类

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/TreeEntity.java`

**用途**: 树型结构实体的基类，继承自 BaseEntity

**属性**: `parentName`, `parentId`, `orderNum`, `ancestors`, `children`

---

### TreeSelect - 树选择实体

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/TreeSelect.java`

**用途**: 前端树形选择组件的数据封装

**属性**: `id`, `label`, `children`

---

### 系统实体类

> 所有实体类位于 `ruoyi-admin/src/main/java/com/ruoyi/common/core/domain/entity/`

| 实体类 | 说明 | 核心属性 |
|--------|------|----------|
| `SysUser` | 用户实体 | userId, deptId, userName, nickName, email, phonenumber, sex, avatar, password, status, roles, dept |
| `SysRole` | 角色实体 | roleId, roleName, roleKey, roleSort, dataScope, status, menuIds, deptIds, permissions |
| `SysMenu` | 菜单实体 | menuId, menuName, parentId, path, component, menuType, visible, status, perms, icon |
| `SysDept` | 部门实体 | deptId, parentId, ancestors, deptName, orderNum, leader, phone, email, status |
| `SysDictData` | 字典数据 | dictCode, dictSort, dictLabel, dictValue, dictType, cssClass, listClass, isDefault |
| `SysDictType` | 字典类型 | dictId, dictName, dictType, status |

**SysUser 校验注解**:
- `@Xss` + `@Size(min=0, max=30)` - 用户昵称
- `@Xss` + `@NotBlank` + `@Size(min=0, max=30)` - 用户账号
- `@Email` + `@Size(min=0, max=50)` - 邮箱

**方法**:
- `SysUser.isAdmin()` - 是否为管理员
- `SysRole.isAdmin()` / `isAdmin(Long roleId)` - 角色是否为管理员

---

## 3. 分页相关

### PageDomain - 分页域

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/page/PageDomain.java`

**用途**: 封装分页和排序参数

**属性**: `pageNum` (页码), `pageSize` (每页条数), `orderByColumn` (排序字段), `isAsc` (排序方式), `reasonable` (是否查询总数)

**方法**: `getOrderBy()` - 获取完整排序 SQL

---

### TableSupport - 分页工具

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/page/TableSupport.java`

**方法**: `buildPageRequest()` - 构建分页请求

---

### TableDataInfo - 表格分页响应

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/page/TableDataInfo.java`

**用途**: 表格分页数据响应封装

**属性**: `total` (总记录数), `rows` (列表数据), `code` (状态码), `msg` (消息内容)

---

## 4. 基础控制器

### BaseController - Web 层通用数据处理

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/controller/BaseController.java`

**用途**: 所有 Controller 的基类

**核心方法**:

| 类型 | 方法 |
|------|------|
| 分页 | `startPage()`, `startOrderBy()`, `clearPage()`, `getDataTable(List<?> list)` |
| 响应 | `success()`, `success(String)`, `success(Object)`, `error()`, `error(String)`, `warn(String)`, `toAjax(int/boolean)`, `redirect(String)` |
| 用户信息 | `getLoginUser()`, `getUserId()`, `getDeptId()`, `getUsername()` |

**使用示例**:
```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    @Autowired
    private SysUserService userService;
    
    @GetMapping("/list")
    public TableDataInfo list(SysUser user) {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }
    
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        return toAjax(userService.insertUser(user));
    }
}
```

---

## 5. 数据模型

### LoginUser - 登录用户信息

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/model/LoginUser.java`

**属性**: `user` (用户对象), `permissions` (权限列表)

### LoginBody - 登录请求体

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/model/LoginBody.java`

**属性**: `username`, `password`, `code` (验证码), `uuid` (验证码 ID)

### RegisterBody - 注册请求体

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/domain/model/RegisterBody.java`

**属性**: `username`, `password`, `code` (验证码), `uuid` (验证码 ID)

---

## 6. Redis 缓存

### RedisCache - Redis 缓存操作工具

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/redis/RedisCache.java`

**用途**: 封装 Redis 模板的常用操作

**核心方法**:

| 类型 | 方法 |
|------|------|
| 基本对象 | `setCacheObject(key, value)`, `setCacheObject(key, value, timeout, unit)`, `getCacheObject(key)`, `deleteObject(key)`, `hasKey(key)`, `expire(key, timeout)`, `getExpire(key)` |
| List | `setCacheList(key, dataList)`, `getCacheList(key)`, `appendList(key, dataList)` |
| Set | `setCacheSet(key, dataSet)`, `getCacheSet(key)` |
| Map | `setCacheMap(key, dataMap)`, `getCacheMap(key)`, `setCacheMapValue(key, hKey, value)`, `getCacheMapValue(key, hKey)`, `getMultiCacheMapValue(key, hKeys)`, `deleteCacheMapValue(key, hKey)` |
| 自增自减 | `increment(key)`, `decrement(key)` |
| Key 操作 | `keys(pattern)` |

**使用示例**:
```java
@Autowired
private RedisCache redisCache;

// 存储登录 Token
redisCache.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, 30, TimeUnit.MINUTES);

// 获取/删除缓存
LoginUser user = redisCache.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token);
redisCache.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);

// Hash 操作
redisCache.setCacheMapValue("user:1", "name", "张三");
String name = redisCache.getCacheMapValue("user:1", "name");

// 自增操作
redisCache.increment("page:view:count");
```

---

## 7. 文本处理

### Convert - 类型转换工具

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/text/Convert.java`

**核心方法**:
| 方法 | 说明 |
|------|------|
| `toStr(obj)` / `toStr(obj, defaultStr)` | 转换为字符串 |
| `toInt(obj)` / `toInt(obj, defaultInt)` | 转换为整数 |
| `toLong(obj)` / `toLong(obj, defaultLong)` | 转换为长整型 |
| `toBool(obj)` | 转换为布尔 |

---

### StrFormatter - 字符串格式化

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/text/StrFormatter.java`

**方法**: `format(String template, Object... params)`

**示例**: `StrFormatter.format("Hello, {}", "World")` → `"Hello, World"`

---

### CharsetKit - 字符集工具

> 源码：`ruoyi-common/core/src/main/java/com/ruoyi/common/core/text/CharsetKit.java`

**方法**: `convert(source, srcCharset, destCharset)`, `charset(charset)`

---

## 最佳实践

1. **统一响应格式**: 所有接口使用 `AjaxResult` 或 `R<T>` 封装响应
2. **继承 BaseController**: 所有 Controller 继承 BaseController 获取通用方法
3. **实体继承 BaseEntity**: 所有实体继承 BaseEntity 获取审计字段
4. **分页使用**: 使用 `startPage()` + `getDataTable()` 快速实现分页
5. **缓存操作**: 使用 `RedisCache` 封装 Redis 操作，避免直接使用 RedisTemplate
6. **参数校验**: 实体类使用 JSR-303 注解进行参数校验
7. **XSS 防护**: 用户输入字段使用 `@Xss` 注解防护

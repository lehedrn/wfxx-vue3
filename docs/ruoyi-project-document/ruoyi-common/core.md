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

**用途**: Web 接口响应数据封装

**结构**:
```java
public class AjaxResult extends HashMap<String, Object> {
    private static final String CODE_TAG = "code";    // 状态码
    private static final String MSG_TAG = "msg";      // 消息内容
    private static final String DATA_TAG = "data";    // 数据对象
}
```

**静态方法**:
```java
// 成功响应
AjaxResult success()                              // 返回成功
AjaxResult success(String msg)                    // 返回成功消息
AjaxResult success(Object data)                   // 返回成功和数据
AjaxResult success(String msg, Object data)       // 返回成功消息和数据

// 警告响应
AjaxResult warn(String msg)                       // 返回警告消息
AjaxResult warn(String msg, Object data)          // 返回警告消息和数据

// 错误响应
AjaxResult error()                                // 返回错误
AjaxResult error(String msg)                      // 返回错误消息
AjaxResult error(String msg, Object data)         // 返回错误消息和数据
AjaxResult error(int code, String msg)            // 返回错误码和消息


// 判断方法
boolean isSuccess()                               // 是否成功
boolean isWarn()                                  // 是否警告
boolean isError()                                 // 是否错误

// 链式调用
AjaxResult put(String key, Object value)     // 方便链式调用
```

**使用示例**:
```java
@RestController
public class UserController {
    
    @GetMapping("/user/{userId}")
    public AjaxResult getUser(@PathVariable Long userId) {
        SysUser user = userService.selectUserById(userId);
        return AjaxResult.success(user);
    }
    
    @PostMapping("/user")
    public AjaxResult addUser(@RequestBody SysUser user) {
        int rows = userService.insertUser(user);
        return rows > 0 ? AjaxResult.success() : AjaxResult.error();
    }
    
    @PutMapping("/user")
    public AjaxResult updateUser(@RequestBody SysUser user) {
        try {
            int rows = userService.updateUser(user);
            return rows > 0 ? AjaxResult.success() : AjaxResult.error("修改失败");
        } catch (Exception e) {
            return AjaxResult.error(e.getMessage());
        }
    }
}
```

**响应格式**:
```json
// 成功响应
{
    "code": 200,
    "msg": "操作成功",
    "data": { ... }
}

// 错误响应
{
    "code": 500,
    "msg": "操作失败"
}

// 警告响应
{
    "code": 601,
    "msg": "警告信息",
    "data": { ... }
}
```

---

### R<T> - 通用响应体

**用途**: 更通用的响应数据封装，支持泛型

**结构**:
```java
public class R<T> implements Serializable {
    private int code;      // 状态码
    private String msg;    // 消息
    private T data;        // 数据
}
```

**静态方法**:
```java
// 成功响应
R<T> ok()                              // 返回成功
R<T> ok(T data)                        // 返回成功和数据
R<T> ok(T data, String msg)            // 返回成功消息和数据

// 失败响应
R<T> fail()                            // 返回失败
R<T> fail(String msg)                  // 返回失败消息
R<T> fail(T data)                      // 返回失败和数据
R<T> fail(T data, String msg)          // 返回失败消息和数据
R<T> fail(int code, String msg)        // 返回失败码和消息

// 判断方法
Boolean isSuccess(R<T> ret)            // 是否成功
Boolean isError(R<T> ret)              // 是否错误
```

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

**用途**: 所有实体类的基类，提供通用字段

**属性**:
```java
String searchValue;           // 搜索值（@JsonIgnore）
String createBy;              // 创建者
Date createTime;              // 创建时间
String updateBy;              // 更新者
Date updateTime;              // 更新时间
String remark;                // 备注
Map<String, Object> params;   // 请求参数
```

**JSON 注解**:
- `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")` - 时间格式化
- `@JsonIgnore` - 忽略字段序列化
- `@JsonInclude(JsonInclude.Include.NON_EMPTY)` - 空值不序列化

**使用示例**:
```java
public class SysUser extends BaseEntity {
    private Long userId;
    private String userName;
    // ... 其他字段
}
```

---

### TreeEntity - 树型实体基类

**用途**: 树型结构实体的基类，继承自 BaseEntity

**属性**:
```java
String parentName;     // 父菜单名称
Long parentId;         // 父菜单 ID
Integer orderNum;      // 显示顺序
String ancestors;      // 祖级列表
List<TreeEntity> children; // 子节点
```

**使用示例**:
```java
public class SysDept extends TreeEntity {
    // 部门实体，支持树型结构
}
```

---

### TreeSelect - 树选择实体

**用途**: 前端树形选择组件的数据封装

**属性**:
```java
Long id;             // 节点 ID
String label;        // 节点名称
List<TreeSelect> children; // 子节点
```

**使用示例**:
```java
// 构建树形选择器数据
TreeSelect treeSelect = new TreeSelect(dept);
```

---

### SysUser - 用户实体

**用途**: 系统用户信息

**核心属性**:
```java
Long userId;           // 用户 ID
Long deptId;           // 部门 ID
String userName;       // 用户账号
String nickName;       // 用户昵称
String email;          // 用户邮箱
String phonenumber;    // 手机号码
String sex;            // 性别
String avatar;         // 头像
String password;       // 密码（@JsonProperty WRITE_ONLY）
String status;         // 账号状态（0 正常 1 停用）
String delFlag;        // 删除标志
String loginIp;        // 最后登录 IP
Date loginDate;        // 最后登录时间
Date pwdUpdateDate;    // 密码最后更新时间
SysDept dept;          // 部门对象
List<SysRole> roles;   // 角色列表
Long[] roleIds;        // 角色组
Long[] postIds;        // 岗位组
```

**校验注解**:
```java
@Xss(message = "用户昵称不能包含脚本字符")
@Size(min = 0, max = 30, message = "用户昵称长度不能超过 30 个字符")
public String getNickName()

@Xss(message = "用户账号不能包含脚本字符")
@NotBlank(message = "用户账号不能为空")
@Size(min = 0, max = 30, message = "用户账号长度不能超过 30 个字符")
public String getUserName()

@Email(message = "邮箱格式不正确")
@Size(min = 0, max = 50, message = "邮箱长度不能超过 50 个字符")
public String getEmail()
```

**方法**:
```java
boolean isAdmin()  // 是否为管理员
```

---

### SysRole - 角色实体

**用途**: 系统角色信息

**核心属性**:
```java
Long roleId;              // 角色 ID
String roleName;          // 角色名称
String roleKey;           // 角色权限字符串
Integer roleSort;         // 角色排序
String dataScope;         // 数据范围
boolean menuCheckStrictly; // 菜单树选择项是否关联显示
boolean deptCheckStrictly; // 部门树选择项是否关联显示
String status;            // 角色状态
String delFlag;           // 删除标志
boolean flag;             // 用户是否存在此角色标识
Long[] menuIds;           // 菜单组
Long[] deptIds;           // 部门组（数据权限）
Set<String> permissions;  // 角色菜单权限
```

**方法**:
```java
boolean isAdmin()           // 是否为管理员
static boolean isAdmin(Long roleId)  // 静态方法判断
```

---

### SysMenu - 菜单实体

**用途**: 系统菜单权限信息

**核心属性**:
```java
Long menuId;          // 菜单 ID
String menuName;      // 菜单名称
String parentName;    // 父菜单名称
Long parentId;        // 父菜单 ID
Integer orderNum;     // 显示顺序
String path;          // 路由地址
String component;     // 组件路径
String query;         // 路由参数
String routeName;     // 路由名称
String isFrame;       // 是否为外链
String isCache;       // 是否缓存
String menuType;      // 类型（M 目录 C 菜单 F 按钮）
String visible;       // 显示状态
String status;        // 菜单状态
String perms;         // 权限字符串
String icon;          // 菜单图标
List<SysMenu> children; // 子菜单
```

---

### SysDept - 部门实体

**用途**: 系统部门信息

**核心属性**:
```java
Long deptId;           // 部门 ID
Long parentId;         // 父部门 ID
String ancestors;      // 祖级列表
String deptName;       // 部门名称
Integer orderNum;      // 显示顺序
String leader;         // 负责人
String phone;          // 联系电话
String email;          // 邮箱
String status;         // 部门状态
Long delFlag;          // 删除标志
String parentName;     // 父部门名称
List<SysDept> children; // 子部门
```

---

### SysDictData - 字典数据实体

**用途**: 字典键值对数据

**核心属性**:
```java
Long dictCode;         // 字典编码
String dictSort;       // 字典排序
String dictLabel;      // 字典标签
String dictValue;      // 字典键值
String dictType;       // 字典类型
String cssClass;       // 样式属性
String listClass;      // 表格回显样式
String isDefault;      // 是否默认
String status;         // 状态
```

---

### SysDictType - 字典类型实体

**用途**: 字典类型定义

**核心属性**:
```java
Long dictId;           // 字典主键
String dictName;       // 字典名称
String dictType;       // 字典类型
String status;         // 状态
```

---

## 3. 分页相关

### PageDomain - 分页域

**用途**: 封装分页和排序参数

**属性**:
```java
Integer pageNum;      // 页码
Integer pageSize;     // 每页条数
String orderByColumn; // 排序字段
String isAsc;         // 排序方式（asc/desc）
Boolean reasonable;   // 是否查询总数（分页参数合理化，默认 true）
```

**方法**:
```java
public String getOrderBy()  // 获取完整排序 SQL
```

---

### TableSupport - 分页工具

**用途**: 构建分页请求

**方法**:
```java
PageDomain buildPageRequest()  // 构建分页请求
```

**使用示例**:
```java
// 前端传递参数
// ?pageNum=1&pageSize=10&orderByColumn=create_time&isAsc=desc

PageDomain pageDomain = TableSupport.buildPageRequest();
// orderByColumn = "create_time", isAsc = "desc"
```

---

### TableDataInfo - 表格分页响应

**用途**: 表格分页数据响应封装

**属性**:
```java
long total;          // 总记录数
List<?> rows;        // 列表数据
int code;            // 状态码
String msg;          // 消息内容
```

**构造方法**:
```java
TableDataInfo()                       // 空构造
TableDataInfo(List<?> list, long total)  // 带数据构造
```

---

## 4. 基础控制器

### BaseController - Web 层通用数据处理

**用途**: 所有 Controller 的基类

**核心方法**:

**分页相关**:
```java
void startPage()           // 设置请求分页数据
void startOrderBy()        // 设置请求排序数据
void clearPage()           // 清理分页线程变量
TableDataInfo getDataTable(List<?> list)  // 响应分页数据
```

**响应相关**:
```java
AjaxResult success()                    // 返回成功
AjaxResult success(String message)      // 返回成功消息
AjaxResult success(Object data)         // 返回成功和数据
AjaxResult error()                      // 返回失败
AjaxResult error(String message)        // 返回失败消息
AjaxResult warn(String message)         // 返回警告消息
AjaxResult toAjax(int rows)             // 根据行数返回
AjaxResult toAjax(boolean result)       // 根据布尔值返回
String redirect(String url)             // 页面跳转
```

**用户信息获取**:
```java
LoginUser getLoginUser()    // 获取登录用户
Long getUserId()            // 获取用户 ID
Long getDeptId()            // 获取部门 ID
String getUsername()        // 获取用户名
```

**使用示例**:
```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    
    @Autowired
    private SysUserService userService;
    
    @GetMapping("/list")
    public TableDataInfo list(SysUser user) {
        startPage();  // 开启分页
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);  // 返回分页数据
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

**用途**: 封装登录用户的完整信息

**属性**:
```java
SysUser user;             // 用户对象
Set<String> permissions;  // 权限列表
```

**方法**:
```java
Long getUserId()          // 获取用户 ID
Long getDeptId()          // 获取部门 ID
String getUsername()      // 获取用户名
```

---

### LoginBody - 登录请求体

**用途**: 封装登录请求参数

**属性**:
```java
String username;     // 用户名
String password;     // 密码
String code;         // 验证码
String uuid;         // 验证码 ID
```

---

### RegisterBody - 注册请求体

**用途**: 封装注册请求参数

**属性**:
```java
String username;     // 用户名
String password;     // 密码
String code;         // 验证码
String uuid;         // 验证码 ID
```

---

## 6. Redis 缓存

### RedisCache - Redis 缓存操作工具

**用途**: 封装 Redis 模板的常用操作

**核心方法**:

**基本对象缓存**:
```java
<T> void setCacheObject(String key, T value)
<T> void setCacheObject(String key, T value, int timeout, TimeUnit unit)
<T> T getCacheObject(String key)
boolean deleteObject(String key)
boolean hasKey(String key)
boolean expire(String key, long timeout)
long getExpire(String key)
```

**List 缓存**:
```java
<T> long setCacheList(String key, List<T> dataList)
<T> List<T> getCacheList(String key)
<T> void appendList(String key, List<T> dataList)
```

**Set 缓存**:
```java
<T> BoundSetOperations<String, T> setCacheSet(String key, Set<T> dataSet)
<T> Set<T> getCacheSet(String key)
```

**Map 缓存**:
```java
<T> void setCacheMap(String key, Map<String, T> dataMap)
<T> Map<String, T> getCacheMap(String key)
<T> void setCacheMapValue(String key, String hKey, T value)
<T> T getCacheMapValue(String key, String hKey)
<T> List<T> getMultiCacheMapValue(String key, Collection<Object> hKeys)
boolean deleteCacheMapValue(String key, String hKey)
```

**自增自减**:
```java
void increment(String key)
void decrement(String key)
```

**Key 操作**:
```java
Collection<String> keys(String pattern)  // 获取匹配 pattern 的 key 集合
```

**使用示例**:
```java
@Autowired
private RedisCache redisCache;

// 存储登录 Token
redisCache.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, 30, TimeUnit.MINUTES);

// 获取登录信息
LoginUser user = redisCache.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token);

// 删除缓存
redisCache.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);

// List 操作
redisCache.setCacheList("user:1:orders", orderList);
List<Order> orders = redisCache.getCacheList("user:1:orders");

// Hash 操作
redisCache.setCacheMapValue("user:1", "name", "张三");
String name = redisCache.getCacheMapValue("user:1", "name");

// 自增操作
redisCache.increment("page:view:count");

// Key 匹配
Collection<String> keys = redisCache.keys("user:*");
```

---

## 7. 文本处理

### Convert - 类型转换工具

**核心方法**:
```java
// 转换为字符串
String toStr(Object obj)
String toStr(Object obj, String defaultStr)

// 转换为数字
Integer toInt(Object obj)
Integer toInt(Object obj, Integer defaultInt)
Long toLong(Object obj)
Long toLong(Object obj, Long defaultLong)

// 转换为布尔
Boolean toBool(Object obj)
```

---

### StrFormatter - 字符串格式化

**用途**: 格式化带占位符的字符串

**方法**:
```java
String format(String template, Object... params)
```

**示例**:
```java
// 基本用法
String result = StrFormatter.format("Hello, {}", "World");
// 结果：Hello, World

// 多个参数
String result = StrFormatter.format("{} 访问 {} 于 {}", "User", "/api", "2024-01-01");
```

---

### CharsetKit - 字符集工具

**方法**:
```java
String convert(String source, String srcCharset, String destCharset)  // 字符集转换
Charset charset(String charset)                                        // 获取字符集
```

---

## 最佳实践

1. **统一响应格式**: 所有接口使用 `AjaxResult` 或 `R<T>` 封装响应
2. **继承 BaseController**: 所有 Controller 继承 BaseController 获取通用方法
3. **实体继承 BaseEntity**: 所有实体继承 BaseEntity 获取审计字段
4. **分页使用**: 使用 `startPage()` + `getDataTable()` 快速实现分页
5. **缓存操作**: 使用 `RedisCache` 封装 Redis 操作，避免直接使用 RedisTemplate
6. **参数校验**: 实体类使用 JSR-303 注解进行参数校验
7. **XSS 防护**: 用户输入字段使用 `@Xss` 注解防护

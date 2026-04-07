# 后端编码规范

本文档基于 RuoYi-Vue 3.9.2 项目的实际编码风格制定，适用于 Java 后端开发。

---

## 1. 项目结构规范

### 1.1 模块划分

```
ruoyi-admin/          # Web 服务入口
ruoyi-common/         # 通用工具模块
ruoyi-framework/      # 核心框架模块
ruoyi-system/         # 系统管理模块
ruoyi-quartz/         # 定时任务模块
ruoyi-generator/      # 代码生成器模块
ruoyi-demo/           # 示例模块
```

### 1.2 包结构

```
com.ruoyi/
├── web/
│   ├── controller/
│   │   ├── common/      # 公共控制器
│   │   ├── system/      # 系统管理控制器
│   │   ├── monitor/     # 监控控制器
│   │   └── tool/        # 工具控制器
│   └── core/
│       └── config/      # 配置类
└── RuoYiApplication.java
```

---

## 2. 命名规范

### 2.1 类命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 实体类 | 实体含义 + 大写后缀 | `SysUser`, `SysRole` |
| Controller | 功能 + Controller | `SysUserController` |
| Service 接口 | I + 功能 + Service | `ISysUserService` |
| Service 实现 | 功能 + ServiceImpl | `SysUserServiceImpl` |
| Mapper 接口 | 功能 + Mapper | `SysUserMapper` |

```java
// 正确 - 符合项目规范
public class SysUserController extends BaseController { }
public interface ISysUserService { }
public class SysUserServiceImpl implements ISysUserService { }

// 错误 - 不符合项目规范
public class UserController { }
public interface UserService { }
```

### 2.2 方法命名

| 操作 | 命名前缀 | 示例 |
|------|---------|------|
| 查询单个 | `select` / `get` | `selectUserById`, `getUser` |
| 查询列表 | `select` + 名词 + `List` | `selectUserList` |
| 新增 | `insert` / `add` | `insertUser`, `addUser` |
| 修改 | `update` / `edit` | `updateUser`, `editUser` |
| 删除 | `delete` / `remove` | `deleteUserByIds`, `removeUser` |
| 分页查询 | 查询方法 + `startPage()` | `startPage(); selectList()` |

```java
// Controller 层方法
@GetMapping("/list")
public TableDataInfo list(SysUser user) {
    startPage();
    List<SysUser> list = userService.selectUserList(user);
    return getDataTable(list);
}

// Service 层方法
public List<SysUser> selectUserList(SysUser user);
```

### 2.3 常量命名

使用大写字母 + 下划线，定义在常量类中：

```java
public class HttpStatus {
    /**
     * 成功状态码
     */
    public static final int SUCCESS = 200;
    
    /**
     * 错误状态码
     */
    public static final int ERROR = 500;
}
```

---

## 3. 代码格式规范

### 3.1 类结构顺序

```java
package com.ruoyi.web.controller.system;

// 1. import 语句
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import com.ruoyi.common.core.controller.BaseController;

/**
 * 2. 类注释（说明类的功能）
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController
{
    // 3. 成员变量（Autowired 的 Service）
    @Autowired
    private ISysUserService userService;
    
    @Autowired
    private ISysRoleService roleService;
    
    // 4. 方法定义
    /**
     * 5. 方法注释
     */
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        // 方法实现
    }
}
```

### 3.2 括号与换行

```java
// 左括号不换行
public class SysUserController extends BaseController
{
    public TableDataInfo list(SysUser user)
    {
        if (condition)
        {
            // 代码块
        }
    }
}

// 操作符前后加空格
private int count = 0;
if (user.getStatus().equals("0"))
```

### 3.3 空行规范

```java
public class SysUserController
{
    @Autowired
    private ISysUserService userService;
    
    // 成员变量后空一行
    
    /**
     * 获取用户列表
     */
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        startPage();
        
        // 逻辑段落之间空一行
        List<SysUser> list = userService.selectUserList(user);
        
        return getDataTable(list);
    }
    
    // 方法之间空一行
    
    /**
     * 新增用户
     */
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user)
    {
    }
}
```

---

## 4. 注解使用规范

### 4.1 核心注解

| 注解 | 用途 | 示例 |
|------|------|------|
| `@RestController` | 标记 REST 控制器 | `@RestController` |
| `@RequestMapping` | 定义请求路径 | `@RequestMapping("/system/user")` |
| `@Autowired` | 自动注入依赖 | `@Autowired private ISysUserService userService;` |
| `@PreAuthorize` | 权限控制 | `@PreAuthorize("@ss.hasPermi('system:user:list')")` |
| `@Log` | 操作日志记录 | `@Log(title = "用户管理", businessType = BusinessType.ADD)` |
| `@Validated` | 参数校验 | `@Validated @RequestBody SysUser user` |

### 4.2 请求映射注解

```java
// 查询 - @GetMapping
@GetMapping("/list")
@GetMapping("/{userId}")

// 新增 - @PostMapping
@PostMapping

// 修改 - @PutMapping
@PutMapping

// 删除 - @DeleteMapping
@DeleteMapping("/{userIds}")

// 导出 - @PostMapping
@PostMapping("/export")
```

### 4.3 业务注解

```java
/**
 * 操作日志注解
 */
@Log(title = "用户管理", businessType = BusinessType.ADD)
@PostMapping
public AjaxResult add(@Validated @RequestBody SysUser user)
{
    return toAjax(userService.insertUser(user));
}
```

---

## 5. 响应封装规范

### 5.1 统一响应类型

| 方法 | 返回类型 | 用途 |
|------|---------|------|
| 查询列表 | `TableDataInfo` | 分页列表数据 |
| 查询单个 | `AjaxResult` | 单个对象数据 |
| 新增/修改/删除 | `AjaxResult` | 操作结果 |
| 导出 | `void` | 直接写入响应流 |

### 5.2 响应方法

```java
// Controller 继承 BaseController，可直接使用以下方法：

// 返回 TableDataInfo（分页列表）
startPage();
List<SysUser> list = userService.selectUserList(user);
return getDataTable(list);

// 返回 AjaxResult（操作结果）
return toAjax(userService.insertUser(user));

// 成功
return AjaxResult.success("操作成功");

// 失败
return AjaxResult.error("操作失败");
```

---

## 6. 分层规范

### 6.1 Controller 层

**职责**：参数接收、参数校验、响应封装

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController
{
    @Autowired
    private ISysUserService userService;
    
    /**
     * 获取用户列表
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        startPage();  // BaseController 提供的分页方法
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);  // BaseController 提供的响应方法
    }
    
    /**
     * 新增用户
     */
    @PreAuthorize("@ss.hasPermi('system:user:add')")
    @Log(title = "用户管理", businessType = BusinessType.ADD)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user)
    {
        // 参数校验由@Validated 完成
        return toAjax(userService.insertUser(user));
    }
}
```

### 6.2 Service 层

**职责**：业务逻辑、事务控制

```java
@Service
public class SysUserServiceImpl implements ISysUserService
{
    @Autowired
    private SysUserMapper userMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertUser(SysUser user)
    {
        // 业务逻辑处理
        user.setCreateBy(SecurityUtils.getUsername());
        user.setCreateTime(DateUtils.getNowDate());
        
        return userMapper.insertUser(user);
    }
}
```

### 6.3 Mapper 层

**职责**：数据访问

```java
/**
 * 用户 数据层
 */
public interface SysUserMapper
{
    /**
     * 根据 ID 查询用户
     */
    SysUser selectUserById(Long userId);
    
    /**
     * 查询用户列表
     */
    List<SysUser> selectUserList(SysUser user);
    
    /**
     * 新增用户
     */
    int insertUser(SysUser user);
}
```

---

## 7. 数据库规范

### 7.1 表命名

| 模块 | 前缀 | 示例 |
|------|------|------|
| 系统模块 | `sys_` | `sys_user`, `sys_role` |
| 示例模块 | `demo_` | `demo_student`, `demo_product` |

### 7.2 字段规范

```sql
-- 主键
user_id BIGINT NOT NULL PRIMARY KEY COMMENT '用户 ID'

-- 通用字段
create_by VARCHAR(64) DEFAULT '' COMMENT '创建者'
create_time DATETIME COMMENT '创建时间'
update_by VARCHAR(64) DEFAULT '' COMMENT '更新者'
update_time DATETIME COMMENT '更新时间'
remark VARCHAR(500) DEFAULT NULL COMMENT '备注'
del_flag CHAR(1) DEFAULT '0' COMMENT '删除标志'
```

### 7.3 Mapper XML 规范

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.ruoyi.system.mapper.SysUserMapper">
    
    <resultMap type="SysUser" id="SysUserResult">
        <id property="userId" column="user_id" />
        <result property="userName" column="user_name" />
        <result property="nickName" column="nick_name" />
    </resultMap>
    
    <select id="selectUserList" parameterType="SysUser" resultMap="SysUserResult">
        select u.user_id, u.user_name, u.nick_name
        from sys_user u
        where u.del_flag = '0'
        <if test="userName != null and userName != ''">
            AND u.user_name like concat('%', #{userName}, '%')
        </if>
    </select>
</mapper>
```

---

## 8. 日志规范

### 8.1 日志对象定义

```java
private static final Logger log = LoggerFactory.getLogger(SysUserController.class);
```

### 8.2 日志使用

```java
// 信息日志
log.info("用户登录成功：{}", userName);

// 错误日志
log.error("用户登录失败", exception);

// 调试日志
log.debug("查询参数：{}", JSON.toJSONString(queryParam));
```

---

## 9. 异常处理规范

### 9.1 业务异常

```java
// 使用 ServiceException 抛出业务异常
if (user == null)
{
    throw new ServiceException("用户不存在");
}

if (!checkPassword(user, password))
{
    throw new ServiceException("密码错误");
}
```

### 9.2 异常处理

```java
try
{
    // 业务逻辑
}
catch (Exception e)
{
    log.error("操作失败", e);
    throw new ServiceException("操作失败");
}
```

---

## 10. 工具类使用规范

### 10.1 常用工具类

| 工具类 | 用途 | 示例 |
|--------|------|------|
| `StringUtils` | 字符串处理 | `StringUtils.isEmpty(str)` |
| `DateUtils` | 日期处理 | `DateUtils.getNowDate()` |
| `SecurityUtils` | 安全工具 | `SecurityUtils.getUsername()` |
| `JsonUtils` | JSON 处理 | `JsonUtils.toJsonString(obj)` |
| `ExcelUtil` | Excel 处理 | `util.exportExcel(response, list, "数据")` |

### 10.2 使用示例

```java
// 字符串判断
if (StringUtils.isNotEmpty(userName))
{
    // 处理逻辑
}

// 获取当前登录用户
String username = SecurityUtils.getUsername();

// 获取当前时间
Date createTime = DateUtils.getNowDate();
```

---

## 11. 代码生成规范

使用 `scripts/gen-code.sh` 生成基础代码后：

1. **检查生成的代码**：确认字段映射正确
2. **添加业务逻辑**：在 Service 层补充业务规则
3. **完善注释**：补充类注释和方法注释
4. **代码格式化**：确保符合本规范

---

## 参考资料

### 项目文档

| 文档 | 说明 |
|------|------|
| [ruoyi-admin](../../ruoyi-project-document/ruoyi-admin.md) | Web 服务入口模块 |
| [ruoyi-common](../../ruoyi-project-document/ruoyi-common.md) | 通用工具模块 |
| [ruoyi-framework](../../ruoyi-project-document/ruoyi-framework.md) | 核心框架模块 |
| [ruoyi-system](../../ruoyi-project-document/ruoyi-system.md) | 系统管理模块 |
| [ruoyi-quartz](../../ruoyi-project-document/ruoyi-quartz.md) | 定时任务模块 |
| [ruoyi-generator](../../ruoyi-project-document/ruoyi-generator.md) | 代码生成器模块 |
| [ruoyi-gen-cli 操作手册](../../ruoyi-project-document/ruoyi-gen-cli_操作手册.md) | 代码生成 CLI 工具使用指南 |

### 外部资源

- [RuoYi 官方文档](http://doc.ruoyi.vip/)
- [RuoYi GitHub](https://github.com/yangzongzhuan/RuoYi-Vue)

---

**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

# 控制器层（Controller）详解

## 概述

`ruoyi-admin` 的控制器层负责处理 HTTP 请求，提供 RESTful API 接口。

**源码位置**: `ruoyi-admin/src/main/java/com/ruoyi/web/controller/`

## 目录结构

```
controller/
├── common/         # 公共控制器（验证码、通用接口）
├── system/         # 系统管理控制器
├── monitor/        # 系统监控控制器
└── tool/           # 工具测试控制器
```

---

## 公共接口（common/）

### CaptchaController - 验证码接口

**源码**: [`CaptchaController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/CaptchaController.java)

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| 生成验证码 | `/captchaImage` | GET | 生成数学计算或字符验证码 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "captchaEnabled": true,
  "uuid": "a3f5d8e9c2b1",
  "img": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**验证码类型**:
- `math`: 数学计算（如 5 + 3 = ?）
- `char`: 字符验证（如 A7B9）

### CommonController - 通用接口

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| 健康检查 | `/health` | GET | 系统健康状态检查 |
| 下载资源 | 通用 | GET | 文件下载 |

---

## 系统管理接口（system/）

### SysLoginController - 登录认证

**源码**: [`SysLoginController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| 登录 | `/login` | POST | 账号密码登录，返回 Token |
| 获取用户信息 | `/getInfo` | GET | 获取当前登录用户信息 |
| 获取路由信息 | `/getRouters` | GET | 获取用户菜单路由 |

**登录请求示例**:
```json
POST /login
{
  "username": "admin",
  "password": "admin123",
  "code": "1234",
  "uuid": "a3f5d8e9c2b1"
}
```

**登录响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**获取用户信息响应**:
```json
{
  "code": 200,
  "user": { "userId": 1, "userName": "admin", ... },
  "roles": ["admin"],
  "permissions": ["*:*:*"],
  "isDefaultModifyPwd": false,
  "isPasswordExpired": false
}
```

### SysRegisterController - 用户注册

**源码**: [`SysRegisterController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java)

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| 注册 | `/register` | POST | 用户自助注册 |

**前提条件**: 系统参数 `sys.account.registerUser` = "true"

### SysUserController - 用户管理

**源码**: [`SysUserController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserController.java)

**路径**: `/system/user`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 用户列表 | `GET /list` | system:user:list | 分页查询用户列表 |
| 导出用户 | `POST /export` | system:user:export | 导出 Excel |
| 导入用户 | `POST /importData` | system:user:import | 导入 Excel 数据 |
| 下载模板 | `POST /importTemplate` | - | 下载导入模板 |
| 用户详情 | `GET /{userId}` | system:user:query | 获取用户详细信息 |
| 新增用户 | `POST` | system:user:add | 创建用户 |
| 修改用户 | `PUT` | system:user:edit | 更新用户信息 |
| 删除用户 | `DELETE /{userIds}` | system:user:remove | 批量删除用户 |
| 重置密码 | `PUT /resetPwd` | system:user:edit | 重置用户密码 |
| 授权页面 | `GET /authRole/{userId}` | system:user:edit | 获取用户角色信息 |
| 保存授权 | `POST /authRole` | system:user:edit | 保存用户角色关系 |
| 获取部门树 | `GET /deptTree` | system:user:list | 获取部门树列表 |

### SysRoleController - 角色管理

**源码**: [`SysRoleController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRoleController.java)

**路径**: `/system/role`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 角色列表 | `GET /list` | system:role:list | 分页查询角色列表 |
| 导出角色 | `POST /export` | system:role:export | 导出 Excel |
| 角色详情 | `GET /{roleId}` | system:role:query | 获取角色详细信息 |
| 新增角色 | `POST` | system:role:add | 创建角色 |
| 修改角色 | `PUT` | system:role:edit | 更新角色信息 |
| 删除角色 | `DELETE /{roleIds}` | system:role:remove | 批量删除角色 |
| 角色状态修改 | `PUT /changeStatus` | system:role:edit | 启用/禁用角色 |
| 角色数据权限 | `PUT /dataScope` | system:role:edit | 设置数据权限范围 |
| 角色菜单树 | `GET /roleMenuTreeselect/{roleId}` | - | 加载角色菜单树 |

### SysMenuController - 菜单管理

**源码**: [`SysMenuController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysMenuController.java)

**路径**: `/system/menu`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 菜单列表 | `GET /list` | system:menu:list | 查询菜单列表 |
| 菜单详情 | `GET /{menuId}` | system:menu:query | 获取菜单详细信息 |
| 菜单下拉树 | `GET /treeselect` | - | 获取菜单树（用于新增/修改） |
| 角色菜单树 | `GET /roleMenuTreeselect/{roleId}` | - | 角色分配菜单时使用 |
| 新增菜单 | `POST` | system:menu:add | 创建菜单 |
| 修改菜单 | `PUT` | system:menu:edit | 更新菜单信息 |
| 删除菜单 | `DELETE /{menuId}` | system:menu:remove | 删除菜单 |

### SysDeptController - 部门管理

**源码**: [`SysDeptController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysDeptController.java)

**路径**: `/system/dept`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 部门列表 | `GET /list` | system:dept:list | 查询部门列表 |
| 排除节点 | `GET /list/exclude/{deptId}` | system:dept:list | 查询部门列表（排除指定节点） |
| 部门详情 | `GET /{deptId}` | system:dept:query | 获取部门详细信息 |
| 新增部门 | `POST` | system:dept:add | 创建部门 |
| 修改部门 | `PUT` | system:dept:edit | 更新部门信息 |
| 删除部门 | `DELETE /{deptId}` | system:dept:remove | 删除部门 |

### SysPostController - 岗位管理

**路径**: `/system/post`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 岗位列表 | `GET /list` | system:post:list | 分页查询岗位列表 |
| 岗位详情 | `GET /{postId}` | system:post:query | 获取岗位详细信息 |
| 新增岗位 | `POST` | system:post:add | 创建岗位 |
| 修改岗位 | `PUT` | system:post:edit | 更新岗位信息 |
| 删除岗位 | `DELETE /{postIds}` | system:post:remove | 批量删除岗位 |

### SysConfigController - 参数配置

**路径**: `/system/config`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 参数列表 | `GET /list` | system:config:list | 分页查询参数列表 |
| 参数详情 | `GET /{configId}` | system:config:query | 获取参数详细信息 |
| 新增参数 | `POST` | system:config:add | 创建参数 |
| 修改参数 | `PUT` | system:config:edit | 更新参数信息 |
| 删除参数 | `DELETE /{configIds}` | system:config:remove | 批量删除参数 |
| 刷新缓存 | `DELETE /refreshCache` | system:config:remove | 清除参数缓存 |

### SysDictTypeController - 字典类型管理

**路径**: `/system/dict/type`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 字典类型列表 | `GET /list` | system:dict:list | 分页查询字典类型列表 |
| 字典类型详情 | `GET /{dictId}` | system:dict:query | 获取字典类型详细信息 |
| 新增字典类型 | `POST` | system:dict:add | 创建字典类型 |
| 修改字典类型 | `PUT` | system:dict:edit | 更新字典类型信息 |
| 删除字典类型 | `DELETE /{dictIds}` | system:dict:remove | 批量删除字典类型 |
| 刷新缓存 | `DELETE /refreshCache` | system:dict:remove | 清除字典缓存 |
| 字典类型下拉框 | `GET /optionselect` | - | 获取字典类型列表（下拉框） |

### SysDictDataController - 字典数据管理

**路径**: `/system/dict/data`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 字典数据列表 | `GET /list` | system:dict:list | 分页查询字典数据列表 |
| 字典数据详情 | `GET /{dictCode}` | system:dict:query | 获取字典数据详细信息 |
| 新增字典数据 | `POST` | system:dict:add | 创建字典数据 |
| 修改字典数据 | `PUT` | system:dict:edit | 更新字典数据信息 |
| 删除字典数据 | `DELETE /{dictCodes}` | system:dict:remove | 批量删除字典数据 |
| 按字典类型查询 | `GET /byType/{dictType}` | - | 根据字典类型查询数据 |

### SysNoticeController - 通知公告管理

**路径**: `/system/notice`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 公告列表 | `GET /list` | system:notice:list | 分页查询公告列表 |
| 公告详情 | `GET /{noticeId}` | system:notice:query | 获取公告详细信息 |
| 新增公告 | `POST` | system:notice:add | 创建公告 |
| 修改公告 | `PUT` | system:notice:edit | 更新公告信息 |
| 删除公告 | `DELETE /{noticeIds}` | system:notice:remove | 批量删除公告 |

### SysProfileController - 个人中心

**路径**: `/system/user/profile`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 个人信息 | `GET` | - | 获取当前用户个人信息 |
| 修改个人信息 | `PUT` | - | 更新个人信息 |
| 修改密码 | `PUT /updatePwd` | - | 修改登录密码 |
| 上传头像 | `POST /avatar` | - | 上传个人头像 |

---

## 系统监控接口（monitor/）

### CacheController - 缓存监控

**源码**: [`CacheController.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/controller/monitor/CacheController.java)

**路径**: `/monitor/cache`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 缓存信息 | `GET` | monitor:cache:list | 获取 Redis 详细信息和命令统计 |
| 缓存列表 | `GET /getNames` | monitor:cache:list | 获取缓存名称列表 |
| 缓存键列表 | `GET /getKeys/{cacheName}` | monitor:cache:list | 获取指定缓存的所有键 |
| 缓存内容 | `GET /getValue/{cacheName}/{cacheKey}` | monitor:cache:list | 获取指定缓存键的值 |
| 清理缓存 | `DELETE /clearCacheName/{cacheName}` | monitor:cache:list | 清理指定名称的缓存 |
| 清理单个键 | `DELETE /clearCacheKey/{cacheKey}` | monitor:cache:list | 清理指定的缓存键 |

**缓存监控项**:
- `login_token_key`: 用户信息缓存
- `sys_config_key`: 配置信息缓存
- `sys_dict_key`: 数据字典缓存
- `captcha_code_key`: 验证码缓存
- `repeat_submit_key`: 防重提交缓存
- `rate_limit_key`: 限流处理缓存
- `pwd_err_cnt_key`: 密码错误次数缓存

### ServerController - 服务器监控

**路径**: `/monitor/server`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 服务器信息 | `GET` | monitor:server:list | 获取服务器 CPU、内存、磁盘等信息 |

**返回信息**:
- CPU 信息（核心数、使用率、系统负载）
- 内存信息（总量、已用、剩余、使用率）
- 磁盘信息（盘符路径、总量、已用、剩余、使用率）
- JVM 信息（启动时间、运行时长、JVM 版本）

### SysLogininforController - 登录日志

**路径**: `/monitor/logininfor`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 登录日志列表 | `GET /list` | monitor:logininfor:list | 分页查询登录日志 |
| 删除日志 | `DELETE /{infoIds}` | monitor:logininfor:remove | 批量删除登录日志 |
| 清空日志 | `DELETE /clean` | monitor:logininfor:remove | 清空所有登录日志 |
| 解锁账户 | `PUT /unlock/{userName}` | monitor:logininfor:unlock | 解除密码错误锁定 |
| 导出日志 | `POST /export` | monitor:logininfor:export | 导出 Excel |

### SysOperlogController - 操作日志

**路径**: `/monitor/operlog`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 操作日志列表 | `GET /list` | monitor:operlog:list | 分页查询操作日志 |
| 操作日志详情 | `GET /{operId}` | monitor:operlog:query | 获取操作日志详细信息 |
| 删除日志 | `DELETE /{operIds}` | monitor:operlog:remove | 批量删除操作日志 |
| 清空日志 | `DELETE /clean` | monitor:operlog:remove | 清空所有操作日志 |
| 导出日志 | `POST /export` | monitor:operlog:export | 导出 Excel |

### SysUserOnlineController - 在线用户

**路径**: `/monitor/online`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 在线用户列表 | `GET /list` | monitor:online:list | 查询在线用户列表 |
| 强退用户 | `POST /forceLogout` | monitor:online:forceLogout | 强制退出在线用户 |
| 批量强退 | `POST /batchForceLogout` | monitor:online:forceLogout | 批量强制退出用户 |

---

## 工具测试接口（tool/）

### TestController - Swagger 测试

**路径**: `/test/user`

| 接口 | 路径 | 权限 | 说明 |
|------|------|------|------|
| 测试用户列表 | `GET /list` | - | 查询测试用户列表（Swagger 示例） |
| 测试用户详情 | `GET /{userId}` | - | 获取测试用户详细信息 |
| 新增测试用户 | `POST` | - | 创建测试用户 |
| 修改测试用户 | `PUT` | - | 更新测试用户信息 |
| 删除测试用户 | `DELETE /{userIds}` | - | 删除测试用户 |

---

## 权限注解说明

### @PreAuthorize

用于接口级别的权限控制：

```java
// 权限验证
@PreAuthorize("@ss.hasPermi('system:user:list')")
@GetMapping("/list")
public TableDataInfo list(SysUser user) { ... }

// 角色验证
@PreAuthorize("@ss.hasRole('admin')")
@GetMapping("/admin")
public AjaxResult admin() { ... }

// 组合验证
@PreAuthorize("@ss.hasAnyRoles('admin', 'user')")
```

### @Log

用于记录操作日志：

```java
@Log(title = "用户管理", businessType = BusinessType.INSERT)
@PostMapping
public AjaxResult add(@RequestBody SysUser user) { ... }
```

**业务类型**:
- `INSERT`: 新增
- `UPDATE`: 修改
- `DELETE`: 删除
- `EXPORT`: 导出
- `IMPORT`: 导入
- `OTHER`: 其他

---

## 统一响应格式

### AjaxResult - 操作结果

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {}
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码（200=成功，500=失败） |
| msg | String | 响应消息 |
| data | Object | 返回数据 |

### TableDataInfo - 表格分页数据

```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 100,
  "rows": [...]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码 |
| msg | String | 响应消息 |
| total | Long | 总记录数 |
| rows | List | 数据列表 |

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

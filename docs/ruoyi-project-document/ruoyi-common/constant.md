# Constant 常量模块

## 概述

`ruoyi-common/constant` 包提供了 RuoYi 框架中使用的各种常量定义，便于统一管理和维护。

## 常量类列表

### 1. Constants - 通用常量

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/Constants.java`

**核心常量**:
| 常量 | 值/说明 |
|------|--------|
| UTF8 / GBK | 字符集 |
| DEFAULT_LOCALE | 系统语言（简体中文） |
| HTTP / HTTPS / WWW | URL 协议 |
| SUCCESS / FAIL | 成功/失败标识 ("0"/"1") |
| LOGIN_SUCCESS / LOGIN_FAIL | 登录成功/失败 |
| ALL_PERMISSION | 所有权限 ("*:*:*") |
| SUPER_ADMIN | 管理员角色 ("admin") |
| CAPTCHA_EXPIRATION | 验证码有效期 (2 分钟) |
| TOKEN / TOKEN_PREFIX | Token 相关 |
| JWT_USERID / JWT_USERNAME / JWT_AVATAR | JWT Claims |
| RESOURCE_PREFIX | 资源映射 ("/profile") |

**安全白名单**:
| 白名单 | 说明 |
|--------|------|
| JSON_WHITELIST_STR | JSON 解析白名单 ("com.ruoyi") |
| JOB_WHITELIST_STR | 定时任务白名单 ("com.ruoyi.quartz.task") |
| JOB_ERROR_STR | 定时任务违规字符（禁止使用）|

**部门常量 (Dept 内部类)**:
| 常量 | 说明 |
|------|------|
| DATA_SCOPE_ALL | 全部数据权限 |
| DATA_SCOPE_CUSTOM | 自定义数据权限 |
| DATA_SCOPE_DEPT | 部门数据权限 |
| DATA_SCOPE_DEPT_AND_CHILD | 部门及以下数据权限 |
| DATA_SCOPE_SELF | 仅本人数据权限 |

**使用示例**:
```java
// 检查是否为成功状态
if (Constants.SUCCESS.equals(result.getCode())) {
    // 处理成功逻辑
}

// 检查是否为超级管理员
if (Constants.SUPER_ADMIN.equals(role.getRoleKey())) {
    // 管理员特殊处理
}

// 构建 Token
String token = Constants.TOKEN_PREFIX + jwtToken;
```

---

### 2. HttpStatus - HTTP 状态码

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/HttpStatus.java`

| 类型 | 状态码 | 说明 |
|------|--------|------|
| **成功** | SUCCESS=200 | 操作成功 |
| | CREATED=201 | 创建成功 |
| | ACCEPTED=202 | 请求已接受 |
| | NO_CONTENT=204 | 无返回数据 |
| **重定向** | MOVED_PERM=301 | 永久重定向 |
| | SEE_OTHER=303 | 查看其他资源 |
| | NOT_MODIFIED=304 | 资源未修改 |
| **客户端错误** | BAD_REQUEST=400 | 参数错误 |
| | UNAUTHORIZED=401 | 未授权 |
| | FORBIDDEN=403 | 访问受限 |
| | NOT_FOUND=404 | 资源未找到 |
| | CONFLICT=409 | 资源冲突 |
| | UNSUPPORTED_TYPE=415 | 不支持的媒体类型 |
| **服务器错误** | ERROR=500 | 系统内部错误 |
| | NOT_IMPLEMENTED=501 | 接口未实现 |
| **自定义** | WARN=601 | 警告消息 |

**使用示例**:
```java
// 返回成功
return new AjaxResult(HttpStatus.SUCCESS, "操作成功", data);

// 返回错误
return new AjaxResult(HttpStatus.ERROR, "操作失败");

// 返回警告
return new AjaxResult(HttpStatus.WARN, "警告信息", data);
```

---

### 3. UserConstants - 用户相关常量

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/UserConstants.java`

**状态常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| NORMAL / EXCEPTION | "0" / "1" | 正常/异常 |
| USER_DISABLE | "1" | 用户封禁 |
| ROLE_NORMAL / ROLE_DISABLE | "0" / "1" | 角色正常/封禁 |
| DEPT_NORMAL / DEPT_DISABLE | "0" / "1" | 部门正常/停用 |
| DICT_NORMAL | "0" | 字典正常 |

**是否标识**:
| 常量 | 值 | 说明 |
|------|-----|------|
| YES | "Y" | 是 |
| YES_FRAME / NO_FRAME | "0" / "1" | 菜单外链是/否 |

**菜单类型**:
| 常量 | 值 | 说明 |
|------|-----|------|
| TYPE_DIR / TYPE_MENU / TYPE_BUTTON | "M" / "C" / "F" | 目录/菜单/按钮 |

**菜单组件**:
| 常量 | 说明 |
|------|------|
| LAYOUT | 布局组件 |
| PARENT_VIEW | 父级视图 |
| INNER_LINK | 内链 |

**长度限制**:
| 常量 | 值 | 说明 |
|------|-----|------|
| USERNAME_MIN_LENGTH / MAX_LENGTH | 2 / 20 | 用户名长度 |
| PASSWORD_MIN_LENGTH / MAX_LENGTH | 5 / 20 | 密码长度 |

**使用示例**:
```java
// 检查用户状态
if (UserConstants.NORMAL.equals(user.getStatus())) {
    // 用户正常
}

// 检查菜单类型
if (UserConstants.TYPE_MENU.equals(menu.getMenuType())) {
    // 菜单类型
}

// 唯一性校验
return userService.checkUserNameUnique(user) ? UserConstants.UNIQUE : UserConstants.NOT_UNIQUE;
```

---

### 4. GenConstants - 代码生成常量

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/GenConstants.java`

**模板类型**:
| 常量 | 说明 |
|------|------|
| TPL_CRUD | 单表增删改查 |
| TPL_TREE | 树表增删改查 |
| TPL_SUB | 主子表增删改查 |

**树表字段**: TREE_CODE, TREE_PARENT_CODE, TREE_NAME, PARENT_MENU_ID, PARENT_MENU_NAME

**数据库类型映射**:
| 类型 | 字段 |
|------|------|
| COLUMNTYPE_STR | char, varchar, nvarchar, varchar2 |
| COLUMNTYPE_TEXT | tinytext, text, mediumtext, longtext |
| COLUMNTYPE_TIME | datetime, time, date, timestamp |
| COLUMNTYPE_NUMBER | tinyint, smallint, mediumint, int, number, integer, bit, bigint, float, double, decimal |

**字段过滤**:
| 常量 | 说明 |
|------|------|
| COLUMNNAME_NOT_EDIT | 不需要编辑的字段 (id, create_by, create_time, del_flag) |
| COLUMNNAME_NOT_LIST | 不需要列表显示的字段 |
| COLUMNNAME_NOT_QUERY | 不需要查询的字段 |

**HTML 控件类型**:
| 类型 | 说明 |
|------|------|
| HTML_INPUT / TEXTAREA / SELECT | 文本框/文本域/下拉框 |
| HTML_RADIO / CHECKBOX / DATETIME | 单选/复选/日期控件 |
| HTML_IMAGE_UPLOAD / FILE_UPLOAD / EDITOR | 图片上传/文件上传/富文本 |

---

### 5. ScheduleConstants - 定时任务常量

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/ScheduleConstants.java`

**任务属性**: TASK_CLASS_NAME (任务类名), TASK_PROPERTIES (任务属性)

**Misfire 策略**:
| 常量 | 说明 |
|------|------|
| MISFIRE_DEFAULT | 默认 |
| MISFIRE_IGNORE_MISFIRES | 忽略 Misfire，立即执行 |
| MISFIRE_FIRE_AND_PROCEED | 触发一次后继续 |
| MISFIRE_DO_NOTHING | 不触发立即执行 |

**任务状态**: NORMAL(0-正常), PAUSE(1-暂停)

---

### 6. CacheConstants - 缓存 Key 常量

> 源码：`ruoyi-common/constant/src/main/java/com/ruoyi/common/constant/CacheConstants.java`

| 常量 | 前缀 | 说明 |
|------|------|------|
| LOGIN_TOKEN_KEY | login_tokens: | 登录用户 Token |
| CAPTCHA_CODE_KEY | captcha_codes: | 验证码 |
| SYS_CONFIG_KEY | sys_config: | 系统配置 |
| SYS_DICT_KEY | sys_dict: | 系统字典 |
| REPEAT_SUBMIT_KEY | repeat_submit: | 防重复提交 |
| RATE_LIMIT_KEY | rate_limit: | 限流 |
| PWD_ERR_CNT_KEY | pwd_err_cnt: | 密码错误次数 |

**使用示例**:
```java
// 存储登录 Token
redisCache.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, timeout, TimeUnit.MINUTES);

// 获取验证码
String captcha = redisCache.getCacheObject(CacheConstants.CAPTCHA_CODE_KEY + uuid);

// 删除用户缓存
redisCache.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
```
> 更多 Redis 操作见 `ruoyi-common/core/src/main/java/com/ruoyi/common/core/redis/RedisCache.java`

---

## 最佳实践

1. **统一使用常量**: 避免在代码中硬编码字符串
2. **分类管理**: 按功能模块将常量拆分到不同的常量类
3. **语义化命名**: 常量名称应清晰表达其用途
4. **集中维护**: 所有常量在 constant 包中统一管理
5. **安全白名单**: 定时任务和 JSON 解析必须使用白名单校验

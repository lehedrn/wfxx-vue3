# Constant 常量模块

## 概述

`ruoyi-common/constant` 包提供了 RuoYi 框架中使用的各种常量定义，便于统一管理和维护。

## 常量类列表

### 1. Constants - 通用常量

**核心常量**:
```java
// 字符集
UTF8 = "UTF-8"
GBK = "GBK"

// 系统语言
DEFAULT_LOCALE = Locale.SIMPLIFIED_CHINESE

// URL 协议
HTTP = "http://"
HTTPS = "https://"
WWW = "www."

// 通用标识
SUCCESS = "0"      // 成功
FAIL = "1"         // 失败

// 登录相关
LOGIN_SUCCESS = "Success"
LOGIN_FAIL = "Error"
LOGOUT = "Logout"
REGISTER = "Register"

// 权限相关
ALL_PERMISSION = "*:*:*"     // 所有权限
SUPER_ADMIN = "admin"         // 管理员角色
ROLE_DELIMITER = ","          // 角色分隔符
PERMISSION_DELIMITER = ","    // 权限分隔符

// 验证码
CAPTCHA_EXPIRATION = 2  // 有效期 2 分钟

// Token 相关
TOKEN = "token"
TOKEN_PREFIX = "Bearer "
LOGIN_USER_KEY = "login_user_key"

// JWT Claims
JWT_USERID = "userid"
JWT_USERNAME = "sub"       // 主题字段
JWT_AVATAR = "avatar"
JWT_CREATED = "created"
JWT_AUTHORITIES = "authorities"

// 资源映射
RESOURCE_PREFIX = "/profile"
```

**安全白名单**:
```java
// JSON 解析白名单
JSON_WHITELIST_STR = { "com.ruoyi" }

// 定时任务白名单
JOB_WHITELIST_STR = { "com.ruoyi.quartz.task" }

// 定时任务违规字符（禁止使用）
JOB_ERROR_STR = { 
    "java.net.URL", 
    "javax.naming.InitialContext", 
    "org.yaml.snakeyaml",
    "org.springframework", 
    "org.apache", 
    "com.ruoyi.common.utils.file", 
    "com.ruoyi.common.config", 
    "com.ruoyi.generator" 
}
```

**部门常量 (Dept 内部类)**:
```java
DATA_SCOPE_ALL = "1"              // 全部数据权限
DATA_SCOPE_CUSTOM = "2"           // 自定义数据权限
DATA_SCOPE_DEPT = "3"             // 部门数据权限
DATA_SCOPE_DEPT_AND_CHILD = "4"   // 部门及以下数据权限
DATA_SCOPE_SELF = "5"             // 仅本人数据权限
```

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

**成功状态**:
```java
SUCCESS = 200           // 操作成功
CREATED = 201           // 对象创建成功
ACCEPTED = 202          // 请求已接受
NO_CONTENT = 204        // 无返回数据
```

**重定向**:
```java
MOVED_PERM = 301        // 永久重定向
SEE_OTHER = 303         // 查看其他资源
NOT_MODIFIED = 304      // 资源未修改
```

**客户端错误**:
```java
BAD_REQUEST = 400       // 参数错误
UNAUTHORIZED = 401      // 未授权
FORBIDDEN = 403         // 访问受限
NOT_FOUND = 404         // 资源未找到
BAD_METHOD = 405        // 方法不允许
CONFLICT = 409          // 资源冲突
UNSUPPORTED_TYPE = 415  // 不支持的媒体类型
```

**服务器错误**:
```java
ERROR = 500             // 系统内部错误
NOT_IMPLEMENTED = 501   // 接口未实现
```

**自定义状态**:
```java
WARN = 601              // 警告消息
```

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

**系统用户**:
```java
SYS_USER = "SYS_USER"   // 系统用户标识
```

**状态常量**:
```java
// 通用状态
NORMAL = "0"      // 正常
EXCEPTION = "1"   // 异常

// 用户状态
USER_DISABLE = "1"  // 用户封禁

// 角色状态
ROLE_NORMAL = "0"     // 正常
ROLE_DISABLE = "1"    // 封禁

// 部门状态
DEPT_NORMAL = "0"     // 正常
DEPT_DISABLE = "1"    // 停用

// 字典状态
DICT_NORMAL = "0"     // 正常
```

**是否标识**:
```java
YES = "Y"             // 是
YES_FRAME = "0"       // 是（菜单外链）
NO_FRAME = "1"        // 否（菜单外链）
```

**菜单类型**:
```java
TYPE_DIR = "M"        // 目录
TYPE_MENU = "C"       // 菜单
TYPE_BUTTON = "F"     // 按钮
```

**菜单组件**:
```java
LAYOUT = "Layout"         // 布局组件
PARENT_VIEW = "ParentView" // 父级视图
INNER_LINK = "InnerLink"   // 内链
```

**校验结果**:
```java
UNIQUE = true         // 唯一
NOT_UNIQUE = false    // 不唯一
```

**长度限制**:
```java
// 用户名长度
USERNAME_MIN_LENGTH = 2
USERNAME_MAX_LENGTH = 20

// 密码长度
PASSWORD_MIN_LENGTH = 5
PASSWORD_MAX_LENGTH = 20
```

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

**模板类型**:
```java
TPL_CRUD = "crud"     // 单表增删改查
TPL_TREE = "tree"     // 树表增删改查
TPL_SUB = "sub"       // 主子表增删改查
```

**树表字段**:
```java
TREE_CODE = "treeCode"           // 树编码字段
TREE_PARENT_CODE = "treeParentCode" // 树父编码字段
TREE_NAME = "treeName"           // 树名称字段
PARENT_MENU_ID = "parentMenuId"  // 上级菜单 ID
PARENT_MENU_NAME = "parentMenuName" // 上级菜单名称
```

**数据库类型映射**:
```java
// 字符串类型
COLUMNTYPE_STR = { "char", "varchar", "nvarchar", "varchar2" }

// 文本类型
COLUMNTYPE_TEXT = { "tinytext", "text", "mediumtext", "longtext" }

// 时间类型
COLUMNTYPE_TIME = { "datetime", "time", "date", "timestamp" }

// 数字类型
COLUMNTYPE_NUMBER = { "tinyint", "smallint", "mediumint", "int", 
                      "number", "integer", "bit", "bigint", 
                      "float", "double", "decimal" }
```

**页面字段过滤**:
```java
// 不需要编辑的字段
COLUMNNAME_NOT_EDIT = { "id", "create_by", "create_time", "del_flag" }

// 不需要列表显示的字段
COLUMNNAME_NOT_LIST = { "id", "create_by", "create_time", "del_flag", 
                        "update_by", "update_time" }

// 不需要查询的字段的字段
COLUMNNAME_NOT_QUERY = { "id", "create_by", "create_time", "del_flag", 
                         "update_by", "update_time", "remark" }
```

**基类字段**:
```java
BASE_ENTITY = { "createBy", "createTime", "updateBy", "updateTime", "remark" }
TREE_ENTITY = { "parentName", "parentId", "orderNum", "ancestors", "children" }
```

**HTML 控件类型**:
```java
HTML_INPUT = "input"           // 文本框
HTML_TEXTAREA = "textarea"     // 文本域
HTML_SELECT = "select"         // 下拉框
HTML_RADIO = "radio"           // 单选框
HTML_CHECKBOX = "checkbox"     // 复选框
HTML_DATETIME = "datetime"     // 日期控件
HTML_IMAGE_UPLOAD = "imageUpload" // 图片上传
HTML_FILE_UPLOAD = "fileUpload"   // 文件上传
HTML_EDITOR = "editor"         // 富文本
```

**Java 类型映射**:
```java
TYPE_STRING = "String"
TYPE_INTEGER = "Integer"
TYPE_LONG = "Long"
TYPE_DOUBLE = "Double"
TYPE_BIGDECIMAL = "BigDecimal"
TYPE_DATE = "Date"
```

**查询类型**:
```java
QUERY_LIKE = "LIKE"  // 模糊查询
QUERY_EQ = "EQ"      // 相等查询
```

**其他**:
```java
REQUIRE = "1"  // 必填
```

---

### 5. ScheduleConstants - 定时任务常量

**任务属性**:
```java
TASK_CLASS_NAME = "TASK_CLASS_NAME"  // 任务类名
TASK_PROPERTIES = "TASK_PROPERTIES"  // 任务属性
```

**Misfire 策略**:
```java
MISFIRE_DEFAULT = "0"              // 默认
MISFIRE_IGNORE_MISFIRES = "1"      // 忽略 Misfire，立即执行
MISFIRE_FIRE_AND_PROCEED = "2"     // 触发一次后继续
MISFIRE_DO_NOTHING = "3"           // 不触发立即执行
```

**任务状态 (Status 枚举)**:
```java
NORMAL = "0"    // 正常
PAUSE = "1"     // 暂停
```

---

### 6. CacheConstants - 缓存 Key 常量

**Redis Key 定义**:
```java
LOGIN_TOKEN_KEY = "login_tokens:"        // 登录用户 Token
CAPTCHA_CODE_KEY = "captcha_codes:"      // 验证码
SYS_CONFIG_KEY = "sys_config:"           // 系统配置
SYS_DICT_KEY = "sys_dict:"               // 系统字典
REPEAT_SUBMIT_KEY = "repeat_submit:"     // 防重复提交
RATE_LIMIT_KEY = "rate_limit:"           // 限流
PWD_ERR_CNT_KEY = "pwd_err_cnt:"         // 密码错误次数
```

**使用示例**:
```java
// 存储登录 Token
redisCache.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, timeout, TimeUnit.MINUTES);

// 获取验证码
String captcha = redisCache.getCacheObject(CacheConstants.CAPTCHA_CODE_KEY + uuid);

// 删除用户缓存
redisCache.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
```

---

## 最佳实践

1. **统一使用常量**: 避免在代码中硬编码字符串
2. **分类管理**: 按功能模块将常量拆分到不同的常量类
3. **语义化命名**: 常量名称应清晰表达其用途
4. **集中维护**: 所有常量在 constant 包中统一管理
5. **安全白名单**: 定时任务和 JSON 解析必须使用白名单校验

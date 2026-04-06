# Utils 工具类模块（上）- 核心工具类

## 概述

`ruoyi-common/utils` 包提供了 RuoYi 框架的核心工具类，涵盖字符串、日期、安全、Servlet、文件、加密等多个方面。

## 模块结构

```
utils/
├── Arith.java              # 精确计算工具
├── DateUtils.java          # 日期工具类
├── DesensitizedUtil.java   # 数据脱敏工具
├── DictUtils.java          # 字典工具类
├── ExceptionUtil.java      # 异常工具类
├── LogUtils.java           # 日志工具类
├── MessageUtils.java       # 消息工具类
├── PageUtils.java          # 分页工具类
├── SecurityUtils.java      # 安全服务工具类
├── ServletUtils.java       # Servlet 工具类
├── StringUtils.java        # 字符串工具类
├── Threads.java            # 线程工具类
├── bean/                   # Bean 工具
├── file/                   # 文件工具
├── html/                   # HTML 工具
├── http/                   # HTTP 工具
├── ip/                     # IP 工具
├── poi/                    # Excel 工具
├── reflect/                # 反射工具
├── sign/                   # 签名工具
├── spring/                 # Spring 工具
├── sql/                    # SQL 工具
└── uuid/                   # UUID 工具
```

---

## 1. StringUtils - 字符串工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/StringUtils.java`  
> 继承：`org.apache.commons.lang3.StringUtils`

**核心方法**:

| 类型 | 方法 |
|------|------|
| 空值判断 | `isEmpty(str)`, `isNotEmpty(str)`, `isNull(object)`, `isNotNull(object)`, `hasText(str)`, `nvl(value, defaultValue)` |
| 截取替换 | `substring(str, start/end)`, `substringBetweenLast(str, open, close)`, `replace(text, search, replacement)`, `removeEnd(str, remove)`, `trim(str)` |
| 隐藏处理 | `hide(str, startInclude, endExclude)` |
| 格式化 | `format(template, params)` |
| 转换 | `toCamelCase(str)`, `convertToCamelCase(name)`, `toUnderScoreCase(str)` |
| 集合转换 | `str2Set(str, sep)`, `str2List(str, sep, filterBlank, trim)` |
| 匹配判断 | `contains()`, `containsAny()`, `containsAnyIgnoreCase()`, `containsIgnoreCase()`, `equals()`, `equalsAny()`, `equalsAnyIgnoreCase()`, `startsWithAny()`, `startsWithIgnoreCase()`, `endsWith()`, `endsWithAny()`, `endsWithIgnoreCase()` |
| 路径匹配 | `isMatch(pattern, url)` (Ant 风格), `matches(str, strs)` |
| 数字补齐 | `padl(num/str, size, c)` |
| 删除末尾 | `lastStringDel(str, spit)` |

**使用示例**:
```java
// 空值判断
StringUtils.isEmpty("")      // true
StringUtils.nvl(null, "default")  // "default"

// 截取
StringUtils.substring("hello", 0, 3)  // "hel"

// 隐藏
StringUtils.hide("13812341234", 3, 7)  // "138****1234"

// 格式化
StringUtils.format("Hello, {}", "World")  // "Hello, World"

// 转换
StringUtils.toCamelCase("user_name")      // "userName"
StringUtils.toUnderScoreCase("userName")  // "user_name"

// 路径匹配 (Ant 风格)
StringUtils.isMatch("/api/*", "/api/users")     // true
StringUtils.isMatch("/api/**", "/api/users/1")  // true

// 数字补齐
StringUtils.padl(123, 5, '0')  // "00123"

// 删除末尾分隔符
StringUtils.lastStringDel("a,b,c,", ",")  // "a,b,c"
```

---

## 2. ExceptionUtil - 异常工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/ExceptionUtil.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `getExceptionMessage(e)` | 获取 exception 的详细错误信息 |
| `getRootErrorMessage(e)` | 获取根异常错误信息 |

**使用示例**:
```java
try {
    // 业务逻辑
} catch (Exception e) {
    String errorMessage = ExceptionUtil.getExceptionMessage(e);
    String rootMessage = ExceptionUtil.getRootErrorMessage(e);
}
```

---

## 3. Arith - 精确计算工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/arith/Arith.java`

**核心方法**:

| 方法 | 说明 |
|------|------|
| `add(v1, v2)` | 提供精确的加法 |
| `sub(v1, v2)` | 提供精确的减法 |
| `mul(v1, v2)` | 提供精确的乘法 |
| `div(v1, v2)` | 提供精确的除法 |
| `div(v1, v2, scale)` | 提供精确的除法（指定精度） |
| `round(v, scale)` | 提供精确的四舍五入 |

**使用示例**:
```java
BigDecimal result = Arith.add(0.1, 0.2);  // 0.3
BigDecimal result = Arith.div(1.0, 3.0, 2);  // 0.33
```

---

## 4. DateUtils - 日期工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/DateUtils.java`  
> 继承：`org.apache.commons.lang3.time.DateUtils`

**常用格式**: `YYYY`, `YYYY_MM`, `YYYY_MM_DD`, `YYYYMMDDHHMMSS`, `YYYY_MM_DD_HH_MM_SS`

**方法**:

| 方法 | 说明 |
|------|------|
| `getNowDate()` | 获取当前 Date 型日期 |
| `getDate()` | 获取当前日期 (yyyy-MM-dd) |
| `getTime()` | 获取当前日期时间 (yyyy-MM-dd HH:mm:ss) |
| `dateTimeNow()` | 获取当前时间戳 (yyyyMMddHHmmss) |
| `dateTimeNow(format)` | 获取指定格式的时间戳 |
| `dateTime(format, ts)` | 字符串转日期 |
| `parseDateToStr(format, date)` | 日期转字符串 |
| `datePath()` | 日期路径 (yyyy/MM/dd) |
| `dateTime()` | 日期路径 (yyyyMMdd) |
| `parseDate(str)` | 日期型字符串转化为日期 |
| `getServerStartDate()` | 获取服务器启动时间 |
| `differentDaysByMillisecond(date1, date2)` | 计算相差天数 |
| `timeDistance(endDate, startTime)` | 计算时间差 |
| `toDate(LocalDateTime)` | LocalDateTime 转 Date |
| `toDate(LocalDate)` | LocalDate 转 Date |

**使用示例**:
```java
DateUtils.getDate()           // "2024-01-01"
DateUtils.getTime()           // "2024-01-01 12:30:00"
DateUtils.dateTimeNow()       // "20240101123000"
DateUtils.parseDateToStr("yyyy-MM-dd", new Date())
DateUtils.differentDaysByMillisecond(date1, date2)  // 相差天数
DateUtils.timeDistance(endDate, startTime)  // "1 天 2 小时 30 分钟"

// Java8 转换
LocalDateTime ldt = LocalDateTime.now();
Date date1 = DateUtils.toDate(ldt);
```

---

## 5. PageUtils - 分页工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/PageUtils.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `startPage()` | 设置请求分页数据 |
| `clearPage()` | 清理分页的线程变量 |

**使用示例**:
```java
// 查询前设置分页
PageUtils.startPage();
List<SysUser> list = userMapper.selectUserList(user);
// 清理分页
PageUtils.clearPage();
```

---

## 6. SecurityUtils - 安全服务工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/SecurityUtils.java`

**核心方法**:

| 类型 | 方法 |
|------|------|
| 用户信息 | `getUserId()`, `getDeptId()`, `getUsername()`, `getLoginUser()`, `getAuthentication()` |
| 密码处理 | `encryptPassword(password)` (BCrypt), `matchesPassword(raw, encoded)` |
| 权限校验 | `isAdmin()`, `isAdmin(userId)`, `hasPermi(permission)`, `hasPermi(auth, perm)`, `hasRole(role)`, `hasRole(roles, role)` |

**使用示例**:
```java
// 获取用户信息
Long userId = SecurityUtils.getUserId();
LoginUser user = SecurityUtils.getLoginUser();

// 密码处理
String encrypted = SecurityUtils.encryptPassword(password);
boolean matches = SecurityUtils.matchesPassword(rawPassword, encryptedPassword);

// 权限检查
if (SecurityUtils.isAdmin()) { }
if (SecurityUtils.hasPermi("system:user:add")) { }
if (SecurityUtils.hasRole("admin")) { }
```

---

## 6. SecurityUtils - 安全服务工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/ServletUtils.java`

**核心方法**:

| 方法 | 说明 |
|------|------|
| `getRequest()` | 获取 request 对象 |
| `getResponse()` | 获取 response 对象 |
| `getSession()` | 获取 HttpSession 对象 |
| `getRequestAttributes()` | 获取 RequestAttributes |
| `getParameter(name)` | 获取 String 参数 |
| `getParameter(name, defaultValue)` | 获取 String 参数（带默认值） |
| `getParameterToInt(name)` | 获取 Integer 参数 |
| `getParameterToInt(name, defaultValue)` | 获取 Integer 参数（带默认值） |
| `getParameterToBool(name)` | 获取 Boolean 参数 |
| `getParameterToBool(name, defaultValue)` | 获取 Boolean 参数（带默认值） |
| `getParams(request)` | 获得所有请求参数 (Map<String, String[]>) |
| `getParamMap(request)` | 获得所有请求参数 (Map<String, String>) |
| `renderString(response, string)` | 将字符串渲染到客户端 |
| `isAjaxRequest(request)` | 判断是否是 Ajax 异步请求 |
| `urlEncode(str)` | 内容编码 |
| `urlDecode(str)` | 内容解码 |

**使用示例**:
```java
HttpServletRequest request = ServletUtils.getRequest();
String token = request.getHeader("Authorization");

String pageNum = ServletUtils.getParameter("pageNum", "1");
Integer pageSize = ServletUtils.getParameterToInt("pageSize", 10);

// 返回 JSON
ServletUtils.renderString(response, JSONObject.toJSONString(result));
```

### 获取请求参数
```java
String getParameter(String name)
String getParameter(String name, String defaultValue)
Integer getParameterToInt(String name)
Integer getParameterToInt(String name, Integer defaultValue)
Boolean getParameterToBool(String name)
Boolean getParameterToBool(String name, Boolean defaultValue)
Map<String, String[]> getParams(ServletRequest request)
Map<String, String> getParamMap(ServletRequest request)
```

**使用示例**:
```java
String pageNum = ServletUtils.getParameter("pageNum", "1");
Integer pageSize = ServletUtils.getParameterToInt("pageSize", 10);
Boolean flag = ServletUtils.getParameterToBool("flag", false);
```

### 响应处理
```java
void renderString(HttpServletResponse response, String string)
```

**使用示例**:
```java
// 返回 JSON
ServletUtils.renderString(response, JSONObject.toJSONString(result));
```

### 请求判断
`isAjaxRequest(request)`

### URL 编解码
`urlEncode(str)`, `urlDecode(str)`

---

## 7. Threads - 线程工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/Threads.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `sleep(milliseconds)` | 休眠 |
| `runAndShutdownAll(executor)` | 运行并关闭所有线程 |

---

## 8. LogUtils - 日志工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/LogUtils.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `getLog()` | 获取日志记录对象 |

---

## 9. MessageUtils - 消息工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/MessageUtils.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `message(code, args)` | 获取消息 |

---

## 10. DesensitizedUtil - 数据脱敏工具

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/DesensitizedUtil.java`

**方法**:

| 方法 | 说明 |
|------|------|
| `password(pwd)` | 密码脱敏 |
| `carLicense(license)` | 车牌脱敏 |

---

## 最佳实践

1. **字符串处理**: 使用 `StringUtils` 避免 NPE，优先使用 `isEmpty()` 而非 `== null`
2. **日期处理**: 统一使用 `DateUtils` 格式化，避免直接使用 `SimpleDateFormat`
3. **精确计算**: 金额计算必须使用 `Arith` 避免精度丢失
4. **权限检查**: 使用 `SecurityUtils.hasPermi()` 进行权限控制
5. **Servlet 获取**: 非 Controller 环境使用 `ServletUtils.getRequest()` 获取请求

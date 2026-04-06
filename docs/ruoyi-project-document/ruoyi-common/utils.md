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
boolean endsWith(CharSequence str, CharSequence suffix)
boolean endsWithAny(CharSequence sequence, CharSequence... searchStrings)
boolean endsWithIgnoreCase(CharSequence str, CharSequence suffix)
```

**使用示例**:
```java
StringUtils.containsIgnoreCase("Hello World", "hello")  // true
StringUtils.equalsAnyIgnoreCase("GET", "get", "post")   // true
StringUtils.startsWithAny("http://abc.com", "http://", "https://")  // true
```

#### 路径匹配
```java
boolean isMatch(String pattern, String url)  // Ant 风格路径匹配
boolean matches(String str, List<String> strs)
```

**使用示例**:
```java
// Ant 风格匹配
StringUtils.isMatch("/api/*", "/api/users")     // true
StringUtils.isMatch("/api/**", "/api/users/1")  // true
StringUtils.isMatch("/api?", "/api1")           // true
```

#### 数字补齐
```java
String padl(Number num, int size)
String padl(String s, int size, char c)
```

**使用示例**:
```java
StringUtils.padl(123, 5, '0')    // "00123"
StringUtils.padl("abc", 5, '0')  // "00abc"
```

#### 删除最后一个字符串
```java
String lastStringDel(String str, String spit)   // 删除字符串末尾指定的分隔符
```

**使用示例**:
```java
StringUtils.lastStringDel("a,b,c,", ",")     // "a,b,c"
StringUtils.lastStringDel("hello", ",")      // "hello" (无变化)
```

---

## 2. DateUtils - 日期工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/DateUtils.java`  
> 继承：`org.apache.commons.lang3.time.DateUtils`

**常用格式**: `YYYY`, `YYYY_MM`, `YYYY_MM_DD`, `YYYYMMDDHHMMSS`, `YYYY_MM_DD_HH_MM_SS`

**核心方法**:

| 类型 | 方法 |
|------|------|
| 获取当前 | `getNowDate()`, `getDate()`, `getTime()`, `dateTimeNow()`, `dateTimeNow(format)` |
| 格式化 | `parseDateToStr(format, date)`, `dateTime(format, ts)`, `parseDate(str)` |
| 日期路径 | `datePath()`, `dateTime()` |
| 时间计算 | `getServerStartDate()`, `differentDaysByMillisecond(date1, date2)`, `timeDistance(endDate, startTime)` |
| Java8 转换 | `toDate(LocalDateTime)`, `toDate(LocalDate)` |

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

## 3. SecurityUtils - 安全服务工具类

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

## 4. ServletUtils - Servlet 工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/ServletUtils.java`

**核心方法**:

| 类型 | 方法 |
|------|------|
| 获取对象 | `getRequest()`, `getResponse()`, `getSession()`, `getRequestAttributes()` |
| 参数获取 | `getParameter(name)`, `getParameter(name, default)`, `getParameterToInt(name)`, `getParameterToBool(name)`, `getParams(request)`, `getParamMap(request)` |
| 响应处理 | `renderString(response, string)` |
| 请求判断 | `isAjaxRequest(request)` |
| URL 编解码 | `urlEncode(str)`, `urlDecode(str)` |

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

## 最佳实践

1. **字符串处理**: 使用 `StringUtils` 避免 NPE，优先使用 `isEmpty()` 而非 `== null`
2. **日期处理**: 统一使用 `DateUtils` 格式化，避免直接使用 `SimpleDateFormat`
3. **精确计算**: 金额计算必须使用 `Arith` 避免精度丢失
4. **权限检查**: 使用 `SecurityUtils.hasPermi()` 进行权限控制
5. **Servlet 获取**: 非 Controller 环境使用 `ServletUtils.getRequest()` 获取请求

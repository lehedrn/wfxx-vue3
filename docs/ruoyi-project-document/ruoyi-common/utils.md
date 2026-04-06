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

**继承**: `org.apache.commons.lang3.StringUtils`

### 核心方法

#### 空值判断
```java
// 判断是否为空
boolean isEmpty(String str)           // 空或空白字符串
boolean isNotEmpty(String str)        // 非空
boolean isNull(Object object)         // null 判断
boolean isNotNull(Object object)      // 非 null 判断
boolean hasText(String str)           // 包含非空白字符

// 获取非空值
<T> T nvl(T value, T defaultValue)    // 空值替换
```

**使用示例**:
```java
StringUtils.isEmpty("")           // true
StringUtils.isEmpty("  ")         // true
StringUtils.isEmpty("abc")        // false
StringUtils.nvl(null, "default")  // "default"
```

#### 截取和替换
```java
// 截取
String substring(String str, int start)
String substring(String str, int start, int end)
String substringBetweenLast(String str, String open, String close)

// 替换
String replace(String text, String searchString, String replacement)
String removeEnd(String str, String remove)

// 去空格
String trim(String str)
```

**使用示例**:
```java
StringUtils.substring("hello", 0, 3)      // "hel"
StringUtils.substring("hello", 2)         // "llo"
StringUtils.trim("  abc  ")               // "abc"
StringUtils.replace("a.b.c", ".", "/")    // "a/b/c"
```

#### 隐藏处理
```java
String hide(CharSequence str, int startInclude, int endExclude)
```

**使用示例**:
```java
StringUtils.hide("13812341234", 3, 7)     // "138****1234"
StringUtils.hide("张三", 1, 2)            // "张*"
```

#### 格式化
```java
String format(String template, Object... params)
```

**使用示例**:
```java
StringUtils.format("Hello, {}", "World")         // "Hello, World"
StringUtils.format("User {} login at {}", name, time)
```

#### 转换
```java
// 下划线转驼峰
String toCamelCase(String s)           // user_name -> userName
String convertToCamelCase(String name) // HELLO_WORLD -> HelloWorld

// 驼峰转下划线
String toUnderScoreCase(String str)    // userName -> user_name
```

**使用示例**:
```java
StringUtils.toCamelCase("user_name")           // "userName"
StringUtils.toUnderScoreCase("userName")       // "user_name"
StringUtils.convertToCamelCase("HELLO_WORLD")  // "HelloWorld"
```

#### 集合转换
```java
Set<String> str2Set(String str, String sep)
List<String> str2List(String str, String sep)
List<String> str2List(String str, String sep, boolean filterBlank, boolean trim)
```

**使用示例**:
```java
StringUtils.str2Set("a,b,c", ",")           // ["a", "b", "c"]
StringUtils.str2List("a, b, c", ",", true, true)  // ["a", "b", "c"]
```

#### 匹配判断
```java
boolean contains(CharSequence seq, CharSequence searchSeq)
boolean containsAny(CharSequence cs, CharSequence... searchCharSequences)
boolean containsAnyIgnoreCase(CharSequence cs, CharSequence... searchCharSequences)
boolean containsIgnoreCase(CharSequence str, CharSequence searchStr)
boolean equals(CharSequence cs1, CharSequence cs2)
boolean equalsAny(CharSequence string, CharSequence... searchStrings)
boolean equalsAnyIgnoreCase(CharSequence string, CharSequence... searchStrings)
boolean startsWithAny(CharSequence sequence, CharSequence... searchStrings)
boolean startsWithIgnoreCase(CharSequence str, CharSequence prefix)
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

**继承**: `org.apache.commons.lang3.time.DateUtils`

### 常用日期格式
```java
String YYYY = "yyyy"
String YYYY_MM = "yyyy-MM"
String YYYY_MM_DD = "yyyy-MM-dd"
String YYYYMMDDHHMMSS = "yyyyMMddHHmmss"
String YYYY_MM_DD_HH_MM_SS = "yyyy-MM-dd HH:mm:ss"
```

### 核心方法

#### 获取当前日期
```java
Date getNowDate()                      // 当前 Date
String getDate()                       // 当前日期 (yyyy-MM-dd)
String getTime()                       // 当前时间 (yyyy-MM-dd HH:mm:ss)
String dateTimeNow()                   // 当前时间戳 (yyyyMMddHHmmss)
String dateTimeNow(String format)      // 指定格式当前时间
```

**使用示例**:
```java
DateUtils.getDate()           // "2024-01-01"
DateUtils.getTime()           // "2024-01-01 12:30:00"
DateUtils.dateTimeNow()       // "20240101123000"
```

#### 日期格式化
```java
String parseDateToStr(String format, Date date)
Date dateTime(String format, String ts)
Date parseDate(Object str)
```

**使用示例**:
```java
DateUtils.parseDateToStr("yyyy-MM-dd", new Date())
DateUtils.dateTime("yyyy-MM-dd", "2024-01-01")
DateUtils.parseDate("2024-01-01")  // 支持多种格式
```

#### 日期路径
```java
String datePath()     // 2018/08/08
String dateTime()     // 20180808
```

#### 时间计算
```java
Date getServerStartDate()                          // 服务器启动时间
int differentDaysByMillisecond(Date date1, Date date2)  // 相差天数
String timeDistance(Date endDate, Date startTime)  // 时间差（天/小时/分钟）
```

**使用示例**:
```java
long days = DateUtils.differentDaysByMillisecond(date1, date2)
String distance = DateUtils.timeDistance(endDate, startTime)  // "1 天 2 小时 30 分钟"
```

#### Java8 时间转换
```java
Date toDate(LocalDateTime temporalAccessor)
Date toDate(LocalDate temporalAccessor)
```

**使用示例**:
```java
// LocalDateTime 转 Date
LocalDateTime ldt = LocalDateTime.now();
Date date1 = DateUtils.toDate(ldt);

// LocalDate 转 Date (时间默认为 00:00:00)
LocalDate ld = LocalDate.now();
Date date2 = DateUtils.toDate(ld);
```

---

## 3. SecurityUtils - 安全服务工具类

### 用户信息获取
```java
Long getUserId()              // 获取当前登录用户 ID
Long getDeptId()              // 获取当前登录部门 ID
String getUsername()          // 获取当前登录用户名
LoginUser getLoginUser()      // 获取当前登录用户对象
Authentication getAuthentication()  // 获取认证信息
```

**使用示例**:
```java
// Controller 中获取用户信息
Long userId = SecurityUtils.getUserId();
String username = SecurityUtils.getUsername();
LoginUser user = SecurityUtils.getLoginUser();
```

### 密码处理
```java
String encryptPassword(String password)           // BCrypt 加密
boolean matchesPassword(String raw, String encoded)  // 密码校验
```

**使用示例**:
```java
// 注册时加密密码
String encrypted = SecurityUtils.encryptPassword(password);

// 登录时校验密码
boolean matches = SecurityUtils.matchesPassword(rawPassword, encryptedPassword);
```

### 权限校验
```java
boolean isAdmin()                          // 是否管理员
boolean isAdmin(Long userId)               // 指定用户是否管理员
boolean hasPermi(String permission)        // 是否有权限
boolean hasPermi(Collection<String> auth, String perm)  // 权限集合校验
boolean hasRole(String role)               // 是否有角色
boolean hasRole(Collection<String> roles, String role)  // 角色集合校验
```

**使用示例**:
```java
// 检查是否管理员
if (SecurityUtils.isAdmin()) {
    // 管理员操作
}

// 检查权限
if (SecurityUtils.hasPermi("system:user:add")) {
    // 有添加权限
}

// 检查角色
if (SecurityUtils.hasRole("admin")) {
    // 管理员角色
}
```

---

## 4. ServletUtils - Servlet 工具类

### 获取请求对象
```java
HttpServletRequest getRequest()
HttpServletResponse getResponse()
HttpSession getSession()
ServletRequestAttributes getRequestAttributes()
```

**使用示例**:
```java
HttpServletRequest request = ServletUtils.getRequest();
String token = request.getHeader("Authorization");
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
```java
boolean isAjaxRequest(HttpServletRequest request)
```

### URL 编解码
```java
String urlEncode(String str)
String urlDecode(String str)
```

---

## 5. Arith - 精确计算工具

**用途**: 精确的浮点数运算，避免精度丢失

### 核心方法
```java
// 加法
static double add(double v1, double v2)

// 减法
static double sub(double v1, double v2)

// 乘法
static double mul(double v1, double v2)

// 除法
static double div(double v1, double v2)
static double div(double v1, double v2, int scale)

// 四舍五入
static double round(double v, int scale)
```

**使用示例**:
```java
// 普通计算会有精度问题
0.1 + 0.2  // 0.30000000000000004

// 使用 Arith
Arith.add(0.1, 0.2)  // 0.3
Arith.mul(0.1, 0.2)  // 0.02
Arith.div(1.0, 3, 2) // 0.33
```

---

## 6. ExceptionUtil - 异常工具类

### 获取错误消息
```java
String getExceptionMessage(Throwable e)
```

### 获取堆栈信息
```java
String getStackTrace(Throwable e)
```

**使用示例**:
```java
try {
    // 可能抛出异常的代码
} catch (Exception e) {
    log.error(ExceptionUtil.getExceptionMessage(e));
    log.error(ExceptionUtil.getStackTrace(e));
}
```

---

## 7. MessageUtils - 消息工具类

**用途**: 国际化消息处理

### 核心方法
```java
String message(String code, Object... args)
```

**使用示例**:
```java
// 从 messages.properties 获取消息
String msg = MessageUtils.message("user.not.exists");
String msg = MessageUtils.message("user.password.retry.limit.exceed", 5);
```

---

## 8. DictUtils - 字典工具类

**用途**: 字典数据缓存和获取

### 核心方法
```java
String getDictLabel(String dictType, String dictValue)
String getDictValue(String dictType, String dictLabel)
```

**使用示例**:
```java
// 根据字典值获取标签
String label = DictUtils.getDictLabel("sys_user_sex", "0");  // "男"

// 根据字典标签获取值
String value = DictUtils.getDictValue("sys_user_sex", "男");  // "0"
```

---

## 9. LogUtils - 日志工具类

### 获取请求信息
```java
String getRequestLog(HttpServletRequest request)
```

### 记录操作日志
```java
void recordLog(OperLogModel operLog, Date startTime, Long timeMs)
```

---

## 10. PageUtils - 分页工具类

### 开启分页
```java
void startPage()
```

### 清理分页
```java
void clearPage()
```

**使用示例**:
```java
// Service 层
PageUtils.startPage();
List<SysUser> list = userMapper.selectList();
PageInfo<SysUser> pageInfo = new PageInfo<>(list);
PageUtils.clearPage();
```

---

## 11. Threads - 线程工具类

### 休眠
```java
void sleep(long milliseconds)
```

### 关闭线程池
```java
void shutdownAndAwaitTermination(ExecutorService pool)
```

### Runnable 转 Callable
```java
<T> Callable<T> callable(Runnable task, T result)
```

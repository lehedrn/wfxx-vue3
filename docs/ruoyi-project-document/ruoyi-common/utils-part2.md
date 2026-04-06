# Utils 工具类模块（下）- 功能工具类

## 12. FileUploadUtils - 文件上传工具类

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/file/FileUploadUtils.java`

**用途**: 处理文件上传，支持大小校验、类型校验、自动命名等

**常量**: `DEFAULT_MAX_SIZE` (50MB), `DEFAULT_FILE_NAME_LENGTH` (100)

**核心方法**:

| 类型 | 方法 |
|------|------|
| 文件上传 | `upload(file)`, `upload(baseDir, file)`, `upload(baseDir, file, allowedExtension)`, `upload(baseDir, file, allowedExtension, useCustomNaming)` |
| 文件名校验 | `extractFilename(file)`, `uuidFilename(file)` |
| 文件校验 | `assertAllowed(file, allowedExtension)`, `isAllowedExtension(extension, allowedExtension)`, `getExtension(file)` |
| 文件路径 | `getAbsoluteFile(uploadDir, fileName)`, `getPathFileName(uploadDir, fileName)` |

**使用示例**:
```java
@PostMapping("/upload")
public AjaxResult upload(@RequestParam("file") MultipartFile file) {
    try {
        String fileName = FileUploadUtils.upload(file);
        return AjaxResult.success(fileName);
    } catch (FileSizeLimitExceededException e) {
        return AjaxResult.error("文件大小超过限制");
    } catch (InvalidExtensionException e) {
        return AjaxResult.error("文件类型不允许");
    }
}
```

---

## 13. 文件工具类 (file 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/file/`

| 工具类 | 核心方法 |
|--------|----------|
| `FileUtils` | `downloadFile(response, fileName, realName)`, `deleteFile(absolutePath)`, `copyFile/copyDirectory(source, target)`, `checkAllowDownload(fileName)`, `getName(fileName)` |
| `FileTypeUtils` | `getFileType(file/fileName)`, `isImage(fileType)`, `isFlash(fileType)`, `isMedia(fileType)` |
| `ImageUtils` | `checkIsImage(fileName/file)`, `getImage(imageUrl)` |
| `MimeTypeUtils` | 常量：`DEFAULT_ALLOWED_EXTENSION`, `IMAGE_EXTENSION`, `FLASH_EXTENSION`, `MEDIA_EXTENSION`, `VIDEO_EXTENSION` |

---

## 14. HTML 工具类 (html 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/html/`

| 工具类 | 核心方法 |
|--------|----------|
| `EscapeUtil` | `escape(html)`, `unescape(html)`, `clean(html)` (XSS 清理) |
| `HTMLFilter` | `filter(dangerousHtml)` |

**使用示例**:
```java
// 转义
EscapeUtil.escape("<script>alert('xss')</script>")  // &lt;script&gt;alert('xss')&lt;/script&gt;

// XSS 清理
EscapeUtil.clean("<script>alert('xss')</script>test")  // test
```

---

## 15. HTTP 工具类 (http 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/http/`

| 工具类 | 核心方法 |
|--------|----------|
| `HttpUtils` | `sendGet(url/param/contentType)`, `sendPost(url, param, contentType)`, `sendSSLPost(url, param, contentType)` |
| `HttpHelper` | `getBodyString(request)` |
| `UserAgentUtils` | `getUserAgent(request)`, `getUserAgent(uaString)` |

**使用示例**:
```java
// GET 请求
String result = HttpUtils.sendGet("https://api.example.com/data");
String result = HttpUtils.sendGet("https://api.example.com/data", "key=value");

// POST 请求 (JSON)
String jsonParam = "{\"name\":\"test\"}";
String result = HttpUtils.sendPost("https://api.example.com/api", jsonParam, "application/json");
```

---

## 16. IP 工具类 (ip 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/ip/`

| 工具类 | 核心方法 |
|--------|----------|
| `AddressUtils` | `getRealAddressByIP(ip)` |
| `IpUtils` | `internalIp(ip)`, `isValidIp(ip)`, `getIpAddr(request)` |

**使用示例**:
```java
// 根据 IP 获取地址
String address = AddressUtils.getRealAddressByIP("8.8.8.8");

// 检查是否内网
boolean isInternal = IpUtils.internalIp("192.168.1.1");  // true

// 获取客户端 IP
String ip = IpUtils.getIpAddr(request);
```

---

## 17. POI 工具类 (poi 包) - Excel 处理

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/poi/`

**ExcelUtil - Excel 工具类**:

| 类型 | 方法 |
|------|------|
| 导出 | `exportExcel(list, sheetName)`, `exportExcel(os, list)`, `exportExcel(data, title)` (多 sheet) |
| 导入 | `importExcel(inputStream)`, `importExcel(filePath)` |

**注解**:
- `@ExcelSheet(name, rowNum)` - 配置 Sheet 属性
- `@Excel` - 配置列属性 (见 annotation.md)

**适配器**: `ExcelHandlerAdapter.format(value, args)` - 自定义数据处理

---

## 18. 签名工具类 (sign 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/sign/`

| 工具类 | 核心方法 |
|--------|----------|
| `Md5Utils` | `hash(s)` (MD5 加密) |
| `Base64` | `encode(data)`, `decode(data)`, `decodeToString(data)` |

**使用示例**:
```java
String md5 = Md5Utils.hash("password123");  // 4297f44b13955235245b2497399d7a93
```

---

## 19. Spring 工具类 (spring 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/spring/`

**SpringUtils**: 从 Spring 容器获取 Bean

**方法**: `getBean(requiredType)`, `getBean(name, requiredType)`, `containsBean(name)`

**使用示例**:
```java
UserService userService = SpringUtils.getBean(UserService.class);
```

---

## 20. Bean 工具类 (bean 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/bean/`

| 工具类 | 核心方法 |
|--------|----------|
| `BeanUtils` | `copyProperties(source, target)`, `describe(bean)`, `populate(map, clazz)` |
| `BeanValidators` | `validateWithException(validator, target, groups)` |

---

## 21. 反射工具类 (reflect 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/reflect/`

**ReflectUtils**:

| 方法 | 说明 |
|------|------|
| `getField(clazz, fieldName)` | 获取字段 |
| `getFieldValue(obj, fieldName)` | 获取字段值 |
| `setFieldValue(obj, fieldName, value)` | 设置字段值 |
| `invokeMethod(obj, methodName, args)` | 调用方法 |

---

## 22. SQL 工具类 (sql 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/sql/`

**SqlUtil**:

| 方法 | 说明 |
|------|------|
| `escapeOrderBySql(value)` | 过滤 SQL 注入 |
| `isSQLInjection(value)` | 检查 SQL 注入 |

**使用示例**:
```java
// 排序字段过滤
String orderBy = SqlUtil.escapeOrderBySql(userInput);
PageHelper.orderBy(orderBy);
```

---

## 23. UUID 工具类 (uuid 包)

> 源码目录：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/uuid/`

| 工具类 | 核心方法 |
|--------|----------|
| `IdUtils` | `simpleUUID()`, `fastSimpleUUID()`, `getId(seqType)` |
| `UUID` | `randomUUID()`, `simple()` |
| `Seq` | `getId(seqType)` - 获取序列 ID |

---

## 24. DesensitizedUtil - 数据脱敏工具

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/DesensitizedUtil.java`

**方法**: `password(pwd)`, `carLicense(license)`

---

## 25. DictUtils - 字典工具

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/DictUtils.java`

**方法**: `getDictLabel(dictType, dictValue)`, `getDictValue(dictType, dictLabel)`, `setDictList(dictType, list)`, `getDictList(dictType)`

---

## 最佳实践

### 1. 文件上传
```java
@PostMapping("/upload")
public AjaxResult upload(@RequestParam("file") MultipartFile file) {
    try {
        if (file.isEmpty()) {
            return AjaxResult.error("请选择文件");
        }
        String fileName = FileUploadUtils.upload(file);
        return AjaxResult.success(fileName);
    } catch (Exception e) {
        return AjaxResult.error(e.getMessage());
    }
}
```

### 2. HTTP 请求
```java
String url = "https://api.example.com/user/" + userId;
String response = HttpUtils.sendGet(url);
User user = JSON.parseObject(response, User.class);
```

### 3. IP 地址获取
```java
@Log(title = "登录日志", businessType = BusinessType.INSERT)
@PostMapping("/login")
public AjaxResult login(@RequestBody LoginBody loginBody) {
    String ip = IpUtils.getIpAddr(ServletUtils.getRequest());
    String address = AddressUtils.getRealAddressByIP(ip);
    loginService.recordLogin(username, ip, address);
}
```

### 4. MD5 加密
```java
String token = Md5Utils.hash(username + System.currentTimeMillis());
```

### 5. Excel 导出
```java
@GetMapping("/export")
public void export(SysUser user, HttpServletResponse response) {
    List<SysUser> list = userService.selectUserList(user);
    ExcelUtil<SysUser> util = new ExcelUtil<>(SysUser.class);
    util.exportExcel(response, list, "用户数据");
}
```

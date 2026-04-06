# Utils 工具类模块（下）- 功能工具类

## 12. FileUploadUtils - 文件上传工具类

**用途**: 处理文件上传，支持大小校验、类型校验、自动命名等

### 常量
```java
DEFAULT_MAX_SIZE = 50 * 1024 * 1024L           // 默认 50MB
DEFAULT_FILE_NAME_LENGTH = 100                 // 文件名最大长度
```

### 核心方法

#### 文件上传
```java
// 使用默认配置上传
String upload(MultipartFile file)

// 指定目录上传
String upload(String baseDir, MultipartFile file)

// 指定目录和类型上传
String upload(String baseDir, MultipartFile file, String[] allowedExtension)

// 指定是否自定义文件名
String upload(String baseDir, MultipartFile file, String[] allowedExtension, boolean useCustomNaming)
```

#### 文件名校验
```java
// 编码文件名（日期目录 + 原文件名 + 序列值 + 后缀）
String extractFilename(MultipartFile file)

// UUID 文件名（日期目录 + UUID + 后缀）
String uuidFilename(MultipartFile file)
```

#### 文件校验
```java
// 文件大小和类型校验
void assertAllowed(MultipartFile file, String[] allowedExtension)

// 检查扩展名是否允许
boolean isAllowedExtension(String extension, String[] allowedExtension)

// 获取文件扩展名
String getExtension(MultipartFile file)
```

#### 获取文件路径
```java
File getAbsoluteFile(String uploadDir, String fileName)
String getPathFileName(String uploadDir, String fileName)
```

**使用示例**:
```java
@PostMapping("/upload")
public AjaxResult upload(@RequestParam("file") MultipartFile file) {
    try {
        // 上传到默认目录，只允许图片
        String fileName = FileUploadUtils.upload(file);
        return AjaxResult.success(fileName);
    } catch (FileSizeLimitExceededException e) {
        return AjaxResult.error("文件大小超过限制");
    } catch (InvalidExtensionException e) {
        return AjaxResult.error("文件类型不允许");
    }
}

// 自定义类型和目录
String[] imageExtension = {"jpg", "png", "gif"};
String fileName = FileUploadUtils.upload("/upload/images", file, imageExtension);
```

---

## 13. 文件工具类 (file 包)

### FileUtils - 文件处理工具

**核心方法**:
```java
// 下载文件
void downloadFile(HttpServletResponse response, String fileName, String realName)

// 删除文件
boolean deleteFile(String absolutePath)

// 复制文件/目录
void copyFile(String source, String target)
void copyDirectory(String source, String target)

// 检查文件是否允许下载
boolean checkAllowDownload(String fileName)

// 获取文件名（去掉路径）
String getName(String fileName)
```

### FileTypeUtils - 文件类型工具

```java
// 获取文件类型
String getFileType(File file)
String getFileType(String fileName)

// 是否图片
boolean isImage(String fileType)

// 是否 Flash
boolean isFlash(String fileType)

// 是否视频
boolean isMedia(String fileType)
```

### ImageUtils - 图片工具

```java
// 检查图片
boolean checkIsImage(String fileName)
boolean checkIsImage(MultipartFile file)

// 获取图片信息
BufferedImage getImage(String imageUrl)
```

### MimeTypeUtils - MIME 类型工具

**允许的类型**:
```java
// 默认允许的类型
DEFAULT_ALLOWED_EXTENSION

// 图片
IMAGE_EXTENSION = {"bmp", "gif", "jpg", "jpeg", "png"}

// Flash
FLASH_EXTENSION = {"swf", "flv"}

// 媒体
MEDIA_EXTENSION = {"swf", "flv", "mp3", "wav", "wma", "wmv", "mid", "avi", "mpg", "asf", "rm", "rmvb"}

// 视频
VIDEO_EXTENSION = {"mp4", "avi", "rmvb", "rm", "mov", "mkv"}
```

---

## 14. HTML 工具类 (html 包)

### EscapeUtil - HTML 转义工具

**核心方法**:
```java
// HTML 转义
String escape(String html)

// HTML 反转义
String unescape(String html)

// XSS 清理（去除脚本）
String clean(String html)
```

**使用示例**:
```java
// 转义
EscapeUtil.escape("<script>alert('xss')</script>")
// 结果：&lt;script&gt;alert('xss')&lt;/script&gt;

// XSS 清理
EscapeUtil.clean("<script>alert('xss')</script>test")
// 结果：test
```

### HTMLFilter - HTML 过滤器

**用途**: 过滤 HTML 中的不安全标签

**使用示例**:
```java
HTMLFilter filter = new HTMLFilter();
String safeHtml = filter.filter(dangerousHtml);
```

---

## 15. HTTP 工具类 (http 包)

### HttpUtils - HTTP 请求工具

**发送 GET 请求**:
```java
String sendGet(String url)
String sendGet(String url, String param)
String sendGet(String url, String param, String contentType)
```

**发送 POST 请求**:
```java
String sendPost(String url, String param)
String sendPost(String url, String param, String contentType)
```

**发送 SSL POST 请求**:
```java
String sendSSLPost(String url, String param)
String sendSSLPost(String url, String param, String contentType)
```

**使用示例**:
```java
// GET 请求
String result = HttpUtils.sendGet("https://api.example.com/data");
String result = HttpUtils.sendGet("https://api.example.com/data", "key=value");

// POST 请求
String param = "name=test&value=123";
String result = HttpUtils.sendPost("https://api.example.com/submit", param);

// JSON POST
String jsonParam = "{\"name\":\"test\"}";
String result = HttpUtils.sendPost("https://api.example.com/api", jsonParam, "application/json");
```

### HttpHelper - HTTP 辅助工具

```java
// 获取请求 Body
String getBodyString(ServletRequest request)
```

### UserAgentUtils - 用户代理工具

```java
// 获取用户代理字符串
String getUserAgent(HttpServletRequest request)

// 解析浏览器信息
UserAgent getUserAgent(String userAgentString)
```

---

## 16. IP 工具类 (ip 包)

### AddressUtils - 地址查询工具

**核心方法**:
```java
String getRealAddressByIP(String ip)
```

**使用示例**:
```java
// 根据 IP 获取地址
String address = AddressUtils.getRealAddressByIP("8.8.8.8");
// 结果：美国 加利福尼亚州
```

### IpUtils - IP 工具

**核心方法**:
```java
// 是否内网 IP
boolean internalIp(String ip)

// 检查 IP 是否合法
boolean isValidIp(String ip)

// 获取客户端 IP
String getIpAddr(HttpServletRequest request)
```

**使用示例**:
```java
// 检查是否内网
boolean isInternal = IpUtils.internalIp("192.168.1.1");  // true

// 获取客户端 IP
String ip = IpUtils.getIpAddr(request);
```

---

## 17. POI 工具类 (poi 包) - Excel 处理

### ExcelUtil - Excel 工具类

**用途**: Excel 导入导出

**核心方法**:

**导出**:
```java
// 导出列表
void exportExcel(List<T> list, String sheetName)

// 导出到流
void exportExcel(OutputStream os, List<T> list)

// 导出多 sheet
void exportExcel(Map<String, List<?>> data, String title)
```

**导入**:
```java
// 从输入流导入
List<T> importExcel(InputStream inputStream)

// 从文件导入
List<T> importExcel(String filePath)
```

**使用示例**:
```java
// 导出
ExcelUtil<UserExportVO> util = new ExcelUtil<>(UserExportVO.class);
util.exportExcel(response, userList, "用户数据");

// 导入
List<UserImportVO> users = util.importExcel(inputStream);
```

### ExcelSheet - Sheet 注解

**用途**: 配置 Excel Sheet 属性

```java
@ExcelSheet(name = "用户列表", rowNum = 100)
```

### ExcelHandlerAdapter - 数据处理器适配器

**用途**: 自定义 Excel 数据处理逻辑

```java
public interface ExcelHandlerAdapter {
    String[] format(Object value, String[] args);
}
```

---

## 18. 签名工具类 (sign 包)

### Md5Utils - MD5 加密工具

**核心方法**:
```java
String hash(String s)  // MD5 加密
```

**使用示例**:
```java
String md5 = Md5Utils.hash("password123");
// 结果：4297f44b13955235245b2497399d7a93
```

### Base64 - Base64 编码工具

**核心方法**:
```java
// 编码
String encode(byte[] data)
String encode(String data)

// 解码
byte[] decode(String data)
String decodeToString(byte[] data)
```

---

## 19. Spring 工具类 (spring 包)

### SpringUtils - Spring 工具

**用途**: 从 Spring 容器获取 Bean

**核心方法**:
```java
<T> T getBean(Class<T> requiredType)
<T> T getBean(String name, Class<T> requiredType)
boolean containsBean(String name)
```

**使用示例**:
```java
// 在非 Spring 管理的类中获取 Bean
UserService userService = SpringUtils.getBean(UserService.class);
List<SysUser> list = userService.selectUserList(user);
```

---

## 20. Bean 工具类 (bean 包)

### BeanUtils - Bean 工具

**核心方法**:
```java
// Bean 复制
void copyProperties(Object source, Object target)

// Bean 转 Map
Map<String, Object> describe(Object bean)

// Map 转 Bean
<T> T populate(Map<String, Object> map, Class<T> clazz)
```

### BeanValidators - Bean 校验工具

**核心方法**:
```java
void validateWithException(Validator validator, Object target, Class<?>... groups)
```

---

## 21. 反射工具类 (reflect 包)

### ReflectUtils - 反射工具

**核心方法**:
```java
// 获取字段
Field getField(Class<?> clazz, String fieldName)

// 获取字段值
Object getFieldValue(Object obj, String fieldName)

// 设置字段值
void setFieldValue(Object obj, String fieldName, Object value)

// 调用方法
Object invokeMethod(Object obj, String methodName, Object... args)
```

---

## 22. SQL 工具类 (sql 包)

### SqlUtil - SQL 工具

**核心方法**:
```java
// 过滤 SQL 注入
String escapeOrderBySql(String value)

// 检查 SQL 注入
boolean isSQLInjection(String value)
```

**使用示例**:
```java
// 排序字段过滤
String orderBy = SqlUtil.escapeOrderBySql(userInput);
PageHelper.orderBy(orderBy);
```

---

## 23. UUID 工具类 (uuid 包)

### IdUtils - ID 工具

**核心方法**:
```java
// 简单 UUID（无横杠）
String simpleUUID()

// 快速 UUID
String fastSimpleUUID()

// 序列 ID
String getId(SeqType type)
```

**使用示例**:
```java
String uuid = IdUtils.fastSimpleUUID();  // 32 位无横杠 UUID
String seqId = IdUtils.getId(Seq.uploadSeqType);  // 上传序列 ID
```

### UUID - UUID 生成器

```java
// 生成 UUID
String randomUUID()

// 生成简单 UUID
String simple()
```

### Seq - 序列生成器

```java
// 获取序列 ID
String getId(SeqType seqType)
```

---

## 24. DesensitizedUtil - 数据脱敏工具

**核心方法**:
```java
// 密码脱敏
String password(String pwd)

// 车牌脱敏
String carLicense(String license)
```

---

## 25. DictUtils - 字典工具

**核心方法**:
```java
// 根据字典值获取标签
String getDictLabel(String dictType, String dictValue)

// 根据字典标签获取值
String getDictValue(String dictType, String dictLabel)

// 设置字典
void setDictList(String dictType, List<DictData> list)

// 获取字典
List<DictData> getDictList(String dictType)
```

**使用示例**:
```java
// 获取字典标签
String sexLabel = DictUtils.getDictLabel("sys_user_sex", "0");  // "男"

// 导出时使用
@Excel(name = "性别", readConverterExp = "0=男，1=女")
private String sex;
```

---

## 最佳实践

### 1. 文件上传
```java
@PostMapping("/upload")
public AjaxResult upload(@RequestParam("file") MultipartFile file) {
    try {
        // 校验文件
        if (file.isEmpty()) {
            return AjaxResult.error("请选择文件");
        }
        
        // 上传
        String fileName = FileUploadUtils.upload(file);
        return AjaxResult.success(fileName);
    } catch (Exception e) {
        return AjaxResult.error(e.getMessage());
    }
}
```

### 2. HTTP 请求
```java
// 调用外部 API
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
    
    // 记录登录日志
    loginService.recordLogin(username, ip, address);
}
```

### 4. MD5 加密
```java
// 生成令牌
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

### 6. 字符串工具
```java
// 链式调用
if (StringUtils.isNotEmpty(userName) && 
    StringUtils.hasText(userName) &&
    !StringUtils.containsAny(userName, "<", ">", "'")) {
    // 处理用户名
}
```

### 7. 日期工具
```java
// 获取当前时间
String now = DateUtils.dateTimeNow();

// 格式化日期
String formatted = DateUtils.parseDateToStr("yyyy-MM-dd", new Date());

// 计算天数
int days = DateUtils.differentDaysByMillisecond(date1, date2);
```

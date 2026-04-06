# Config 配置模块

## 概述

`ruoyi-common/config` 包提供了 RuoYi 框架的配置类，用于读取和管理项目的全局配置信息。

## 配置类列表

### 1. RuoYiConfig - 项目配置类

**用途**: 读取 `application.yml` 或 `application.properties` 中配置的若依项目相关参数

**配置前缀**: `ruoyi`

**属性**:
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| name | String | 项目名称 | 若依 |
| version | String | 版本 | 3.9.2 |
| copyrightYear | String | 版权年份 | 2024 |
| profile | String | 上传路径（静态） | /home/ruoyi/upload |
| addressEnabled | boolean | 获取地址开关（静态） | true |
| captchaType | String | 验证码类型（静态） | math |

**静态方法**:
```java
// 获取上传路径
String getProfile()

// 是否启用地址获取
boolean isAddressEnabled()

// 获取验证码类型
String getCaptchaType()

// 获取导入路径
String getImportPath()

// 获取头像上传路径
String getAvatarPath()

// 获取下载路径
String getDownloadPath()

// 获取上传路径
String getUploadPath()
```

**配置示例** (application.yml):
```yaml
ruoyi:
  name: 若依
  version: 3.9.2
  copyrightYear: 2024
  profile: /home/ruoyi/upload
  addressEnabled: true
  captchaType: math
```

**使用示例**:
```java
// 获取上传目录
String uploadDir = RuoYiConfig.getProfile();

// 获取头像路径
String avatarPath = RuoYiConfig.getAvatarPath();

// 检查是否启用地址查询
if (RuoYiConfig.isAddressEnabled()) {
    String address = AddressUtils.getRealAddressByIP(ip);
}

// 获取验证码类型
String captchaType = RuoYiConfig.getCaptchaType();  // "math" 或 "char"
```

---

### 2. SensitiveJsonSerializer - 敏感数据序列化器

**用途**: Jackson 序列化器，用于处理 `@Sensitive` 注解的字段脱敏

**核心逻辑**:
```java
public class SensitiveJsonSerializer extends JsonSerializer<String> 
        implements ContextualSerializer {
    
    private DesensitizedType desensitizedType;
    
    @Override
    public void serialize(String value, JsonGenerator gen, 
                         SerializerProvider serializers) throws IOException {
        if (desensitization()) {
            // 执行脱敏
            gen.writeString(desensitizedType.desensitizer().apply(value));
        } else {
            // 不脱敏，返回原值
            gen.writeString(value);
        }
    }
    
    /**
     * 是否需要脱敏处理
     */
    private boolean desensitization() {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            // 管理员不脱敏
            return !loginUser.getUser().isAdmin();
        } catch (Exception e) {
            return true;
        }
    }
}
```

**特性**:
- 管理员用户查看所有原始数据（不脱敏）
- 普通用户查看脱敏数据
- 无登录状态时默认脱敏

**使用示例**:
```java
public class UserVO {
    @Sensitive(desensitizedType = DesensitizedType.PHONE)
    private String phone;
    
    // 管理员查看：13812341234
    // 普通用户查看：138****1234
}
```

---

## 配置文件说明

### application.yml 完整配置

```yaml
# 若依配置
ruoyi:
  # 项目名称
  name: 若依
  # 版本
  version: 3.9.2
  # 版权年份
  copyrightYear: 2024
  # 上传路径（绝对路径）
  profile: /home/ruoyi/upload
  # 是否启用地址查询
  addressEnabled: true
  # 验证码类型 (math 数字计算 char 字符验证)
  captchaType: math

# Spring 配置
spring:
  # 数据源配置
  datasource:
    dynamic:
      enabled: true  # 是否启用多数据源
      primary: MASTER  # 默认数据源
      
  # Redis 配置
  redis:
    host: localhost
    port: 6379
    password: 
    database: 0
    
  # 文件上传配置
  servlet:
    multipart:
      max-file-size: 50MB
      max-request-size: 50MB
```

---

## 配置使用场景

### 1. 文件上传路径配置

```java
// 文件上传工具类使用
public class FileUploadUtils {
    private static String defaultBaseDir = RuoYiConfig.getProfile();
    
    public static String upload(MultipartFile file) {
        return upload(getDefaultBaseDir(), file);
    }
}
```

### 2. 头像上传

```java
@PostMapping("/avatar")
public AjaxResult updateAvatar(@RequestParam MultipartFile file) {
    // 头像保存路径：/home/ruoyi/upload/avatar/
    String avatarPath = RuoYiConfig.getAvatarPath();
    String fileName = FileUploadUtils.upload(avatarPath, file);
    return AjaxResult.success(fileName);
}
```

### 3. IP 地址查询开关

```java
public class AddressUtils {
    public static String getRealAddressByIP(String ip) {
        // 内网不查询
        if (IpUtils.internalIp(ip)) {
            return "内网 IP";
        }
        // 根据配置决定是否查询
        if (RuoYiConfig.isAddressEnabled()) {
            // 查询逻辑
        }
        return UNKNOWN;
    }
}
```

### 4. 验证码类型配置

```java
@GetMapping("/captchaImage")
public AjaxResult getCaptchaImg() throws IOException {
    String type = RuoYiConfig.getCaptchaType();
    
    if ("math".equals(type)) {
        // 数字计算验证码
        return createMathCaptcha();
    } else {
        // 字符验证码
        return createCharCaptcha();
    }
}
```

---

## 注意事项

1. **profile 路径**: 生产环境建议配置到独立的磁盘分区，避免占用应用空间
2. **地址查询**: 地址查询依赖外部 API，生产环境根据需要开启
3. **验证码类型**: 修改验证码类型后需要重启应用
4. **静态属性**: `profile`、`addressEnabled`、`captchaType` 是静态属性，通过 setter 注入

---

## 相关配置类

除了 `RuoYiConfig`，项目还可能包含以下配置类（根据项目实际需求）：

- **JwtConfig** - JWT Token 配置
- **SecurityConfig** - Spring Security 安全配置
- **CaptchaConfig** - 验证码配置
- **MybatisPlusConfig** - MyBatis-Plus 配置
- **ThreadPoolConfig** - 线程池配置

这些配置类通常位于主项目的 `config` 包中，而不是 `ruoyi-common` 模块。

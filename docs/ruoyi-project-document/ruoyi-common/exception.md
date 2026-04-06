# Exception 异常模块

## 概述

`ruoyi-common/exception` 包提供了 RuoYi 框架的异常处理体系，用于统一处理业务异常和系统异常。

## 异常体系结构

```
exception/
├── base/
│   └── BaseException           # 基础异常（国际化支持）
├── user/
│   ├── UserException           # 用户异常基类
│   ├── UserNotExistsException  # 用户不存在
│   ├── UserPasswordNotMatchException # 密码不匹配
│   ├── UserPasswordRetryLimitExceedException # 密码重试超限
│   ├── CaptchaException        # 验证码错误
│   ├── CaptchaExpireException  # 验证码过期
│   └── BlackListException      # 黑名单异常
├── file/
│   ├── FileException           # 文件异常基类
│   ├── FileSizeLimitExceededException # 文件大小超限
│   ├── FileNameLengthLimitExceededException # 文件名长度超限
│   ├── InvalidExtensionException # 文件类型无效
│   └── FileUploadException     # 文件上传异常
├── job/
│   └── TaskException           # 任务异常
├── GlobalException             # 全局异常
├── ServiceException          # 业务异常
├── UtilException             # 工具类异常
└── DemoModeException         # 演示模式异常
```

---

## 核心异常类

### 1. BaseException - 基础异常

**用途**: 支持国际化的基础异常类

**属性**:
```java
String module;            // 所属模块（如：user, file）
String code;              // 错误码（用于国际化消息查找）
Object[] args;            // 错误码对应的参数
String defaultMessage;    // 默认错误消息
```

**构造方法**:
```java
BaseException(String module, String code, Object[] args, String defaultMessage)
BaseException(String module, String code, Object[] args)
BaseException(String module, String defaultMessage)
BaseException(String code, Object[] args)
BaseException(String defaultMessage)
```

**方法**:
```java
String getMessage()       // 获取消息（支持国际化）
String getModule()        // 获取模块
String getCode()          // 获取错误码
Object[] getArgs()        // 获取参数
String getDefaultMessage() // 获取默认消息
```

**原理**:
```java
@Override
public String getMessage() {
    String message = null;
    if (!StringUtils.isEmpty(code)) {
        // 通过 MessageUtils 查找国际化消息
        message = MessageUtils.message(code, args);
    }
    if (message == null) {
        // 找不到则使用默认消息
        message = defaultMessage;
    }
    return message;
}
```

---

### 2. ServiceException - 业务异常

**用途**: 业务逻辑异常，最常用

**属性**:
```java
Integer code;           // 错误码
String message;         // 错误提示
String detailMessage;   // 详细错误消息（调试用）
```

**构造方法**:
```java
ServiceException()                              // 空构造
ServiceException(String message)                // 消息
ServiceException(String message, Integer code)  // 消息 + 错误码
```

**方法**:
```java
String getMessage()                           // 获取消息
Integer getCode()                             // 获取错误码
String getDetailMessage()                     // 获取详细消息
ServiceException setMessage(String message)   // 设置消息
ServiceException setDetailMessage(String msg) // 设置详细消息
```

**使用示例**:
```java
// 抛出业务异常
throw new ServiceException("用户不存在");

// 带错误码
throw new ServiceException("余额不足", 400);

// 链式调用
throw new ServiceException()
    .setMessage("操作失败")
    .setCode(500)
    .setDetailMessage("数据库连接超时");
```

---

### 3. GlobalException - 全局异常

**用途**: 系统级全局异常

**属性**:
```java
String message;           // 错误提示
String detailMessage;     // 详细错误消息
```

**构造方法**:
```java
GlobalException()                    // 空构造
GlobalException(String message)      // 消息
```

**方法**:
```java
String getMessage()                              // 获取消息
String getDetailMessage()                        // 获取详细消息
GlobalException setMessage(String message)       // 设置消息
GlobalException setDetailMessage(String msg)     // 设置详细消息
```

**使用示例**:
```java
// 系统级异常
throw new GlobalException("系统内部错误");

// 带详细信息
throw new GlobalException("配置加载失败")
    .setDetailMessage("配置文件不存在：config.yml");
```

---

### 4. UtilException - 工具类异常

**用途**: 工具类执行异常

**使用示例**:
```java
// 工具类执行失败
throw new UtilException("文件读取失败：" + filePath);
```

---

## 用户异常体系

所有用户异常都继承自 `UserException`，模块标识为 `"user"`。

### UserException - 用户异常基类

```java
public class UserException extends BaseException {
    public UserException(String code, Object[] args) {
        super("user", code, args, null);
    }
}
```

### UserNotExistsException - 用户不存在

```java
// 抛出异常
throw new UserNotExistsException();

// 国际化消息 key: user.not.exists
```

### UserPasswordNotMatchException - 密码不匹配

```java
// 抛出异常
throw new UserPasswordNotMatchException();

// 国际化消息 key: user.password.not.match
```

### UserPasswordRetryLimitExceedException - 密码重试超限

**属性**:
```java
int retryLimitCount;    // 最大尝试次数
int lockTime;           // 锁定时间（分钟）
```

**构造方法**:
```java
UserPasswordRetryLimitExceedException(int retryLimitCount, int lockTime)
```

**使用示例**:
```java
// 抛出异常：5 次重试，锁定 10 分钟
throw new UserPasswordRetryLimitExceedException(5, 10);

// 国际化消息 key: user.password.retry.limit.exceed
// 消息参数：{retryLimitCount, lockTime}
```

### CaptchaException - 验证码错误

```java
// 抛出异常
throw new CaptchaException();

// 国际化消息 key: user.jcaptcha.error
```

### CaptchaExpireException - 验证码过期

```java
// 抛出异常
throw new CaptchaExpireException();

// 国际化消息 key: user.jcaptcha.expire
```

### BlackListException - 黑名单限制

```java
// 抛出异常
throw new BlackListException();

// 国际化消息 key: user.blocklist
```

---

## 文件异常体系

所有文件异常都继承自 `FileException`，模块标识为 `"file"`。

### FileException - 文件异常基类

```java
public class FileException extends BaseException {
    public FileException(String code, Object[] args) {
        super("file", code, args, null);
    }
}
```

### FileSizeLimitExceededException - 文件大小超限

**属性**:
```java
long maxSize;  // 最大允许大小
```

**使用示例**:
```java
long maxSize = 10 * 1024 * 1024;  // 10MB
throw new FileSizeLimitExceededException(maxSize);
```

### FileNameLengthLimitExceededException - 文件名长度超限

**属性**:
```java
int maxLength;  // 最大允许长度
```

**使用示例**:
```java
int maxLength = 64;
throw new FileNameLengthLimitExceededException(maxLength);
```

### InvalidExtensionException - 文件类型无效

**属性**:
```java
String[] allowedExtension;  // 允许的文件类型
String extension;           // 实际文件类型
MimeTypeType type;          // 文件类型类别
```

**使用示例**:
```java
String[] allowed = {"jpg", "png", "gif"};
throw new InvalidExtensionException(allowed, "exe", MimeTypeType.IMAGE);
```

### FileUploadException - 文件上传异常

```java
// 抛出异常
throw new FileUploadException();
```

---

## 任务异常

### TaskException - 定时任务异常

**属性**:
```java
Code code;    // 错误代码枚举
```

**Code 枚举**:
```java
TASK_EXISTS,              // 任务已存在
NO_TASK_EXISTS,           // 任务不存在
TASK_ALREADY_STARTED,     // 任务已启动
UNKNOWN,                  // 未知异常
CONFIG_ERROR,             // 配置错误
TASK_NODE_NOT_AVAILABLE   // 任务节点不可用
```

---

## 演示模式异常

### DemoModeException - 演示模式异常

**用途**: 演示环境下禁止某些操作

**使用示例**:
```java
@Aspect
@Component
public class DemoModeAspect {
    @Around("@annotation(demoMode)")
    public Object around(ProceedingJoinPoint point, DemoMode demoMode) throws Throwable {
        String value = demoMode.value();
        throw new DemoModeException(value);
    }
}

// 使用
@DemoMode
@PostMapping("/user")
public AjaxResult add(@RequestBody SysUser user) {
    // 演示模式下会抛出 DemoModeException
}
```

---

## 全局异常处理

RuoYi 框架通过全局异常处理器统一处理所有异常：

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    // 处理基础异常（国际化）
    @ExceptionHandler(BaseException.class)
    public AjaxResult handleBaseException(BaseException e) {
        return AjaxResult.error(e.getMessage());
    }

    // 处理业务异常
    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e) {
        return AjaxResult.error(e.getCode(), e.getMessage());
    }

    // 处理演示模式异常
    @ExceptionHandler(DemoModeException.class)
    public AjaxResult handleDemoModeException(DemoModeException e) {
        return AjaxResult.error(e.getMessage());
    }

    // 处理系统异常
    @ExceptionHandler(Exception.class)
    public AjaxResult handleException(Exception e) {
        log.error(e.getMessage(), e);
        return AjaxResult.error("服务器内部错误");
    }
}
```

---

## 使用示例

### 1. 服务层异常处理

```java
@Service
public class UserServiceImpl implements UserService {
    
    @Autowired
    private UserMapper userMapper;
    
    @Override
    public SysUser selectUserById(Long userId) {
        SysUser user = userMapper.selectUserById(userId);
        if (user == null) {
            throw new UserNotExistsException();
        }
        return user;
    }
    
    @Override
    public int insertUser(SysUser user) {
        // 检查用户名是否存在
        if (!checkUserNameUnique(user)) {
            throw new ServiceException("新增用户失败，用户名已存在");
        }
        
        // 检查手机号是否存在
        if (!checkPhoneUnique(user)) {
            throw new ServiceException("新增用户失败，手机号已存在");
        }
        
        // 检查邮箱是否存在
        if (!checkEmailUnique(user)) {
            throw new ServiceException("新增用户失败，邮箱已存在");
        }
        
        return userMapper.insertUser(user);
    }
    
    @Override
    public String loginUser(String username, String password) {
        // 检查用户是否存在
        SysUser user = userMapper.selectUserByUserName(username);
        if (user == null) {
            throw new UserNotExistsException();
        }
        
        // 检查用户是否停用
        if (UserConstants.USER_DISABLE.equals(user.getStatus())) {
            throw new UserBlockedException();
        }
        
        // 验证密码
        if (!SecurityUtils.matchesPassword(password, user.getPassword())) {
            // 记录密码错误次数
            incrementPasswordErrorCount(username);
            throw new UserPasswordNotMatchException();
        }
        
        // 清除密码错误次数
        clearPasswordErrorCount(username);
        
        // 生成 Token
        return tokenService.createToken(user);
    }
}
```

### 2. 文件上传异常处理

```java
public class FileUploadUtils {
    
    public static final String upload(String baseDir, MultipartFile file) 
            throws IOException {
        
        // 检查文件大小
        if (file.getSize() > DEFAULT_FILE_SIZE) {
            throw new FileSizeLimitExceededException(DEFAULT_FILE_SIZE / 1024 / 1024);
        }
        
        // 检查文件扩展名
        String extension = getExtension(file);
        if (!isAllowedExtension(extension)) {
            throw new InvalidExtensionException(
                DEFAULT_ALLOWED_EXTENSION, extension, null);
        }
        
        // 检查文件名长度
        String fileName = file.getOriginalFilename();
        if (fileName.length() > DEFAULT_FILE_NAME_LENGTH) {
            throw new FileNameLengthLimitExceededException(DEFAULT_FILE_NAME_LENGTH);
        }
        
        // 保存文件
        File dest = new File(baseDir + "/" + fileName);
        file.transferTo(dest);
        
        return getFileAbsolutePath(dest);
    }
}
```

### 3. 控制器层异常处理

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    
    @Autowired
    private SysUserService userService;
    
    @GetMapping("/{userId}")
    public AjaxResult getUser(@PathVariable Long userId) {
        try {
            SysUser user = userService.selectUserById(userId);
            return AjaxResult.success(user);
        } catch (UserNotExistsException e) {
            return AjaxResult.error("用户不存在");
        } catch (Exception e) {
            return AjaxResult.error("获取用户失败：" + e.getMessage());
        }
    }
    
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        // 全局异常处理器会捕获 ServiceException
        return toAjax(userService.insertUser(user));
    }
}
```

---

## 最佳实践

1. **选择合适的异常类型**:
   - 业务逻辑异常使用 `ServiceException`
   - 用户相关异常使用 `UserException` 子类
   - 文件相关异常使用 `FileException` 子类
   - 系统级异常使用 `GlobalException`

2. **使用国际化**: 继承 `BaseException` 支持国际化消息

3. **提供详细信息**: 使用 `detailMessage` 提供调试信息

4. **不要吞掉异常**: 捕获异常后要么处理，要么重新抛出

5. **避免滥用异常**: 异常应该用于异常情况，而不是流程控制

6. **记录异常日志**: 在异常处理器中记录完整堆栈信息

7. **统一错误码**: 使用统一的错误码规范，便于前端处理

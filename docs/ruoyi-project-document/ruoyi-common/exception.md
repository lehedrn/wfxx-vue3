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

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/base/BaseException.java`

**用途**: 支持国际化的基础异常类

**属性**: `module` (所属模块), `code` (错误码), `args` (参数), `defaultMessage` (默认消息)

**构造方法**:
```java
BaseException(String module, String code, Object[] args, String defaultMessage)
BaseException(String module, String code, Object[] args)
BaseException(String module, String defaultMessage)
BaseException(String code, Object[] args)
BaseException(String defaultMessage)
```

**原理**: 通过 `MessageUtils.message(code, args)` 查找国际化消息，找不到则使用默认消息

---

### 2. ServiceException - 业务异常

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/ServiceException.java`

**用途**: 业务逻辑异常，最常用

**属性**: `code` (错误码), `message` (错误提示), `detailMessage` (详细错误消息)

**构造方法**:
```java
ServiceException()                              // 空构造
ServiceException(String message)                // 消息
ServiceException(String message, Integer code)  // 消息 + 错误码
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

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/GlobalException.java`

**用途**: 系统级全局异常

**属性**: `message`, `detailMessage`

**构造方法**: `GlobalException()`, `GlobalException(String message)`

---

### 4. UtilException - 工具类异常

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/UtilException.java`

**用途**: 工具类执行异常

**使用示例**:
```java
// 工具类执行失败
throw new UtilException("文件读取失败：" + filePath);
```

---

## 用户异常体系

> 所有用户异常都继承自 `UserException`，模块标识为 `"user"`  
> 源码目录：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/user/`

| 异常类 | 说明 | 国际化消息 key |
|--------|------|---------------|
| `UserNotExistsException` | 用户不存在 | `user.not.exists` |
| `UserPasswordNotMatchException` | 密码不匹配 | `user.password.not.match` |
| `UserPasswordRetryLimitExceedException` | 密码重试超限 | `user.password.retry.limit.exceed` |
| `CaptchaException` | 验证码错误 | `user.jcaptcha.error` |
| `CaptchaExpireException` | 验证码过期 | `user.jcaptcha.expire` |
| `BlackListException` | 黑名单限制 | `user.blocklist` |

### UserPasswordRetryLimitExceedException

**属性**: `retryLimitCount` (最大尝试次数), `lockTime` (锁定时间/分钟)

**构造方法**: `UserPasswordRetryLimitExceedException(int retryLimitCount, int lockTime)`

**使用示例**:
```java
// 5 次重试，锁定 10 分钟
throw new UserPasswordRetryLimitExceedException(5, 10);
```

---

## 文件异常体系

> 所有文件异常都继承自 `FileException`，模块标识为 `"file"`  
> 源码目录：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/file/`

| 异常类 | 说明 | 属性 |
|--------|------|------|
| `FileSizeLimitExceededException` | 文件大小超限 | `maxSize` |
| `FileNameLengthLimitExceededException` | 文件名长度超限 | `maxLength` |
| `InvalidExtensionException` | 文件类型无效 | `allowedExtension`, `extension`, `type` |
| `FileUploadException` | 文件上传异常 | - |

**使用示例**:
```java
// 文件大小超限 (10MB)
throw new FileSizeLimitExceededException(10 * 1024 * 1024);

// 文件名长度超限 (64 字符)
throw new FileNameLengthLimitExceededException(64);

// 文件类型无效
throw new InvalidExtensionException(new String[]{"jpg", "png"}, "exe", null);
```

---

## 任务异常

### TaskException - 定时任务异常

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/job/TaskException.java`

**Code 枚举**: `TASK_EXISTS`, `NO_TASK_EXISTS`, `TASK_ALREADY_STARTED`, `UNKNOWN`, `CONFIG_ERROR`, `TASK_NODE_NOT_AVAILABLE`

---

## 演示模式异常

### DemoModeException - 演示模式异常

> 源码：`ruoyi-common/exception/src/main/java/com/ruoyi/common/exception/DemoModeException.java`

**用途**: 演示环境下禁止某些操作

**使用示例**:
```java
@Aspect
@Component
public class DemoModeAspect {
    @Around("@annotation(demoMode)")
    public Object around(ProceedingJoinPoint point, DemoMode demoMode) throws Throwable {
        throw new DemoModeException(demoMode.value());
    }
}
```

---

## 全局异常处理

> 源码：`ruoyi-admin/src/main/java/com/ruoyi/web/core/exception/GlobalExceptionHandler.java`

RuoYi 框架通过全局异常处理器统一处理所有异常：

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseException.class)
    public AjaxResult handleBaseException(BaseException e) {
        return AjaxResult.error(e.getMessage());
    }

    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e) {
        return AjaxResult.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(DemoModeException.class)
    public AjaxResult handleDemoModeException(DemoModeException e) {
        return AjaxResult.error(e.getMessage());
    }

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
        if (!checkUserNameUnique(user)) {
            throw new ServiceException("新增用户失败，用户名已存在");
        }
        return userMapper.insertUser(user);
    }
    
    @Override
    public String loginUser(String username, String password) {
        SysUser user = userMapper.selectUserByUserName(username);
        if (user == null) {
            throw new UserNotExistsException();
        }
        if (UserConstants.USER_DISABLE.equals(user.getStatus())) {
            throw new UserBlockedException();
        }
        if (!SecurityUtils.matchesPassword(password, user.getPassword())) {
            incrementPasswordErrorCount(username);
            throw new UserPasswordNotMatchException();
        }
        return tokenService.createToken(user);
    }
}
```

### 2. 文件上传异常处理

> 完整实现见源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/file/FileUploadUtils.java`

```java
public class FileUploadUtils {
    public static String upload(String baseDir, MultipartFile file) throws IOException {
        // 检查文件大小
        if (file.getSize() > DEFAULT_FILE_SIZE) {
            throw new FileSizeLimitExceededException(DEFAULT_FILE_SIZE / 1024 / 1024);
        }
        // 检查文件扩展名
        String extension = getExtension(file);
        if (!isAllowedExtension(extension)) {
            throw new InvalidExtensionException(DEFAULT_ALLOWED_EXTENSION, extension, null);
        }
        // 检查文件名长度
        String fileName = file.getOriginalFilename();
        if (fileName.length() > DEFAULT_FILE_NAME_LENGTH) {
            throw new FileNameLengthLimitExceededException(DEFAULT_FILE_NAME_LENGTH);
        }
        file.transferTo(new File(baseDir + "/" + fileName));
        return getFileAbsolutePath(dest);
    }
}
```

### 3. 控制器层异常处理

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    
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

# Exception 全局异常处理模块

## 概述

`ruoyi-framework/web/exception` 包提供全局异常处理器，用于统一捕获和处理系统中的各类异常，保证系统的稳定性和用户体验。

## 模块结构

```
exception/
└── GlobalExceptionHandler.java    # 全局异常处理器
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/exception/GlobalExceptionHandler.java`

---

## GlobalExceptionHandler - 全局异常处理器

**用途**: 统一处理 Controller 层抛出的各类异常，返回标准化的错误响应

**核心逻辑**:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    /**
     * 业务异常 - 可指定错误码
     */
    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e, HttpServletRequest request) {
        log.error(e.getMessage(), e);
        Integer code = e.getCode();
        return StringUtils.isNotNull(code) 
            ? AjaxResult.error(code, e.getMessage()) 
            : AjaxResult.error(e.getMessage());
    }
    
    /**
     * 权限校验异常
     */
    @ExceptionHandler(AccessDeniedException.class)
    public AjaxResult handleAccessDeniedException(AccessDeniedException e, 
                                                  HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',权限校验失败'{}'", requestURI, e.getMessage());
        return AjaxResult.error(HttpStatus.FORBIDDEN, "没有权限，请联系管理员授权");
    }
    
    /**
     * 参数校验失败 - 返回第一个错误消息
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public AjaxResult handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        log.error(e.getMessage(), e);
        String message = e.getBindingResult().getFieldError().getDefaultMessage();
        return AjaxResult.error(message);
    }
    
    // 其他异常处理方法：RuntimeException、BindException、DemoModeException 等
}
```

**处理的异常类型**:

| 异常类型 | HTTP 状态码 | 说明 |
|---------|------------|------|
| AccessDeniedException | 403 | 权限不足 |
| HttpRequestMethodNotSupportedException | 405 | 请求方法不支持 |
| ServiceException | 500 | 业务异常 |
| MissingPathVariableException | 400 | 路径变量缺失 |
| MethodArgumentTypeMismatchException | 400 | 参数类型不匹配 |
| RuntimeException | 500 | 运行时异常 |
| Exception | 500 | 系统异常 |
| BindException | 400 | 参数绑定异常 |
| MethodArgumentNotValidException | 400 | 参数校验失败 |
| DemoModeException | 500 | 演示模式限制 |

---

## 业务异常 ServiceException

**源码位置**: `ruoyi-common/exception/ServiceException.java`

**用法**:

```java
// 默认 500 错误码
throw new ServiceException("用户不存在");

// 指定错误码
throw new ServiceException("用户不存在", 404);
throw new ServiceException("参数错误", 400);
```

---

## 使用示例

### Service 层抛出异常

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    @Override
    public SysUser selectUserById(Long userId) {
        SysUser user = userMapper.selectUserById(userId);
        if (user == null) {
            throw new ServiceException("用户不存在", 404);
        }
        return user;
    }
    
    @Override
    public int updateUser(SysUser user) {
        SysUser existUser = userMapper.selectUserByUserName(user.getUserName());
        if (existUser != null && !existUser.getUserId().equals(user.getUserId())) {
            throw new ServiceException("用户名已存在", 400);
        }
        return userMapper.updateUser(user);
    }
}
```

### Controller 层参数校验

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    /**
     * 新增用户 - @Validated 校验失败自动处理
     */
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user) {
        return toAjax(userService.insertUser(user));
    }
}
```

### 参数校验注解

```java
public class SysUser {
    
    @NotBlank(message = "用户名不能为空", groups = { Create.class, Update.class })
    @Size(min = 2, max = 20, message = "用户名长度必须在 2-20 之间")
    public String getUserName() { ... }
    
    @NotBlank(message = "密码不能为空", groups = { Create.class })
    @Size(min = 5, max = 20, message = "密码长度必须在 5-20 之间")
    public String getPassword() { ... }
    
    @Email(message = "邮箱格式不正确", groups = { Create.class, Update.class })
    public String getEmail() { ... }
}
```

---

## 标准错误响应格式

```json
{
    "code": 403,
    "msg": "没有权限，请联系管理员授权",
    "data": null
}
```

**常见错误码**:

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 参数错误/校验失败 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 405 | 请求方法不支持 |
| 500 | 系统内部错误 |

---

## 最佳实践

1. **异常分类**: 业务异常返回具体提示，系统异常返回通用错误
2. **日志记录**: 所有异常必须记录日志，系统异常记录完整堆栈
3. **安全考虑**: 不将 SQL、堆栈等敏感信息返回给前端
4. **参数校验**: 使用 `@Validated` 进行参数校验，统一处理校验失败
5. **异常包装**: 底层异常包装成业务异常再抛出

---

## 注意事项

1. `ServiceException` 的 `code` 属性可为 null，需要判断
2. `BindException` 和 `MethodArgumentNotValidException` 只返回第一个错误消息
3. 演示模式异常仅在 demo 环境下抛出

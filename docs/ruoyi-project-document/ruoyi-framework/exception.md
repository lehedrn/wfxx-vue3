# Exception 全局异常处理模块

## 概述

`ruoyi-framework/web/exception` 包提供了全局异常处理器，用于统一捕获和处理系统中的各类异常，保证系统的稳定性和用户体验。

## 模块结构

```
exception/
└── GlobalExceptionHandler.java    # 全局异常处理器
```

---

## GlobalExceptionHandler - 全局异常处理器

**用途**: 统一处理 Controller 层抛出的各类异常，返回标准化的错误响应

**核心实现**:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    /**
     * 权限校验异常 (AccessDeniedException)
     */
    @ExceptionHandler(AccessDeniedException.class)
    public AjaxResult handleAccessDeniedException(AccessDeniedException e, 
                                                  HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',权限校验失败'{}'", requestURI, e.getMessage());
        return AjaxResult.error(HttpStatus.FORBIDDEN, "没有权限，请联系管理员授权");
    }
    
    /**
     * 请求方式不支持 (HttpRequestMethodNotSupportedException)
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public AjaxResult handleHttpRequestMethodNotSupported(
            HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',不支持'{}'请求", requestURI, e.getMethod());
        return AjaxResult.error(e.getMessage());
    }
    
    /**
     * 业务异常 (ServiceException)
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
     * 请求路径中缺少必需的路径变量 (MissingPathVariableException)
     */
    @ExceptionHandler(MissingPathVariableException.class)
    public AjaxResult handleMissingPathVariableException(
            MissingPathVariableException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求路径中缺少必需的路径变量'{}',发生系统异常.", requestURI, e);
        return AjaxResult.error(
            String.format("请求路径中缺少必需的路径变量 [%s]", e.getVariableName())
        );
    }
    
    /**
     * 请求参数类型不匹配 (MethodArgumentTypeMismatchException)
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public AjaxResult handleMethodArgumentTypeMismatchException(
            MethodArgumentTypeMismatchException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        String value = Convert.toStr(e.getValue());
        if (StringUtils.isNotEmpty(value)) {
            value = EscapeUtil.clean(value);
        }
        log.error("请求参数类型不匹配'{}',发生系统异常.", requestURI, e);
        return AjaxResult.error(String.format(
            "请求参数类型不匹配，参数 [%s] 要求类型为：'%s'，但输入值为：'%s'", 
            e.getName(), e.getRequiredType().getName(), value
        ));
    }
    
    /**
     * 未知的运行时异常 (RuntimeException)
     */
    @ExceptionHandler(RuntimeException.class)
    public AjaxResult handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',发生未知异常.", requestURI, e);
        return AjaxResult.error(e.getMessage());
    }
    
    /**
     * 系统异常 (Exception)
     */
    @ExceptionHandler(Exception.class)
    public AjaxResult handleException(Exception e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',发生系统异常.", requestURI, e);
        return AjaxResult.error(e.getMessage());
    }
    
    /**
     * 自定义验证异常 (BindException)
     */
    @ExceptionHandler(BindException.class)
    public AjaxResult handleBindException(BindException e) {
        log.error(e.getMessage(), e);
        String message = e.getAllErrors().get(0).getDefaultMessage();
        return AjaxResult.error(message);
    }
    
    /**
     * 自定义验证异常 (MethodArgumentNotValidException)
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public AjaxResult handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        log.error(e.getMessage(), e);
        String message = e.getBindingResult().getFieldError().getDefaultMessage();
        return AjaxResult.error(message);
    }
    
    /**
     * 演示模式异常 (DemoModeException)
     */
    @ExceptionHandler(DemoModeException.class)
    public AjaxResult handleDemoModeException(DemoModeException e) {
        return AjaxResult.error("演示模式，不允许操作");
    }
}
```

---

## 实际处理的异常类型

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

## 异常分类说明

### 1. 业务异常 (ServiceException)

**位置**: `ruoyi-common/exception/ServiceException.java`

```java
public class ServiceException extends RuntimeException {
    
    private Integer code;
    
    public ServiceException(String message) {
        super(message);
        this.code = 500;
    }
    
    public ServiceException(String message, Integer code) {
        super(message);
        this.code = code;
    }
    
    public Integer getCode() {
        return code;
    }
}

// 使用示例
throw new ServiceException("用户不存在", 404);
throw new ServiceException("密码错误");
```

### 2. 演示模式异常 (DemoModeException)

**位置**: `ruoyi-common/exception/DemoModeException.java`

```java
public class DemoModeException extends RuntimeException {
    
    public DemoModeException() {
        super("演示模式，不允许操作");
    }
}

// 使用示例
if (isDemoMode()) {
    throw new DemoModeException();
}
```

---

## 标准错误响应格式

```json
// 权限异常
{
    "code": 403,
    "msg": "没有权限，请联系管理员授权",
    "data": null
}

// 请求方法不支持
{
    "code": 405,
    "msg": "不支持'DELETE'请求",
    "data": null
}

// 业务异常
{
    "code": 500,
    "msg": "用户不存在",
    "data": null
}

// 参数校验失败
{
    "code": 400,
    "msg": "用户名不能为空",
    "data": null
}

// 演示模式
{
    "code": 500,
    "msg": "演示模式，不允许操作",
    "data": null
}

// 系统异常
{
    "code": 500,
    "msg": "系统内部错误，请联系管理员",
    "data": null
}
```

---

## 使用示例

### 1. Service 层抛出异常

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    @Autowired
    private UserMapper userMapper;
    
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
        
        int rows = userMapper.updateUser(user);
        if (rows <= 0) {
            throw new ServiceException("修改失败");
        }
        return rows;
    }
}
```

### 2. Controller 层异常处理

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    
    @Autowired
    private SysUserService userService;
    
    /**
     * 获取用户详情
     */
    @GetMapping("/{userId}")
    public AjaxResult getUser(@PathVariable Long userId) {
        // 可能抛出 ServiceException
        SysUser user = userService.selectUserById(userId);
        return AjaxResult.success(user);
    }
    
    /**
     * 新增用户（带参数校验）
     */
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user) {
        // @Validated 校验失败会抛出 MethodArgumentNotValidException
        return toAjax(userService.insertUser(user));
    }
}
```

### 3. 参数校验注解

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

## 日志记录

```java
// 不同级别的日志记录
log.error("请求地址'{}',发生系统异常.", requestURI, e);  // 错误日志，带堆栈
log.error("请求地址'{}',权限校验失败'{}'", requestURI, e.getMessage());
log.warn("请求地址'{}',不支持'{}'请求", requestURI, e.getMethod());
```

**日志输出示例**:

```
2024-01-01 12:00:00 ERROR GlobalExceptionHandler - 请求地址'/system/user',发生系统异常.
java.lang.NullPointerException: Cannot invoke method on null object
    at com.ruoyi.system.service.UserServiceImpl.getUser(UserServiceImpl.java:50)
    at com.ruoyi.system.controller.SysUserController.getUser(SysUserController.java:100)
    ...
```

---

## 最佳实践

1. **异常分类**: 区分业务异常和系统异常，业务异常返回具体提示，系统异常返回通用错误
2. **日志记录**: 所有异常必须记录日志，系统异常记录完整堆栈
3. **安全考虑**: 不要将敏感信息（如 SQL、堆栈）返回给前端
4. **HTTP 状态码**: 根据异常类型返回合适的 HTTP 状态码
5. **参数校验**: 使用@Validated 进行参数校验，统一处理校验失败
6. **异常包装**: 底层异常包装成业务异常再抛出

---

## 常见异常码

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

## 注意事项

1. **GlobalExceptionHandler 只处理实际存在的 9 种异常**
2. **不存在的异常处理**: BaseException、PreAuthorizeException、AuthenticationException、NullPointerException、DataAccessException、ConstraintViolationException、RepeatSubmitException、RateLimiterException 等不在实际代码中
3. **ServiceException 的 code 属性**: 可为 null，需要判断
4. **BindException 和 MethodArgumentNotValidException**: 只返回第一个错误消息

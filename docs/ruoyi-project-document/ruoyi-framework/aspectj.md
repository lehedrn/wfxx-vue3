# AspectJ AOP 切面模块

## 概述

`ruoyi-framework/aspectj` 包提供 4 个核心 AOP 切面，用于横切关注点的统一处理，包括操作日志、数据权限、数据源切换和限流控制。

## 模块结构

```
aspectj/
├── LogAspect.java           # 操作日志切面
├── DataScopeAspect.java     # 数据权限切面
├── DataSourceAspect.java    # 数据源切面
└── RateLimiterAspect.java   # 限流切面
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/`

---

## 1. LogAspect - 操作日志切面

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/LogAspect.java`

**用途**: 自动记录带有 `@Log` 注解的方法执行情况

### 注解定义

**源码位置**: `ruoyi-common/annotation/Log.java`

```java
@Target({ ElementType.PARAMETER, ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {
    String title() default "";                    // 模块
    BusinessType businessType() default BusinessType.OTHER; // 功能
    OperatorType operatorType() default OperatorType.MANAGE; // 操作人类别
    boolean isSaveRequestData() default true;     // 是否保存请求参数
    boolean isSaveResponseData() default false;   // 是否保存响应参数
    String[] excludeParamNames() default {};      // 排除的参数名
}
```

### 核心实现

```java
@Aspect
@Component
public class LogAspect {
    
    private static final Logger log = LoggerFactory.getLogger(LogAspect.class);
    
    public static final String[] EXCLUDE_PROPERTIES = { 
        "password", "oldPassword", "newPassword", "confirmPassword" 
    };
    
    private static final ThreadLocal<Long> TIME_THREADLOCAL = 
        new NamedThreadLocal<>("Cost Time");
    
    /**
     * 请求前执行 - 记录开始时间
     */
    @Before(value = "@annotation(controllerLog)")
    public void doBefore(JoinPoint joinPoint, Log controllerLog) {
        TIME_THREADLOCAL.set(System.currentTimeMillis());
    }
    
    /**
     * 请求成功后执行
     */
    @AfterReturning(pointcut = "@annotation(controllerLog)", returning = "jsonResult")
    public void doAfterReturning(JoinPoint joinPoint, Log controllerLog, Object jsonResult) {
        handleLog(joinPoint, controllerLog, null, jsonResult);
    }
    
    /**
     * 请求异常后执行
     */
    @AfterThrowing(value = "@annotation(controllerLog)", throwing = "e")
    public void doAfterThrowing(JoinPoint joinPoint, Log controllerLog, Exception e) {
        handleLog(joinPoint, controllerLog, e, null);
    }
    
    /**
     * 处理日志
     */
    protected void handleLog(JoinPoint joinPoint, Log controllerLog, Exception e, Object jsonResult) {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            SysOperLog operLog = new SysOperLog();
            operLog.setStatus(e != null ? BusinessStatus.FAIL.ordinal() : BusinessStatus.SUCCESS.ordinal());
            
            // 设置 IP、URL、用户信息
            operLog.setOperIp(IpUtils.getIpAddr());
            operLog.setOperName(loginUser != null ? loginUser.getUsername() : "");
            operLog.setMethod(joinPoint.getTarget().getClass().getName() + "." + joinPoint.getSignature().getName() + "()");
            
            // 处理注解参数
            if (e != null) {
                operLog.setErrorMsg(StringUtils.substring(e.getMessage(), 0, 2000));
            }
            getControllerMethodDescription(joinPoint, controllerLog, operLog, jsonResult);
            
            // 设置消耗时间
            operLog.setCostTime(System.currentTimeMillis() - TIME_THREADLOCAL.get());
            
            // 异步保存数据库
            AsyncManager.me().execute(AsyncFactory.recordOper(operLog));
            
        } catch (Exception exp) {
            log.error("异常信息:{}", exp.getMessage());
        } finally {
            TIME_THREADLOCAL.remove();
        }
    }
}
```

### 使用示例

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    /**
     * 新增用户
     */
    @Log(title = "用户管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        return toAjax(userService.insertUser(user));
    }
    
    /**
     * 修改用户（保存响应参数）
     */
    @Log(title = "用户管理", businessType = BusinessType.UPDATE, 
         isSaveResponseData = true)
    @PutMapping
    public AjaxResult edit(@RequestBody SysUser user) {
        return toAjax(userService.updateUser(user));
    }
    
    /**
     * 删除用户（排除 password 参数）
     */
    @Log(title = "用户管理", businessType = BusinessType.DELETE, 
         excludeParamNames = {"password"})
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds) {
        return toAjax(userService.deleteUserByIds(userIds));
    }
}
```

---

## 2. DataScopeAspect - 数据权限切面

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/DataScopeAspect.java`

**用途**: 根据用户角色自动注入数据范围过滤 SQL 到方法参数的 params 中

### 注解定义

**源码位置**: `ruoyi-common/annotation/DataScope.java`

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataScope {
    String deptAlias() default "";    // 部门别名
    String userAlias() default "";    // 用户别名
    String permission() default "";   // 权限字符
}
```

### 核心实现

```java
@Aspect
@Component
public class DataScopeAspect {
    
    public static final String DATA_SCOPE = "dataScope";
    
    @Before("@annotation(controllerDataScope)")
    public void doBefore(JoinPoint point, DataScope controllerDataScope) throws Throwable {
        clearDataScope(point);
        handleDataScope(point, controllerDataScope);
    }
    
    /**
     * 数据范围过滤核心方法
     */
    public static void dataScopeFilter(JoinPoint joinPoint, SysUser user, 
            String userAlias, String deptAlias, String permission) {
        
        StringBuilder sqlString = new StringBuilder();
        
        for (SysRole role : user.getRoles()) {
            String dataScope = role.getDataScope();
            
            if (Constants.Dept.DATA_SCOPE_ALL.equals(dataScope)) {
                // 全部数据权限，清空 SQL
                sqlString = new StringBuilder();
                break;
            } else if (Constants.Dept.DATA_SCOPE_CUSTOM.equals(dataScope)) {
                // 自定义数据权限
                sqlString.append(StringUtils.format(
                    " OR {}.dept_id IN ( SELECT dept_id FROM sys_role_dept WHERE role_id = {} )", 
                    deptAlias, role.getRoleId()
                ));
            } else if (Constants.Dept.DATA_SCOPE_DEPT.equals(dataScope)) {
                // 本部门数据权限
                sqlString.append(StringUtils.format(
                    " OR {}.dept_id = {} ", deptAlias, user.getDeptId()
                ));
            } else if (Constants.Dept.DATA_SCOPE_DEPT_AND_CHILD.equals(dataScope)) {
                // 本部门及子部门
                sqlString.append(StringUtils.format(
                    " OR {}.dept_id IN ( SELECT dept_id FROM sys_dept WHERE dept_id = {} or find_in_set( {} , ancestors ) )", 
                    deptAlias, user.getDeptId(), user.getDeptId()
                ));
            } else if (Constants.Dept.DATA_SCOPE_SELF.equals(dataScope)) {
                // 仅本人
                if (StringUtils.isNotBlank(userAlias)) {
                    sqlString.append(StringUtils.format(
                        " OR {}.user_id = {} ", userAlias, user.getUserId()
                    ));
                }
            }
        }
        
        // 拼接到 params.dataScope
        if (StringUtils.isNotBlank(sqlString.toString())) {
            Object params = joinPoint.getArgs()[0];
            if (params instanceof BaseEntity) {
                BaseEntity baseEntity = (BaseEntity) params;
                baseEntity.getParams().put(DATA_SCOPE, " AND (" + sqlString.substring(4) + ")");
            }
        }
    }
}
```

### 数据范围常量

**源码位置**: `ruoyi-common/core/Constants.java`

```java
public interface Dept {
    String DATA_SCOPE_ALL = "1";           // 全部数据
    String DATA_SCOPE_CUSTOM = "2";        // 自定义数据
    String DATA_SCOPE_DEPT = "3";          // 本部门数据
    String DATA_SCOPE_DEPT_AND_CHILD = "4"; // 本部门及以下
    String DATA_SCOPE_SELF = "5";          // 仅本人数据
}
```

### Mapper XML 使用示例

```xml
<select id="selectUserList" parameterType="SysUser" resultMap="SysUserResult">
    select u.user_id, u.user_name, d.dept_id, d.dept_name
    from sys_user u
    left join sys_dept d on u.dept_id = d.dept_id
    where u.del_flag = '0'
    <!-- 数据权限过滤 -->
    ${params.dataScope}
    <if test="userName != null and userName != ''">
        AND u.user_name like concat('%', #{userName}, '%')
    </if>
</select>
```

### Service 使用示例

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    /**
     * 查询用户列表 - 自动应用数据权限
     */
    @DataScope(deptAlias = "d", userAlias = "u")
    @Override
    public List<SysUser> selectUserList(SysUser user) {
        return userMapper.selectUserList(user);
    }
    
    /**
     * 带权限字符的数据权限过滤
     */
    @DataScope(deptAlias = "d", userAlias = "u", permission = "system:user:list")
    public List<SysUser> selectUserListByPermission(SysUser user) {
        return userMapper.selectUserList(user);
    }
}
```

---

## 3. DataSourceAspect - 数据源切面

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/DataSourceAspect.java`

**用途**: 根据 `@DataSource` 注解动态切换数据源

### 注解定义

**源码位置**: `ruoyi-common/annotation/DataSource.java`

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataSource {
    DataSourceType value() default DataSourceType.MASTER;
}
```

### 核心实现

```java
@Aspect
@Order(1) // 优先级高于事务
public class DataSourceAspect {
    
    @Around("@annotation(ds)")
    public Object around(ProceedingJoinPoint point, DataSource ds) throws Throwable {
        DataSourceType dataSourceType = ds.value();
        
        // 切换数据源
        DynamicDataSourceContextHolder.setDataSourceType(dataSourceType.name());
        
        try {
            return point.proceed();
        } finally {
            DynamicDataSourceContextHolder.clearDataSourceType();
        }
    }
}
```

### 使用示例

```java
@Service
public class UserServiceImpl {
    
    // 查询使用从库
    @DataSource(DataSourceType.SLAVE)
    public List<SysUser> selectUserList(SysUser user) {
        return userMapper.selectUserList(user);
    }
    
    // 写入使用主库
    @DataSource(DataSourceType.MASTER)
    public int insertUser(SysUser user) {
        return userMapper.insertUser(user);
    }
}
```

---

## 4. RateLimiterAspect - 限流切面

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/RateLimiterAspect.java`

**用途**: 基于 Redis + Lua 脚本实现接口限流

### 注解定义

**源码位置**: `ruoyi-common/annotation/RateLimiter.java`

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RateLimiter {
    int time() default 60;                // 限流时间 (秒)
    int count() default 100;              // 限流次数
    LimitType limitType() default LimitType.DEFAULT; // 限流策略
    String message() default "访问过于频繁，请稍后再试";
}
```

### 限流策略

```java
public enum LimitType {
    DEFAULT,  // 全局限流
    IP        // 按 IP 限流
}
```

### 核心实现

```java
@Aspect
@Component
public class RateLimiterAspect {
    
    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;
    
    @Autowired
    private RedisScript<Long> limitScript;
    
    @Before("@annotation(rateLimiter)")
    public void doBefore(JoinPoint point, RateLimiter rateLimiter) throws Throwable {
        int time = rateLimiter.time();
        int count = rateLimiter.count();
        
        // 生成 Redis Key
        String combineKey = getCombineKey(rateLimiter, point);
        List<Object> keys = Collections.singletonList(combineKey);
        
        // 执行 Lua 脚本
        Long number = redisTemplate.execute(limitScript, keys, count, time);
        
        if (StringUtils.isNull(number) || number.intValue() > count) {
            throw new ServiceException("访问过于频繁，请稍候再试");
        }
    }
    
    /**
     * 生成限流 Key
     */
    public String getCombineKey(RateLimiter rateLimiter, JoinPoint point) {
        StringBuffer stringBuffer = new StringBuffer(rateLimiter.key());
        if (rateLimiter.limitType() == LimitType.IP) {
            stringBuffer.append(IpUtils.getIpAddr()).append("-");
        }
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        stringBuffer.append(method.getDeclaringClass().getName()).append("-").append(method.getName());
        return stringBuffer.toString();
    }
}
```

### Lua 脚本配置

**源码位置**: `ruoyi-framework/config/RedisConfig.java`

```java
@Bean
public RedisScript<Long> limitScript() {
    DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
    redisScript.setScriptText(
        "local key = KEYS[1] " +
        "local limit = tonumber(ARGV[1]) " +
        "local expire = tonumber(ARGV[2]) " +
        "local current = redis.call('INCR', key) " +
        "if current == 1 then " +
        "    redis.call('EXPIRE', key, expire) " +
        "end " +
        "return current"
    );
    redisScript.setResultType(Long.class);
    return redisScript;
}
```

### 使用示例

```java
@RestController
@RequestMapping("/sms")
public class SmsController {
    
    /**
     * 发送短信 - 60 秒内最多 5 次
     */
    @RateLimiter(time = 60, count = 5)
    @PostMapping("/send")
    public AjaxResult sendCode(@RequestParam String phone) {
        return toAjax(smsService.send(phone));
    }
    
    /**
     * 图片验证码 - 同一 IP 60 秒内最多 10 次
     */
    @RateLimiter(time = 60, count = 10, limitType = LimitType.IP)
    @GetMapping("/captcha")
    public AjaxResult getCaptcha() {
        return AjaxResult.success(captchaService.create());
    }
}
```

---

## 切面执行顺序

```
请求 → Filter (XssFilter, RepeatSubmitFilter)
       ↓
       JwtAuthenticationTokenFilter
       ↓
       RateLimiterAspect (@Before)
       ↓
       DataSourceAspect (@Around) - Order: 1
       ↓
       DataScopeAspect (@Before)
       ↓
       LogAspect (@Before/@AfterReturning/@AfterThrowing)
       ↓
       Controller 方法
```

**Order 说明**:
- `DataSourceAspect` Order=1，优先级最高，确保在事务开启前切换数据源
- 其他切面按默认顺序执行

---

## 最佳实践

1. **日志切面**: 敏感接口设置 `isSaveRequestData=false` 避免记录敏感参数
2. **数据权限**: 管理员自动跳过数据权限过滤
3. **数据源切换**: 写操作必须使用 MASTER，读操作使用 SLAVE
4. **限流配置**: 公开接口使用 IP 限流，内部接口使用全局限流
5. **ThreadLocal 清理**: 所有切面必须在 finally 中清理 ThreadLocal
6. **Lua 脚本**: 限流使用 Lua 脚本保证原子性

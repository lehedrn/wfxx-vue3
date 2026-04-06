# AspectJ AOP 切面模块

## 概述

`ruoyi-framework/aspectj` 包提供了 4 个核心 AOP 切面，用于横切关注点的统一处理，包括操作日志、数据权限、数据源切换和限流控制。

## 模块结构

```
aspectj/
├── LogAspect.java           # 操作日志切面
├── DataScopeAspect.java     # 数据权限切面
├── DataSourceAspect.java    # 数据源切面
└── RateLimiterAspect.java   # 限流切面
```

---

## 1. LogAspect - 操作日志切面

**用途**: 自动记录带有 `@Log` 注解的方法执行情况

**注解定义**:

```java
@Target({ ElementType.PARAMETER, ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {
    /**
     * 模块
     */
    String title() default "";
    
    /**
     * 功能
     */
    BusinessType businessType() default BusinessType.OTHER;
    
    /**
     * 操作人类别
     */
    OperatorType operatorType() default OperatorType.MANAGE;
    
    /**
     * 是否保存请求的参数
     */
    boolean isSaveRequestData() default true;
    
    /**
     * 是否保存响应的参数
     */
    boolean isSaveResponseData() default false;
    
    /**
     * 排除的参数名
     */
    String[] excludeParamNames() default {};
}
```

**核心实现**:

```java
@Aspect
@Component
public class LogAspect {
    
    private static final Logger log = LoggerFactory.getLogger(LogAspect.class);
    
    /** 排除敏感属性字段 */
    public static final String[] EXCLUDE_PROPERTIES = { 
        "password", "oldPassword", "newPassword", "confirmPassword" 
    };
    
    /** 计算操作消耗时间 */
    private static final ThreadLocal<Long> TIME_THREADLOCAL = 
        new NamedThreadLocal<Long>("Cost Time");
    
    /**
     * 处理请求前执行 - 记录开始时间
     */
    @Before(value = "@annotation(controllerLog)")
    public void doBefore(JoinPoint joinPoint, Log controllerLog) {
        TIME_THREADLOCAL.set(System.currentTimeMillis());
    }
    
    /**
     * 处理完请求后执行
     */
    @AfterReturning(pointcut = "@annotation(controllerLog)", returning = "jsonResult")
    public void doAfterReturning(JoinPoint joinPoint, Log controllerLog, Object jsonResult) {
        handleLog(joinPoint, controllerLog, null, jsonResult);
    }
    
    /**
     * 拦截异常操作
     */
    @AfterThrowing(value = "@annotation(controllerLog)", throwing = "e")
    public void doAfterThrowing(JoinPoint joinPoint, Log controllerLog, Exception e) {
        handleLog(joinPoint, controllerLog, e, null);
    }
    
    /**
     * 处理日志
     */
    protected void handleLog(final JoinPoint joinPoint, Log controllerLog, 
                            final Exception e, Object jsonResult) {
        try {
            // 获取当前登录用户
            LoginUser loginUser = SecurityUtils.getLoginUser();
            
            // 创建操作日志对象
            SysOperLog operLog = new SysOperLog();
            operLog.setStatus(BusinessStatus.SUCCESS.ordinal());
            
            // 设置 IP 和 URL
            String ip = IpUtils.getIpAddr();
            operLog.setOperIp(ip);
            operLog.setOperUrl(StringUtils.substring(
                ServletUtils.getRequest().getRequestURI(), 0, 255
            ));
            
            // 设置用户信息
            if (loginUser != null) {
                operLog.setOperName(loginUser.getUsername());
                SysUser currentUser = loginUser.getUser();
                if (StringUtils.isNotNull(currentUser) && 
                    StringUtils.isNotNull(currentUser.getDept())) {
                    operLog.setDeptName(currentUser.getDept().getDeptName());
                }
            }
            
            // 设置异常信息
            if (e != null) {
                operLog.setStatus(BusinessStatus.FAIL.ordinal());
                operLog.setErrorMsg(StringUtils.substring(
                    Convert.toStr(e.getMessage(), ExceptionUtil.getExceptionMessage(e)), 
                    0, 2000
                ));
            }
            
            // 设置方法名称和请求方式
            String className = joinPoint.getTarget().getClass().getName();
            String methodName = joinPoint.getSignature().getName();
            operLog.setMethod(className + "." + methodName + "()");
            operLog.setRequestMethod(ServletUtils.getRequest().getMethod());
            
            // 处理注解参数
            getControllerMethodDescription(joinPoint, controllerLog, operLog, jsonResult);
            
            // 设置消耗时间
            operLog.setCostTime(System.currentTimeMillis() - TIME_THREADLOCAL.get());
            
            // 异步保存数据库
            AsyncManager.me().execute(AsyncFactory.recordOper(operLog));
            
        } catch (Exception exp) {
            log.error("异常信息:{}", exp.getMessage());
            exp.printStackTrace();
        } finally {
            TIME_THREADLOCAL.remove();
        }
    }
    
    /**
     * 获取注解描述信息
     */
    public void getControllerMethodDescription(JoinPoint joinPoint, Log log, 
                                               SysOperLog operLog, Object jsonResult) {
        // 设置 action 动作
        operLog.setBusinessType(log.businessType().ordinal());
        // 设置标题
        operLog.setTitle(log.title());
        // 设置操作人类别
        operLog.setOperatorType(log.operatorType().ordinal());
        
        // 保存请求参数
        if (log.isSaveRequestData()) {
            setRequestValue(joinPoint, operLog, log.excludeParamNames());
        }
        
        // 保存响应参数
        if (log.isSaveResponseData() && StringUtils.isNotNull(jsonResult)) {
            operLog.setJsonResult(StringUtils.substring(
                JSON.toJSONString(jsonResult), 0, 2000
            ));
        }
    }
    
    /**
     * 获取请求参数
     */
    private void setRequestValue(JoinPoint joinPoint, SysOperLog operLog, 
                                String[] excludeParamNames) {
        String requestMethod = operLog.getRequestMethod();
        Map<?, ?> paramsMap = ServletUtils.getParamMap(ServletUtils.getRequest());
        
        if (StringUtils.isEmpty(paramsMap) && 
            StringUtils.equalsAny(requestMethod, 
                HttpMethod.PUT.name(), HttpMethod.POST.name(), HttpMethod.DELETE.name())) {
            // PUT/POST/DELETE 请求从参数数组获取
            String params = argsArrayToString(joinPoint.getArgs(), excludeParamNames);
            operLog.setOperParam(params);
        } else {
            // GET 请求从参数 Map 获取
            operLog.setOperParam(StringUtils.substring(
                JSON.toJSONString(paramsMap, excludePropertyPreFilter(excludeParamNames)), 
                0, 2000
            ));
        }
    }
    
    /**
     * 参数数组转字符串
     */
    private String argsArrayToString(Object[] paramsArray, String[] excludeParamNames) {
        StringBuilder params = new StringBuilder();
        if (paramsArray != null && paramsArray.length > 0) {
            for (Object o : paramsArray) {
                if (StringUtils.isNotNull(o) && !isFilterObject(o)) {
                    String jsonObj = JSON.toJSONString(o, excludePropertyPreFilter(excludeParamNames));
                    params.append(jsonObj).append(" ");
                }
            }
        }
        return params.toString();
    }
    
    /**
     * 判断是否需要过滤的对象
     */
    public boolean isFilterObject(final Object o) {
        // 过滤 MultipartFile、HttpServletRequest、HttpServletResponse、BindingResult
        return o instanceof MultipartFile || 
               o instanceof HttpServletRequest || 
               o instanceof HttpServletResponse ||
               o instanceof BindingResult;
    }
    
    /**
     * 忽略敏感属性
     */
    public PropertyPreExcludeFilter excludePropertyPreFilter(String[] excludeParamNames) {
        return new PropertyPreExcludeFilter().addExcludes(
            ArrayUtils.addAll(EXCLUDE_PROPERTIES, excludeParamNames)
        );
    }
}
```

**通知类型**:

- `@Before`: 请求前执行，记录开始时间
- `@AfterReturning`: 请求成功后执行，记录成功日志
- `@AfterThrowing`: 请求异常后执行，记录失败日志

**使用示例**:

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
     * 修改用户（保存请求和响应参数）
     */
    @Log(title = "用户管理", businessType = BusinessType.UPDATE, 
         isSaveRequestData = true, isSaveResponseData = true)
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

**用途**: 根据用户角色自动注入数据范围过滤 SQL 到方法参数的 params 中

**注解定义**:

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataScope {
    /**
     * 部门别名（用于 SQL 拼接）
     */
    String deptAlias() default "";
    
    /**
     * 用户别名
     */
    String userAlias() default "";
    
    /**
     * 用户名字段
     */
    String userField() default "";
    
    /**
     * 部门名字段
     */
    String deptField() default "";
    
    /**
     * 权限字符（用于过滤角色）
     */
    String permission() default "";
}
```

**核心实现**:

```java
@Aspect
@Component
public class DataScopeAspect {
    
    /**
     * 数据权限过滤关键字
     */
    public static final String DATA_SCOPE = "dataScope";
    
    /**
     * 在方法执行前处理数据权限
     */
    @Before("@annotation(controllerDataScope)")
    public void doBefore(JoinPoint point, DataScope controllerDataScope) throws Throwable {
        clearDataScope(point);
        handleDataScope(point, controllerDataScope);
    }
    
    /**
     * 清空 dataScope 参数，防止 SQL 注入
     */
    private void clearDataScope(final JoinPoint joinPoint) {
        Object params = joinPoint.getArgs()[0];
        if (StringUtils.isNotNull(params) && params instanceof BaseEntity) {
            BaseEntity baseEntity = (BaseEntity) params;
            baseEntity.getParams().put(DATA_SCOPE, "");
        }
    }
    
    /**
     * 处理数据权限
     */
    protected void handleDataScope(final JoinPoint joinPoint, DataScope controllerDataScope) {
        // 获取当前用户
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (StringUtils.isNotNull(loginUser)) {
            SysUser currentUser = loginUser.getUser();
            // 超级管理员不过滤数据
            if (StringUtils.isNotNull(currentUser) && !currentUser.isAdmin()) {
                // 获取权限字符，默认为 PermissionContextHolder 中的值
                String permission = StringUtils.defaultIfEmpty(
                    controllerDataScope.permission(), 
                    PermissionContextHolder.getContext()
                );
                dataScopeFilter(
                    joinPoint, 
                    currentUser, 
                    controllerDataScope.userAlias(), 
                    controllerDataScope.deptAlias(), 
                    controllerDataScope.userField(), 
                    controllerDataScope.deptField(), 
                    permission
                );
            }
        }
    }
    
    /**
     * 数据范围过滤核心方法
     */
    public static void dataScopeFilter(
            JoinPoint joinPoint, 
            SysUser user, 
            String userAlias, 
            String deptAlias, 
            String userField, 
            String deptField, 
            String permission) {
        
        StringBuilder sqlString = new StringBuilder();
        List<String> conditions = new ArrayList<String>();
        List<String> scopeCustomIds = new ArrayList<String>();
        
        // 先收集所有自定义数据权限的角色 ID
        user.getRoles().forEach(role -> {
            if (Constants.Dept.DATA_SCOPE_CUSTOM.equals(role.getDataScope()) 
                    && StringUtils.equals(role.getStatus(), UserConstants.ROLE_NORMAL) 
                    && (StringUtils.isEmpty(permission) 
                        || StringUtils.containsAny(role.getPermissions(), Convert.toStrArray(permission)))) {
                scopeCustomIds.add(Convert.toStr(role.getRoleId()));
            }
        });
        
        // 遍历角色，拼接数据权限 SQL
        for (SysRole role : user.getRoles()) {
            String dataScope = role.getDataScope();
            
            // 已处理过的数据范围或禁用的角色，跳过
            if (conditions.contains(dataScope) || StringUtils.equals(role.getStatus(), UserConstants.ROLE_DISABLE)) {
                continue;
            }
            
            // 权限字符不匹配，跳过
            if (StringUtils.isNotEmpty(permission) && !StringUtils.containsAny(role.getPermissions(), Convert.toStrArray(permission))) {
                continue;
            }
            
            if (Constants.Dept.DATA_SCOPE_ALL.equals(dataScope)) {
                // 全部数据权限，清空 SQL，直接返回
                sqlString = new StringBuilder();
                conditions.add(dataScope);
                break;
            }
            else if (Constants.Dept.DATA_SCOPE_CUSTOM.equals(dataScope)) {
                // 自定义数据权限
                if (scopeCustomIds.size() > 1) {
                    // 多个自定数据权限使用 in 查询
                    sqlString.append(StringUtils.format(
                        " OR {}.{} IN ( SELECT dept_id FROM sys_role_dept WHERE role_id in ({}) ) ", 
                        deptAlias, deptField, String.join(",", scopeCustomIds)
                    ));
                } else {
                    sqlString.append(StringUtils.format(
                        " OR {}.{} IN ( SELECT dept_id FROM sys_role_dept WHERE role_id = {} ) ", 
                        deptAlias, deptField, role.getRoleId()
                    ));
                }
            }
            else if (Constants.Dept.DATA_SCOPE_DEPT.equals(dataScope)) {
                // 本部门数据权限
                sqlString.append(StringUtils.format(
                    " OR {}.{} = {} ", deptAlias, deptField, user.getDeptId()
                ));
            }
            else if (Constants.Dept.DATA_SCOPE_DEPT_AND_CHILD.equals(dataScope)) {
                // 本部门及子部门数据权限（使用 find_in_set 查询祖先）
                sqlString.append(StringUtils.format(
                    " OR {}.{} IN ( SELECT dept_id FROM sys_dept WHERE dept_id = {} or find_in_set( {} , ancestors ) )", 
                    deptAlias, deptField, user.getDeptId(), user.getDeptId()
                ));
            }
            else if (Constants.Dept.DATA_SCOPE_SELF.equals(dataScope)) {
                // 仅本人数据权限
                if (StringUtils.isNotBlank(userAlias)) {
                    sqlString.append(StringUtils.format(
                        " OR {}.{} = {} ", userAlias, userField, user.getUserId()
                    ));
                } else {
                    // 无 userAlias 别名则不查询任何数据
                    sqlString.append(StringUtils.format(
                        " OR {}.{} = 0 ", deptAlias, deptField
                    ));
                }
            }
            conditions.add(dataScope);
        }
        
        // 角色都不包含传递过来的权限字符，不查询任何数据
        if (StringUtils.isEmpty(conditions)) {
            sqlString.append(StringUtils.format(" OR {}.{} = 0 ", deptAlias, deptField));
        }
        
        // 将 SQL 拼接到 params.dataScope
        if (StringUtils.isNotBlank(sqlString.toString())) {
            Object params = joinPoint.getArgs()[0];
            if (StringUtils.isNotNull(params) && params instanceof BaseEntity) {
                BaseEntity baseEntity = (BaseEntity) params;
                // 去掉开头的 " OR "（4 个字符）
                baseEntity.getParams().put(DATA_SCOPE, " AND (" + sqlString.substring(4) + ")");
            }
        }
    }
}
```

**数据范围常量**:

```java
public interface Dept {
    /**
     * 全部数据权限
     */
    String DATA_SCOPE_ALL = "1";
    
    /**
     * 自定义数据权限
     */
    String DATA_SCOPE_CUSTOM = "2";
    
    /**
     * 本部门数据权限
     */
    String DATA_SCOPE_DEPT = "3";
    
    /**
     * 本部门及以下数据权限
     */
    String DATA_SCOPE_DEPT_AND_CHILD = "4";
    
    /**
     * 仅本人数据权限
     */
    String DATA_SCOPE_SELF = "5";
}
```

**Mapper XML 使用示例**:

```xml
<!-- 用户列表查询 -->
<select id="selectUserList" parameterType="com.ruoyi.system.domain.SysUser" resultMap="SysUserResult">
    select u.user_id, u.user_name, u.nick_name, u.email, u.phonenumber, u.sex,
           d.dept_id, d.dept_name, d.leader
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

**Service 使用示例**:

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    @Autowired
    private UserMapper userMapper;
    
    /**
     * 查询用户列表 - 自动应用数据权限
     * @DataScope 参数：
     * - deptAlias: 部门表别名
     * - userAlias: 用户表别名
     * - permission: 权限字符（可选，为空则使用 PermissionContextHolder 中的值）
     */
    @DataScope(deptAlias = "d", userAlias = "u")
    @Override
    public List<SysUser> selectUserList(SysUser user) {
        // 参数 user 会被注入 dataScope SQL
        // user.getParams().get("dataScope") 包含类似：
        // " AND (d.dept_id = 100 OR d.dept_id IN (SELECT dept_id FROM sys_role_dept WHERE role_id = 2))"
        return userMapper.selectUserList(user);
    }
    
    /**
     * 带权限字符的数据权限过滤
     * 只过滤包含 system:user:list 权限的角色
     */
    @DataScope(deptAlias = "d", userAlias = "u", permission = "system:user:list")
    public List<SysUser> selectUserListByPermission(SysUser user) {
        return userMapper.selectUserList(user);
    }
}
```

---

## 3. DataSourceAspect - 数据源切面

**用途**: 根据 `@DataSource` 注解动态切换数据源

**注解定义**:

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataSource {
    /**
     * 切换数据源
     */
    DataSourceType value() default DataSourceType.MASTER;
}
```

**核心实现**:

```java
@Aspect
@Order(1) // 优先级高于事务
public class DataSourceAspect {
    
    @Around("@annotation(ds)")
    public Object around(ProceedingJoinPoint point, DataSource ds) throws Throwable {
        // 1. 获取注解配置的数据源类型
        DataSourceType dataSourceType = ds.value();
        
        // 2. 切换数据源
        DynamicDataSourceContextHolder.setDataSourceType(dataSourceType.name());
        
        try {
            // 3. 执行目标方法
            return point.proceed();
        } finally {
            // 4. 清除数据源，避免 ThreadLocal 内存泄漏
            DynamicDataSourceContextHolder.clearDataSourceType();
        }
    }
}
```

**数据源类型**:

```java
public enum DataSourceType {
    /**
     * 主库（写库）
     */
    MASTER,
    
    /**
     * 从库（读库）
     */
    SLAVE
}
```

**使用示例**:

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    @Autowired
    private UserMapper userMapper;
    
    /**
     * 查询用户 - 使用从库
     */
    @DataSource(DataSourceType.SLAVE)
    @Override
    public List<SysUser> selectUserList(SysUser user) {
        return userMapper.selectUserList(user);
    }
    
    /**
     * 新增用户 - 使用主库
     */
    @DataSource(DataSourceType.MASTER)
    @Override
    public int insertUser(SysUser user) {
        return userMapper.insertUser(user);
    }
    
    /**
     * 批量导入用户 - 使用主库
     */
    @DataSource(DataSourceType.MASTER)
    @Override
    public int batchInsertUser(List<SysUser> list) {
        return userMapper.batchInsertUser(list);
    }
}
```

**类级别配置**:

```java
// 类级别默认从库，方法级别覆盖
@DataSource(DataSourceType.SLAVE)
@Service
public class ReportServiceImpl {
    
    // 使用从库（类级别）
    public List<Report> selectReports() {
        return reportMapper.selectReports();
    }
    
    // 使用主库（方法级别覆盖）
    @DataSource(DataSourceType.MASTER)
    public int generateReport(Report report) {
        return reportMapper.insert(report);
    }
}
```

---

## 4. RateLimiterAspect - 限流切面

**用途**: 基于 Redis + Lua 脚本实现接口限流

**注解定义**:

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RateLimiter {
    /**
     * 限流时间 (秒)
     */
    int time() default 60;
    
    /**
     * 限流次数
     */
    int count() default 100;
    
    /**
     * 限流策略
     */
    LimitType limitType() default LimitType.DEFAULT;
    
    /**
     * 提示信息
     */
    String message() default "访问过于频繁，请稍后再试";
}
```

**限流策略**:

```java
public enum LimitType {
    /**
     * 默认策略，全局限流
     */
    DEFAULT,
    
    /**
     * 根据 IP 限流
     */
    IP
}
```

**核心实现**:

```java
@Aspect
@Component
public class RateLimiterAspect {
    
    private static final Logger log = LoggerFactory.getLogger(RateLimiterAspect.class);
    
    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;
    
    @Autowired
    private RedisScript<Long> limitScript;
    
    /**
     * 限流处理（@Before 通知）
     */
    @Before("@annotation(rateLimiter)")
    public void doBefore(JoinPoint point, RateLimiter rateLimiter) throws Throwable {
        int time = rateLimiter.time();
        int count = rateLimiter.count();
        
        // 1. 生成 Redis Key
        String combineKey = getCombineKey(rateLimiter, point);
        List<Object> keys = Collections.singletonList(combineKey);
        
        try {
            // 2. 执行 Lua 脚本限流
            Long number = redisTemplate.execute(limitScript, keys, count, time);
            
            // 3. 检查是否超过限流次数
            if (StringUtils.isNull(number) || number.intValue() > count) {
                throw new ServiceException("访问过于频繁，请稍候再试");
            }
            
            log.info("限制请求'{}',当前请求'{}',缓存 key'{}'", count, number.intValue(), combineKey);
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("服务器限流异常，请稍候再试");
        }
    }
    
    /**
     * 生成限流 Key
     */
    public String getCombineKey(RateLimiter rateLimiter, JoinPoint point) {
        StringBuffer stringBuffer = new StringBuffer(rateLimiter.key());
        
        // 根据限流类型添加 IP
        if (rateLimiter.limitType() == LimitType.IP) {
            stringBuffer.append(IpUtils.getIpAddr()).append("-");
        }
        
        // 添加方法签名
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        Class<?> targetClass = method.getDeclaringClass();
        stringBuffer.append(targetClass.getName()).append("-").append(method.getName());
        
        return stringBuffer.toString();
    }
}
```

**Lua 脚本配置** (在 RedisConfig 中配置):

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

**Lua 脚本逻辑**:

```lua
-- KEYS[1]: 限流 Key
-- ARGV[1]: 限流次数 (count)
-- ARGV[2]: 限流时间 (time/秒)

local key = KEYS[1]
local limit = tonumber(ARGV[1])
local expire = tonumber(ARGV[2])

-- 计数器 +1
local current = redis.call('INCR', key)

-- 如果是第一次访问，设置过期时间
if current == 1 then
    redis.call('EXPIRE', key, expire)
end

-- 返回当前访问次数
return current
```

**使用示例**:

```java
@RestController
@RequestMapping("/sms")
public class SmsController {
    
    /**
     * 发送短信验证码 - 同一接口 60 秒内最多 5 次
     */
    @RateLimiter(time = 60, count = 5, message = "发送过于频繁，请稍后再试")
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
    
    /**
     * 登录接口 - 同一接口 10 秒内最多 3 次
     */
    @RateLimiter(time = 10, count = 3)
    @PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody loginBody) {
        return AjaxResult.success(authService.login(loginBody));
    }
}
```

**执行流程**:

```
请求 → @Before("@annotation(rateLimiter)")
        ↓
生成 combineKey (key + IP(可选) + 方法签名)
        ↓
执行 Lua 脚本 (INCR + EXPIRE)
        ↓
获取当前访问次数 number
        ↓
number > count → 抛出 ServiceException
number <= count → 放行
        ↓
执行目标方法
```

**Redis Key 示例**:

```
# 全局限流（不限 IP）
rate_limit:test.com.service.UserService-getUserById

# IP 限流
rate_limit:192.168.1.100-test.com.service.UserService-getUserById
```

---

## 切面执行顺序

```
请求 → Filter (XssFilter, RepeatSubmitFilter)
       ↓
       JwtAuthenticationTokenFilter
       ↓
       RateLimiterAspect (@RateLimiter)
       ↓
       DataSourceAspect (@DataSource) - Order: 1
       ↓
       DataScopeAspect (@DataScope)
       ↓
       LogAspect (@Log)
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

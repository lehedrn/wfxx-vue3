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
}
```

**核心实现**:

```java
@Component
@Aspect
public class LogAspect {
    
    private static final Logger log = LoggerFactory.getLogger(LogAspect.class);
    
    @Autowired
    private RedisCache redisCache;
    
    // 排除的操作
    private static final Set<String> EXCLUDE_OPERATIONS = Sets.newHashSet(
        "新增", "修改", "删除"
    );
    
    /**
     * 处理业务方法
     */
    @Around("@annotation(controllerLog)")
    public Object around(ProceedingJoinPoint point, Log controllerLog) throws Throwable {
        long startTime = System.currentTimeMillis();
        Object result = null;
        
        // 1. 构建操作日志对象
        OperLog operLog = new OperLog();
        try {
            // 2. 设置基本信息
            handleRecord(point, controllerLog, operLog);
            
            // 3. 执行目标方法
            result = point.proceed();
            
            // 4. 设置执行状态
            operLog.setBusinessStatus(BusinessStatus.SUCCESS.getCode());
            
            // 5. 记录执行时间
            long endTime = System.currentTimeMillis();
            operLog.setOperTime(new Date());
            operLog.setCostTime(endTime - startTime);
            
            // 6. 异步保存日志
            AsyncManager.getInstance().execute(AsyncFactory.recordOper(operLog));
            
        } catch (Exception e) {
            // 7. 记录异常
            operLog.setBusinessStatus(BusinessStatus.FAIL.getCode());
            operLog.setErrorMsg(StringUtils.substring(e.getMessage(), 0, 2000));
            AsyncManager.getInstance().execute(AsyncFactory.recordOper(operLog));
            throw e;
        }
        
        return result;
    }
    
    /**
     * 记录日志详情
     */
    private void handleRecord(ProceedingJoinPoint point, Log log, OperLog operLog) {
        ServletRequestAttributes attributes = 
            (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attributes.getRequest();
        
        // 基本信息
        operLog.setOperIp(IpUtils.getIpAddr(request));
        operLog.setOperUrl(request.getRequestURI());
        operLog.setOperLocation= AddressUtils.getRealAddressByIP(operLog.getOperIp());
        
        // 获取登录用户
        String operName = SecurityUtils.getUsername();
        if (StringUtils.isNull(operName) || "anonymous".equals(operName)) {
            operName = "匿名用户";
        }
        operLog.setOperName(operName);
        
        // 部门信息
        Long deptId = SecurityUtils.getDeptId();
        operLog.setDeptId(deptId);
        
        // 方法信息
        String className = point.getTarget().getClass().getName();
        String methodName = point.getSignature().getName();
        operLog.setMethod(className + "." + methodName + "()");
        
        // 注解信息
        operLog.setTitle(log.title());
        operLog.setBusinessType(log.businessType().ordinal());
        operLog.setOperatorType(log.operatorType().ordinal());
        
        // 请求参数
        if (log.isSaveRequestData()) {
            Map<String, String> params = WebUtils.getParams(request);
            if (MapUtils.isNotEmpty(params)) {
                String paramString = JSONObject.toJSONString(params);
                operLog.setOperParam(StringUtils.substring(paramString, 0, 2000));
            }
        }
        
        // JSON 请求体
        Object arg = point.getArgs()[0];
        if (arg instanceof JSONObject) {
            String paramString = ((JSONObject) arg).toString();
            operLog.setOperParam(StringUtils.substring(paramString, 0, 2000));
        }
    }
}
```

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
     * 修改用户
     */
    @Log(title = "用户管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysUser user) {
        return toAjax(userService.updateUser(user));
    }
    
    /**
     * 删除用户
     */
    @Log(title = "用户管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds) {
        return toAjax(userService.deleteUserByIds(userIds));
    }
    
    /**
     * 导出用户
     */
    @Log(title = "用户管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, SysUser user) {
        List<SysUser> list = userService.selectUserList(user);
        ExcelUtil<SysUser> util = new ExcelUtil<>(SysUser.class);
        util.exportExcel(response, list, "用户数据");
    }
}
```

---

## 2. DataScopeAspect - 数据权限切面

**用途**: 根据用户角色自动注入数据范围过滤 SQL

**注解定义**:

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DataScope {
    /**
     * department 部门的别名（用于 SQL 拼接）
     */
    String deptAlias() default "";
    
    /**
     * user 用户的别名
     */
    String userAlias() default "";
    
    /**
     * 当前方法是否忽略其他方法的权限
     */
    boolean excludeSelf() default false;
}
```

**核心实现**:

```java
@Component
@Aspect
public class DataScopeAspect {
    
    @Autowired
    private PermissionContextHolder permissionContextHolder;
    
    /**
     * 数据权限处理
     */
    @Before("@annotation(controllerDataScope)")
    public void doBefore(JoinPoint point, DataScope controllerDataScope) {
        // 1. 获取当前用户
        LoginUser user = SecurityUtils.getLoginUser();
        if (user == null) {
            return;
        }
        
        SysUser currentUser = user.getUser();
        if (currentUser == null) {
            return;
        }
        
        // 2. 管理员拥有全部数据权限
        if (currentUser.isAdmin()) {
            return;
        }
        
        // 3. 构建数据权限 SQL
        StringBuilder dataScope = new StringBuilder();
        dataScope.append(" AND ( ");
        
        // 4. 获取用户角色
        List<SysRole> roles = currentUser.getRoles();
        if (CollectionUtils.isEmpty(roles)) {
            // 无角色，只能看到自己的数据
            dataScope.append(" 1=0 ");
        } else {
            // 5. 拼接各角色的数据范围
            List<String> scopeSqlList = new ArrayList<>();
            for (SysRole role : roles) {
                String dataScopeStr = getDataScopeString(role, controllerDataScope, currentUser);
                if (StringUtils.hasText(dataScopeStr)) {
                    scopeSqlList.add(dataScopeStr);
                }
            }
            
            if (scopeSqlList.isEmpty()) {
                dataScope.append(" 1=0 ");
            } else {
                dataScope.append(StringUtils.join(scopeSqlList, " OR "));
            }
        }
        
        dataScope.append(" ) ");
        
        // 6. 设置到上下文，供 Mapper 使用
        permissionContextHolder.setContext(dataScope.toString());
    }
    
    /**
     * 获取单个角色的数据范围 SQL
     */
    private String getDataScopeString(SysRole role, DataScope dataScope, SysUser user) {
        StringBuilder sql = new StringBuilder();
        
        switch (role.getDataScope()) {
            case DATA_SCOPE_ALL:
                // 全部数据权限，不过滤
                return "";
                
            case DATA_SCOPE_CUSTOM:
                // 自定义数据权限
                sql.append(" ( ");
                sql.append(String.format(
                    "%s.dept_id IN ( SELECT dept_id FROM sys_role_dept WHERE role_id = %s ) ",
                    dataScope.deptAlias(), role.getRoleId()
                ));
                
                // 如果排除自己，加上部门过滤
                if (dataScope.excludeSelf()) {
                    sql.append(String.format(
                        " OR %s.dept_id = %s ",
                        dataScope.deptAlias(), user.getDeptId()
                    ));
                }
                sql.append(" ) ");
                break;
                
            case DATA_SCOPE_DEPT:
                // 本部门数据权限
                sql.append(String.format(
                    "%s.dept_id = %s ",
                    dataScope.deptAlias(), user.getDeptId()
                ));
                break;
                
            case DATA_SCOPE_DEPT_AND_CHILD:
                // 本部门及子部门数据权限
                sql.append(String.format(
                    "%s.dept_id IN ( %s ) ",
                    dataScope.deptAlias(),
                    StringUtils.join(getDeptChildren(user.getDeptId()), ",")
                ));
                break;
                
            case DATA_SCOPE_SELF:
            default:
                // 仅本人数据权限
                sql.append(String.format(
                    "%s.user_id = %s ",
                    dataScope.userAlias(), user.getUserId()
                ));
                break;
        }
        
        return sql.toString();
    }
    
    /**
     * 获取部门的所有子部门 ID
     */
    private List<Long> getDeptChildren(Long deptId) {
        // 递归查询子部门
        List<SysDept> depts = deptMapper.selectDeptChildrenById(deptId);
        return depts.stream().map(SysDept::getDeptId).collect(Collectors.toList());
    }
}
```

**数据范围枚举**:

```java
public interface DataScopeType {
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
    $dataScope
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
     */
    @DataScope(deptAlias = "d", userAlias = "u")
    @Override
    public List<SysUser> selectUserList(SysUser user) {
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
@Component
@Aspect
public class RateLimiterAspect {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    /**
     * 限流处理
     */
    @Around("@annotation(rateLimiter)")
    public Object around(ProceedingJoinPoint point, RateLimiter rateLimiter) throws Throwable {
        // 1. 生成 Redis Key
        String key = getKey(rateLimiter, point);
        
        // 2. 执行 Lua 脚本限流
        Long count = executeLuaScript(key, rateLimiter.time(), rateLimiter.count());
        
        // 3. 检查是否超过限流
        if (count != null && count > rateLimiter.count()) {
            // 4. 超过限流次数，抛出异常
            throw new ServiceException(rateLimiter.message());
        }
        
        // 5. 执行目标方法
        return point.proceed();
    }
    
    /**
     * 生成限流 Key
     */
    private String getKey(RateLimiter rateLimiter, ProceedingJoinPoint point) {
        StringBuilder key = new StringBuilder();
        key.append(CacheConstants.RATE_LIMIT_KEY);
        key.append(":");
        
        // 方法签名
        String methodName = point.getSignature().getName();
        key.append(methodName);
        
        // 根据限流类型添加维度
        if (rateLimiter.limitType() == LimitType.IP) {
            // 按 IP 限流
            ServletRequestAttributes attributes = 
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            HttpServletRequest request = attributes.getRequest();
            key.append(":");
            key.append(IpUtils.getIpAddr(request));
        }
        
        return key.toString();
    }
    
    /**
     * 执行 Lua 脚本
     * 返回当前访问次数
     */
    private Long executeLuaScript(String key, int time, int count) {
        String script = 
            "local key = KEYS[1] " +
            "local limit = tonumber(ARGV[1]) " +
            "local expire = tonumber(ARGV[2]) " +
            "local current = redis.call('INCR', key) " +
            "if current == 1 then " +
            "    redis.call('EXPIRE', key, expire) " +
            "end " +
            "return current";
        
        RedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);
        return redisTemplate.execute(redisScript, Collections.singletonList(key), count, time);
    }
}
```

**Lua 脚本逻辑**:

```lua
-- KEYS[1]: 限流 Key
-- ARGV[1]: 限流次数
-- ARGV[2]: 限流时间 (秒)

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
     * 发送短信 - 每个 IP 60 秒内最多 10 次
     */
    @RateLimiter(time = 60, count = 10, limitType = LimitType.IP)
    @PostMapping("/send")
    public AjaxResult sendSms(@RequestParam String phone) {
        smsService.sendVerifyCode(phone);
        return AjaxResult.success("发送成功");
    }
    
    /**
     * 公共查询接口 - 全局限流 60 秒 100 次
     */
    @RateLimiter(time = 60, count = 100, limitType = LimitType.DEFAULT)
    @GetMapping("/query")
    public AjaxResult query() {
        return AjaxResult.success(dataService.query());
    }
    
    /**
     * 登录接口 - 防止暴力破解，每个 IP 60 秒最多 5 次
     */
    @RateLimiter(time = 60, count = 5, limitType = LimitType.IP, message = "登录太频繁，请稍后再试")
    @PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody loginBody) {
        return loginService.login(loginBody);
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

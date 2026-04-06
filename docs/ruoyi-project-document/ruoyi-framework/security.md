# Security 安全认证模块

## 概述

`ruoyi-framework/security` 包提供基于 Spring Security + JWT 的安全认证机制，包括用户认证、权限校验、Token 管理等功能。

## 模块结构

```
security/
├── JwtAuthenticationTokenFilter.java  # JWT 认证过滤器
├── AuthenticationContextHolder.java   # 认证上下文持有者
├── PermissionContextHolder.java       # 权限上下文持有者
├── AuthenticationEntryPointImpl.java  # 认证失败处理
└── LogoutSuccessHandlerImpl.java      # 登出成功处理
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/`

---

## 核心组件

### 1. JwtAuthenticationTokenFilter - JWT 认证过滤器

**用途**: 解析 JWT Token 并设置 Spring Security 认证上下文

**核心逻辑**:

```java
@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {
    
    @Autowired
    private TokenService tokenService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain chain) throws ServletException, IOException {
        // 1. 获取登录用户
        LoginUser loginUser = tokenService.getLoginUser(request);
        
        // 2. 用户不为空且未认证则继续
        if (StringUtils.isNotNull(loginUser) && 
            StringUtils.isNull(SecurityUtils.getAuthentication())) {
            
            // 3. 验证 Token 有效期
            tokenService.verifyToken(loginUser);
            
            // 4. 创建认证令牌
            UsernamePasswordAuthenticationToken authenticationToken = 
                new UsernamePasswordAuthenticationToken(
                    loginUser, null, loginUser.getAuthorities()
                );
            
            // 5. 设置到 SecurityContextHolder
            SecurityContextHolder.getContext().setAuthentication(authenticationToken);
        }
        
        chain.doFilter(request, response);
    }
}
```

**认证流程**:

```
请求 → JwtAuthenticationTokenFilter
        ↓
    TokenService.getLoginUser(request)
        ↓
    从 Header 获取 Token → 解析 JWT 获取 uuid
        ↓
    Redis 获取 LoginUser
        ↓
    verifyToken() 检查有效期
        ↓
    创建 AuthenticationToken
        ↓
    设置到 SecurityContextHolder
```

---

### 2. AuthenticationContextHolder - 认证上下文持有者

**用途**: 工具类，用于检查当前是否有认证信息

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/AuthenticationContextHolder.java`

```java
public class AuthenticationContextHolder {
    
    public static Authentication getAuthentication() {
        return SecurityContextHolder.getContext().getAuthentication();
    }
    
    public static void clear() {
        SecurityContextHolder.clearContext();
    }
}
```

---

### 3. PermissionContextHolder - 权限上下文持有者

**用途**: 存储和获取数据权限上下文（使用 RequestContextHolder 而非 ThreadLocal）

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/PermissionContextHolder.java`

```java
public class PermissionContextHolder {
    
    /**
     * 设置权限上下文到 RequestAttributes
     */
    public static void setContext(String permissionSQL) {
        RequestContextHolder.currentRequestAttributes().setAttribute(
            "permission_context", permissionSQL,
            RequestAttributes.SCOPE_REQUEST
        );
    }
    
    /**
     * 获取权限上下文
     */
    public static String getContext() {
        RequestAttributes attributes = RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            return (String) attributes.getAttribute("permission_context", 
                RequestAttributes.SCOPE_REQUEST);
        }
        return null;
    }
}
```

**使用场景**: DataScope 注解配合使用，在 Mapper XML 中动态拼接数据权限 SQL

---

### 4. AuthenticationEntryPointImpl - 认证失败处理

**用途**: 未认证用户访问受保护资源时的处理

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/AuthenticationEntryPointImpl.java`

**触发场景**:
- 未携带 Token 访问需要认证的接口
- Token 过期
- Token 格式错误

---

### 5. LogoutSuccessHandlerImpl - 登出成功处理

**用途**: 用户登出后的处理逻辑

**核心逻辑**:

```java
@Component
public class LogoutSuccessHandlerImpl implements LogoutSuccessHandler {
    
    @Autowired
    private TokenService tokenService;
    
    @Override
    public void onLogoutSuccess(HttpServletRequest request, 
                               HttpServletResponse response, 
                               Authentication authentication) throws IOException {
        try {
            // 1. 获取登录用户信息
            LoginUser loginUser = tokenService.getLoginUser(request);
            
            if (loginUser != null) {
                // 2. 删除 Redis 中的登录缓存
                String token = tokenService.resolveToken(request);
                String loginKey = CacheConstants.LOGIN_TOKEN_KEY + token;
                redisCache.deleteObject(loginKey);
                
                // 3. 记录登出日志
                recordLogoutLog(loginUser);
            }
            
            // 4. 返回成功响应
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(JSONObject.toJSONString(AjaxResult.success("退出成功")));
            out.flush();
            out.close();
        } catch (Exception e) {
            log.error("登出异常：{}", e.getMessage(), e);
            throw new IOException("登出失败");
        }
    }
}
```

**登出流程**:

```
请求/logout → Spring Security LogoutFilter
                  ↓
            LogoutSuccessHandler
                  ↓
            获取 LoginUser → 删除 Redis 登录缓存
                  ↓
            记录登出日志 → 返回成功响应
```

---

## TokenService - Token 服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java`

**用途**: JWT Token 的创建、解析、验证和刷新

**核心方法**:

```java
@Component
public class TokenService {
    
    @Value("${token.expireTime}")
    private int expireTime; // 令牌有效期（分钟）
    
    @Value("${token.secret}")
    private String secret;  // 令牌秘钥
    
    @Autowired
    private RedisCache redisCache;
    
    /**
     * 创建 Token
     */
    public String createToken(LoginUser loginUser) {
        String token = IdUtils.fastUUID();
        loginUser.setToken(token);
        setUserAgent(loginUser);
        refreshToken(loginUser);

        Map<String, Object> claims = new HashMap<>();
        claims.put(Constants.LOGIN_USER_KEY, token);
        claims.put(Constants.JWT_USERNAME, loginUser.getUsername());
        return Jwts.builder()
                .setClaims(claims)
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }
    
    /**
     * 获取登录用户（从请求）
     */
    public LoginUser getLoginUser(HttpServletRequest request) {
        String token = getToken(request);
        if (StringUtils.isNotEmpty(token)) {
            try {
                Claims claims = parseToken(token);
                String uuid = (String) claims.get(Constants.LOGIN_USER_KEY);
                return redisCache.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + uuid);
            } catch (Exception e) {
                log.error("获取用户信息异常'{}'", e.getMessage());
            }
        }
        return null;
    }
    
    /**
     * 验证 Token 有效期（相差不足 20 分钟自动刷新）
     */
    public void verifyToken(LoginUser loginUser) {
        long expireTime = loginUser.getExpireTime();
        long currentTime = System.currentTimeMillis();
        if (expireTime - currentTime <= MILLIS_MINUTE_TWENTY) {
            refreshToken(loginUser);
        }
    }
    
    /**
     * 刷新 Token 有效期
     */
    public void refreshToken(LoginUser loginUser) {
        loginUser.setLoginTime(System.currentTimeMillis());
        loginUser.setExpireTime(
            loginUser.getLoginTime() + expireTime * MILLIS_MINUTE
        );
        String userKey = getTokenKey(loginUser.getToken());
        redisCache.setCacheObject(userKey, loginUser, expireTime, TimeUnit.MINUTES);
    }
}
```

**JWT Token 结构**:

```
Header: {"alg": "HS512", "typ": "JWT"}
Payload: {"loginUserKey": "uuid-token-string", "username": "admin"}
Signature: HS512(base64(header) + "." + base64(payload), secret)
```

**说明**:
- Token 由 JWT 构成，但实际用户信息存储在 Redis 中
- JWT 中只包含 loginUserKey（用于 Redis 查询）和 username
- Token 有效期由配置决定（默认 120 分钟）
- 相差不足 20 分钟自动刷新

---

## 认证授权完整流程

### 1. 登录流程

```
用户登录请求
    ↓
SysLoginService.login()
    ↓
验证用户名密码
    ↓
AuthenticationManager.authenticate()
    ↓
UserDetailsServiceImpl.loadUserByUsername()
    ↓
Authentication 认证成功
    ↓
TokenService.createToken()
    ↓
Redis 存储登录信息
    ↓
返回 Token 和用户信息
```

### 2. 请求认证流程

```
HTTP 请求 → JwtAuthenticationTokenFilter
        ↓
解析 Token 请求头
        ↓
TokenService.getLoginUser() → Redis 获取登录信息
        ↓
创建 AuthenticationToken
        ↓
设置到 AuthenticationContextHolder
        ↓
后续业务使用 SecurityUtils.getLoginUser()
```

### 3. 权限校验流程

```
@PreAuthorize("@ss.hasPermi('system:user:list')")
    ↓
PermissionEvaluator.evaluate()
    ↓
SysPermissionService.hasPermi()
    ↓
SecurityUtils.getLoginUser()
    ↓
LoginUser.getPermissions()
    ↓
检查权限集合是否包含
    ↓
返回 true/false
```

---

## 使用示例

### Controller 中的权限控制

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    /**
     * 获取用户列表 - 需要 system:user:list 权限
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser user) {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }
    
    /**
     * 新增用户 - 需要 system:user:add 权限
     */
    @PreAuthorize("@ss.hasPermi('system:user:add')")
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        return toAjax(userService.insertUser(user));
    }
}
```

### 获取当前登录用户

```java
// 方式 1：使用 SecurityUtils
Long userId = SecurityUtils.getUserId();
String username = SecurityUtils.getUsername();
LoginUser loginUser = SecurityUtils.getLoginUser();

// 方式 2：Controller 参数注入
@GetMapping("/info")
public AjaxResult getUserInfo(@LoginUser LoginUser user) {
    return AjaxResult.success(user);
}
```

---

## 最佳实践

1. **Token 安全**: Token 有效期建议设置为 2 小时，敏感操作要求重新验证
2. **权限注解**: 优先使用 `@PreAuthorize` 注解进行权限控制
3. **登出清理**: 登出时必须清理 Redis 中的登录缓存
4. **异常处理**: 认证失败统一返回 401 状态码
5. **ThreadLocal 清理**: 请求结束后必须清理 AuthenticationContextHolder
6. **Token 刷新**: 前端检测到 Token 即将过期时自动刷新

# Web Service Web 服务模块

## 概述

`ruoyi-framework/web/service` 包提供 Web 层的核心服务类，包括用户登录、注册、Token 管理、权限校验等功能。

## 模块结构

```
web/service/
├── SysLoginService.java            # 登录服务
├── SysRegisterService.java         # 注册服务
├── TokenService.java               # Token 服务
├── SysPermissionService.java       # 权限服务
├── PermissionService.java          # 通用权限服务
├── SysPasswordService.java         # 密码服务
└── UserDetailsServiceImpl.java     # 用户详情服务
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/`

---

## 1. SysLoginService - 登录服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java`

**用途**: 处理用户登录请求，包括验证码校验、用户认证、Token 生成等

**核心方法**:

```java
@Component
public class SysLoginService {
    
    @Autowired
    private TokenService tokenService;
    
    @Resource
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private RedisCache redisCache;
    
    /**
     * 登录验证
     * @return Token 字符串
     */
    public String login(String username, String password, String code, String uuid) {
        // 1. 验证码校验
        validateCaptcha(username, code, uuid);
        
        // 2. 登录前置校验
        loginPreCheck(username, password);
        
        // 3. 用户验证
        Authentication authentication = null;
        try {
            UsernamePasswordAuthenticationToken authenticationToken = 
                new UsernamePasswordAuthenticationToken(username, password);
            AuthenticationContextHolder.setContext(authenticationToken);
            authentication = authenticationManager.authenticate(authenticationToken);
        } catch (BadCredentialsException e) {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.LOGIN_FAIL, "用户密码错误"
            ));
            throw new UserPasswordNotMatchException();
        } finally {
            AuthenticationContextHolder.clearContext();
        }
        
        // 4. 记录登录成功日志
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(
            username, Constants.LOGIN_SUCCESS, "登录成功"
        ));
        
        // 5. 生成 Token
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        recordLoginInfo(loginUser.getUserId());
        return tokenService.createToken(loginUser);
    }
    
    /**
     * 验证码校验
     */
    public void validateCaptcha(String username, String code, String uuid) {
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (captchaEnabled) {
            String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + StringUtils.nvl(uuid, "");
            String captcha = redisCache.getCacheObject(verifyKey);
            redisCache.deleteObject(verifyKey);
            if (captcha == null) {
                throw new CaptchaExpireException();
            }
            if (!code.equalsIgnoreCase(captcha)) {
                throw new CaptchaException();
            }
        }
    }
    
    /**
     * 登录前置校验
     */
    public void loginPreCheck(String username, String password) {
        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(password)) {
            throw new UserNotExistsException();
        }
        // IP 黑名单校验
        String blackStr = configService.selectConfigByKey("sys.login.blackIPList");
        if (IpUtils.isMatchedIp(blackStr, IpUtils.getIpAddr())) {
            throw new BlackListException();
        }
    }
    
    /**
     * 记录登录信息
     */
    public void recordLoginInfo(Long userId) {
        userService.updateLoginInfo(userId, IpUtils.getIpAddr(), DateUtils.getNowDate());
    }
}
```

**登录流程**:

```
登录请求
    ↓
验证码校验 (validateCaptcha)
    ↓
登录前置校验 (loginPreCheck)
    ↓
AuthenticationManager.authenticate()
    ↓
UserDetailsServiceImpl.loadUserByUsername()
    ↓
认证成功 → 创建 LoginUser
    ↓
TokenService.createToken()
    ↓
Redis 存储登录信息
    ↓
返回 Token 字符串
```

---

## 2. SysRegisterService - 注册服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysRegisterService.java`

**用途**: 处理用户注册请求

**核心方法**:

```java
@Component
public class SysRegisterService {
    
    @Autowired
    private ISysUserService userService;
    
    @Autowired
    private ISysConfigService configService;
    
    /**
     * 注册
     * @return 错误消息（为空表示注册成功）
     */
    public String register(RegisterBody registerBody) {
        String username = registerBody.getUsername();
        String password = registerBody.getPassword();
        
        // 1. 验证码校验
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (captchaEnabled) {
            validateCaptcha(username, registerBody.getCode(), registerBody.getUuid());
        }
        
        // 2. 参数校验
        if (StringUtils.isEmpty(username)) {
            return "用户名不能为空";
        } else if (StringUtils.isEmpty(password)) {
            return "用户密码不能为空";
        } else if (!userService.checkUserNameUnique(new SysUser(username))) {
            return "注册账号已存在";
        }
        
        // 3. 创建用户
        SysUser sysUser = new SysUser();
        sysUser.setUserName(username);
        sysUser.setNickName(username);
        sysUser.setPassword(SecurityUtils.encryptPassword(password));
        boolean regFlag = userService.registerUser(sysUser);
        
        if (regFlag) {
            // 4. 记录注册日志
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.REGISTER, "注册成功"
            ));
            return ""; // 成功返回空
        }
        return "注册失败，请联系系统管理人员";
    }
    
    /**
     * 验证码校验
     */
    public void validateCaptcha(String username, String code, String uuid) {
        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + StringUtils.nvl(uuid, "");
        String captcha = redisCache.getCacheObject(verifyKey);
        redisCache.deleteObject(verifyKey);
        if (captcha == null) {
            throw new CaptchaExpireException();
        }
        if (!code.equalsIgnoreCase(captcha)) {
            throw new CaptchaException();
        }
    }
}
```

**注册流程**:

```
注册请求 → 验证码校验 → 参数校验 → 用户名唯一性检查
    ↓
密码加密 → 创建用户 → 记录注册日志 → 返回结果
```

---

## 3. TokenService - Token 服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java`

**用途**: JWT Token 的创建、解析、验证和刷新

**核心方法**:

```java
@Component
public class TokenService {
    
    @Value("${token.expireTime}")
    private int expireTime; // 有效期（分钟）
    
    @Value("${token.secret}")
    private String secret;  // 密钥
    
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
        String token = resolveToken(request);
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
        loginUser.setExpireTime(loginUser.getLoginTime() + expireTime * MILLIS_MINUTE);
        String userKey = getTokenKey(loginUser.getToken());
        redisCache.setCacheObject(userKey, loginUser, expireTime, TimeUnit.MINUTES);
    }
    
    /**
     * 删除用户身份信息
     */
    public void delLoginUser(String token) {
        if (StringUtils.isNotEmpty(token)) {
            redisCache.deleteObject(getTokenKey(token));
        }
    }
}
```

---

## 4. SysPermissionService - 权限服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysPermissionService.java`

**用途**: 权限校验的核心服务，提供给 `@PreAuthorize` 注解使用（Bean 名为 "ss"）

**核心方法**:

```java
@Service("ss")
public class SysPermissionService {
    
    /**
     * 验证用户是否拥有某个权限
     */
    public boolean hasPermi(String permission) {
        if (StringUtils.isEmpty(permission)) {
            return false;
        }
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getPermissions() == null) {
            return false;
        }
        Set<String> permissions = loginUser.getPermissions();
        // 超级管理员拥有所有权限
        if (permissions.contains("*:*:*")) {
            return true;
        }
        return permissions.contains(permission);
    }
    
    /**
     * 验证用户是否拥有某个角色
     */
    public boolean hasRole(String role) {
        if (StringUtils.isEmpty(role)) {
            return false;
        }
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            return false;
        }
        Set<String> roles = loginUser.getRoles();
        // 超级管理员拥有所有角色
        if (roles.contains("admin")) {
            return true;
        }
        return roles.contains(role);
    }
}
```

**使用示例**:

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser user) { ... }
    
    @PreAuthorize("@ss.hasRole('admin')")
    @DeleteMapping("/{userId}")
    public AjaxResult remove(@PathVariable Long userId) { ... }
}
```

---

## 5. PermissionService - 通用权限服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/PermissionService.java`

**用途**: 通用的权限判断工具类

**核心方法**:

```java
@Component
public class PermissionService {
    
    /**
     * 验证用户是否拥有某一权限（满足任意一个即可）
     */
    public void checkPermissions(String... permissions) {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getPermissions() == null) {
            throw new ServiceException("未登录或权限不足");
        }
        Set<String> auths = loginUser.getPermissions();
        if (auths.contains("*:*:*")) {
            return;
        }
        for (String permission : permissions) {
            if (auths.contains(permission)) {
                return;
            }
        }
        throw new ServiceException("权限不足");
    }
    
    /**
     * 验证是否拥有多个权限（满足任意一个）
     */
    public boolean hasAnyPermi(String... permissions) {
        // ...
    }
    
    /**
     * 验证是否拥有多个角色（满足任意一个）
     */
    public boolean hasAnyRoles(String... roles) {
        // ...
    }
    
    /**
     * 验证是否缺少某个权限
     */
    public boolean lacksPermi(String permission) {
        return !hasPermi(permission);
    }
}
```

**使用示例**:

```java
@Autowired
private PermissionService permissionService;

// 检查权限
if (permissionService.hasPermi("system:user:list")) {
    // 有权限
}

// 检查多个权限（满足任意一个）
if (permissionService.hasAnyPermi("system:user:list", "system:user:query")) {
    // 有其中一个权限
}

// 检查是否缺少权限
if (permissionService.lacksPermi("system:user:add")) {
    // 没有添加权限
}
```

---

## 6. UserDetailsServiceImpl - 用户详情服务

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/UserDetailsServiceImpl.java`

**用途**: Spring Security 的用户加载器，实现 AuthenticationManager 认证

**核心实现**:

```java
@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    
    @Autowired
    private ISysUserService userService;
    
    @Autowired
    private SysPermissionService permissionService;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. 查询用户信息
        SysUser user = userService.selectUserByUserName(username);
        
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在");
        }
        
        // 2. 检查用户状态
        if (UserStatus.DELETED.getCode().equals(user.getDelFlag())) {
            throw new UsernameNotFoundException("用户已被删除");
        }
        if (UserStatus.DISABLE.getCode().equals(user.getStatus())) {
            throw new UsernameNotFoundException("用户已被停用");
        }
        
        // 3. 获取权限信息
        Set<String> dbRoles = userService.selectUserRoleByUserId(user.getUserId());
        Set<String> dbPerms = userService.selectUserPermissionByUserId(user.getUserId());
        
        // 4. 构建 LoginUser
        LoginUser loginUser = new LoginUser();
        loginUser.setUserId(user.getUserId());
        loginUser.setDeptId(user.getDeptId());
        loginUser.setUser(user);
        loginUser.setRoles(dbRoles);
        loginUser.setPermissions(dbPerms);
        
        return loginUser;
    }
}
```

---

## 最佳实践

1. **密码安全**: 使用 BCrypt 加密，永不存储明文密码
2. **Token 管理**: Token 有效期不宜过长，支持自动刷新
3. **验证码**: 登录/注册必须校验验证码，防止暴力破解
4. **重试限制**: 密码错误 5 次锁定账户 10 分钟
5. **日志记录**: 登录/注册操作必须记录日志
6. **权限校验**: 所有敏感接口必须添加权限注解

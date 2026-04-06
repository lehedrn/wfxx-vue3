# Web Service Web 服务模块

## 概述

`ruoyi-framework/web/service` 包提供了 Web 层的核心服务类，包括用户登录、注册、Token 管理、权限校验等功能。

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

---

## 1. SysLoginService - 登录服务

**用途**: 处理用户登录请求，包括验证码校验、用户认证、Token 生成等

**核心实现**:

```java
@Component
public class SysLoginService {
    
    @Autowired
    private TokenService tokenService;
    
    @Resource
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private RedisCache redisCache;
    
    @Autowired
    private ISysUserService userService;
    
    @Autowired
    private ISysConfigService configService;
    
    /**
     * 登录验证
     * 
     * @param username 用户名
     * @param password 密码
     * @param code 验证码
     * @param uuid 唯一标识
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
            // 调用 UserDetailsServiceImpl.loadUserByUsername
            authentication = authenticationManager.authenticate(authenticationToken);
        } catch (Exception e) {
            if (e instanceof BadCredentialsException) {
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                    username, Constants.LOGIN_FAIL, 
                    MessageUtils.message("user.password.not.match")
                ));
                throw new UserPasswordNotMatchException();
            } else {
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                    username, Constants.LOGIN_FAIL, e.getMessage()
                ));
                throw new ServiceException(e.getMessage());
            }
        } finally {
            AuthenticationContextHolder.clearContext();
        }
        
        // 4. 记录登录成功日志
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(
            username, Constants.LOGIN_SUCCESS, MessageUtils.message("user.login.success")
        ));
        
        // 5. 获取登录用户
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        
        // 6. 记录登录信息
        recordLoginInfo(loginUser.getUserId());
        
        // 7. 生成 Token
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
            if (captcha == null) {
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                    username, Constants.LOGIN_FAIL, MessageUtils.message("user.jcaptcha.expire")
                ));
                throw new CaptchaExpireException();
            }
            redisCache.deleteObject(verifyKey);
            if (!code.equalsIgnoreCase(captcha)) {
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                    username, Constants.LOGIN_FAIL, MessageUtils.message("user.jcaptcha.error")
                ));
                throw new CaptchaException();
            }
        }
    }
    
    /**
     * 登录前置校验
     */
    public void loginPreCheck(String username, String password) {
        // 用户名或密码为空
        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(password)) {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.LOGIN_FAIL, MessageUtils.message("not.null")
            ));
            throw new UserNotExistsException();
        }
        // 密码长度校验
        if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
                || password.length() > UserConstants.PASSWORD_MAX_LENGTH) {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.LOGIN_FAIL, MessageUtils.message("user.password.not.match")
            ));
            throw new UserPasswordNotMatchException();
        }
        // 用户名长度校验
        if (username.length() < UserConstants.USERNAME_MIN_LENGTH
                || username.length() > UserConstants.USERNAME_MAX_LENGTH) {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.LOGIN_FAIL, MessageUtils.message("user.password.not.match")
            ));
            throw new UserPasswordNotMatchException();
        }
        // IP 黑名单校验
        String blackStr = configService.selectConfigByKey("sys.login.blackIPList");
        if (IpUtils.isMatchedIp(blackStr, IpUtils.getIpAddr())) {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                username, Constants.LOGIN_FAIL, MessageUtils.message("login.blocked")
            ));
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
密码校验
    ↓
认证成功 → 创建 LoginUser
    ↓
TokenService.createToken()
    ↓
Redis 存储登录信息
    ↓
返回 Token 字符串
```

**注意**: 
- 方法签名：`login(String, String, String, String)` 返回 `String`（Token）
- 不使用 LoginBody 参数
- 返回 Token 字符串而非 LoginToken 对象
认证成功 → 创建 LoginUser
    ↓
TokenService.createToken()
    ↓
Redis 存储登录信息
    ↓
返回 Token
```

---

## 2. SysRegisterService - 注册服务

**用途**: 处理用户注册请求，包括验证码校验、用户名检查、密码加密、用户创建等

**核心实现**:

```java
@Component
public class SysRegisterService {
    
    @Autowired
    private ISysUserService userService;
    
    @Autowired
    private ISysConfigService configService;
    
    @Autowired
    private RedisCache redisCache;
    
    /**
     * 注册
     * 
     * @param registerBody 注册参数
     * @return 错误消息（为空表示注册成功）
     */
    public String register(RegisterBody registerBody) {
        String msg = "";
        String username = registerBody.getUsername();
        String password = registerBody.getPassword();
        SysUser sysUser = new SysUser();
        sysUser.setUserName(username);
        
        // 1. 验证码开关
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (captchaEnabled) {
            validateCaptcha(username, registerBody.getCode(), registerBody.getUuid());
        }
        
        // 2. 参数校验
        if (StringUtils.isEmpty(username)) {
            msg = "用户名不能为空";
        } else if (StringUtils.isEmpty(password)) {
            msg = "用户密码不能为空";
        } else if (username.length() < UserConstants.USERNAME_MIN_LENGTH
                || username.length() > UserConstants.USERNAME_MAX_LENGTH) {
            msg = "账户长度必须在 2 到 20 个字符之间";
        } else if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
                || password.length() > UserConstants.PASSWORD_MAX_LENGTH) {
            msg = "密码长度必须在 5 到 20 个字符之间";
        } else if (!userService.checkUserNameUnique(sysUser)) {
            msg = "保存用户'" + username + "'失败，注册账号已存在";
        } else {
            // 3. 创建用户
            sysUser.setNickName(username);
            sysUser.setPwdUpdateDate(DateUtils.getNowDate());
            sysUser.setPassword(SecurityUtils.encryptPassword(password));
            boolean regFlag = userService.registerUser(sysUser);
            if (!regFlag) {
                msg = "注册失败，请联系系统管理人员";
            } else {
                // 4. 记录登录日志
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                    username, Constants.REGISTER, MessageUtils.message("user.register.success")
                ));
            }
        }
        return msg;
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
注册请求
    ↓
验证码校验
    ↓
用户名/密码长度校验
    ↓
用户名唯一性检查
    ↓
密码加密
    ↓
创建用户
    ↓
记录注册日志
    ↓
返回错误消息（空表示成功）
```

**注意**: 
- 方法签名：`register(RegisterBody)` 返回 `String`（错误消息）
- 只检查用户名唯一性，不检查手机号和邮箱
- 返回空字符串表示注册成功，非空表示失败原因

---

## 3. TokenService - Token 服务

**用途**: JWT Token 的创建、解析、验证和刷新

**核心实现**:

```java
@Component
public class TokenService {
    
    // Token 有效期（分钟）
    private static final int EXPIRE_MINUTES = 120;
    // 刷新阈值（分钟）
    private static final int REFRESH_THRESHOLD = 20;
    // Token 密钥
    private static final String SECRET = "ruoyi-secret-key";
    
    @Autowired
    private RedisCache redisCache;
    
    /**
     * 创建 Token
     */
    public LoginToken createToken(LoginUser loginUser) {
        // 1. 生成 UUID 作为 Token
        String token = UUID.randomUUID().toString().replace("-", "");
        
        // 2. 设置过期时间
        loginUser.setExpireTime(System.currentTimeMillis() + EXPIRE_MINUTES * 60 * 1000);
        
        // 3. 存储到 Redis
        String loginKey = CacheConstants.LOGIN_TOKEN_KEY + token;
        redisCache.setCacheObject(loginKey, loginUser);
        
        // 4. 返回 Token 信息
        LoginToken loginToken = new LoginToken();
        loginToken.setToken(token);
        loginToken.setLoginUser(loginUser);
        
        return loginToken;
    }
    
    /**
     * 从请求中解析 Token
     */
    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(CacheConstants.HEADER);
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(CacheConstants.PREFIX)) {
            return bearerToken.substring(CacheConstants.PREFIX.length());
        }
        return null;
    }
    
    /**
     * 获取登录用户
     */
    public LoginUser getLoginUser(String token) {
        String loginKey = CacheConstants.LOGIN_TOKEN_KEY + token;
        return redisCache.getCacheObject(loginKey);
    }
    
    /**
     * 获取登录用户 (从请求)
     */
    public LoginUser getLoginUser(HttpServletRequest request) {
        String token = resolveToken(request);
        if (StringUtils.hasText(token)) {
            return getLoginUser(token);
        }
        return null;
    }
    
    /**
     * 验证 Token 是否有效
     */
    public boolean verifyToken(LoginUser loginUser) {
        long expireTime = loginUser.getExpireTime();
        long currentTime = System.currentTimeMillis();
        
        // 剩余时间小于阈值则刷新
        if ((expireTime - currentTime) < REFRESH_THRESHOLD * 60 * 1000) {
            return false;
        }
        return true;
    }
    
    /**
     * 刷新 Token 有效期
     */
    public void refreshToken(LoginUser loginUser) {
        loginUser.setExpireTime(System.currentTimeMillis() + EXPIRE_MINUTES * 60 * 1000);
        // 更新 Redis
        String token = getToken(loginUser);
        String loginKey = CacheConstants.LOGIN_TOKEN_KEY + token;
        redisCache.setCacheObject(loginKey, loginUser);
    }
    
    /**
     * 获取 Token (从 LoginUser)
     */
    private String getToken(LoginUser loginUser) {
        // 从 Redis 反查 Token
        Collection<String> keys = redisCache.keys(CacheConstants.LOGIN_TOKEN_KEY + "*");
        for (String key : keys) {
            LoginUser user = redisCache.getCacheObject(key);
            if (user != null && user.getUserId().equals(loginUser.getUserId())) {
                return key.replace(CacheConstants.LOGIN_TOKEN_KEY, "");
            }
        }
        return null;
    }
}
```

---

## 4. SysPermissionService - 权限服务

**用途**: 权限校验的核心服务，提供给 `@PreAuthorize` 注解使用

**核心实现**:

```java
@Service("ss")
public class SysPermissionService {
    
    /**
     * 验证用户是否拥有某个权限
     * 
     * @param permission 权限字符串
     * @return true-拥有权限 false-无权限
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
     * 验证用户是否拥有某个权限
     * 
     * @param loginUser 登录用户
     * @param permission 权限字符串
     * @return true-拥有权限 false-无权限
     */
    public boolean hasPermi(LoginUser loginUser, String permission) {
        if (loginUser == null || loginUser.getPermissions() == null) {
            return false;
        }
        
        Set<String> permissions = loginUser.getPermissions();
        if (permissions.contains("*:*:*")) {
            return true;
        }
        
        return permissions.contains(permission);
    }
    
    /**
     * 验证用户是否拥有某个角色
     * 
     * @param role 角色字符串
     * @return true-拥有角色 false-无角色
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
    
    /**
     * 验证用户是否拥有某个角色
     * 
     * @param loginUser 登录用户
     * @param role 角色字符串
     * @return true-拥有角色 false-无角色
     */
    public boolean hasRole(LoginUser loginUser, String role) {
        if (loginUser == null || loginUser.getRoles() == null) {
            return false;
        }
        
        Set<String> roles = loginUser.getRoles();
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
    
    /**
     * 需要 system:user:list 权限
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser user) {
        // ...
    }
    
    /**
     * 需要 admin 角色
     */
    @PreAuthorize("@ss.hasRole('admin')")
    @DeleteMapping("/{userId}")
    public AjaxResult remove(@PathVariable Long userId) {
        // ...
    }
}
```

---

## 5. PermissionService - 通用权限服务

**用途**: 通用的权限判断工具类

**核心实现**:

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
        // 超级管理员判断
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
     * 验证用户是否拥有某一角色（满足任意一个即可）
     */
    public void checkRoles(String... roles) {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            throw new ServiceException("未登录或角色不足");
        }
        
        Set<String> authRoles = loginUser.getRoles();
        // 超级管理员判断
        if (authRoles.contains("admin")) {
            return;
        }
        
        for (String role : roles) {
            if (authRoles.contains(role)) {
                return;
            }
        }
        throw new ServiceException("角色不足");
    }
    
    /**
     * 验证是否拥有某个权限
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
        if (permissions.contains("*:*:*")) {
            return true;
        }
        return permissions.contains(permission);
    }
    
    /**
     * 验证是否拥有多个权限（满足任意一个即可）
     */
    public boolean hasAnyPermi(String... permissions) {
        if (StringUtils.isEmpty(permissions) || permissions.length == 0) {
            return false;
        }
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getPermissions() == null) {
            return false;
        }
        Set<String> auths = loginUser.getPermissions();
        if (auths.contains("*:*:*")) {
            return true;
        }
        for (String permission : permissions) {
            if (auths.contains(permission)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * 验证是否拥有某个角色
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
        if (roles.contains("admin")) {
            return true;
        }
        return roles.contains(role);
    }
    
    /**
     * 验证是否拥有多个角色（满足任意一个即可）
     */
    public boolean hasAnyRoles(String... roles) {
        if (StringUtils.isEmpty(roles) || roles.length == 0) {
            return false;
        }
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            return false;
        }
        Set<String> authRoles = loginUser.getRoles();
        if (authRoles.contains("admin")) {
            return true;
        }
        for (String role : roles) {
            if (authRoles.contains(role)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * 验证是否缺少某个权限
     */
    public boolean lacksPermi(String permission) {
        return !hasPermi(permission);
    }
    
    /**
     * 验证是否缺少某个角色
     */
    public boolean lacksRole(String role) {
        return !hasRole(role);
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

// 检查角色
if (permissionService.hasRole("admin")) {
    // 是管理员
}

// 检查多个角色（满足任意一个）
if (permissionService.hasAnyRoles("admin", "manager")) {
    // 是管理员或经理
}

// 检查是否缺少权限
if (permissionService.lacksPermi("system:user:add")) {
    // 没有添加权限
}
```

---

## 7. UserDetailsServiceImpl - 用户详情服务

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

**使用示例**:

```java
// Spring Security 认证时自动调用
Authentication authentication = authenticationManager.authenticate(
    new UsernamePasswordAuthenticationToken(username, password)
);

// loadUserByUsername 方法会被调用
// 返回 LoginUser 对象
LoginUser loginUser = (LoginUser) authentication.getPrincipal();
```

**注意**: 
- 实现 `UserDetailsService` 接口
- 返回 `LoginUser` 对象（包含用户信息、角色、权限）
- 检查用户状态（删除、停用）
- 从 AuthenticationContextHolder 获取密码
- 重试次数存储到 Redis，锁定时间为配置值
- 超过重试次数抛出 `UserPasswordRetryLimitExceedException(maxRetryCount, lockTime)`

---

## 7. UserDetailsServiceImpl - 用户详情服务

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

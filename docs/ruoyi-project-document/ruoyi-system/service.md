# Service 业务逻辑层

## 概述

`ruoyi-system/service` 包提供了系统业务逻辑处理，包括接口定义和实现类。Service 层负责处理复杂的业务逻辑、事务管理和数据校验。

## 模块结构

```
service/
├── ISysUserService.java         # 用户服务接口
├── ISysRoleService.java         # 角色服务接口
├── ISysMenuService.java         # 菜单服务接口
├── ISysDeptService.java         # 部门服务接口
├── ISysDictTypeService.java     # 字典类型服务接口
├── ISysDictDataService.java     # 字典数据服务接口
├── ISysPostService.java         # 岗位服务接口
├── ISysConfigService.java       # 参数配置服务接口
├── ISysNoticeService.java       # 通知公告服务接口
├── ISysNoticeReadService.java   # 公告已读服务接口
├── ISysOperLogService.java      # 操作日志服务接口
├── ISysLogininforService.java   # 登录日志服务接口
├── ISysUserOnlineService.java   # 在线用户服务接口
└── impl/
    ├── SysUserServiceImpl.java    # 用户服务实现
    ├── SysRoleServiceImpl.java    # 角色服务实现
    ├── SysMenuServiceImpl.java    # 菜单服务实现
    ├── SysDeptServiceImpl.java    # 部门服务实现
    ├── SysDictTypeServiceImpl.java  # 字典类型服务实现
    ├── SysDictDataServiceImpl.java  # 字典数据服务实现
    ├── SysPostServiceImpl.java    # 岗位服务实现
    ├── SysConfigServiceImpl.java  # 参数配置服务实现
    ├── SysNoticeServiceImpl.java  # 通知公告服务实现
    ├── SysNoticeReadServiceImpl.java  # 公告已读服务实现
    ├── SysOperLogServiceImpl.java # 操作日志服务实现
    ├── SysLogininforServiceImpl.java  # 登录日志服务实现
    └── SysUserOnlineServiceImpl.java  # 在线用户服务实现
```

---

## 服务接口详解

### 1. ISysPostService - 岗位服务接口

**接口路径**: `com.ruoyi.system.service.ISysPostService`

```java
public interface ISysPostService {
    
    // ========== 查询操作 ==========
    
    /**
     * 查询岗位信息集合
     * @param post 岗位信息（查询条件）
     * @return 岗位信息集合
     */
    List<SysPost> selectPostList(SysPost post);
    
    /**
     * 查询所有岗位
     * @return 岗位列表
     */
    List<SysPost> selectPostAll();
    
    /**
     * 通过岗位 ID 查询岗位信息
     * @param postId 岗位 ID
     * @return 岗位信息
     */
    SysPost selectPostById(Long postId);
    
    /**
     * 根据用户 ID 获取岗位选择框列表
     * @param userId 用户 ID
     * @return 选中岗位 ID 列表
     */
    List<Long> selectPostListByUserId(Long userId);
    
    // ========== 唯一性校验 ==========
    
    /**
     * 校验岗位名称是否唯一
     * @param post 岗位信息
     * @return UNIQUE-唯一，NOT_UNIQUE-不唯一
     */
    boolean checkPostNameUnique(SysPost post);
    
    /**
     * 校验岗位编码是否唯一
     * @param post 岗位信息
     * @return UNIQUE-唯一，NOT_UNIQUE-不唯一
     */
    boolean checkPostCodeUnique(SysPost post);
    
    // ========== 统计操作 ==========
    
    /**
     * 通过岗位 ID 查询岗位使用数量
     * @param postId 岗位 ID
     * @return 使用数量
     */
    int countUserPostById(Long postId);
    
    // ========== 删除操作 ==========
    
    /**
     * 删除岗位信息
     * @param postId 岗位 ID
     * @return 影响行数
     */
    int deletePostById(Long postId);
    
    /**
     * 批量删除岗位信息
     * @param postIds 需要删除的岗位 ID 数组
     * @return 影响行数
     */
    int deletePostByIds(Long[] postIds);
    
    // ========== 新增操作 ==========
    
    /**
     * 新增保存岗位信息
     * @param post 岗位信息
     * @return 影响行数
     */
    int insertPost(SysPost post);
    
    // ========== 修改操作 ==========
    
    /**
     * 修改保存岗位信息
     * @param post 岗位信息
     * @return 影响行数
     */
    int updatePost(SysPost post);
}
```

---

### 2. ISysConfigService - 参数配置服务接口

**接口路径**: `com.ruoyi.system.service.ISysConfigService`

```java
public interface ISysConfigService {
    
    /**
     * 查询参数配置信息
     * @param configId 参数配置 ID
     * @return 参数配置信息
     */
    SysConfig selectConfigById(Long configId);
    
    /**
     * 根据键名查询参数配置信息
     * @param configKey 参数键名
     * @return 参数键值
     */
    String selectConfigByKey(String configKey);
    
    /**
     * 获取验证码开关
     * @return true 开启，false 关闭
     */
    boolean selectCaptchaEnabled();
    
    /**
     * 查询参数配置列表
     * @param config 参数配置信息（查询条件）
     * @return 参数配置集合
     */
    List<SysConfig> selectConfigList(SysConfig config);
    
    /**
     * 新增参数配置
     * @param config 参数配置信息
     * @return 结果
     */
    int insertConfig(SysConfig config);
    
    /**
     * 修改参数配置
     * @param config 参数配置信息
     * @return 结果
     */
    int updateConfig(SysConfig config);
    
    /**
     * 批量删除参数信息
     * @param configIds 需要删除的参数 ID 数组
     */
    void deleteConfigByIds(Long[] configIds);
    
    // ========== 缓存管理 ==========
    
    /**
     * 加载参数缓存数据
     */
    void loadingConfigCache();
    
    /**
     * 清空参数缓存数据
     */
    void clearConfigCache();
    
    /**
     * 重置参数缓存数据
     */
    void resetConfigCache();
    
    /**
     * 校验参数键名是否唯一
     * @param config 参数信息
     * @return 结果
     */
    boolean checkConfigKeyUnique(SysConfig config);
}
```

---

### 3. ISysNoticeService - 通知公告服务接口

**接口路径**: `com.ruoyi.system.service.ISysNoticeService`

```java
public interface ISysNoticeService {
    
    /**
     * 查询公告信息
     * @param noticeId 公告 ID
     * @return 公告信息
     */
    SysNotice selectNoticeById(Long noticeId);
    
    /**
     * 查询公告列表
     * @param notice 公告信息（查询条件）
     * @return 公告集合
     */
    List<SysNotice> selectNoticeList(SysNotice notice);
    
    /**
     * 新增公告
     * @param notice 公告信息
     * @return 结果
     */
    int insertNotice(SysNotice notice);
    
    /**
     * 修改公告
     * @param notice 公告信息
     * @return 结果
     */
    int updateNotice(SysNotice notice);
    
    /**
     * 批量删除公告
     * @param noticeIds 需要删除的公告 ID 数组
     */
    void deleteNoticeByIds(Long[] noticeIds);
}
```

---

### 4. ISysNoticeReadService - 公告已读服务接口

**接口路径**: `com.ruoyi.system.service.ISysNoticeReadService`

```java
public interface ISysNoticeReadService {
    
    /**
     * 标记已读（幂等，重复调用不报错）
     * @param noticeId 公告 ID
     * @param userId 用户 ID
     */
    void markRead(Long noticeId, Long userId);
    
    /**
     * 查询某用户未读公告数量
     * @param userId 用户 ID
     * @return 未读数量
     */
    int selectUnreadCount(Long userId);
    
    /**
     * 查询公告列表并标记当前用户已读状态（用于首页展示）
     * @param userId 用户 ID
     * @param limit 最多返回条数
     * @return 带 isRead 标记的公告列表
     */
    List<SysNotice> selectNoticeListWithReadStatus(Long userId, int limit);
    
    /**
     * 批量标记已读
     * @param userId 用户 ID
     * @param noticeIds 公告 ID 数组
     */
    void markReadBatch(Long userId, Long[] noticeIds);
    
    /**
     * 删除公告时清理对应已读记录
     * @param noticeIds 公告 ID 数组
     */
    void deleteByNoticeIds(Long[] noticeIds);
}
```

**使用说明**:

```java
@Autowired
private ISysNoticeReadService noticeReadService;

// 标记单条公告为已读
noticeReadService.markRead(noticeId, userId);

// 查询用户未读公告数量
int unreadCount = noticeReadService.selectUnreadCount(userId);

// 查询带已读状态的公告列表（首页展示）
List<SysNotice> notices = noticeReadService.selectNoticeListWithReadStatus(userId, 10);

// 批量标记已读
Long[] noticeIds = {1L, 2L, 3L};
noticeReadService.markReadBatch(userId, noticeIds);

// 删除公告时清理记录
noticeReadService.deleteByNoticeIds(noticeIds);
```

---

### 5. ISysOperLogService - 操作日志服务接口

**接口路径**: `com.ruoyi.system.service.ISysOperLogService`

```java
public interface ISysOperLogService {
    
    /**
     * 新增操作日志
     * @param operLog 操作日志对象
     */
    void insertOperlog(SysOperLog operLog);
    
    /**
     * 查询系统操作日志集合
     * @param operLog 操作日志对象（查询条件）
     * @return 操作日志集合
     */
    TableDataInfo selectOperLogList(SysOperLog operLog);
    
    /**
     * 批量删除系统操作日志
     * @param operIds 需要删除的操作日志 ID 数组
     * @return 结果
     */
    int deleteOperLogByIds(Long[] operIds);
    
    /**
     * 查询操作日志详细
     * @param operId 操作 ID
     * @return 操作日志对象
     */
    SysOperLog selectOperLogById(Long operId);
    
    /**
     * 清空操作日志
     */
    void cleanOperLog();
}
```

---

### 6. ISysLogininforService - 登录日志服务接口

**接口路径**: `com.ruoyi.system.service.ISysLogininforService`

```java
public interface ISysLogininforService {
    
    /**
     * 新增登录日志
     * @param logininfor 登录日志对象
     */
    void insertLogininfor(SysLogininfor logininfor);
    
    /**
     * 查询系统登录日志集合
     * @param logininfor 登录日志对象（查询条件）
     * @return 登录日志集合
     */
    TableDataInfo selectLogininforList(SysLogininfor logininfor);
    
    /**
     * 批量删除系统登录日志
     * @param infoIds 需要删除的登录日志 ID 数组
     * @return 结果
     */
    int deleteLogininforByIds(Long[] infoIds);
    
    /**
     * 清空系统登录日志
     */
    void cleanLogininfor();
    
    /**
     * 记录账户锁定
     * @param userName 用户名
     * @param isIncrement 是否增加锁定次数
     */
    void recordLoginInfo(String userName, boolean isIncrement);
}
```

---

### 7. ISysUserOnlineService - 在线用户服务接口

**接口路径**: `com.ruoyi.system.service.ISysUserOnlineService`

```java
public interface ISysUserOnlineService {
    
    /**
     * 通过登录地址查询信息
     * @param ipaddr 登录地址
     * @param user 用户信息
     * @return 在线用户信息
     */
    SysUserOnline selectOnlineByIpaddr(String ipaddr, LoginUser user);
    
    /**
     * 通过用户名称查询信息
     * @param userName 用户名称
     * @param user 用户信息
     * @return 在线用户信息
     */
    SysUserOnline selectOnlineByUserName(String userName, LoginUser user);
    
    /**
     * 通过登录地址/用户名称查询信息
     * @param ipaddr 登录地址
     * @param userName 用户名称
     * @param user 用户信息
     * @return 在线用户信息
     */
    SysUserOnline selectOnlineByInfo(String ipaddr, String userName, LoginUser user);
    
    /**
     * 设置在线用户信息
     * @param user 用户信息
     * @return 在线用户
     */
    SysUserOnline loginUserToUserOnline(LoginUser user);
}
```

**使用说明**:

```java
@Autowired
private ISysUserOnlineService userOnlineService;

// 通过 IP 查询在线用户
SysUserOnline online = userOnlineService.selectOnlineByIpaddr("192.168.1.100", loginUser);

// 通过用户名查询在线用户
SysUserOnline online = userOnlineService.selectOnlineByUserName("admin", loginUser);

// 通过 IP 和用户名查询
SysUserOnline online = userOnlineService.selectOnlineByInfo("192.168.1.100", "admin", loginUser);

// 将 LoginUser 转换为 SysUserOnline
SysUserOnline online = userOnlineService.loginUserToUserOnline(loginUser);
```

---

## 服务实现类详解

### SysPostServiceImpl - 岗位服务实现

**实现路径**: `com.ruoyi.system.service.impl.SysPostServiceImpl`

```java
@Service
public class SysPostServiceImpl implements ISysPostService {
    
    @Autowired
    private SysPostMapper postMapper;
    
    @Autowired
    private SysUserPostMapper userPostMapper;
    
    /**
     * 查询岗位信息集合
     */
    @Override
    public List<SysPost> selectPostList(SysPost post) {
        return postMapper.selectPostList(post);
    }
    
    /**
     * 查询所有岗位
     */
    @Override
    public List<SysPost> selectPostAll() {
        return postMapper.selectPostAll();
    }
    
    /**
     * 通过岗位 ID 查询岗位信息
     */
    @Override
    public SysPost selectPostById(Long postId) {
        return postMapper.selectPostById(postId);
    }
    
    /**
     * 根据用户 ID 获取岗位选择框列表
     */
    @Override
    public List<Long> selectPostListByUserId(Long userId) {
        return postMapper.selectPostListByUserId(userId);
    }
    
    /**
     * 校验岗位名称是否唯一
     */
    @Override
    public boolean checkPostNameUnique(SysPost post) {
        Long postId = StringUtils.isNull(post.getPostId()) ? -1L : post.getPostId();
        SysPost info = postMapper.checkPostNameUnique(post.getPostName());
        if (StringUtils.isNotNull(info) && info.getPostId().longValue() != postId.longValue()) {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }
    
    /**
     * 校验岗位编码是否唯一
     */
    @Override
    public boolean checkPostCodeUnique(SysPost post) {
        Long postId = StringUtils.isNull(post.getPostId()) ? -1L : post.getPostId();
        SysPost info = postMapper.checkPostCodeUnique(post.getPostCode());
        if (StringUtils.isNotNull(info) && info.getPostId().longValue() != postId.longValue()) {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }
    
    /**
     * 通过岗位 ID 查询岗位使用数量
     */
    @Override
    public int countUserPostById(Long postId) {
        return userPostMapper.countUserPostById(postId);
    }
    
    /**
     * 删除岗位信息（带检查）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePostById(Long postId) {
        // 检查岗位是否已被用户使用
        if (countUserPostById(postId) > 0) {
            SysPost post = selectPostById(postId);
            throw new ServiceException(String.format("%1$s已分配，不能删除", post.getPostName()));
        }
        return postMapper.deletePostById(postId);
    }
    
    /**
     * 批量删除岗位信息（带检查）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePostByIds(Long[] postIds) {
        for (Long postId : postIds) {
            SysPost post = selectPostById(postId);
            if (countUserPostById(postId) > 0) {
                throw new ServiceException(String.format("%1$s已分配，不能删除", post.getPostName()));
            }
        }
        return postMapper.deletePostByIds(postIds);
    }
    
    /**
     * 新增保存岗位信息
     */
    @Override
    public int insertPost(SysPost post) {
        return postMapper.insertPost(post);
    }
    
    /**
     * 修改保存岗位信息
     */
    @Override
    public int updatePost(SysPost post) {
        return postMapper.updatePost(post);
    }
}
```

---

### SysConfigServiceImpl - 参数配置服务实现

**实现路径**: `com.ruoyi.system.service.impl.SysConfigServiceImpl`

```java
@Service
public class SysConfigServiceImpl implements ISysConfigService {
    
    @Autowired
    private SysConfigMapper configMapper;
    
    @Autowired
    private RedisCache redisCache;
    
    /**
     * 项目启动时，初始化参数到缓存
     */
    @PostConstruct
    public void init() {
        loadingConfigCache();
    }
    
    /**
     * 根据键名查询参数配置信息（先查缓存，缓存不存在查数据库）
     */
    @Override
    public String selectConfigByKey(String configKey) {
        String configValue = Convert.toStr(redisCache.getCacheObject(getCacheKey(configKey)));
        if (StringUtils.isNotEmpty(configValue)) {
            return configValue;
        }
        SysConfig config = new SysConfig();
        config.setConfigKey(configKey);
        SysConfig retConfig = configMapper.selectConfig(config);
        if (StringUtils.isNotNull(retConfig)) {
            redisCache.setCacheObject(getCacheKey(configKey), retConfig.getConfigValue());
            return retConfig.getConfigValue();
        }
        return StringUtils.EMPTY;
    }
    
    /**
     * 获取验证码开关
     */
    @Override
    public boolean selectCaptchaEnabled() {
        String captchaEnabled = selectConfigByKey("sys.account.captchaEnabled");
        if (StringUtils.isEmpty(captchaEnabled)) {
            return true;
        }
        return Convert.toBool(captchaEnabled);
    }
    
    /**
     * 加载参数缓存数据
     */
    @Override
    public void loadingConfigCache() {
        List<SysConfig> configsList = configMapper.selectConfigList(new SysConfig());
        for (SysConfig config : configsList) {
            redisCache.setCacheObject(getCacheKey(config.getConfigKey()), config.getConfigValue());
        }
    }
    
    /**
     * 清空参数缓存数据
     */
    @Override
    public void clearConfigCache() {
        Collection<String> keys = redisCache.keys(CacheConstants.SYS_CONFIG_KEY + "*");
        redisCache.deleteObject(keys);
    }
    
    /**
     * 重置参数缓存数据
     */
    @Override
    public void resetConfigCache() {
        clearConfigCache();
        loadingConfigCache();
    }
    
    /**
     * 新增参数配置（同步更新缓存）
     */
    @Override
    public int insertConfig(SysConfig config) {
        int row = configMapper.insertConfig(config);
        if (row > 0) {
            redisCache.setCacheObject(getCacheKey(config.getConfigKey()), config.getConfigValue());
        }
        return row;
    }
    
    /**
     * 修改参数配置（同步更新缓存）
     */
    @Override
    public int updateConfig(SysConfig config) {
        SysConfig temp = configMapper.selectConfigById(config.getConfigId());
        if (!StringUtils.equals(temp.getConfigKey(), config.getConfigKey())) {
            redisCache.deleteObject(getCacheKey(temp.getConfigKey()));
        }
        int row = configMapper.updateConfig(config);
        if (row > 0) {
            redisCache.setCacheObject(getCacheKey(config.getConfigKey()), config.getConfigValue());
        }
        return row;
    }
    
    /**
     * 批量删除参数信息（同步删除缓存）
     */
    @Override
    public void deleteConfigByIds(Long[] configIds) {
        for (Long configId : configIds) {
            SysConfig config = selectConfigById(configId);
            if (StringUtils.equals(UserConstants.YES, config.getConfigType())) {
                throw new ServiceException(String.format("内置参数【%1$s】不能删除 ", config.getConfigKey()));
            }
            configMapper.deleteConfigById(configId);
            redisCache.deleteObject(getCacheKey(config.getConfigKey()));
        }
    }
    
    /**
     * 校验参数键名是否唯一
     */
    @Override
    public boolean checkConfigKeyUnique(SysConfig config) {
        Long configId = StringUtils.isNull(config.getConfigId()) ? -1L : config.getConfigId();
        SysConfig info = configMapper.checkConfigKeyUnique(config.getConfigKey());
        if (StringUtils.isNotNull(info) && info.getConfigId().longValue() != configId.longValue()) {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }
    
    /**
     * 设置 cache key
     */
    private String getCacheKey(String configKey) {
        return CacheConstants.SYS_CONFIG_KEY + configKey;
    }
}
```

---

## Service 层使用示例

### Controller 中使用 Service

```java
@RestController
@RequestMapping("/system/post")
public class SysPostController {
    
    @Autowired
    private ISysPostService postService;
    
    /**
     * 获取岗位列表
     */
    @GetMapping("/list")
    public TableDataInfo list(SysPost post) {
        startPage(); // 分页
        List<SysPost> list = postService.selectPostList(post);
        return getDataTable(list);
    }
    
    /**
     * 获取岗位详情
     */
    @GetMapping("/{postId}")
    public AjaxResult getInfo(@PathVariable Long postId) {
        return success(postService.selectPostById(postId));
    }
    
    /**
     * 新增岗位
     */
    @PostMapping
    public AjaxResult add(@RequestBody SysPost post) {
        // 校验岗位名称
        if (!postService.checkPostNameUnique(post)) {
            return error("新增岗位'" + post.getPostName() + "'失败，岗位名称已存在");
        }
        // 校验岗位编码
        if (!postService.checkPostCodeUnique(post)) {
            return error("新增岗位'" + post.getPostName() + "'失败，岗位编码已存在");
        }
        return toAjax(postService.insertPost(post));
    }
    
    /**
     * 修改岗位
     */
    @PutMapping
    public AjaxResult edit(@RequestBody SysPost post) {
        // 校验岗位名称
        if (!postService.checkPostNameUnique(post)) {
            return error("修改岗位'" + post.getPostName() + "'失败，岗位名称已存在");
        }
        // 校验岗位编码
        if (!postService.checkPostCodeUnique(post)) {
            return error("修改岗位'" + post.getPostName() + "'失败，岗位编码已存在");
        }
        return toAjax(postService.updatePost(post));
    }
    
    /**
     * 删除岗位
     */
    @DeleteMapping("/{postIds}")
    public AjaxResult remove(@PathVariable Long[] postIds) {
        return toAjax(postService.deletePostByIds(postIds));
    }
}
```

### Service 层调用其他 Service

```java
@Service
public class SysUserServiceImpl implements ISysUserService {
    
    @Autowired
    private SysUserMapper userMapper;
    
    @Autowired
    private SysPostMapper postMapper;
    
    @Autowired
    private ISysPostService postService;
    
    @Autowired
    private PasswordService passwordService;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertUser(SysUser user) {
        // 1. 新增用户
        int rows = userMapper.insertUser(user);
        
        // 2. 新增用户岗位关联
        if (user.getPostIds() != null && user.getPostIds().length > 0) {
            for (Long postId : user.getPostIds()) {
                SysUserPost up = new SysUserPost();
                up.setUserId(user.getUserId());
                up.setPostId(postId);
                userPostMapper.insertUserPost(up);
            }
        }
        
        return rows;
    }
}
```

---

## 事务管理

### @Transactional 注解使用

```java
@Service
public class SysPostServiceImpl implements ISysPostService {
    
    /**
     * 删除岗位（带事务）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePostById(Long postId) {
        // 检查岗位是否已被使用
        if (countUserPostById(postId) > 0) {
            throw new ServiceException("岗位已分配，不能删除");
        }
        return postMapper.deletePostById(postId);
    }
    
    /**
     * 批量删除岗位（带事务）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePostByIds(Long[] postIds) {
        for (Long postId : postIds) {
            SysPost post = selectPostById(postId);
            if (countUserPostById(postId) > 0) {
                throw new ServiceException(
                    String.format("%1$s已分配，不能删除", post.getPostName())
                );
            }
        }
        return postMapper.deletePostByIds(postIds);
    }
}
```

### 事务传播行为

```java
@Service
public class SysUserServiceImpl implements ISysUserService {
    
    /**
     * 默认事务传播行为：REQUIRED（如果当前存在事务，则加入该事务；
     * 如果当前没有事务，则创建一个新的事务）
     */
    @Transactional(propagation = Propagation.REQUIRED)
    @Override
    public int insertUser(SysUser user) {
        // ...
    }
    
    /**
     * 支持当前事务，如果当前没有事务，就以非事务方式执行
     */
    @Transactional(propagation = Propagation.SUPPORTS)
    @Override
    public SysUser selectUserById(Long userId) {
        // ...
    }
}
```

---

## 异常处理

### ServiceException 使用

```java
@Service
public class SysPostServiceImpl implements ISysPostService {
    
    @Override
    public int deletePostById(Long postId) {
        SysPost post = selectPostById(postId);
        if (countUserPostById(postId) > 0) {
            // 抛出自定义业务异常
            throw new ServiceException(
                String.format("%1$s已分配，不能删除", post.getPostName())
            );
        }
        return postMapper.deletePostById(postId);
    }
}
```

### 异常统一处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    /**
     * 业务异常处理
     */
    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e) {
        Integer code = e.getCode();
        return StringUtils.isNotNull(code) 
            ? AjaxResult.error(code, e.getMessage()) 
            : AjaxResult.error(e.getMessage());
    }
}
```

---

## 缓存管理

### Redis 缓存使用

```java
@Service
public class SysConfigServiceImpl implements ISysConfigService {
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    /**
     * 查询带缓存
     */
    @Override
    public String selectConfigByKey(String configKey) {
        // 1. 查询缓存
        String configValue = redisTemplate.opsForValue().get(getCacheKey(configKey));
        if (StringUtils.isNotEmpty(configValue)) {
            return configValue;
        }
        
        // 2. 查询数据库
        SysConfig config = configMapper.selectConfigByKey(configKey);
        if (StringUtils.isNotNull(config)) {
            // 3. 更新缓存
            redisTemplate.opsForValue().set(
                getCacheKey(configKey), 
                config.getConfigValue()
            );
            return config.getConfigValue();
        }
        
        return null;
    }
    
    /**
     * 删除缓存
     */
    @Override
    public void deleteConfigByIds(Long[] configIds) {
        for (Long configId : configIds) {
            SysConfig config = selectConfigById(configId);
            // 删除缓存
            redisTemplate.delete(getCacheKey(config.getConfigKey()));
        }
    }
}
```

### 缓存注解使用

```java
@Service
public class SysDictTypeServiceImpl implements ISysDictTypeService {
    
    /**
     * 查询字典类型（带缓存）
     */
    @Cacheable(value = "dict_type", key = "#dictType")
    @Override
    public SysDictType selectDictTypeById(Long dictTypeId) {
        return dictTypeMapper.selectDictTypeById(dictTypeId);
    }
    
    /**
     * 删除字典类型（清除缓存）
     */
    @CacheEvict(value = "dict_type", key = "#dictType")
    @Override
    public int deleteDictTypeById(Long dictTypeId) {
        return dictTypeMapper.deleteDictTypeById(dictTypeId);
    }
    
    /**
     * 修改字典类型（清除缓存）
     */
    @CachePut(value = "dict_type", key = "#dictType.dictType")
    @Override
    public int updateDictType(SysDictType dictType) {
        return dictTypeMapper.updateDictType(dictType);
    }
}
```

---

## 最佳实践

### 1. Service 层职责

- 处理复杂的业务逻辑
- 事务管理
- 数据校验
- 缓存管理
- 调用多个 Mapper

### 2. 事务使用原则

```java
// 推荐：在 Service 层添加事务
@Service
public class SysUserServiceImpl implements ISysUserService {
    
    @Transactional(rollbackFor = Exception.class)
    @Override
    public int insertUser(SysUser user) {
        // 新增用户
        userMapper.insertUser(user);
        // 新增用户岗位关联
        for (Long postId : user.getPostIds()) {
            userPostMapper.insertUserPost(...);
        }
    }
}
```

### 3. 异常抛出

```java
// 推荐：使用 ServiceException 抛出业务异常
if (countUserPostById(postId) > 0) {
    throw new ServiceException("岗位已分配，不能删除");
}

// 不推荐：直接抛出 RuntimeException
throw new RuntimeException("岗位已分配，不能删除");
```

### 4. 日志记录

```java
@Service
public class SysOperLogServiceImpl implements ISysOperLogService {
    
    private static final Logger log = LoggerFactory.getLogger(
        SysOperLogServiceImpl.class
    );
    
    @Override
    public void cleanOperLog() {
        log.info("清空操作日志");
        operLogMapper.cleanOperLog();
    }
}
```

### 5. 避免循环依赖

```java
// 推荐：使用接口注入
@Autowired
private ISysPostService postService;

// 不推荐：使用实现类注入
@Autowired
private SysPostServiceImpl postService;
```

---

## 补充：核心 Service 接口

### ISysUserService - 用户服务接口

**接口路径**: `com.ruoyi.system.service.ISysUserService`

```java
public interface ISysUserService {
    
    /**
     * 根据条件分页查询用户列表
     */
    List<SysUser> selectUserList(SysUser user);
    
    /**
     * 通过用户名查询用户
     */
    SysUser selectUserByUserName(String userName);
    
    /**
     * 通过用户 ID 查询用户
     */
    SysUser selectUserById(Long userId);
    
    /**
     * 根据用户 ID 查询用户所属角色组
     */
    String selectUserRoleGroup(String userName);
    
    /**
     * 根据用户 ID 查询用户所属岗位组
     */
    String selectUserPostGroup(String userName);
    
    /**
     * 校验用户名称是否唯一
     */
    boolean checkUserNameUnique(SysUser user);
    
    /**
     * 校验手机号码是否唯一
     */
    boolean checkPhoneUnique(SysUser user);
    
    /**
     * 校验邮箱是否唯一
     */
    boolean checkEmailUnique(SysUser user);
    
    /**
     * 新增用户信息
     */
    int insertUser(SysUser user);
    
    /**
     * 修改用户信息
     */
    int updateUser(SysUser user);
    
    /**
     * 删除用户信息
     */
    int deleteUserById(Long userId);
    
    /**
     * 批量删除用户信息
     */
    int deleteUserByIds(Long[] userIds);
    
    /**
     * 保存用户和岗位关联
     */
    void insertUserAndPost(SysUser user);
    
    /**
     * 修改用户状态
     */
    int updateUserStatus(SysUser user);
}
```

### ISysRoleService - 角色服务接口

**接口路径**: `com.ruoyi.system.service.ISysRoleService`

```java
public interface ISysRoleService {
    
    /**
     * 根据条件分页查询角色数据
     */
    List<SysRole> selectRoleList(SysRole role);
    
    /**
     * 根据用户 ID 查询角色列表
     */
    List<SysRole> selectRolesByUserId(Long userId);
    
    /**
     * 根据用户 ID 查询角色权限
     */
    Set<String> selectRolePermissionByUserId(Long userId);
    
    /**
     * 查询所有角色
     */
    List<SysRole> selectRoleAll();
    
    /**
     * 根据用户 ID 获取角色选择框列表
     */
    List<Long> selectRoleListByUserId(Long userId);
    
    /**
     * 通过角色 ID 查询角色
     */
    SysRole selectRoleById(Long roleId);
    
    /**
     * 校验角色名称是否唯一
     */
    boolean checkRoleNameUnique(SysRole role);
    
    /**
     * 校验角色权限是否唯一
     */
    boolean checkRoleKeyUnique(SysRole role);
    
    /**
     * 通过角色 ID 查询已分配用户角色列表
     */
    List<SysUser> selectAllocatedList(SysUser user);
    
    /**
     * 通过角色 ID 查询未分配用户角色列表
     */
    List<SysUser> selectUnallocatedList(SysUser user);
    
    /**
     * 新增角色信息
     */
    int insertRole(SysRole role);
    
    /**
     * 修改角色信息
     */
    int updateRole(SysRole role);
    
    /**
     * 删除角色信息
     */
    int deleteRoleById(Long roleId);
    
    /**
     * 批量删除角色信息
     */
    int deleteRoleByIds(Long[] roleIds);
    
    /**
     * 批量新增角色菜单权限
     */
    void insertRoleMenu(SysRole role);
    
    /**
     * 批量删除角色菜单权限
     */
    void deleteRoleMenu(SysRole role);
}
```

### ISysMenuService - 菜单服务接口

**接口路径**: `com.ruoyi.system.service.ISysMenuService`

```java
public interface ISysMenuService {
    
    /**
     * 根据条件查询菜单集合
     */
    List<SysMenu> selectMenuList(SysMenu menu);
    
    /**
     * 根据用户 ID 查询权限
     */
    Set<String> selectMenuPermsByUserId(Long userId);
    
    /**
     * 根据用户 ID 查询菜单树信息
     */
    List<SysMenu> selectMenuTreeByUserId(Long userId);
    
    /**
     * 查询菜单树信息
     */
    List<SysMenu> selectMenuTreeAll();
    
    /**
     * 通过菜单 ID 查询菜单
     */
    SysMenu selectMenuById(Long menuId);
    
    /**
     * 通过用户 ID 查询菜单
     */
    List<SysMenu> selectMenusByUserId(Long userId);
    
    /**
     * 新增菜单信息
     */
    int insertMenu(SysMenu menu);
    
    /**
     * 修改菜单信息
     */
    int updateMenu(SysMenu menu);
    
    /**
     * 删除菜单信息
     */
    int deleteMenuById(Long menuId);
    
    /**
     * 批量删除菜单信息
     */
    int deleteMenuByIds(Long[] menuIds);
    
    /**
     * 校验菜单名称是否唯一
     */
    boolean checkMenuNameUnique(SysMenu menu);
}
```

### ISysDeptService - 部门服务接口

**接口路径**: `com.ruoyi.system.service.ISysDeptService`

```java
public interface ISysDeptService {
    
    /**
     * 查询部门管理集合
     */
    List<SysDept> selectDeptList(SysDept dept);
    
    /**
     * 查询部门树
     */
    List<SysDept> selectDeptTreeList(SysDept dept);
    
    /**
     * 根据 ID 查询部门
     */
    SysDept selectDeptById(Long deptId);
    
    /**
     * 查询部门是否存在下级
     */
    boolean hasChildByDeptId(Long deptId);
    
    /**
     * 查询部门是否被分配
     */
    boolean checkDeptExistUser(Long deptId);
    
    /**
     * 新增部门信息
     */
    int insertDept(SysDept dept);
    
    /**
     * 修改部门信息
     */
    int updateDept(SysDept dept);
    
    /**
     * 删除部门管理
     */
    int deleteDeptById(Long deptId);
    
    /**
     * 批量删除部门管理
     */
    int deleteDeptByIds(Long[] deptIds);
}
```

### ISysDictTypeService - 字典类型服务接口

**接口路径**: `com.ruoyi.system.service.ISysDictTypeService`

```java
public interface ISysDictTypeService {
    
    /**
     * 查询字典类型集合
     */
    List<SysDictType> selectDictTypeList(SysDictType dictType);
    
    /**
     * 通过 ID 查询字典类型
     */
    SysDictType selectDictTypeById(Long dictId);
    
    /**
     * 通过字典类型查询字典数据
     */
    List<SysDictData> selectDictDataByDictType(String dictType);
    
    /**
     * 校验字典类型是否唯一
     */
    boolean checkDictTypeUnique(SysDictType dictType);
    
    /**
     * 新增字典类型
     */
    int insertDictType(SysDictType dictType);
    
    /**
     * 修改字典类型
     */
    int updateDictType(SysDictType dictType);
    
    /**
     * 删除字典类型
     */
    int deleteDictTypeById(Long dictId);
    
    /**
     * 批量删除字典类型
     */
    int deleteDictTypeByIds(Long[] dictIds);
    
    /**
     * 加载字典缓存
     */
    void loadingDictCache();
    
    /**
     * 清空字典缓存
     */
    void clearDictCache();
}
```

### ISysDictDataService - 字典数据服务接口

**接口路径**: `com.ruoyi.system.service.ISysDictDataService`

```java
public interface ISysDictDataService {
    
    /**
     * 查询字典数据列表
     */
    List<SysDictData> selectDictDataList(SysDictData dictData);
    
    /**
     * 通过 ID 查询字典数据
     */
    SysDictData selectDictDataById(Long dictCode);
    
    /**
     * 查询字典数据
     */
    List<SysDictData> selectDictDataByDictType(String dictType);
    
    /**
     * 新增字典数据
     */
    int insertDictData(SysDictData dictData);
    
    /**
     * 修改字典数据
     */
    int updateDictData(SysDictData dictData);
    
    /**
     * 删除字典数据
     */
    int deleteDictDataById(Long dictCode);
    
    /**
     * 批量删除字典数据
     */
    int deleteDictDataByIds(Long[] dictCodes);
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

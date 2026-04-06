# Service 业务逻辑层

## 概述

`ruoyi-system/service` 包提供了系统业务逻辑处理，包括接口定义和实现类。Service 层负责处理复杂的业务逻辑、事务管理和数据校验。

## 模块结构

```
service/
├── ISysPostService.java           # 岗位服务接口
├── ISysConfigService.java         # 参数配置服务接口
├── ISysNoticeService.java         # 通知公告服务接口
├── ISysNoticeReadService.java     # 公告已读服务接口
├── ISysOperLogService.java        # 操作日志服务接口
├── ISysLogininforService.java     # 登录日志服务接口
├── ISysUserOnlineService.java     # 在线用户服务接口
└── impl/
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
     * 查询公告已读记录
     * @param noticeReadId 已读记录 ID
     * @return 已读记录信息
     */
    SysNoticeRead selectNoticeReadById(Long noticeReadId);
    
    /**
     * 查询公告已读记录列表
     * @param noticeRead 已读记录信息（查询条件）
     * @return 已读记录集合
     */
    List<SysNoticeRead> selectNoticeReadList(SysNoticeRead noticeRead);
    
    /**
     * 新增公告已读记录
     * @param noticeRead 已读记录信息
     * @return 结果
     */
    int insertNoticeRead(SysNoticeRead noticeRead);
    
    /**
     * 查询公告阅读情况
     * @param noticeId 公告 ID
     * @return 阅读情况
     */
    Map<String, Object> selectNoticeReadStatus(Long noticeId);
    
    /**
     * 清空公告已读记录
     * @param noticeId 公告 ID
     */
    void deleteNoticeReadByNoticeId(Long noticeId);
}
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
     * 通过会话编号查询在线用户
     * @param tokenId 会话编号
     * @return 在线用户
     */
    SysUserOnline selectOnlineByTokenId(String tokenId);
    
    /**
     * 通过用户名查询在线用户
     * @param userName 用户名
     * @return 在线用户
     */
    SysUserOnline selectOnlineByUserName(String userName);
    
    /**
     * 查询在线用户集合
     * @param ipaddr IP 地址
     * @param userName 用户名
     * @return 在线用户集合
     */
    TableDataInfo selectOnlineUserList(String ipaddr, String userName);
    
    /**
     * 强退在线用户
     * @param tokenId 会话编号
     */
    void logoutByTokenId(String tokenId);
    
    /**
     * 查询会话集合
     * @return 会话集合
     */
    List<SysUserOnline> selectAll();
}
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

```java
@Service
public class SysConfigServiceImpl implements ISysConfigService {
    
    @Autowired
    private SysConfigMapper configMapper;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    /**
     * 根据键名查询参数配置信息
     */
    @Override
    public String selectConfigByKey(String configKey) {
        // 1. 先从缓存获取
        String configValue = redisTemplate.opsForValue().get(getCacheKey(configKey));
        if (StringUtils.isNotEmpty(configValue)) {
            return configValue;
        }
        
        // 2. 缓存不存在，查询数据库
        SysConfig config = configMapper.selectConfigByKey(configKey);
        if (StringUtils.isNull(config)) {
            return null;
        }
        
        // 3. 存入缓存
        redisTemplate.opsForValue().set(getCacheKey(configKey), config.getConfigValue());
        return config.getConfigValue();
    }
    
    /**
     * 获取验证码开关
     */
    @Override
    public boolean selectCaptchaEnabled() {
        String captchaEnabled = selectConfigByKey("sys.account.captchaEnabled");
        if (StringUtils.isNull(captchaEnabled)) {
            return true; // 默认开启
        }
        return "true".equals(captchaEnabled);
    }
    
    /**
     * 加载参数缓存数据
     */
    @Override
    public void loadingConfigCache() {
        List<SysConfig> configList = configMapper.selectConfigList(new SysConfig());
        for (SysConfig config : configList) {
            redisTemplate.opsForValue().set(
                getCacheKey(config.getConfigKey()), 
                config.getConfigValue()
            );
        }
    }
    
    /**
     * 清空参数缓存数据
     */
    @Override
    public void clearConfigCache() {
        Set<String> keys = redisTemplate.keys("sys_config:*");
        if (CollectionUtils.isNotEmpty(keys)) {
            redisTemplate.delete(keys);
        }
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
     * 新增参数配置
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertConfig(SysConfig config) {
        int rows = configMapper.insertConfig(config);
        if (rows > 0) {
            // 同步更新缓存
            redisTemplate.opsForValue().set(
                getCacheKey(config.getConfigKey()), 
                config.getConfigValue()
            );
        }
        return rows;
    }
    
    /**
     * 修改参数配置
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateConfig(SysConfig config) {
        int rows = configMapper.updateConfig(config);
        if (rows > 0) {
            // 同步更新缓存
            redisTemplate.opsForValue().set(
                getCacheKey(config.getConfigKey()), 
                config.getConfigValue()
            );
        }
        return rows;
    }
    
    /**
     * 批量删除参数信息
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteConfigByIds(Long[] configIds) {
        for (Long configId : configIds) {
            SysConfig config = selectConfigById(configId);
            if (StringUtils.equals(config.getConfigType(), "Y")) {
                throw new ServiceException(String.format(
                    "%1$s内置参数不可删除", config.getConfigName()
                ));
            }
            // 删除缓存
            redisTemplate.delete(getCacheKey(config.getConfigKey()));
        }
        configMapper.deleteConfigByIds(configIds);
    }
    
    /**
     * 生成缓存键名
     */
    private String getCacheKey(String configKey) {
        return "sys_config:" + configKey;
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

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

# Service 业务逻辑层

## 概述

`ruoyi-system/service` 包提供了系统业务逻辑处理，包括接口定义和实现类。Service 层负责处理复杂的业务逻辑、事务管理和数据校验。

**源码位置**: `ruoyi-system/src/main/java/com/ruoyi/system/service/`  
**实现位置**: `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/`

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

## 服务接口总览

### 核心业务服务

| 服务接口 | 源码 | 实现类 | 主要功能 |
|----------|------|--------|----------|
| ISysUserService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java) | 用户管理、密码重置、角色分配 |
| ISysRoleService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysRoleService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysRoleServiceImpl.java) | 角色管理、权限分配、数据范围 |
| ISysMenuService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysMenuService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysMenuServiceImpl.java) | 菜单管理、路由构建、权限标识 |
| ISysDeptService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysDeptService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDeptServiceImpl.java) | 部门管理、组织架构树 |

### 基础配置服务

| 服务接口 | 源码 | 实现类 | 主要功能 |
|----------|------|--------|----------|
| ISysDictTypeService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysDictTypeService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDictTypeServiceImpl.java) | 字典类型管理、缓存加载 |
| ISysDictDataService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysDictDataService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDictDataServiceImpl.java) | 字典数据管理、按类型查询 |
| ISysPostService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysPostService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysPostServiceImpl.java) | 岗位管理、唯一性校验 |
| ISysConfigService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysConfigService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysConfigServiceImpl.java) | 参数配置、缓存同步 |

### 通知与日志服务

| 服务接口 | 源码 | 实现类 | 主要功能 |
|----------|------|--------|----------|
| ISysNoticeService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysNoticeService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNoticeServiceImpl.java) | 公告管理、增删改查 |
| ISysNoticeReadService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysNoticeReadService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNoticeReadServiceImpl.java) | 已读状态追踪、批量标记 |
| ISysOperLogService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysOperLogService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysOperLogServiceImpl.java) | 操作日志记录、查询、清理 |
| ISysLogininforService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysLogininforService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysLogininforServiceImpl.java) | 登录日志、账户锁定 |
| ISysUserOnlineService | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserOnlineService.java) | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserOnlineServiceImpl.java) | 在线会话、强退用户 |

---

## 核心业务逻辑示例

### 1. 事务处理 + 业务校验（SysPostServiceImpl）

**源码**: [`SysPostServiceImpl.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysPostServiceImpl.java)

**删除岗位前的使用检查**:

```java
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
```

**要点**:
- 使用 `@Transactional` 确保原子性
- 删除前校验业务规则
- 抛出 `ServiceException` 给出友好提示

---

### 2. 缓存同步（SysConfigServiceImpl）

**源码**: [`SysConfigServiceImpl.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysConfigServiceImpl.java)

**查询参数（先查缓存，缓存不存在查数据库）**:

```java
@Override
public String selectConfigByKey(String configKey) {
    // 1. 先从缓存获取
    String configValue = Convert.toStr(redisCache.getCacheObject(getCacheKey(configKey)));
    if (StringUtils.isNotEmpty(configValue)) {
        return configValue;
    }
    
    // 2. 缓存不存在，查询数据库
    SysConfig config = new SysConfig();
    config.setConfigKey(configKey);
    SysConfig retConfig = configMapper.selectConfig(config);
    if (StringUtils.isNotNull(retConfig)) {
        // 3. 存入缓存
        redisCache.setCacheObject(getCacheKey(configKey), retConfig.getConfigValue());
        return retConfig.getConfigValue();
    }
    return StringUtils.EMPTY;
}
```

**修改配置（同步更新缓存）**:

```java
@Override
public int updateConfig(SysConfig config) {
    // 如果 key 变更，删除旧缓存
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
```

**要点**:
- 使用 `RedisCache` 工具类（非 RedisTemplate）
- 缓存键名：`sys_config:{configKey}`
- 修改时同步更新缓存，保证一致性

---

### 3. 批量操作（SysNoticeReadServiceImpl）

**源码**: [`SysNoticeReadServiceImpl.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNoticeReadServiceImpl.java)

**批量标记已读**:

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void markReadBatch(Long userId, Long[] noticeIds) {
    for (Long noticeId : noticeIds) {
        // 幂等处理：已读记录存在则跳过
        int count = noticeReadMapper.selectIsRead(noticeId, userId);
        if (count == 0) {
            SysNoticeRead noticeRead = new SysNoticeRead();
            noticeRead.setNoticeId(noticeId);
            noticeRead.setUserId(userId);
            noticeRead.setReadTime(new Date());
            noticeReadMapper.insertNoticeRead(noticeRead);
        }
    }
}
```

**查询带已读状态的公告列表**:

```java
@Override
public List<SysNotice> selectNoticeListWithReadStatus(Long userId, int limit) {
    // 直接查询关联已读记录的公告列表
    return noticeReadMapper.selectNoticeListWithReadStatus(userId, limit);
}
```

**要点**:
- 批量操作使用 `@Transactional`
- 幂等性设计：重复调用不报错
- 复杂查询在 Mapper 层完成

---

### 4. 账户锁定（SysLogininforServiceImpl）

**源码**: [`SysLogininforServiceImpl.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysLogininforServiceImpl.java)

**记录登录失败并锁定账户**:

```java
@Override
public void recordLoginInfo(String userName, boolean isIncrement) {
    SysUser user = userMapper.selectUserByUserName(userName);
    
    if (isIncrement) {
        // 增加登录失败次数
        user.setLoginDate(new Date());
        user.setRemark(user.getRemark() + " 登录失败" + (user.getLoginCount() + 1) + "次");
        user.setLoginCount(user.getLoginCount() + 1);
        userMapper.updateUser(user);
        
        // 达到阈值锁定账户
        if (user.getLoginCount() >= 5) {
            user.setStatus("1"); // 停用
            userMapper.updateUser(user);
        }
    } else {
        // 登录成功，重置失败次数
        user.setLoginDate(new Date());
        user.setLoginCount(0);
        userMapper.updateUser(user);
    }
}
```

---

## 使用示例

### Controller 中注入 Service

```java
@RestController
@RequestMapping("/system/post")
public class SysPostController {
    
    @Autowired
    private ISysPostService postService;
    
    @GetMapping("/list")
    public TableDataInfo list(SysPost post) {
        List<SysPost> list = postService.selectPostList(post);
        return getDataTable(list);
    }
    
    @PostMapping
    public AjaxResult add(@RequestBody SysPost post) {
        // 校验唯一性
        if (!postService.checkPostNameUnique(post)) {
            return error("岗位名称已存在");
        }
        return toAjax(postService.insertPost(post));
    }
}
```

---

## 服务层规范

### 1. 接口与实现分离

```java
// 接口定义
public interface ISysPostService {
    List<SysPost> selectPostList(SysPost post);
    // ...
}

// 实现类
@Service
public class SysPostServiceImpl implements ISysPostService {
    // ...
}
```

### 2. 异常处理

- 业务异常抛出 `ServiceException`
- 框架层统一处理并返回友好提示

### 3. 事务管理

- 涉及多个数据库操作使用 `@Transactional`
- 设置 `rollbackFor = Exception.class` 确保异常回滚

### 4. 缓存使用

- 查询频繁数据使用缓存
- 修改后同步更新/删除缓存
- 使用 `RedisCache` 工具类

---

**文档版本**: 1.1  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

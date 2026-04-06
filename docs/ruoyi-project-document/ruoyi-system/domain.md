# Domain 实体模块

## 概述

`ruoyi-system/domain` 包提供了系统业务实体类，用于表示数据库表结构对应的 Java 对象。实体类继承自 `BaseEntity` 基础类，支持 MyBatis 自动映射。

## 模块结构

```
domain/
├── vo/                      # 视图对象
│   ├── RouterVo.java        # 前端路由配置
│   └── MetaVo.java          # 路由显示元数据
├── SysPost.java             # 岗位实体
├── SysConfig.java           # 参数配置实体
├── SysNotice.java           # 通知公告实体
├── SysNoticeRead.java       # 公告已读记录实体
├── SysOperLog.java          # 操作日志实体
├── SysLogininfor.java       # 登录日志实体
├── SysUserOnline.java       # 在线用户会话实体
├── SysCache.java            # 缓存信息实体
├── SysRoleDept.java         # 角色部门关联实体
├── SysRoleMenu.java         # 角色菜单关联实体
├── SysUserRole.java         # 用户角色关联实体
└── SysUserPost.java         # 用户岗位关联实体
```

## 基础实体类

所有实体类继承自 `BaseEntity`（位于 `ruoyi-common` 模块）：

```java
public class BaseEntity implements Serializable {
    /** ID */
    private Long id;
    
    /** 创建者 */
    private String createBy;
    
    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
    
    /** 更新者 */
    private String updateBy;
    
    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
    
    /** 备注 */
    private String remark;
    
    /** 删除标志 */
    private String delFlag;
    
    // Getters and Setters
}
```

---

## 业务实体类

### 1. SysPost - 岗位实体

**表名**: `sys_post`

```java
@TableName("sys_post")
public class SysPost implements Serializable {
    
    /** 岗位 ID */
    @TableId
    private Long postId;
    
    /** 岗位编码 */
    private String postCode;
    
    /** 岗位名称 */
    private String postName;
    
    /** 岗位排序 */
    private Integer postSort;
    
    /** 状态（0 正常 1 停用） */
    private String status;
    
    /** 备注 */
    private String remark;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| post_id | BIGINT | 岗位 ID（主键） |
| post_code | VARCHAR | 岗位编码 |
| post_name | VARCHAR | 岗位名称 |
| post_sort | INT | 显示顺序 |
| status | CHAR | 状态（0 正常 1 停用） |
| create_time | DATETIME | 创建时间 |

**使用示例**:

```java
// 创建岗位
SysPost post = new SysPost();
post.setPostCode("DEV");
post.setPostName("开发岗位");
post.setPostSort(1);
post.setStatus("0");

// 插入数据库
postMapper.insertPost(post);
```

---

### 2. SysConfig - 参数配置实体

**表名**: `sys_config`

```java
@TableName("sys_config")
public class SysConfig implements Serializable {
    
    /** 参数主键 */
    @TableId
    private Long configId;
    
    /** 参数名称 */
    private String configName;
    
    /** 参数键名 */
    private String configKey;
    
    /** 参数键值 */
    private String configValue;
    
    /** 系统内置（Y 是 N 否） */
    private String configType;
    
    /** 备注 */
    private String remark;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| config_id | BIGINT | 参数主键（主键） |
| config_name | VARCHAR | 参数名称 |
| config_key | VARCHAR | 参数键名 |
| config_value | VARCHAR | 参数键值 |
| config_type | CHAR | 系统内置（Y 是 N 否） |
| create_time | DATETIME | 创建时间 |

**内置配置示例**:

| config_key | config_value | 说明 |
|------------|-------------|------|
| sys.user.initPassword | 123456 | 用户初始密码 |
| sys.account.closeUser | false | 账号是否关闭 |
| sys.account.registerUser | true | 是否允许注册 |

**使用示例**:

```java
// 查询参数配置
SysConfig config = configMapper.selectConfigByKey("sys.user.initPassword");
String initPassword = config.getConfigValue();

// 更新参数
config.setConfigValue("new_value");
configMapper.updateConfig(config);
```

---

### 3. SysNotice - 通知公告实体

**表名**: `sys_notice`

```java
@TableName("sys_notice")
public class SysNotice implements Serializable {
    
    /** 公告 ID */
    @TableId
    private Long noticeId;
    
    /** 公告标题 */
    private String noticeTitle;
    
    /** 公告类型（1 通知 2 公告） */
    private String noticeType;
    
    /** 公告内容 */
    private String noticeContent;
    
    /** 公告状态（0 正常 1 关闭） */
    private String status;
    
    /** 是否已读 */
    @JsonProperty("isRead")
    private boolean isRead;
    
    /** 备注 */
    private String remark;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| notice_id | BIGINT | 公告 ID（主键） |
| notice_title | VARCHAR | 公告标题 |
| notice_type | CHAR | 公告类型（1 通知 2 公告） |
| notice_content | TEXT | 公告内容（HTML） |
| status | CHAR | 状态（0 正常 1 关闭） |
| create_time | DATETIME | 创建时间 |
| isRead | boolean | 是否已读（非数据库字段） |

**使用示例**:

```java
// 创建公告
SysNotice notice = new SysNotice();
notice.setNoticeTitle("系统维护通知");
notice.setNoticeType("1"); // 通知
notice.setNoticeContent("<p>系统将于今晚 23:00 进行维护...</p>");
notice.setStatus("0");

noticeMapper.insertNotice(notice);

// 设置已读状态（用于前端展示）
notice.setIsRead(true);
```

---

### 4. SysNoticeRead - 公告已读记录实体

**表名**: `sys_notice_read`

```java
@TableName("sys_notice_read")
public class SysNoticeRead implements Serializable {
    
    /** 已读记录 ID */
    @TableId
    private Long noticeReadId;
    
    /** 公告 ID */
    private Long noticeId;
    
    /** 用户 ID */
    private Long userId;
    
    /** 已读状态（0 未读 1 已读） */
    private String readStatus;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| notice_read_id | BIGINT | 已读记录 ID（主键） |
| notice_id | BIGINT | 公告 ID |
| user_id | BIGINT | 用户 ID |
| read_status | CHAR | 已读状态（0 未读 1 已读） |
| create_time | DATETIME | 阅读时间 |

**使用示例**:

```java
// 标记公告为已读
SysNoticeRead noticeRead = new SysNoticeRead();
noticeRead.setNoticeId(1L);
noticeRead.setUserId(1L);
noticeRead.setReadStatus("1");

noticeReadMapper.insertNoticeRead(noticeRead);

// 检查是否已读
Boolean isRead = noticeReadMapper.checkNoticeRead(1L, 1L);
```

---

### 5. SysOperLog - 操作日志实体

**表名**: `sys_oper_log`

```java
@TableName("sys_oper_log")
public class SysOperLog extends BaseEntity implements Serializable {
    
    /** 日志主键 */
    @TableId
    private Long operId;
    
    /** 模块标题 */
    private String title;
    
    /** 业务类型（0 其它 1 新增 2 修改 3 删除） */
    private Integer businessType;
    
    /** 业务类型数组 */
    private Integer[] businessTypes;
    
    /** 请求方法 */
    private String method;
    
    /** 请求方式 */
    private String requestMethod;
    
    /** 操作类别（0 其它 1 后台用户 2 手机端用户） */
    private Integer operatorType;
    
    /** 操作人员 */
    private String operName;
    
    /** 部门名称 */
    private String deptName;
    
    /** 请求 URL */
    private String operUrl;
    
    /** 主机地址 */
    private String operIp;
    
    /** 操作地点 */
    private String operLocation;
    
    /** 请求参数 */
    private String operParam;
    
    /** 返回参数 */
    private String jsonResult;
    
    /** 操作状态（0 正常 1 异常） */
    private Integer status;
    
    /** 错误消息 */
    private String errorMsg;
    
    /** 操作时间 */
    private Date operTime;
    
    /** 消耗时间（毫秒） */
    private Long costTime;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| oper_id | BIGINT | 日志主键（主键） |
| title | VARCHAR | 模块标题 |
| business_type | INT | 业务类型 |
| method | VARCHAR | 请求方法 |
| request_method | VARCHAR | 请求方式 |
| oper_name | VARCHAR | 操作人员 |
| oper_url | VARCHAR | 请求 URL |
| oper_ip | VARCHAR | 主机地址 |
| oper_param | TEXT | 请求参数 |
| json_result | TEXT | 返回参数 |
| status | INT | 操作状态 |
| oper_time | DATETIME | 操作时间 |
| cost_time | LONG | 消耗时间（毫秒） |

**使用示例**:

```java
// 记录操作日志
SysOperLog operLog = new SysOperLog();
operLog.setTitle("用户管理");
operLog.setBusinessType(BusinessType.INSERT.ordinal());
operLog.setRequestMethod("POST");
operLog.setOperName("admin");
operLog.setOperUrl("/system/user");
operLog.setOperIp("127.0.0.1");
operLog.setStatus(0);

operLogMapper.insertOperlog(operLog);
```

---

### 6. SysLogininfor - 登录日志实体

**表名**: `sys_logininfor`

```java
@TableName("sys_logininfor")
public class SysLogininfor implements Serializable {
    
    /** 访问 ID */
    @TableId
    private Long infoId;
    
    /** 用户账号 */
    private String userName;
    
    /** 登录状态（0 成功 1 失败） */
    private String status;
    
    /** 登录 IP 地址 */
    private String ipaddr;
    
    /** 登录地点 */
    private String loginLocation;
    
    /** 浏览器类型 */
    private String browser;
    
    /** 操作系统 */
    private String os;
    
    /** 提示消息 */
    private String msg;
    
    /** 访问时间 */
    private Date loginTime;
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| info_id | BIGINT | 访问 ID（主键） |
| user_name | VARCHAR | 用户账号 |
| status | CHAR | 登录状态 |
| ipaddr | VARCHAR | 登录 IP 地址 |
| login_location | VARCHAR | 登录地点 |
| browser | VARCHAR | 浏览器类型 |
| os | VARCHAR | 操作系统 |
| login_time | DATETIME | 访问时间 |

**使用示例**:

```java
// 记录登录成功
SysLogininfor logininfor = new SysLogininfor();
logininfor.setUserName("admin");
logininfor.setStatus(Constants.SUCCESS);
logininfor.setIpaddr("127.0.0.1");
logininfor.setLoginLocation("内网 IP");
logininfor.setBrowser("Chrome");
logininfor.setOs("Windows 10");
logininfor.setMsg("登录成功");

logininforMapper.insertLogininfor(logininfor);
```

---

### 7. SysUserOnline - 在线用户会话实体

**说明**: 该实体不对应数据库表，用于表示当前在线用户的会话信息。

```java
public class SysUserOnline implements Serializable {
    
    /** 会话编号 */
    private String tokenId;
    
    /** 部门名称 */
    private String deptName;
    
    /** 用户名称 */
    private String userName;
    
    /** 登录 IP 地址 */
    private String ipaddr;
    
    /** 登录地址 */
    private String loginLocation;
    
    /** 浏览器类型 */
    private String browser;
    
    /** 操作系统 */
    private String os;
    
    /** 登录时间 */
    private Long loginTime;
}
```

**使用示例**:

```java
// 从 LoginUser 转换为 SysUserOnline
public static SysUserOnline toOnline(LoginUser loginUser) {
    SysUser user = loginUser.getUser();
    SysUserOnline online = new SysUserOnline();
    online.setTokenId(loginUser.getToken());
    online.setDeptName(user.getDept().getDeptName());
    online.setUserName(user.getUserName());
    online.setIpaddr(loginUser.getIpaddr());
    online.setLoginLocation(loginUser.getLoginLocation());
    online.setBrowser(loginUser.getBrowser());
    online.setOs(loginUser.getOs());
    online.setLoginTime(loginUser.getLoginTime());
    return online;
}
```

---

### 8. SysCache - 缓存信息实体

**说明**: 该实体不对应数据库表，用于表示缓存信息。

```java
public class SysCache implements Serializable {
    
    /** 缓存名称 */
    private String cacheName;
    
    /** 缓存键名 */
    private String cacheKey;
    
    /** 缓存内容 */
    private String cacheValue;
    
    /** 备注 */
    private String remark;
    
    public SysCache() {}
    
    public SysCache(String cacheName, String cacheKey, String cacheValue) {
        this.cacheName = cacheName;
        this.cacheKey = cacheKey;
        this.cacheValue = cacheValue;
    }
}
```

**使用示例**:

```java
// 获取缓存信息
Cache cache = SpringUtils.getBean(CacheManager.class).getCache("userCache");
Object value = cache.get("user:1001");

// 转换为 SysCache 对象
SysCache sysCache = new SysCache(
    "userCache", 
    "user:1001", 
    value.toString()
);
```

---

## 关联实体类

### 9. SysRoleDept - 角色部门关联实体

**表名**: `sys_role_dept`

```java
@TableName("sys_role_dept")
public class SysRoleDept implements Serializable {
    
    /** 角色 ID */
    private Long roleId;
    
    /** 部门 ID */
    private Long deptId;
}
```

### 10. SysRoleMenu - 角色菜单关联实体

**表名**: `sys_role_menu`

```java
@TableName("sys_role_menu")
public class SysRoleMenu implements Serializable {
    
    /** 角色 ID */
    private Long roleId;
    
    /** 菜单 ID */
    private Long menuId;
}
```

### 11. SysUserRole - 用户角色关联实体

**表名**: `sys_user_role`

```java
@TableName("sys_user_role")
public class SysUserRole implements Serializable {
    
    /** 用户 ID */
    private Long userId;
    
    /** 角色 ID */
    private Long roleId;
}
```

### 12. SysUserPost - 用户岗位关联实体

**表名**: `sys_user_post`

```java
@TableName("sys_user_post")
public class SysUserPost implements Serializable {
    
    /** 用户 ID */
    private Long userId;
    
    /** 岗位 ID */
    private Long postId;
}
```

---

## 视图对象（VO）

### RouterVo - 前端路由配置

```java
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class RouterVo implements Serializable {
    
    /** 路由名字 */
    private String name;
    
    /** 路由地址 */
    private String path;
    
    /** 是否隐藏路由 */
    private boolean hidden;
    
    /** 重定向地址 */
    private String redirect;
    
    /** 组件地址 */
    private String component;
    
    /** 路由参数 */
    private String query;
    
    /** 是否总是显示父路由 */
    private Boolean alwaysShow;
    
    /** 路由显示元数据 */
    private MetaVo meta;
    
    /** 子路由 */
    private List<RouterVo> children;
    
    // Getters and Setters
}
```

### MetaVo - 路由显示元数据

```java
public class MetaVo implements Serializable {
    
    /** 路由标题（显示在侧边栏和面包屑） */
    private String title;
    
    /** 路由图标 */
    private String icon;
    
    /** 是否被缓存 */
    private boolean noCache;
    
    /** 内链地址（http(s)://开头） */
    private String link;
    
    // Constructors and Getters and Setters
}
```

**使用示例**:

```java
// 创建路由配置
RouterVo router = new RouterVo();
router.setName("User");
router.setPath("/system/user");
router.setHidden(false);
router.setComponent("system/user/index");

// 创建元数据
MetaVo meta = new MetaVo("用户管理", "user", false);
router.setMeta(meta);

// 创建子路由
List<RouterVo> children = new ArrayList<>();
RouterVo child = new RouterVo();
child.setPath("list");
child.setComponent("system/user/list");
child.setMeta(new MetaVo("用户列表", "list"));
children.add(child);
router.setChildren(children);
```

---

## 实体类使用规范

### 1. 新增操作

```java
SysPost post = new SysPost();
post.setPostCode("DEV");
post.setPostName("开发岗位");
post.setPostSort(1);
post.setStatus("0");

// 由 BaseEntity 自动设置创建者和创建时间
post.setCreateBy(SecurityUtils.getUsername());
post.setCreateTime(new Date());

postMapper.insertPost(post);
```

### 2. 修改操作

```java
SysPost post = postMapper.selectPostById(postId);
post.setPostName("高级开发岗位");
post.setPostSort(2);
post.setUpdateBy(SecurityUtils.getUsername());
post.setUpdateTime(new Date());

postMapper.updatePost(post);
```

### 3. 删除操作

```java
// 逻辑删除（推荐）
post.setDelFlag("1");
postMapper.updatePost(post);

// 物理删除
postMapper.deletePostById(postId);
```

### 4. 查询操作

```java
// 根据 ID 查询
SysPost post = postMapper.selectPostById(postId);

// 条件查询
SysPost condition = new SysPost();
condition.setPostCode("DEV");
List<SysPost> list = postMapper.selectPostList(condition);
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

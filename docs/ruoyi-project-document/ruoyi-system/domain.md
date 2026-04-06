# Domain 实体模块

## 概述

`ruoyi-system/domain` 包提供了系统业务实体类，用于表示数据库表结构对应的 Java 对象。所有实体类继承自 `BaseEntity`，使用 MyBatis XML 映射（非 JPA 注解）。

**源码位置**: `ruoyi-system/src/main/java/com/ruoyi/system/domain/`

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

所有业务实体继承自 `BaseEntity`（位于 `ruoyi-common` 模块），自动包含以下字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 ID |
| createBy | String | 创建者 |
| createTime | Date | 创建时间 |
| updateBy | String | 更新者 |
| updateTime | Date | 更新时间 |
| remark | String | 备注 |
| delFlag | String | 删除标志 |

---

## 业务实体类

### 1. SysPost - 岗位实体

**源码**: [`SysPost.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysPost.java)

**表名**: `sys_post`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| postId | Long | 岗位 ID（主键） |
| postCode | String | 岗位编码 |
| postName | String | 岗位名称 |
| postSort | Integer | 显示顺序 |
| status | String | 状态（0 正常 1 停用） |
| flag | boolean | 用户是否存在此岗位标识 |

**使用示例**:

```java
// 创建岗位
SysPost post = new SysPost();
post.setPostCode("DEV");
post.setPostName("开发岗位");
post.setPostSort(1);
post.setStatus("0");
postMapper.insertPost(post);
```

---

### 2. SysConfig - 参数配置实体

**源码**: [`SysConfig.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysConfig.java)

**表名**: `sys_config`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| configId | Long | 参数主键 |
| configName | String | 参数名称 |
| configKey | String | 参数键名 |
| configValue | String | 参数键值 |
| configType | String | 系统内置（Y 是 N 否） |

**内置配置示例**:

| configKey | configValue | 说明 |
|-----------|-------------|------|
| sys.user.initPassword | 123456 | 用户初始密码 |
| sys.account.captchaEnabled | true | 验证码开关 |
| sys.account.registerUser | false | 是否允许注册 |

---

### 3. SysNotice - 通知公告实体

**源码**: [`SysNotice.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNotice.java)

**表名**: `sys_notice`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| noticeId | Long | 公告 ID（主键） |
| noticeTitle | String | 公告标题 |
| noticeType | String | 公告类型（1 通知 2 公告） |
| noticeContent | String | 公告内容（HTML） |
| status | String | 状态（0 正常 1 关闭） |
| isRead | boolean | 是否已读（非数据库字段） |

**注意**: `isRead` 字段使用 `@JsonProperty("isRead")` 注解，用于前端展示，不映射到数据库。

---

### 4. SysNoticeRead - 公告已读记录实体

**源码**: [`SysNoticeRead.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNoticeRead.java)

**表名**: `sys_notice_read`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| readId | Long | 主键 |
| noticeId | Long | 公告 ID |
| userId | Long | 用户 ID |
| readTime | Date | 阅读时间 |

**注意**: 
- 该类不继承 BaseEntity
- 没有 createBy、createTime 等字段
- 通过记录是否存在判断是否已读

---

### 5. SysOperLog - 操作日志实体

**源码**: [`SysOperLog.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysOperLog.java)

**表名**: `sys_oper_log`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| operId | Long | 日志主键 |
| title | String | 模块标题 |
| businessType | Integer | 业务类型（0 其它 1 新增 2 修改 3 删除） |
| operName | String | 操作人员 |
| operUrl | String | 请求 URL |
| operIp | String | 主机地址 |
| operParam | String | 请求参数 |
| jsonResult | String | 返回参数 |
| status | Integer | 操作状态（0 正常 1 异常） |
| costTime | Long | 消耗时间（毫秒） |

**使用示例**:

```java
// 记录操作日志
SysOperLog operLog = new SysOperLog();
operLog.setTitle("用户管理");
operLog.setBusinessType(BusinessType.INSERT.ordinal());
operLog.setOperName("admin");
operLog.setOperUrl("/system/user");
operLog.setStatus(0);
operLogMapper.insertOperlog(operLog);
```

---

### 6. SysLogininfor - 登录日志实体

**源码**: [`SysLogininfor.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysLogininfor.java)

**表名**: `sys_logininfor`

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| infoId | Long | 访问 ID |
| userName | String | 用户账号 |
| status | String | 登录状态（0 成功 1 失败） |
| ipaddr | String | 登录 IP 地址 |
| loginLocation | String | 登录地点 |
| browser | String | 浏览器类型 |
| os | String | 操作系统 |
| loginTime | Date | 访问时间 |

---

### 7. SysUserOnline - 在线用户会话实体

**源码**: [`SysUserOnline.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserOnline.java)

**说明**: 该实体不对应数据库表，用于表示当前在线用户的会话信息。

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| tokenId | String | 会话编号 |
| deptName | String | 部门名称 |
| userName | String | 用户名称 |
| ipaddr | String | 登录 IP 地址 |
| loginLocation | String | 登录地址 |
| browser | String | 浏览器类型 |
| os | String | 操作系统 |
| loginTime | Long | 登录时间 |

---

### 8. SysCache - 缓存信息实体

**源码**: [`SysCache.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysCache.java)

**说明**: 该实体不对应数据库表，用于表示缓存信息。

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| cacheName | String | 缓存名称 |
| cacheKey | String | 缓存键名 |
| cacheValue | String | 缓存内容 |

---

### 9-12. 关联实体类

以下关联实体类用于多对多关系映射，仅包含两个 ID 字段：

| 实体类 | 表名 | 字段 | 说明 |
|--------|------|------|------|
| SysRoleDept | sys_role_dept | roleId, deptId | 角色部门关联 |
| SysRoleMenu | sys_role_menu | roleId, menuId | 角色菜单关联 |
| SysUserRole | sys_user_role | userId, roleId | 用户角色关联 |
| SysUserPost | sys_user_post | userId, postId | 用户岗位关联 |

---

## 视图对象（VO）

### RouterVo - 前端路由配置

**源码**: [`RouterVo.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/vo/RouterVo.java)

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| name | String | 路由名字 |
| path | String | 路由地址 |
| hidden | boolean | 是否隐藏路由 |
| redirect | String | 重定向地址 |
| component | String | 组件地址 |
| alwaysShow | Boolean | 是否总是显示父路由 |
| meta | MetaVo | 路由显示元数据 |
| children | List<RouterVo> | 子路由 |

### MetaVo - 路由显示元数据

**源码**: [`MetaVo.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/vo/MetaVo.java)

**核心字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| title | String | 路由标题（显示在侧边栏和面包屑） |
| icon | String | 路由图标 |
| noCache | boolean | 是否被缓存 |
| link | String | 内链地址（http(s)://开头） |

---

## 实体类使用规范

### 1. 继承关系

所有业务实体类都继承自 `BaseEntity`（位于 `ruoyi-common` 模块），自动拥有创建者、创建时间、更新者、更新时间、备注、删除标志等字段。

**源码示例**: [`SysPost.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysPost.java)

```java
public class SysPost extends BaseEntity implements Serializable {
    // 仅定义业务特有字段：postId, postCode, postName, postSort, status, flag
}
```

### 2. 使用方式

实体类主要用于数据传输，配合 Mapper 使用：

- **新增/修改**: 设置业务字段后调用 Mapper 的 `insert`/`update` 方法
- **删除**: 调用 Mapper 的 `deleteById` 方法（物理删除）或通过 `setDelFlag` 逻辑删除
- **查询**: Mapper 返回实体对象或列表

**相关源码**:
- Mapper 接口：`ruoyi-system/src/main/java/com/ruoyi/system/mapper/`
- 使用示例：[`SysPostServiceImpl.java`](../../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysPostServiceImpl.java#L162-L177)

---

**文档版本**: 1.1  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

# RuoYi-System 系统模块

## 概述

`ruoyi-system` 是若依框架的核心业务模块，提供了系统管理功能的基础实现，包括用户、角色、菜单、部门、岗位、字典、参数、公告、日志等管理功能。

## 模块位置

- **工程路径**: `/home/workspace/com/wfxx-vue3/ruoyi-system`
- **文档路径**: `/home/workspace/com/wfxx-vue3/docs/ruoyi-project-document/ruoyi-system/`

## Maven 坐标

```xml
<artifactId>ruoyi-system</artifactId>
<groupId>com.ruoyi</groupId>
<version>3.9.2</version>
<description>system 系统模块</description>
```

## 模块结构

```
ruoyi-system/
├── pom.xml                      # Maven 配置文件
└── src/
    └── main/
        └── java/
            └── com/ruoyi/system/
                ├── domain/      # 实体类层
                │   ├── vo/      # 视图对象
                │   └── *.java   # 领域模型
                ├── mapper/      # MyBatis Mapper 接口
                └── service/     # 业务服务层
                    ├── impl/    # 服务实现类
                    └── *.java   # 服务接口
```

## 功能模块

| 模块 | 说明 | 文档链接 |
|------|------|----------|
| Domain 实体层 | 系统实体类和视图对象 | [domain.md](ruoyi-system/domain.md) |
| Mapper 数据访问层 | MyBatis Mapper 接口 | [mapper.md](ruoyi-system/mapper.md) |
| Service 业务逻辑层 | 业务服务接口和实现 | [service.md](ruoyi-system/service.md) |

## 核心功能

### 1. 用户管理
- 用户增删改查
- 密码重置
- 头像上传
- 角色分配
- 状态管理

### 2. 角色管理
- 角色增删改查
- 权限分配
- 数据范围设置
- 用户授权

### 3. 菜单管理
- 菜单/目录/按钮管理
- 路由构建
- 权限标识配置

### 4. 部门管理
- 组织架构树形管理
- 部门负责人设置

### 5. 岗位管理
- 岗位设置
- 用户岗位关联

### 6. 字典管理
- 字典类型与数据维护
- 字典缓存

### 7. 参数配置
- 系统参数键值对配置
- 缓存同步

### 8. 通知公告
- 公告发布
- 已读状态追踪

### 9. 日志管理
- 操作日志记录
- 登录日志记录
- 日志清理

### 10. 在线用户
- 当前在线会话查看
- 强退功能

## 架构分层

```
┌─────────────────────────────────────────┐
│          Controller 层 (ruoyi-admin)     │
│     处理 HTTP 请求，调用 Service 层         │
├─────────────────────────────────────────┤
│          Service 层 (ruoyi-system)       │
│    业务逻辑处理、事务管理、权限校验       │
├─────────────────────────────────────────┤
│           Mapper 层 (ruoyi-system)       │
│       MyBatis 接口，与数据库交互           │
├─────────────────────────────────────────┤
│          Domain 层 (ruoyi-system)        │
│    实体类、VO 对象，表示数据结构            │
├─────────────────────────────────────────┤
│         Entity 层 (ruoyi-common)         │
│  SysUser/SysRole/SysMenu 等核心实体       │
├─────────────────────────────────────────┤
│              Database (MySQL)            │
└─────────────────────────────────────────┘
```

## 主要依赖

| 依赖 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 4.0.3 | 核心框架 |
| MyBatis Spring Boot | 4.0.1 | ORM 框架 |
| Druid | 1.2.28 | 数据库连接池 |
| PageHelper | 2.1.1 | 分页插件 |
| FastJSON2 | 2.0.61 | JSON 解析 |

## 使用说明

### 1. 在项目中引入 ruoyi-system

```xml
<dependency>
    <groupId>com.ruoyi</groupId>
    <artifactId>ruoyi-system</artifactId>
</dependency>
```

### 2. 注入服务使用

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    @Autowired
    private ISysUserService userService;
    
    @GetMapping("/{userId}")
    public AjaxResult getUser(@PathVariable Long userId) {
        SysUser user = userService.selectUserById(userId);
        return AjaxResult.success(user);
    }
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

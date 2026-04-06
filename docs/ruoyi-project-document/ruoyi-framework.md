# Ruoyi-Framework 框架模块

## 概述

`ruoyi-framework` 模块是 RuoYi 框架的核心集成模块，提供了 Spring Boot 应用的运行时基础设施，包括安全认证、AOP 切面、数据源管理、异步任务处理等功能。

## 模块结构

```
ruoyi-framework/
├── config/                     # 配置类
│   ├── ApplicationConfig.java          # 应用基础配置
│   ├── DruidConfig.java                # Druid 数据源配置
│   ├── RedisConfig.java                # Redis 配置
│   ├── MyBatisConfig.java              # MyBatis 配置
│   ├── SecurityConfig.java             # Spring Security 配置
│   ├── ThreadPoolConfig.java           # 线程池配置
│   ├── ResourcesConfig.java            # 资源访问配置
│   ├── CaptchaConfig.java              # 验证码配置
│   ├── FilterConfig.java               # 过滤器配置
│   ├── I18nConfig.java                 # 国际化配置
│   ├── ServerConfig.java               # 服务监控配置
│   └── properties/                     # 配置属性类
├── security/                   # 安全认证
│   ├── JwtAuthenticationTokenFilter.java  # JWT 认证过滤器
│   ├── AuthenticationContextHolder.java   # 认证上下文持有者
│   ├── PermissionContextHolder.java       # 权限上下文持有者
│   ├── AuthenticationEntryPointImpl.java  # 认证失败处理
│   └── LogoutSuccessHandlerImpl.java      # 登出成功处理
├── aspectj/                    # AOP 切面
│   ├── LogAspect.java                  # 操作日志切面
│   ├── DataScopeAspect.java            # 数据权限切面
│   ├── DataSourceAspect.java           # 数据源切面
│   └── RateLimiterAspect.java          # 限流切面
├── interceptor/                # 拦截器
│   ├── RepeatSubmitInterceptor.java    # 防重复提交拦截器
│   └── SameUrlDataInterceptor.java     # 同 URL 数据拦截器
├── datasource/                 # 动态数据源
│   ├── DynamicDataSource.java          # 动态数据源实现
│   └── DynamicDataSourceContextHolder.java # 数据源上下文
├── manager/                    # 异步任务管理
│   ├── AsyncManager.java                 # 异步任务管理器
│   ├── ShutdownManager.java            # 关闭管理器
│   └── AsyncFactory.java               # 异步任务工厂
└── web/                        # Web 服务
    ├── service/                        # 服务类
    │   ├── SysLoginService.java        # 登录服务
    │   ├── SysRegisterService.java     # 注册服务
    │   ├── TokenService.java           # Token 服务
    │   ├── SysPermissionService.java   # 权限服务
    │   ├── PermissionService.java      # 权限通用服务
    │   ├── SysPasswordService.java     # 密码服务
    │   └── UserDetailsServiceImpl.java # 用户详情服务
    ├── domain/server/                  # 服务器监控
    │   ├── Server.java                 # 服务器信息
    │   ├── Cpu.java                    # CPU 信息
    │   ├── Jvm.java                    # JVM 信息
    │   ├── Mem.java                    # 内存信息
    │   ├── Sys.java                    # 系统信息
    │   └── SysFile.java                # 文件信息
    └── exception/                      # 异常处理
        └── GlobalExceptionHandler.java # 全局异常处理器
```

## 核心功能

| 功能模块 | 说明 | 关键类 |
|----------|------|--------|
| 安全认证 | JWT + Spring Security 认证授权 | SecurityConfig, JwtAuthenticationTokenFilter |
| 登录注册 | 用户登录、注册、登出 | SysLoginService, SysRegisterService |
| 多数据源 | 动态主从数据源切换 | DynamicDataSource, DataSourceAspect |
| 操作日志 | AOP 记录操作日志 | LogAspect, AsyncFactory |
| 数据权限 | 基于角色的数据范围控制 | DataScopeAspect |
| 限流控制 | Redis 实现接口限流 | RateLimiterAspect, RedisConfig |
| 防重复提交 | 注解 + 拦截器防重提交 | RepeatSubmitInterceptor |
| 服务监控 | 服务器、JVM、CPU、内存监控 | Server, Cpu, Jvm, Mem |
| 异步任务 | 线程池异步处理 | AsyncManager, ThreadPoolConfig |
| 全局异常 | 统一异常处理 | GlobalExceptionHandler |

## 子模块文档

- [config.md](ruoyi-framework/config.md) - 配置类详解
- [security.md](ruoyi-framework/security.md) - 安全认证模块
- [aspectj.md](ruoyi-framework/aspectj.md) - AOP 切面模块
- [interceptor.md](ruoyi-framework/interceptor.md) - 拦截器模块
- [datasource.md](ruoyi-framework/datasource.md) - 动态数据源模块
- [manager.md](ruoyi-framework/manager.md) - 异步任务管理
- [web-service.md](ruoyi-framework/web-service.md) - Web 服务类
- [server-monitoring.md](ruoyi-framework/server-monitoring.md) - 服务器监控
- [exception.md](ruoyi-framework/exception.md) - 全局异常处理

## 依赖关系

```xml
<dependencies>
    <!-- Spring Boot Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webmvc</artifactId>
    </dependency>
    
    <!-- Spring Security -->
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-web</artifactId>
    </dependency>
    
    <!-- AOP -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-aspectj</artifactId>
    </dependency>
    
    <!-- Druid 数据源 -->
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>druid-spring-boot-4-starter</artifactId>
    </dependency>
    
    <!-- Redis -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
    
    <!-- 验证码 -->
    <dependency>
        <groupId>com.github.penggle</groupId>
        <artifactId>kaptcha</artifactId>
    </dependency>
    
    <!-- 系统信息 -->
    <dependency>
        <groupIdId>com.github.oshi</groupId>
        <artifactId>oshi-core</artifactId>
    </dependency>
    
    <!-- 系统模块 -->
    <dependency>
        <groupId>com.ruoyi</groupId>
        <artifactId>ruoyi-system</artifactId>
    </dependency>
</dependencies>
```

## 最佳实践

1. **安全配置**: 所有接口通过 SecurityConfig 配置安全策略
2. **日志记录**: 使用 `@Log` 注解自动记录操作日志
3. **数据源切换**: 使用 `@DataSource` 注解切换主从库
4. **限流保护**: 敏感接口使用 `@RateLimiter` 注解限流
5. **防重提交**: 表单提交使用 `@RepeatSubmit` 注解防护
6. **异步处理**: 耗时操作使用 AsyncManager 异步处理
7. **权限控制**: 使用 `@PreAuthorize` 注解控制接口权限

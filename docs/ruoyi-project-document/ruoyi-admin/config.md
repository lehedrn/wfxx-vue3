# 配置类详解

## 概述

`ruoyi-admin` 的配置类主要负责 Spring Boot 应用的各种配置，包括 Swagger 文档、Servlet 容器、MyBatis 等。

**源码位置**: `ruoyi-admin/src/main/java/com/ruoyi/web/core/config/`

---

## SwaggerConfig - Swagger 接口配置

**源码**: [`SwaggerConfig.java`](../../ruoyi-admin/src/main/java/com/ruoyi/web/core/config/SwaggerConfig.java)

### 作用

配置 Springdoc OpenAPI（Swagger）文档，包含：
- API 文档标题和描述
- Token 认证头配置
- 接口分组管理

### 核心配置

```java
@Configuration
public class SwaggerConfig
{
    @Bean
    public OpenAPI customOpenApi()
    {
        return new OpenAPI().components(new Components()
            // 设置认证的请求头
            .addSecuritySchemes("apikey", securityScheme()))
            .addSecurityItem(new SecurityRequirement().addList("apikey"))
            .info(getApiInfo());
    }
}
```

### SecurityScheme 配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| type | APIKEY | 认证类型为 API Key |
| name | Authorization | Token 传递的请求头名称 |
| in | HEADER | Token 放在请求头 |
| scheme | Bearer | 认证方案 |

### 访问 Swagger 文档

- Swagger UI: `http://localhost:18080/swagger-ui.html`
- API Docs: `http://localhost:18080/v3/api-docs`

### 接口分组配置

在 `application.yml` 中配置：

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
  group-configs:
    - group: 'default'
      display-name: '测试模块'
      paths-to-match: '/**'
      packages-to-scan: com.ruoyi.web.controller.tool
```

---

## RuoYiServletInitializer - Servlet 容器初始化

**源码**: [`RuoYiServletInitializer.java`](../../ruoyi-admin/src/main/java/com/ruoyi/RuoYiServletInitializer.java)

### 作用

支持 WAR 包部署到外部 Servlet 容器（如 Tomcat、Jetty）。

### 核心代码

```java
public class RuoYiServletInitializer extends SpringBootServletInitializer
{
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application)
    {
        return application.sources(RuoYiApplication.class);
    }
}
```

### 使用场景

- **JAR 部署**：使用 `RuoYiApplication` 的 `main` 方法直接运行
- **WAR 部署**：打包为 WAR 后部署到外部 Tomcat 容器

---

## application.yml 配置详解

**源码**: [`application.yml`](../../ruoyi-admin/src/main/resources/application.yml)

### 项目配置

```yaml
ruoyi:
  name: RuoYi                    # 项目名称
  version: 3.9.2                 # 版本号
  copyrightYear: 2026            # 版权年份
  profile: /home/workspace/com/wfxx-vue3/upload_path  # 文件上传路径
  addressEnabled: false          # 是否获取 IP 地址
  captchaType: math              # 验证码类型（math/char）
```

### 服务器配置

```yaml
server:
  port: 18080                    # HTTP 端口
  servlet:
    context-path: /              # 应用路径
  tomcat:
    uri-encoding: UTF-8          # URI 编码
    accept-count: 1000           # 排队请求数
    threads:
      max: 800                   # 最大线程数
      min-spare: 100             # 最小空闲线程数
```

### 用户密码配置

```yaml
user:
  password:
    maxRetryCount: 5             # 密码最大错误次数
    lockTime: 10                 # 密码锁定时间（分钟）
```

### Token 配置

```yaml
token:
  header: Authorization          # Token 请求头
  secret: abcdefghijklmnopqrstuvwxyz  # 密钥
  expireTime: 30                 # 有效期（分钟）
```

### Redis 配置

```yaml
spring:
  data:
    redis:
      host: localhost            # Redis 地址
      port: 6379                 # Redis 端口
      database: 0                # 数据库索引
      password: lihaidong        # Redis 密码
      timeout: 10s               # 连接超时
      lettuce:
        pool:
          min-idle: 0            # 最小空闲连接
          max-idle: 8            # 最大空闲连接
          max-active: 8          # 最大连接数
          max-wait: -1ms         # 最大阻塞等待时间
```

### XSS 过滤配置

```yaml
xss:
  enabled: true                  # 过滤开关
  excludes: /system/notice       # 排除链接
  urlPatterns: /system/*,/monitor/*,/tool/*  # 匹配链接
```

### 防盗链配置

```yaml
referer:
  enabled: false                 # 防盗链开关
  allowed-domains: localhost,127.0.0.1,ruoyi.vip,www.ruoyi.vip
```

---

## mybatis-config.xml 配置

**源码**: [`mybatis-config.xml`](../../ruoyi-admin/src/main/resources/mybatis/mybatis-config.xml)

### 全局配置

```xml
<configuration>
    <settings>
        <!-- 启用缓存 -->
        <setting name="cacheEnabled" value="true"/>
        <!-- 使用 JDBC 生成主键 -->
        <setting name="useGeneratedKeys" value="true"/>
        <!-- 默认执行器 -->
        <setting name="defaultExecutorType" value="SIMPLE"/>
        <!-- 日志实现 -->
        <setting name="logImpl" value="SLF4J"/>
        <!-- 驼峰命名转换（默认注释） -->
        <!-- <setting name="mapUnderscoreToCamelCase" value="true"/> -->
    </settings>
</configuration>
```

---

## PageHelper 分页配置

**源码**: [`application.yml`](../../ruoyi-admin/src/main/resources/application.yml) L113-L117

```yaml
pagehelper:
  helperDialect: mysql           # 数据库类型
  supportMethodsArguments: true  # 支持方法参数
  params: count=countSql         # 自定义参数
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

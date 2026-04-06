# Filter 过滤器模块（含 XSS 防护）

## 概述

`ruoyi-common/filter` 包提供了 RuoYi 框架的 Servlet 过滤器链，用于处理请求的预处理，包括 XSS 防护、重复提交防护、防盗链等功能。

## 过滤器列表

```
filter/
├── XssFilter                      # XSS 攻击防护过滤器
├── XssHttpServletRequestWrapper   # XSS 请求包装器
├── RepeatableFilter               # 可重复读取过滤器
├── RepeatedlyRequestWrapper       # 可重复读取请求包装器
├── RefererFilter                  # 防盗链过滤器
└── PropertyPreExcludeFilter       # JSON 属性排除过滤器
```

---

## 1. XSS 防护体系

### XssFilter - XSS 攻击防护过滤器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/XssFilter.java`

**用途**: 过滤所有请求中的 XSS 脚本攻击

**配置参数**:
| 参数名 | 说明 | 示例 |
|--------|------|------|
| excludes | 排除的 URL 路径（逗号分隔） | `/system/notice,/common/download` |

**过滤规则**:
- GET、DELETE 请求不过滤（避免影响正常数据）
- POST、PUT 请求进行过滤
- 支持配置排除路径

**核心逻辑**:
```java
public class XssFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        
        // 如果是排除的 URL，直接放行
        if (handleExcludeURL(req, resp)) {
            chain.doFilter(request, response);
            return;
        }
        
        // 包装请求进行 XSS 过滤
        XssHttpServletRequestWrapper xssRequest = 
            new XssHttpServletRequestWrapper((HttpServletRequest) request);
        chain.doFilter(xssRequest, response);
    }
}
```

**配置方式** (web.xml 或 FilterConfig):
```xml
<filter>
    <filter-name>XssFilter</filter-name>
    <filter-class>com.ruoyi.common.filter.XssFilter</filter-class>
    <init-param>
        <param-name>excludes</param-name>
        <param-value>/system/notice,/common/download,/common/upload</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>XssFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

**Spring Boot 配置**:
```java
@Configuration
public class FilterConfig {
    
    @Bean
    public FilterRegistrationBean<XssFilter> xssFilterRegistration() {
        FilterRegistrationBean<XssFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new XssFilter());
        registration.addUrlPatterns("/*");
        registration.addInitParameter("excludes", "/system/notice,/common/download");
        registration.setName("xssFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return registration;
    }
}
```

---

### XssHttpServletRequestWrapper - XSS 请求包装器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/XssHttpServletRequestWrapper.java`

**用途**: 包装 HttpServletRequest，对请求参数和 JSON 体进行 XSS 过滤

**核心方法**:

**1. 参数过滤**: 对 `getParameterValues()` 返回的值进行 `EscapeUtil.clean()` 处理

**2. JSON 请求体过滤**: 对 `getInputStream()` 返回的请求体进行 XSS 清理

**3. JSON 请求判断**: `isJsonRequest()` 检查 Content-Type 是否为 application/json

---

### EscapeUtil.clean() - XSS 清理方法

> 源码：`ruoyi-common/utils/src/main/java/com/ruoyi/common/utils/html/EscapeUtil.java`

**处理逻辑**:
1. 去除 script/iframe/style 标签
2. 去除 on 开头的事件属性
3. 去除 javascript: 协议
4. HTML 转义

---

## 2. XSS 校验注解

### @Xss - 自定义 XSS 校验注解

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/Xss.java`

**用途**: 在字段或参数上添加 XSS 校验

**定义**:
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(value = { ElementType.METHOD, ElementType.FIELD, 
                  ElementType.CONSTRUCTOR, ElementType.PARAMETER })
@Constraint(validatedBy = { XssValidator.class })
public @interface Xss {
    String message() default "不允许任何脚本运行";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

### XssValidator - XSS 校验器

> 源码：`ruoyi-common/annotation/src/main/java/com/ruoyi/common/annotation/XssValidator.java`

**用途**: 实现 @Xss 注解的校验逻辑，检测是否包含 HTML 标签

**使用示例**:
```java
public class SysUser extends BaseEntity {
    @Xss(message = "用户昵称不能包含脚本字符")
    @Size(min = 0, max = 30, message = "用户昵称长度不能超过 30 个字符")
    private String nickName;
    
    @Xss(message = "用户账号不能包含脚本字符")
    @NotBlank(message = "用户账号不能为空")
    @Size(min = 0, max = 30, message = "用户账号长度不能超过 30 个字符")
    private String userName;
}
```

---

## 3. 可重复读取过滤器

### RepeatableFilter - 可重复读取过滤器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/RepeatableFilter.java`

**用途**: 解决请求体只能读取一次的问题，用于后续过滤器或拦截器需要多次读取请求体的场景

**核心逻辑**: 仅对 JSON 请求进行包装，使用 `RepeatedlyRequestWrapper` 包装请求

### RepeatedlyRequestWrapper - 可重复读取请求包装器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/RepeatedlyRequestWrapper.java`

**用途**: 将请求体缓存到缓冲区，支持多次读取

**应用场景**:
- 日志记录需要记录请求体
- 防重复提交需要计算请求体签名
- 数据权限过滤需要解析请求体

---

## 4. 防盗链过滤器

### RefererFilter - 防盗链过滤器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/RefererFilter.java`

**用途**: 通过检查 Referer 头防止资源被盗用

**配置参数**:
| 参数名 | 说明 | 示例 |
|--------|------|------|
| allowedDomains | 允许的域名列表（逗号分隔） | `example.com,test.com` |

**核心逻辑**: 检查 Referer 头是否为空且在允许的域名列表中

**配置示例**:
```xml
<filter>
    <filter-name>RefererFilter</filter-name>
    <filter-class>com.ruoyi.common.filter.RefererFilter</filter-class>
    <init-param>
        <param-name>allowedDomains</param-name>
        <param-value>ruoyi.vip,example.com</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>RefererFilter</filter-name>
    <url-pattern>/profile/*</url-pattern>
</filter-mapping>
```

**使用场景**: 图片资源防盗链、文件下载防盗链、API 接口防盗用

---

## 5. JSON 属性排除过滤器

### PropertyPreExcludeFilter - JSON 属性排除过滤器

> 源码：`ruoyi-common/filter/src/main/java/com/ruoyi/common/filter/PropertyPreExcludeFilter.java`

**用途**: 在 JSON 序列化前排除指定属性，用于敏感数据过滤

---

## 过滤器链顺序

推荐的过滤器注册顺序：

1. **RepeatableFilter** (Order: HIGHEST_PRECEDENCE) - 最先执行，包装请求体
2. **XssFilter** (Order: HIGHEST_PRECEDENCE + 1) - XSS 过滤
3. **RefererFilter** (Order: HIGHEST_PRECEDENCE + 2) - 防盗链

> 完整配置示例见源码：`ruoyi-admin/src/main/java/com/ruoyi/web/core/config/FilterConfig.java`

---

## 最佳实践

### 1. XSS 防护配置

```java
@Configuration
public class XssConfig {
    @Bean
    public FilterRegistrationBean<XssFilter> xssFilterRegistration() {
        FilterRegistrationBean<XssFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new XssFilter());
        registration.addUrlPatterns("/*");
        // 排除文件上传下载等接口
        registration.addInitParameter("excludes", "/system/notice,/common/download,/common/upload");
        registration.setName("xssFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return registration;
    }
    
    @Bean
    public FilterRegistrationBean<RepeatableFilter> repeatableFilterRegistration() {
        FilterRegistrationBean<RepeatableFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new RepeatableFilter());
        registration.addUrlPatterns("/*");
        registration.setName("repeatableFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE - 1);  // 在 XSS 之前
        return registration;
    }
}
```

### 2. 实体类 XSS 校验

```java
public class UserDTO {
    @Xss(message = "用户名不能包含脚本字符")
    @NotBlank(message = "用户名不能为空")
    private String userName;
    
    @Xss(message = "昵称不能包含脚本字符")
    @Size(min = 0, max = 30, message = "昵称长度不能超过 30 个字符")
    private String nickName;
    
    @Email(message = "邮箱格式不正确")
    private String email;
}
```

### 3. 控制器层处理

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    @Autowired
    private SysUserService userService;
    
    @PostMapping
    @Log(title = "用户管理", businessType = BusinessType.INSERT)
    public AjaxResult add(@Validated @RequestBody SysUser user) {
        // @Validated 会触发@Xss 校验
        return toAjax(userService.insertUser(user));
    }
}
```

### 4. 自定义 XSS 过滤规则

```java
public class CustomXssFilter extends XssFilter {
    @Override
    protected boolean handleExcludeURL(HttpServletRequest request, 
                                       HttpServletResponse response) {
        // 自定义排除逻辑
        String url = request.getServletPath();
        
        // 排除 Swagger 相关接口
        if (url.startsWith("/swagger") || url.startsWith("/v2/api-docs")) {
            return true;
        }
        
        return super.handleExcludeURL(request, response);
    }
}
```

---

## 安全建议

1. **开启 XSS 过滤**: 生产环境必须开启 XSS 过滤
2. **合理配置排除路径**: 文件上传下载等接口可排除，但要确保有其他安全措施
3. **使用@Xss 注解**: 在实体类字段上添加@Xss 注解进行校验
4. **配合前端验证**: 前后端双重验证，提高安全性
5. **定期更新规则**: 根据新的 XSS 攻击手段更新过滤规则
6. **日志记录**: 记录被拦截的 XSS 攻击请求，用于安全分析

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

**用途**: 过滤所有请求中的 XSS 脚本攻击

**配置参数**:
| 参数名 | 说明 | 示例 |
|--------|------|------|
| excludes | 排除的 URL 路径（逗号分隔） | `/system/notice,/common/download` |

**过滤规则**:
- GET、DELETE 请求不过滤（避免影响正常数据）
- POST、PUT 请求进行过滤
- 支持配置排除路径

**源代码分析**:
```java
public class XssFilter implements Filter {
    public List<String> excludes = new ArrayList<>();
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String tempExcludes = filterConfig.getInitParameter("excludes");
        if (StringUtils.isNotEmpty(tempExcludes)) {
            String[] urls = tempExcludes.split(",");
            for (String url : urls) {
                excludes.add(url);
            }
        }
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        
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
    
    private boolean handleExcludeURL(HttpServletRequest request, HttpServletResponse response) {
        String url = request.getServletPath();
        String method = request.getMethod();
        
        // GET DELETE 不过滤
        if (method == null || HttpMethod.GET.matches(method) || 
            HttpMethod.DELETE.matches(method)) {
            return true;
        }
        
        return StringUtils.matches(url, excludes);
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

**用途**: 包装 HttpServletRequest，对请求参数和 JSON 体进行 XSS 过滤

**核心方法**:

**1. 参数过滤**:
```java
@Override
public String[] getParameterValues(String name) {
    String[] values = super.getParameterValues(name);
    if (values != null) {
        int length = values.length;
        String[] escapesValues = new String[length];
        for (int i = 0; i < length; i++) {
            // 防 xss 攻击和过滤前后空格
            escapesValues[i] = EscapeUtil.clean(values[i]).trim();
        }
        return escapesValues;
    }
    return super.getParameterValues(name);
}
```

**2. JSON 请求体过滤**:
```java
@Override
public ServletInputStream getInputStream() throws IOException {
    // 非 json 类型，直接返回
    if (!isJsonRequest()) {
        return super.getInputStream();
    }

    // 为空，直接返回
    String json = IOUtils.toString(super.getInputStream(), "utf-8");
    if (StringUtils.isEmpty(json)) {
        return super.getInputStream();
    }

    // xss 过滤
    json = EscapeUtil.clean(json).trim();
    byte[] jsonBytes = json.getBytes("utf-8");
    final ByteArrayInputStream bis = new ByteArrayInputStream(jsonBytes);
    
    return new ServletInputStream() {
        @Override
        public boolean isFinished() { return true; }
        
        @Override
        public boolean isReady() { return true; }
        
        @Override
        public int available() throws IOException {
            return jsonBytes.length;
        }
        
        @Override
        public void setReadListener(ReadListener readListener) {}
        
        @Override
        public int read() throws IOException {
            return bis.read();
        }
    };
}
```

**3. JSON 请求判断**:
```java
public boolean isJsonRequest() {
    String header = super.getHeader(HttpHeaders.CONTENT_TYPE);
    return StringUtils.startsWithIgnoreCase(header, MediaType.APPLICATION_JSON_VALUE);
}
```

---

### EscapeUtil.clean() - XSS 清理方法

**用途**: 清理字符串中的 XSS 攻击脚本

**处理逻辑**:
```java
public static String clean(String html) {
    if (StringUtils.isEmpty(html)) {
        return html;
    }
    
    // 1. 去除 script 标签
    html = html.replaceAll("<script[^>]*>.*?</script>", "");
    
    // 2. 去除 iframe 标签
    html = html.replaceAll("<iframe[^>]*>.*?</iframe>", "");
    
    // 3. 去除 style 标签
    html = html.replaceAll("<style[^>]*>.*?</style>", "");
    
    // 4. 去除 on 开头的事件属性
    html = html.replaceAll("on\\w+\\s*=\\s*['\"][^'\"]*['\"]", "");
    
    // 5. 去除 javascript: 协议
    html = html.replaceAll("javascript:", "");
    
    // 6. HTML 转义
    return escape(html);
}
```

---

## 2. XSS 校验注解

### @Xss - 自定义 XSS 校验注解

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

**用途**: 实现 @Xss 注解的校验逻辑

**核心方法**:
```java
public class XssValidator implements ConstraintValidator<Xss, String> {
    private static final String HTML_PATTERN = "<(\\S*?)[^>]*>.*?|<.*? />";
    
    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (StringUtils.isBlank(value)) {
            return true;
        }
        return !containsHtml(value);
    }
    
    public static boolean containsHtml(String value) {
        StringBuilder sHtml = new StringBuilder();
        Pattern pattern = Pattern.compile(HTML_PATTERN);
        Matcher matcher = pattern.matcher(value);
        while (matcher.find()) {
            sHtml.append(matcher.group());
        }
        return pattern.matcher(sHtml).matches();
    }
}
```

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
    
    // getters and setters...
}
```

---

## 3. 可重复读取过滤器

### RepeatableFilter - 可重复读取过滤器

**用途**: 解决请求体只能读取一次的问题，用于后续过滤器或拦截器需要多次读取请求体的场景

**配置**:
```java
public class RepeatableFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        ServletRequest requestWrapper = null;
        
        // 仅对 JSON 请求进行包装
        if (request instanceof HttpServletRequest
                && StringUtils.startsWithIgnoreCase(request.getContentType(), 
                    MediaType.APPLICATION_JSON_VALUE)) {
            requestWrapper = new RepeatedlyRequestWrapper(
                (HttpServletRequest) request, response);
        }
        
        if (null == requestWrapper) {
            chain.doFilter(request, response);
        } else {
            chain.doFilter(requestWrapper, response);
        }
    }
}
```

### RepeatedlyRequestWrapper - 可重复读取请求包装器

**用途**: 将请求体缓存到缓冲区，支持多次读取

**核心实现**:
```java
public class RepeatedlyRequestWrapper extends HttpServletRequestWrapper {
    private final byte[] body;
    
    public RepeatedlyRequestWrapper(HttpServletRequest request, ServletResponse response) {
        super(request);
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 读取请求体并缓存
        body = getBodyBuffer(request);
    }
    
    @Override
    public BufferedReader getReader() throws IOException {
        return new BufferedReader(new InputStreamReader(getInputStream()));
    }
    
    @Override
    public ServletInputStream getInputStream() throws IOException {
        final ByteArrayInputStream bais = new ByteArrayInputStream(body);
        return new RepeatedlyRequestInputStream(bais);
    }
    
    private byte[] getBodyBuffer(HttpServletRequest request) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try {
            IOUtils.copy(request.getInputStream(), bos);
        } catch (IOException e) {
            throw new RuntimeException("读取请求体失败", e);
        }
        return bos.toByteArray();
    }
}
```

**应用场景**:
- 日志记录需要记录请求体
- 防重复提交需要计算请求体签名
- 数据权限过滤需要解析请求体

---

## 4. 防盗链过滤器

### RefererFilter - 防盗链过滤器

**用途**: 通过检查 Referer 头防止资源被盗用

**配置参数**:
| 参数名 | 说明 | 示例 |
|--------|------|------|
| allowedDomains | 允许的域名列表（逗号分隔） | `example.com,test.com` |

**核心实现**:
```java
public class RefererFilter implements Filter {
    public List<String> allowedDomains;
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String domains = filterConfig.getInitParameter("allowedDomains");
        this.allowedDomains = Arrays.asList(domains.split(","));
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        
        String referer = req.getHeader("Referer");
        
        // 如果 Referer 为空，拒绝访问
        if (referer == null || referer.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "Access denied: Referer header is required");
            return;
        }
        
        // 检查 Referer 是否在允许的域名列表中
        boolean allowed = false;
        for (String domain : allowedDomains) {
            if (referer.contains(domain)) {
                allowed = true;
                break;
            }
        }
        
        if (allowed) {
            chain.doFilter(request, response);
        } else {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "Access denied: Referer '" + referer + "' is not allowed");
        }
    }
}
```

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

**使用场景**:
- 图片资源防盗链
- 文件下载防盗链
- API 接口防盗用

---

## 5. JSON 属性排除过滤器

### PropertyPreExcludeFilter - JSON 属性排除过滤器

**用途**: 在 JSON 序列化前排除指定属性，用于敏感数据过滤

**使用示例**:
```java
// 排除密码字段
FastJsonJsonView jsonView = new FastJsonJsonView();
SimplePropertyPreFilter filter = new SimplePropertyPreFilter();
filter.getExcludes().add("password");
jsonView.setPreFilters(filter);
```

---

## 过滤器链顺序

推荐的过滤器注册顺序：

```java
@Configuration
public class FilterConfig {
    
    @Bean
    public FilterRegistrationBean<RepeatableFilter> repeatableFilter() {
        FilterRegistrationBean<RepeatableFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new RepeatableFilter());
        registration.addUrlPatterns("/*");
        registration.setName("repeatableFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);  // 最先执行
        return registration;
    }
    
    @Bean
    public FilterRegistrationBean<XssFilter> xssFilter() {
        FilterRegistrationBean<XssFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new XssFilter());
        registration.addUrlPatterns("/*");
        registration.addInitParameter("excludes", "/system/notice,/common/download");
        registration.setName("xssFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE + 1);
        return registration;
    }
    
    @Bean
    public FilterRegistrationBean<RefererFilter> refererFilter() {
        FilterRegistrationBean<RefererFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new RefererFilter());
        registration.addUrlPatterns("/profile/*");
        registration.addInitParameter("allowedDomains", "ruoyi.vip");
        registration.setName("refererFilter");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE + 2);
        return registration;
    }
}
```

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
        registration.addInitParameter("excludes", 
            "/system/notice,/common/download,/common/upload");
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

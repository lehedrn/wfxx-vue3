# Config 配置模块

## 概述

`ruoyi-framework/config` 包提供了 11 个核心配置类，用于配置 Spring Boot 应用的各个方面的行为。

## 模块结构

```
config/
├── ApplicationConfig.java          # 应用基础配置
├── DruidConfig.java                # Druid 数据源配置
├── RedisConfig.java                # Redis 配置
├── MyBatisConfig.java              # MyBatis 配置
├── SecurityConfig.java             # Spring Security 配置
├── ThreadPoolConfig.java           # 线程池配置
├── ResourcesConfig.java            # 资源访问配置
├── CaptchaConfig.java              # 验证码配置
├── FilterConfig.java               # 过滤器配置
├── I18nConfig.java                 # 国际化配置
├── ServerConfig.java               # 服务监控配置
└── properties/                     # 配置属性类
    ├── XssProperties.java          # XSS 配置属性
    └── PackageProperties.java      # 包配置属性
```

---

## 1. ApplicationConfig - 应用基础配置

**用途**: 提供 Spring Boot 应用的基础注解配置

**核心配置**:

```java
@Configuration
// 通过 AOP 框架暴露代理对象，AopContext 能够访问
@EnableAspectJAutoProxy(exposeProxy = true)
// 指定要扫描的 Mapper 类的包路径
@MapperScan("com.ruoyi.**.mapper")
public class ApplicationConfig
{
    // 空的配置类，仅通过注解提供基础配置
}
```

**注解说明**:

- `@EnableAspectJAutoProxy(exposeProxy = true)`: 启用 AOP 代理，并暴露代理对象到 AopContext
- `@MapperScan("com.ruoyi.**.mapper")`: 扫描所有 com.ruoyi 包下的 Mapper 接口

**使用示例**:

```java
// 在 Service 中获取 AOP 代理对象
SysUserService service = (SysUserService) AopContext.currentProxy();
service.someMethod();
```

---

## 2. DruidConfig - Druid 多数据源配置

**用途**: 配置 Druid 多数据源（主库/从库）和去除监控页面广告

**核心配置**:

```java
@Configuration
public class DruidConfig {
    
    /**
     * 主数据源配置
     */
    @Bean
    @ConfigurationProperties("spring.datasource.druid.master")
    public DataSource masterDataSource(DruidProperties druidProperties) {
        DruidDataSource dataSource = DruidDataSourceBuilder.create().build();
        return druidProperties.dataSource(dataSource);
    }
    
    /**
     * 从数据源配置（可选）
     */
    @Bean
    @ConfigurationProperties("spring.datasource.druid.slave")
    @ConditionalOnProperty(prefix = "spring.datasource.druid.slave", 
                          name = "enabled", havingValue = "true")
    public DataSource slaveDataSource(DruidProperties druidProperties) {
        DruidDataSource dataSource = DruidDataSourceBuilder.create().build();
        return druidProperties.dataSource(dataSource);
    }
    
    /**
     * 动态数据源
     */
    @Bean(name = "dynamicDataSource")
    @Primary
    public DynamicDataSource dataSource(DataSource masterDataSource) {
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put(DataSourceType.MASTER.name(), masterDataSource);
        setDataSource(targetDataSources, DataSourceType.SLAVE.name(), "slaveDataSource");
        return new DynamicDataSource(masterDataSource, targetDataSources);
    }
    
    /**
     * 去除监控页面底部广告
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    @Bean
    @ConditionalOnProperty(name = "spring.datasource.druid.statViewServlet.enabled", 
                          havingValue = "true")
    public FilterRegistrationBean removeDruidFilterRegistrationBean(DruidStatProperties properties) {
        // 获取 web 监控页面参数
        DruidStatProperties.StatViewServlet config = properties.getStatViewServlet();
        String pattern = config.getUrlPattern() != null ? config.getUrlPattern() : "/druid/*";
        String commonJsPattern = pattern.replaceAll("\\*", "js/common.js");
        
        Filter filter = (request, response, chain) -> {
            chain.doFilter(request, response);
            response.resetBuffer();
            // 获取 common.js 并去除广告
            String text = Utils.readFromResource("support/http/resources/js/common.js");
            text = text.replaceAll("<a.*?banner\"></a><br/>", "");
            text = text.replaceAll("powered.*?shrek.wang</a>", "");
            response.getWriter().write(text);
        };
        
        FilterRegistrationBean registrationBean = new FilterRegistrationBean();
        registrationBean.setFilter(filter);
        registrationBean.addUrlPatterns(commonJsPattern);
        return registrationBean;
    }
}
```

**application.yml 配置示例**:

```yaml
spring:
  datasource:
    druid:
      master:
        url: jdbc:mysql://localhost:3306/ruoyi?useUnicode=true&characterEncoding=utf8
        username: root
        password: password
        driver-class-name: com.mysql.cj.jdbc.Driver
      slave:
        enabled: true
        url: jdbc:mysql://localhost:3307/ruoyi_slave
        username: root
        password: password
        driver-class-name: com.mysql.cj.jdbc.Driver
      stat-view-servlet:
        enabled: true
        url-pattern: /druid/*
        login-username: admin
        login-password: 123456
```

**监控页面**: `http://localhost:8080/druid/index.html`

---

## 3. RedisConfig - Redis 配置

**用途**: 配置 Redis 连接、序列化器和限流脚本

**核心配置**:

```java
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport {
    
    /**
     * RedisTemplate 配置
     * 使用 FastJson2JsonRedisSerializer 序列化 value
     */
    @Bean
    @SuppressWarnings(value = { "unchecked", "rawtypes" })
    public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<Object, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        // 使用 FastJson2JsonRedisSerializer 序列化器
        FastJson2JsonRedisSerializer serializer = new FastJson2JsonRedisSerializer(Object.class);

        // 使用 StringRedisSerializer 序列化 key
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(serializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);

        template.afterPropertiesSet();
        return template;
    }
    
    /**
     * 限流 Lua 脚本
     */
    @Bean
    public DefaultRedisScript<Long> limitScript() {
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
        redisScript.setScriptText(limitScriptText());
        redisScript.setResultType(Long.class);
        return redisScript;
    }
    
    /**
     * 限流脚本内容
     */
    private String limitScriptText() {
        return "local key = KEYS[1]\n" +
                "local count = tonumber(ARGV[1])\n" +
                "local time = tonumber(ARGV[2])\n" +
                "local current = redis.call('get', key);\n" +
                "if current and tonumber(current) > count then\n" +
                "    return tonumber(current);\n" +
                "end\n" +
                "current = redis.call('incr', key)\n" +
                "if tonumber(current) == 1 then\n" +
                "    redis.call('expire', key, time)\n" +
                "end\n" +
                "return tonumber(current);";
    }
}
```

**Lua 限流脚本说明**:

- `KEYS[1]`: 限流 Key
- `ARGV[1]`: 限流次数
- `ARGV[2]`: 限流时间 (秒)
- 逻辑：如果当前计数超过限制则返回当前值，否则递增并设置过期时间

**使用示例**:

```java
@Autowired
private RedisTemplate<String, Object> redisTemplate;

@Autowired
private DefaultRedisScript<Long> limitScript;

// 执行限流
Long count = redisTemplate.execute(
    limitScript, 
    Collections.singletonList("rate:limit:key"), 
    100,  // 限流次数
    60    // 限流时间 (秒)
);

if (count > 100) {
    throw new ServiceException("访问过于频繁");
}
```

---

## 4. MyBatisConfig - MyBatis 配置

**用途**: 配置 MyBatis 分页插件和类型处理器

**核心配置**:

```java
@Configuration
public class MyBatisConfig {
    
    /**
     * PageHelper 分页插件
     */
    @Bean
    public PageInterceptor pageInterceptor() {
        PageInterceptor interceptor = new PageInterceptor();
        Properties properties = new Properties();
        // 支持通过参数动态设置分页
        properties.setProperty("supportMethodsArguments", "true");
        // 自动检测分页合理性
        properties.setProperty("reasonable", "true");
        // 指定数据库类型
        properties.setProperty("dialect", "mysql");
        interceptor.setProperties(properties);
        return interceptor;
    }
}
```

---

## 5. SecurityConfig - Spring Security 配置

**用途**: 配置 Spring Security 6.x 的安全策略（使用 SecurityFilterChain 而非 WebSecurityConfigurerAdapter）

**核心配置**:

```java
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
@Configuration
public class SecurityConfig {
    
    @Autowired
    private AuthenticationEntryPointImpl unauthorizedHandler;
    
    @Autowired
    private LogoutSuccessHandlerImpl logoutSuccessHandler;
    
    @Autowired
    private JwtAuthenticationTokenFilter authenticationTokenFilter;
    
    @Autowired
    private CorsFilter corsFilter;
    
    @Autowired
    private PermitAllUrlProperties permitAllUrl;
    
    /**
     * 认证管理器
     */
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }
    
    /**
     * 安全过滤链配置
     */
    @Bean
    protected SecurityFilterChain filterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
            // CSRF 禁用
            .csrf(csrf -> csrf.disable())
            // 禁用 HTTP 响应标头
            .headers(headers -> headers
                .cacheControl(cache -> cache.disable())
                .frameOptions(options -> options.sameOrigin()))
            // 认证失败处理
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint(unauthorizedHandler))
            // 基于 token，不创建 session
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            // 请求授权配置
            .authorizeHttpRequests(requests -> {
                // 匿名访问的 URL
                permitAllUrl.getUrls().forEach(url -> 
                    requests.requestMatchers(url).permitAll());
                
                // 登录、注册、验证码允许匿名访问
                requests.requestMatchers("/login", "/register", "/captchaImage").permitAll()
                    // 静态资源匿名访问
                    .requestMatchers(HttpMethod.GET, "/", "/*.html", "/**.html", 
                                    "/**.css", "/**.js", "/profile/**").permitAll()
                    // Swagger 和 Druid 监控匿名访问
                    .requestMatchers("/swagger-ui.html", "/v3/api-docs/**", 
                                    "/swagger-ui/**", "/druid/**").permitAll()
                    // 其他请求需要认证
                    .anyRequest().authenticated();
            })
            // 登出配置
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessHandler(logoutSuccessHandler))
            // 添加 JWT 过滤器
            .addFilterBefore(authenticationTokenFilter, 
                            UsernamePasswordAuthenticationFilter.class)
            // 添加 CORS 过滤器
            .addFilterBefore(corsFilter, JwtAuthenticationTokenFilter.class)
            .addFilterBefore(corsFilter, LogoutFilter.class)
            .build();
    }
    
    /**
     * BCrypt 密码加密器
     */
    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

**注解说明**:

- `@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)`: 启用方法级安全注解
  - `prePostEnabled = true`: 支持 `@PreAuthorize`、`@PostAuthorize` 注解
  - `securedEnabled = true`: 支持 `@Secured` 注解

**Spring Security 6.x 新特性**:

- 不再继承 `WebSecurityConfigurerAdapter`（已废弃）
- 使用 `SecurityFilterChain` Bean 配置安全策略
- 使用 Lambda DSL 配置语法

**使用示例**:

```java
// 方法级权限控制
@PreAuthorize("@ss.hasPermi('system:user:list')")
@GetMapping("/list")
public TableDataInfo list() { ... }

// 方法级角色控制
@Secured("ROLE_ADMIN")
@PostMapping("/add")
public AjaxResult add() { ... }
```

---

## 6. ThreadPoolConfig - 线程池配置

**用途**: 配置异步任务执行的线程池

**核心配置**:

```java
@Configuration
public class ThreadPoolConfig {
    
    // 核心线程数
    private static final int CORE_POOL_SIZE = 50;
    // 最大线程数
    private static final int MAX_POOL_SIZE = 200;
    // 队列大小
    private static final int QUEUE_CAPACITY = 1000;
    // 空闲线程存活时间 (秒)
    private static final int KEEP_ALIVE_SECONDS = 60;
    
    @Bean(name = "threadPoolTaskExecutor")
    public ThreadPoolTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(CORE_POOL_SIZE);
        executor.setMaxPoolSize(MAX_POOL_SIZE);
        executor.setQueueCapacity(QUEUE_CAPACITY);
        executor.setKeepAliveSeconds(KEEP_ALIVE_SECONDS);
        // 线程命名前缀
        executor.setThreadNamePrefix("ruoyi-");
        // 拒绝策略：由调用线程处理
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
```

**使用示例**:

```java
@Autowired
private ThreadPoolTaskExecutor taskExecutor;

// 异步执行
taskExecutor.execute(() -> {
    // 耗时操作
    log.info("异步任务执行中");
});
```

---

## 7. ResourcesConfig - 资源访问配置

**用途**: 配置静态资源访问路径

**核心配置**:

```java
@Configuration
public class ResourcesConfig implements WebMvcConfigurer {
    
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 本地文件上传路径映射
        registry.addResourceHandler("/profile/**")
                .addResourceLocations("file:" + RuoYiConfig.getProfile() + "/");
        
        // 下载路径映射
        registry.addResourceHandler("/download/**")
                .addResourceLocations("file:" + RuoYiConfig.getDownloadPath() + "/");
        
        // 导入路径映射
        registry.addResourceHandler("/import/**")
                .addResourceLocations("file:" + RuoYiConfig.getImportPath() + "/");
        
        // classpath 静态资源
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
    }
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowCredentials(true)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .maxAge(3600);
    }
}
```

---

## 8. CaptchaConfig - 验证码配置

**用途**: 配置验证码生成器

**核心配置**:

```java
@Configuration
public class CaptchaConfig {
    
    @Bean(name = "captchaProducer")
    public DefaultKaptcha getKaptchaBean() {
        DefaultKaptcha defaultKaptcha = new DefaultKaptcha();
        Properties properties = new Properties();
        // 是否有边框
        properties.setProperty("kaptcha.border", "no");
        // 边框颜色
        properties.setProperty("kaptcha.border.color", "105,179,90");
        // 字体大小
        properties.setProperty("kaptcha.textproducer.font.size", "30");
        // 图片宽度
        properties.setProperty("kaptcha.image.width", "160");
        // 图片高度
        properties.setProperty("kaptcha.image.height", "60");
        // 验证码字符集
        properties.setProperty("kaptcha.textproducer.char.string", "23456789ABCDEFGHJKLMNPQRSTUVWXYZ");
        // 验证码长度
        properties.setProperty("kaptcha.textproducer.char.length", "4");
        // 字体
        properties.setProperty("kaptcha.textproducer.font.names", "Arial,Courier");
        defaultKaptcha.setConfig(new Config(properties));
        return defaultKaptcha;
    }
    
    @Bean(name = "captchaProducerMath")
    public DefaultKaptcha getKaptchaBeanMath() {
        DefaultKaptcha defaultKaptcha = new DefaultKaptcha();
        Properties properties = new Properties();
        properties.setProperty("kaptcha.border", "no");
        properties.setProperty("kaptcha.border.color", "105,179,90");
        properties.setProperty("kaptcha.textproducer.font.size", "35");
        properties.setProperty("kaptcha.image.width", "160");
        properties.setProperty("kaptcha.image.height", "60");
        properties.setProperty("kaptcha.textproducer.font.names", "Arial,Courier");
        defaultKaptcha.setConfig(new Config(properties));
        return defaultKaptcha;
    }
}
```

---

## 9. FilterConfig - 过滤器配置

**用途**: 配置 Web 过滤器，包括 XSS 过滤器

**核心配置**:

```java
@Configuration
public class FilterConfig {
    
    @Bean
    public FilterRegistrationBean<RepeatSubmitFilter> repeatSubmitFilter() {
        FilterRegistrationBean<RepeatSubmitFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new RepeatSubmitFilter());
        registration.addUrlPatterns("/*");
        registration.setOrder(1);
        return registration;
    }
    
    @Bean
    public FilterRegistrationBean<XssFilter> xssFilter() {
        FilterRegistrationBean<XssFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new XssFilter());
        registration.addUrlPatterns("/*");
        registration.setName("xssFilter");
        registration.setOrder(2);
        return registration;
    }
}
```

---

## 10. I18nConfig - 国际化配置

**用途**: 配置国际化消息解析器

**核心配置**:

```java
@Configuration
public class I18nConfig {
    
    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource source = new ResourceBundleMessageSource();
        source.setBasenames("i18n/messages");
        source.setDefaultEncoding("UTF-8");
        return source;
    }
}
```

---

## 11. ServerConfig - 服务监控配置

**用途**: 配置服务器监控相关参数

**核心配置**:

```java
@Component
@ConfigurationProperties(prefix = "server.monitor")
public class ServerConfig {
    
    /**
     * 服务器名称
     */
    private String serverName;
    
    /**
     * 是否启用监控
     */
    private boolean enabled = true;
    
    // Getter 和 Setter
}
```

---

## properties 配置属性类

### XssProperties - XSS 配置属性

```java
@Component
@ConfigurationProperties(prefix = "xss")
public class XssProperties {
    
    /**
     * XSS 开关
     */
    private boolean enabled = true;
    
    /**
     * 排除路径
     */
    private List<String> excludes = new ArrayList<>();
    
    /**
     * URL 匹配模式
     */
    private List<String> urlPatterns = new ArrayList<>();
    
    // Getter 和 Setter
}
```

### PackageProperties - 包配置属性

```java
@Component
@ConfigurationProperties(prefix = "package")
public class PackageProperties {
    
    /**
     * 需要扫描的包路径
     */
    private List<String> scanPackages = new ArrayList<>();
    
    // Getter 和 Setter
}
```

---

## 最佳实践

1. **线程池配置**: 根据服务器 CPU 核心数调整 CORE_POOL_SIZE 和 MAX_POOL_SIZE
2. **Redis 序列化**: 统一使用 Jackson2JsonRedisSerializer 保证跨语言兼容
3. **安全配置**: 生产环境修改默认密码和密钥
4. **监控配置**: 生产环境关闭 Druid 监控或设置强密码
5. **资源映射**: 文件上传路径配置到独立磁盘分区
6. **XSS 过滤**: 根据实际情况配置排除路径，避免误伤正常请求

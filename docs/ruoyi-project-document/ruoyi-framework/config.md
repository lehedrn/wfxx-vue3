# Config 配置模块

## 概述

`ruoyi-framework/config` 包提供 11 个核心配置类，用于配置 Spring Boot 应用的各个方面的行为。

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
└── properties/
    ├── XssProperties.java          # XSS 配置属性
    └── PackageProperties.java      # 包配置属性
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/config/`

---

## 1. ApplicationConfig - 应用基础配置

**源码位置**: `ruoyi-framework/config/ApplicationConfig.java`

**核心配置**:

```java
@Configuration
@EnableAspectJAutoProxy(exposeProxy = true)  // 暴露 AOP 代理到 AopContext
@MapperScan("com.ruoyi.**.mapper")           // 扫描 Mapper 接口
public class ApplicationConfig {
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

**源码位置**: `ruoyi-framework/config/DruidConfig.java`

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
    @Bean
    @ConditionalOnProperty(name = "spring.datasource.druid.statViewServlet.enabled", 
                          havingValue = "true")
    public FilterRegistrationBean removeDruidFilterRegistrationBean(DruidStatProperties properties) {
        // 获取 common.js 并去除广告内容
        // ...
    }
}
```

**application.yml 配置示例**:

```yaml
spring:
  datasource:
    druid:
      master:
        url: jdbc:mysql://localhost:3306/ruoyi
        username: root
        password: password
        driver-class-name: com.mysql.cj.jdbc.Driver
      slave:
        enabled: true
        url: jdbc:mysql://localhost:3307/ruoyi_slave
        username: root
        password: password
      stat-view-servlet:
        enabled: true
        url-pattern: /druid/*
        login-username: admin
        login-password: 123456
```

**监控页面**: `http://localhost:8080/druid/index.html`

---

## 3. RedisConfig - Redis 配置

**源码位置**: `ruoyi-framework/config/RedisConfig.java`

**核心配置**:

```java
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport {
    
    /**
     * RedisTemplate 配置
     */
    @Bean
    public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<Object, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        // 使用 FastJson2JsonRedisSerializer 序列化 value
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

| 参数 | 说明 |
|------|------|
| KEYS[1] | 限流 Key |
| ARGV[1] | 限流次数 |
| ARGV[2] | 限流时间 (秒) |

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

**源码位置**: `ruoyi-framework/config/MyBatisConfig.java`

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
        properties.setProperty("supportMethodsArguments", "true"); // 支持动态分页
        properties.setProperty("reasonable", "true");              // 智能分页
        properties.setProperty("dialect", "mysql");                // 数据库类型
        interceptor.setProperties(properties);
        return interceptor;
    }
}
```

---

## 5. SecurityConfig - Spring Security 配置

**源码位置**: `ruoyi-framework/config/SecurityConfig.java`

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
    
    /**
     * 安全过滤链配置
     */
    @Bean
    protected SecurityFilterChain filterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
            .csrf(csrf -> csrf.disable())                                    // 禁用 CSRF
            .headers(headers -> headers.cacheControl(cache -> cache.disable())) // 禁用缓存
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint(unauthorizedHandler))              // 认证失败处理
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))     // 无状态
            .authorizeHttpRequests(requests -> {
                // 匿名访问的 URL
                permitAllUrl.getUrls().forEach(url -> 
                    requests.requestMatchers(url).permitAll());
                
                requests.requestMatchers("/login", "/register", "/captchaImage").permitAll()
                    .requestMatchers("/*.html", "/**.css", "/**.js").permitAll()
                    .requestMatchers("/swagger-ui.html", "/druid/**").permitAll()
                    .anyRequest().authenticated();
            })
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessHandler(logoutSuccessHandler))
            .addFilterBefore(authenticationTokenFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
    
    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

**注解说明**:
- `@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)`: 启用方法级安全注解
  - 支持 `@PreAuthorize`、`@PostAuthorize` 注解
  - 支持 `@Secured` 注解

**使用示例**:

```java
@PreAuthorize("@ss.hasPermi('system:user:list')")
@GetMapping("/list")
public TableDataInfo list() { ... }

@Secured("ROLE_ADMIN")
@PostMapping("/add")
public AjaxResult add() { ... }
```

---

## 6. ThreadPoolConfig - 线程池配置

**源码位置**: `ruoyi-framework/config/ThreadPoolConfig.java`

**核心配置**:

```java
@Configuration
public class ThreadPoolConfig {
    
    private static final int CORE_POOL_SIZE = 50;
    private static final int MAX_POOL_SIZE = 200;
    private static final int QUEUE_CAPACITY = 1000;
    private static final int KEEP_ALIVE_SECONDS = 60;
    
    @Bean(name = "threadPoolTaskExecutor")
    public ThreadPoolTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(CORE_POOL_SIZE);
        executor.setMaxPoolSize(MAX_POOL_SIZE);
        executor.setQueueCapacity(QUEUE_CAPACITY);
        executor.setKeepAliveSeconds(KEEP_ALIVE_SECONDS);
        executor.setThreadNamePrefix("ruoyi-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
    
    @Bean(name = "scheduledExecutorService")
    public ScheduledExecutorService scheduledExecutorService() {
        return Executors.newScheduledThreadPool(10);
    }
}
```

---

## 7. ResourcesConfig - 资源访问配置

**源码位置**: `ruoyi-framework/config/ResourcesConfig.java`

**核心配置**:

```java
@Configuration
public class ResourcesConfig implements WebMvcConfigurer {
    
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/profile/**")
                .addResourceLocations("file:" + RuoYiConfig.getProfile() + "/");
        registry.addResourceHandler("/download/**")
                .addResourceLocations("file:" + RuoYiConfig.getDownloadPath() + "/");
        registry.addResourceHandler("/import/**")
                .addResourceLocations("file:" + RuoYiConfig.getImportPath() + "/");
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

**源码位置**: `ruoyi-framework/config/CaptchaConfig.java`

**核心配置**:

```java
@Configuration
public class CaptchaConfig {
    
    @Bean(name = "captchaProducer")
    public DefaultKaptcha getKaptchaBean() {
        DefaultKaptcha defaultKaptcha = new DefaultKaptcha();
        Properties properties = new Properties();
        properties.setProperty("kaptcha.border", "no");
        properties.setProperty("kaptcha.image.width", "160");
        properties.setProperty("kaptcha.image.height", "60");
        properties.setProperty("kaptcha.textproducer.char.string", 
            "23456789ABCDEFGHJKLMNPQRSTUVWXYZ");
        properties.setProperty("kaptcha.textproducer.char.length", "4");
        defaultKaptcha.setConfig(new Config(properties));
        return defaultKaptcha;
    }
}
```

---

## 9. FilterConfig - 过滤器配置

**源码位置**: `ruoyi-framework/config/FilterConfig.java`

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

**源码位置**: `ruoyi-framework/config/I18nConfig.java`

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

**源码位置**: `ruoyi-framework/config/ServerConfig.java`

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

### XssProperties

**源码位置**: `ruoyi-framework/config/properties/XssProperties.java`

```java
@Component
@ConfigurationProperties(prefix = "xss")
public class XssProperties {
    
    private boolean enabled = true;         // XSS 开关
    private List<String> excludes = new ArrayList<>();  // 排除路径
    private List<String> urlPatterns = new ArrayList<>(); // URL 匹配模式
    
    // Getter 和 Setter
}
```

### PackageProperties

**源码位置**: `ruoyi-framework/config/properties/PackageProperties.java`

```java
@Component
@ConfigurationProperties(prefix = "package")
public class PackageProperties {
    
    private List<String> scanPackages = new ArrayList<>();
    
    // Getter 和 Setter
}
```

---

## 最佳实践

1. **线程池配置**: 根据服务器 CPU 核心数调整 CORE_POOL_SIZE 和 MAX_POOL_SIZE
2. **Redis 序列化**: 统一使用 FastJson2JsonRedisSerializer 保证序列化一致
3. **安全配置**: 生产环境修改默认密码和密钥
4. **监控配置**: 生产环境关闭 Druid 监控或设置强密码
5. **资源映射**: 文件上传路径配置到独立磁盘分区

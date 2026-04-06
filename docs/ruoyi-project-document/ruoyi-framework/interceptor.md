# Interceptor 拦截器模块

## 概述

`ruoyi-framework/interceptor` 包提供了 Web 请求拦截器，主要用于防重复提交控制和同 URL 数据拦截。

## 模块结构

```
interceptor/
├── RepeatSubmitInterceptor.java    # 防重复提交拦截器
└── SameUrlDataInterceptor.java     # 同 URL 数据拦截器
```

---

## 1. RepeatSubmitInterceptor - 防重复提交拦截器

**用途**: 防止用户重复提交表单数据，基于 Token 机制实现幂等性控制

**注解定义**:

```java
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RepeatSubmit {
    
    /**
     * 间隔时间 (秒)，小于此时间内的重复提交将被拦截
     * 默认 5 秒
     */
    int interval() default 5;
    
    /**
     * 提示消息
     */
    String message() default "不允许重复提交，请稍后再试";
}
```

**核心实现**:

```java
@Component
public class RepeatSubmitInterceptor implements HandlerInterceptor {
    
    @Autowired
    private RedisCache redisCache;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) throws Exception {
        // 1. 仅处理请求方法为 POST/PUT/DELETE 的情况
        String method = request.getMethod();
        if (!HttpMethod.POST.matches(method) && 
            !HttpMethod.PUT.matches(method) && 
            !HttpMethod.DELETE.matches(method)) {
            return true;
        }
        
        // 2. 检查方法是否有@RepeatSubmit 注解
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        RepeatSubmit repeatSubmit = handlerMethod.getMethodAnnotation(RepeatSubmit.class);
        
        if (repeatSubmit == null) {
            // 没有注解，不拦截
            return true;
        }
        
        // 3. 获取重复提交标识
        String repeatKey = getRepeatKey(request, handlerMethod);
        
        // 4. 检查是否重复提交
        if (redisCache.hasKey(repeatKey)) {
            // 5. 在间隔时间内重复提交
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(JSONObject.toJSONString(
                AjaxResult.error(repeatSubmit.getMessage())
            ));
            out.flush();
            out.close();
            return false;
        }
        
        // 6. 设置 Redis 缓存，过期时间为间隔时间
        redisCache.setCacheObject(repeatKey, true, repeatSubmit.interval(), TimeUnit.SECONDS);
        
        return true;
    }
    
    /**
     * 生成重复提交标识 Key
     */
    private String getRepeatKey(HttpServletRequest request, HandlerMethod handlerMethod) {
        StringBuilder key = new StringBuilder();
        
        // 1. 方法签名
        key.append(handlerMethod.getBean().getClass().getName());
        key.append(":");
        key.append(handlerMethod.getMethod().getName());
        
        // 2. 请求 URL
        key.append(":");
        key.append(request.getRequestURI());
        
        // 3. 用户 ID（区分不同用户）
        key.append(":");
        try {
            Long userId = SecurityUtils.getUserId();
            key.append(userId);
        } catch (Exception e) {
            // 未登录用户使用 IP 地址
            key.append(IpUtils.getIpAddr(request));
        }
        
        return key.toString();
    }
}
```

**使用示例**:

```java
@RestController
@RequestMapping("/order")
public class OrderController {
    
    /**
     * 创建订单 - 防止 5 秒内重复提交
     */
    @RepeatSubmit(interval = 5, message = "订单提交中，请勿重复操作")
    @PostMapping("/create")
    public AjaxResult createOrder(@RequestBody Order order) {
        return toAjax(orderService.createOrder(order));
    }
    
    /**
     * 支付订单 - 防止 10 秒内重复提交
     */
    @RepeatSubmit(interval = 10, message = "支付处理中，请稍候")
    @PostMapping("/pay/{orderId}")
    public AjaxResult pay(@PathVariable Long orderId) {
        return toAjax(orderService.pay(orderId));
    }
    
    /**
     * 取消订单 - 防止 3 秒内重复提交
     */
    @RepeatSubmit(interval = 3)
    @DeleteMapping("/cancel/{orderId}")
    public AjaxResult cancel(@PathVariable Long orderId) {
        return toAjax(orderService.cancel(orderId));
    }
}
```

**执行流程**:

```
请求 POST/PUT/DELETE
    ↓
检查@RepeatSubmit 注解
    ↓
生成 RepeatKey (方法签名 +URL+ 用户 ID)
    ↓
Redis 检查 Key 是否存在
    ↓
存在 → 返回错误 "不允许重复提交"
    ↓
不存在 → 设置 Key，过期时间=interval
    ↓
放行到 Controller
```

---

## 2. SameUrlDataInterceptor - 同 URL 数据拦截器

**用途**: 拦截相同 URL 和相同参数的重复请求，避免短时间内重复的数据查询或操作

**核心实现**:

```java
@Component
public class SameUrlDataInterceptor implements HandlerInterceptor {
    
    @Autowired
    private RedisCache redisCache;
    
    // 默认缓存时间 (秒)
    private static final int DEFAULT_CACHE_TIME = 1;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) throws Exception {
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }
        
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        
        // 1. 获取请求参数
        String params = getRequestParams(request);
        
        // 2. 生成缓存 Key
        String cacheKey = getCacheKey(request, handlerMethod, params);
        
        // 3. 检查是否重复请求
        if (redisCache.hasKey(cacheKey)) {
            // 获取缓存的响应数据
            String cachedResponse = redisCache.getCacheObject(cacheKey);
            
            if (StringUtils.hasText(cachedResponse)) {
                // 直接返回缓存的响应
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.write(cachedResponse);
                out.flush();
                out.close();
                return false;
            }
        }
        
        // 4. 包装响应，用于缓存
        ResponseBodyWrapper wrapper = new ResponseBodyWrapper(response);
        ResponseBodyWrapper.copyBody(response, wrapper);
        
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, 
                               HttpServletResponse response, 
                               Object handler, 
                               Exception ex) throws Exception {
        // 5. 请求完成后缓存响应数据
        if (ex == null) {
            String cacheKey = (String) request.getAttribute("same_url_cache_key");
            if (StringUtils.hasText(cacheKey)) {
                String responseBody = ResponseBodyWrapper.getResponseBody(response);
                redisCache.setCacheObject(cacheKey, responseBody, DEFAULT_CACHE_TIME, TimeUnit.SECONDS);
            }
        }
    }
    
    /**
     * 获取请求参数
     */
    private String getRequestParams(HttpServletRequest request) {
        Map<String, String[]> params = request.getParameterMap();
        return JSONObject.toJSONString(params);
    }
    
    /**
     * 生成缓存 Key
     */
    private String getCacheKey(HttpServletRequest request, 
                              HandlerMethod handlerMethod, 
                              String params) {
        StringBuilder key = new StringBuilder();
        
        // 1. 请求 URL
        key.append(request.getRequestURI());
        
        // 2. 请求参数
        key.append(":");
        key.append(params);
        
        // 3. 用户 ID
        key.append(":");
        try {
            Long userId = SecurityUtils.getUserId();
            key.append(userId);
        } catch (Exception e) {
            key.append("anonymous");
        }
        
        return key.toString();
    }
}
```

**使用示例**:

```java
@RestController
@RequestMapping("/report")
public class ReportController {
    
    /**
     * 查询统计报表 - 1 秒内相同请求直接返回缓存
     */
    @GetMapping("/statistics")
    public AjaxResult getStatistics(SysUser user) {
        // 耗时查询
        ReportData data = reportService.getStatistics(user);
        return AjaxResult.success(data);
    }
    
    /**
     * 查询用户详情 - 1 秒内相同请求直接返回缓存
     */
    @GetMapping("/user/{userId}")
    public AjaxResult getUserDetail(@PathVariable Long userId) {
        SysUser user = userService.selectUserById(userId);
        return AjaxResult.success(user);
    }
}
```

---

## 拦截器配置

**FilterConfig 中的注册**:

```java
@Configuration
public class FilterConfig implements WebMvcConfigurer {
    
    @Autowired
    private RepeatSubmitInterceptor repeatSubmitInterceptor;
    
    @Autowired
    private SameUrlDataInterceptor sameUrlDataInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 注册防重复提交拦截器
        registry.addInterceptor(repeatSubmitInterceptor)
                .addPathPatterns("/**")
                .order(1);
        
        // 注册同 URL 数据拦截器
        registry.addInterceptor(sameUrlDataInterceptor)
                .addPathPatterns("/api/**")
                .order(2);
    }
}
```

---

## 两种拦截器对比

| 特性 | RepeatSubmitInterceptor | SameUrlDataInterceptor |
|------|------------------------|------------------------|
| 目的 | 防止表单重复提交 | 缓存相同请求的响应 |
| 触发条件 | 间隔时间内的重复请求 | 相同 URL+ 参数的请求 |
| 处理方式 | 直接拒绝，返回错误 | 返回缓存的响应数据 |
| 适用场景 | 写入操作 (POST/PUT/DELETE) | 读取操作 (GET) |
| Redis Key 过期时间 | 由@RepeatSubmit.interval 指定 | 默认 1 秒 |
| 是否需要注解 | 是 (@RepeatSubmit) | 否 (自动拦截) |

---

## 实际应用场景

### 场景 1: 表单提交防重

```java
@PostMapping("/submit")
@RepeatSubmit(interval = 10, message = "表单已提交，请勿重复操作")
public AjaxResult submitForm(@RequestBody FormDTO form) {
    return toAjax(formService.submit(form));
}
```

### 场景 2: 支付接口防重

```java
@PostMapping("/pay")
@RepeatSubmit(interval = 30, message = "支付处理中，请勿重复点击")
public AjaxResult pay(@RequestParam Long orderId) {
    return toAjax(paymentService.pay(orderId));
}
```

### 场景 3: 报表查询缓存

```java
// 1 秒内相同查询直接返回缓存，减轻数据库压力
@GetMapping("/report/monthly")
public AjaxResult getMonthlyReport(@RequestParam String month) {
    ReportData data = reportService.getMonthlyReport(month);
    return AjaxResult.success(data);
}
```

### 场景 4: 列表查询缓存

```java
// 高频查询接口，1 秒内相同参数直接返回
@GetMapping("/list")
public TableDataInfo list(SysUser user) {
    startPage();
    List<SysUser> list = userService.selectUserList(user);
    return getDataTable(list);
}
```

---

## 注意事项

1. **Redis 依赖**: 拦截器依赖 Redis，确保 Redis 服务可用
2. **时间设置**: `@RepeatSubmit` 的 interval 不宜过长，建议 3-10 秒
3. **用户区分**: 两个拦截器都支持按用户 ID 区分，避免误伤
4. **GET 请求**: `@RepeatSubmit` 不过滤 GET 请求，仅针对 POST/PUT/DELETE
5. **缓存污染**: SameUrlDataInterceptor 缓存时间很短，避免占用过多 Redis 空间
6. **动态参数**: 含时间戳、随机数的请求不会命中缓存

---

## 最佳实践

1. **写操作**: 所有新增、修改、删除接口添加 `@RepeatSubmit` 注解
2. **读操作**: 高频查询接口可考虑使用 SameUrlDataInterceptor 缓存
3. **幂等性**: 关键业务接口除了拦截器外，应在数据库层面保证幂等性
4. **前端配合**: 提交按钮点击后禁用，从源头减少重复提交
5. **异常处理**: 重复提交返回友好的错误提示，避免用户困惑

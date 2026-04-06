# Interceptor 拦截器模块

## 概述

`ruoyi-framework/interceptor` 包提供了 Web 请求拦截器，主要用于防重复提交控制。

## 模块结构

```
interceptor/
├── RepeatSubmitInterceptor.java          # 防重复提交拦截器（抽象基类）
└── impl/
    └── SameUrlDataInterceptor.java       # 同 URL 数据拦截器（具体实现）
```

---

## 1. RepeatSubmitInterceptor - 防重复提交拦截器（抽象基类）

**用途**: 抽象拦截器基类，定义防重复提交的框架逻辑，具体规则由子类实现

**注解定义**:

```java
@Target({ ElementType.METHOD, ElementType.TYPE, ElementType.ANNOTATION_TYPE })
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RepeatSubmit {
    /**
     * 间隔时间 (毫秒)，小于此时间内的重复提交将被拦截
     * 默认 100ms
     */
    long interval() default 100L;
    
    /**
     * 提示消息
     */
    String message() default "不允许重复提交，请稍候再试";
}
```

**核心实现**:

```java
@Component
public abstract class RepeatSubmitInterceptor implements HandlerInterceptor {
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) throws Exception {
        // 1. 仅处理 HandlerMethod 类型的请求
        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            Method method = handlerMethod.getMethod();
            
            // 2. 检查方法是否有@RepeatSubmit 注解
            RepeatSubmit annotation = method.getAnnotation(RepeatSubmit.class);
            if (annotation != null) {
                // 3. 调用子类实现的判断逻辑
                if (this.isRepeatSubmit(request, annotation)) {
                    // 4. 重复提交，返回错误响应
                    AjaxResult ajaxResult = AjaxResult.error(annotation.message());
                    ServletUtils.renderString(response, JSON.toJSONString(ajaxResult));
                    return false;
                }
            }
            return true;
        } else {
            return true;
        }
    }
    
    /**
     * 验证是否重复提交，由子类实现具体的防重复提交规则
     * 
     * @param request 请求信息
     * @param annotation 防重复注解参数
     * @return true-重复提交，false-正常请求
     */
    public abstract boolean isRepeatSubmit(HttpServletRequest request, RepeatSubmit annotation);
}
```

**执行流程**:

```
请求 → preHandle
        ↓
检查 handler 是否为 HandlerMethod
        ↓
是 → 获取方法上的@RepeatSubmit 注解
        ↓
有注解 → 调用 isRepeatSubmit() 判断
        ↓
返回 true(重复) → 返回错误响应，return false
返回 false(正常) → 放行，return true
```

**使用示例**:

```java
@RestController
@RequestMapping("/order")
public class OrderController {
    
    /**
     * 创建订单 - 防止 100ms 内重复提交
     */
    @RepeatSubmit(interval = 100, message = "订单提交中，请勿重复操作")
    @PostMapping("/create")
    public AjaxResult createOrder(@RequestBody Order order) {
        return toAjax(orderService.createOrder(order));
    }
    
    /**
     * 支付订单 - 防止 10 秒内重复提交
     */
    @RepeatSubmit(interval = 10000, message = "支付处理中，请稍候")
    @PostMapping("/pay/{orderId}")
    public AjaxResult pay(@PathVariable Long orderId) {
        return toAjax(orderService.pay(orderId));
    }
}
```

---

## 2. SameUrlDataInterceptor - 同 URL 数据拦截器

**用途**: 判断请求 URL 和数据是否和上一次相同，如果相同则是重复提交表单。有效时间为注解指定的间隔时间内（默认 100ms）。

**核心实现**:

```java
@Component
public class SameUrlDataInterceptor extends RepeatSubmitInterceptor {
    
    public final String REPEAT_PARAMS = "repeatParams";
    
    public final String REPEAT_TIME = "repeatTime";
    
    // 令牌自定义标识（从配置获取）
    @Value("${token.header}")
    private String header;
    
    @Autowired
    private RedisCache redisCache;
    
    @SuppressWarnings("unchecked")
    @Override
    public boolean isRepeatSubmit(HttpServletRequest request, RepeatSubmit annotation) {
        // 1. 获取请求参数
        String nowParams = "";
        if (request instanceof RepeatedlyRequestWrapper) {
            // 可重复读取的请求包装器
            RepeatedlyRequestWrapper repeatedlyRequest = (RepeatedlyRequestWrapper) request;
            nowParams = HttpHelper.getBodyString(repeatedlyRequest);
        }
        
        // 2. body 参数为空，获取 Parameter 的数据
        if (StringUtils.isEmpty(nowParams)) {
            nowParams = JSON.toJSONString(request.getParameterMap());
        }
        
        // 3. 构建当前请求数据 Map
        Map<String, Object> nowDataMap = new HashMap<String, Object>();
        nowDataMap.put(REPEAT_PARAMS, nowParams);
        nowDataMap.put(REPEAT_TIME, System.currentTimeMillis());
        
        // 4. 请求地址（作为存放 cache 的 key 值）
        String url = request.getRequestURI();
        
        // 5. 唯一值（没有消息头则使用请求地址）
        String submitKey = StringUtils.trimToEmpty(request.getHeader(header));
        
        // 6. 唯一标识（指定 key + url + 消息头）
        String cacheRepeatKey = CacheConstants.REPEAT_SUBMIT_KEY + url + submitKey;
        
        // 7. 检查 Redis 中是否有缓存
        Object sessionObj = redisCache.getCacheObject(cacheRepeatKey);
        if (sessionObj != null) {
            Map<String, Object> sessionMap = (Map<String, Object>) sessionObj;
            if (sessionMap.containsKey(url)) {
                // 8. 获取上一次的请求数据
                Map<String, Object> preDataMap = (Map<String, Object>) sessionMap.get(url);
                
                // 9. 比较参数和时间
                if (compareParams(nowDataMap, preDataMap) && 
                    compareTime(nowDataMap, preDataMap, annotation.interval())) {
                    // 参数相同且时间间隔小于指定值，判定为重复提交
                    return true;
                }
            }
        }
        
        // 10. 保存当前请求数据到 Redis
        Map<String, Object> cacheMap = new HashMap<String, Object>();
        cacheMap.put(url, nowDataMap);
        redisCache.setCacheObject(cacheRepeatKey, cacheMap, 
                                   annotation.interval(), TimeUnit.MILLISECONDS);
        return false;
    }
    
    /**
     * 判断参数是否相同
     */
    private boolean compareParams(Map<String, Object> nowMap, Map<String, Object> preMap) {
        String nowParams = (String) nowMap.get(REPEAT_PARAMS);
        String preParams = (String) preMap.get(REPEAT_PARAMS);
        return nowParams.equals(preParams);
    }
    
    /**
     * 判断两次间隔时间是否小于指定值
     */
    private boolean compareTime(Map<String, Object> nowMap, Map<String, Object> preMap, int interval) {
        long time1 = (Long) nowMap.get(REPEAT_TIME);
        long time2 = (Long) preMap.get(REPEAT_TIME);
        if ((time1 - time2) < interval) {
            return true;
        }
        return false;
    }
}
```

**执行流程**:

```
请求 → isRepeatSubmit
        ↓
获取请求参数（body 或 parameter）
        ↓
构建 nowDataMap{params, timestamp}
        ↓
生成 cacheKey = REPEAT_SUBMIT_KEY + url + submitKey
        ↓
Redis 获取缓存
        ↓
存在 → 获取上一次的 preDataMap
        ↓
比较 params 是否相同 AND 时间间隔是否小于 interval
        ↓
都满足 → true(重复提交)
不满足 → false(正常请求)，保存当前数据到 Redis
```

**Redis 缓存结构**:

```
Key: repeat_submit_key + /api/xxx + token-uuid
Value: {
    "/api/xxx": {
        "repeatParams": "{\"id\":1,\"name\":\"test\"}",
        "repeatTime": 1704672000000
    }
}
TTL: annotation.interval() (毫秒)
```

**使用示例**:

```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    /**
     * 新增用户 - 默认 100ms 内重复提交会被拦截
     */
    @RepeatSubmit
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        return toAjax(userService.insertUser(user));
    }
    
    /**
     * 修改用户 - 5 秒内相同 URL+ 相同参数会被拦截
     */
    @RepeatSubmit(interval = 5000, message = "数据保存中，请勿重复提交")
    @PutMapping
    public AjaxResult edit(@RequestBody SysUser user) {
        return toAjax(userService.updateUser(user));
    }
    
    /**
     * 删除用户 - 3 秒内重复删除会被拦截
     */
    @RepeatSubmit(interval = 3000, message = "删除操作进行中，请稍候")
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds) {
        return toAjax(userService.deleteUserByIds(userIds));
    }
}
```

---

## 拦截器配置

**ResourcesConfig 中的注册**:

```java
@Configuration
public class ResourcesConfig implements WebMvcConfigurer {
    
    @Autowired
    private RepeatSubmitInterceptor repeatSubmitInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 注册防重复提交拦截器
        registry.addInterceptor(repeatSubmitInterceptor)
                .addPathPatterns("/**")
                .order(1);
    }
}
```

---

## 注意事项

1. **Redis 依赖**: 拦截器依赖 Redis，确保 Redis 服务可用
2. **时间单位**: `@RepeatSubmit.interval()` 单位是毫秒，不是秒
3. **请求参数获取**: 
   - 优先从 request body 获取（使用 `RepeatedlyRequestWrapper` 包装）
   - body 为空则从 `request.getParameterMap()` 获取
4. **唯一标识**: 使用 Token Header 作为 submitKey，没有则使用空字符串
5. **缓存结构**: Redis 中存储的是嵌套 Map，外层 key 包含 URL 和 submitKey
6. **比较逻辑**: 只有参数相同 AND 时间间隔小于指定值才判定为重复提交
7. **抽象基类**: `RepeatSubmitInterceptor` 是抽象类，不能直接使用，需子类实现 `isRepeatSubmit()` 方法

---

## 最佳实践

1. **写操作必加**: 所有新增、修改、删除接口添加 `@RepeatSubmit` 注解
2. **时间设置**: 根据业务场景设置合适的 interval，一般 100ms-5000ms
3. **幂等性**: 关键业务接口除了拦截器外，应在数据库层面保证幂等性
4. **前端配合**: 提交按钮点击后禁用，从源头减少重复提交
5. **异常处理**: 重复提交返回友好的错误提示，避免用户困惑
6. **消息头配置**: 确保前端传递 Token Header，用于生成唯一的 submitKey

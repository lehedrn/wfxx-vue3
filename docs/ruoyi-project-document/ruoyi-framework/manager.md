# Manager 异步任务管理模块

## 概述

`ruoyi-framework/manager` 包提供了异步任务管理功能，用于处理耗时操作的异步执行，避免阻塞主线程，提升系统响应速度。

## 模块结构

```
manager/
├── AsyncManager.java        # 异步任务管理器
├── ShutdownManager.java   # 关闭管理器
└── AsyncFactory.java      # 异步任务工厂
```

## 线程池配置

**位置**: `ruoyi-framework/config/ThreadPoolConfig.java`

```java
@Configuration
public class ThreadPoolConfig {
    
    // 核心线程数
    private static final int CORE_POOL_SIZE = 50;
    // 最大线程数
    private static final int MAX_POOL_SIZE = 200;
    // 队列容量
    private static final int QUEUE_CAPACITY = 1000;
    // 线程存活时间 (秒)
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
    
    /**
     * 周期性任务调度线程池
     */
    @Bean(name = "scheduledExecutorService")
    public ScheduledExecutorService scheduledExecutorService() {
        return Executors.newScheduledThreadPool(10);
    }
}
```

---

## 1. AsyncManager - 异步任务管理器

**用途**: 单例模式的异步任务执行器，提供统一的异步任务提交入口

**核心实现**:

```java
public class AsyncManager {
    
    /**
     * 操作延迟 10 毫秒
     */
    private final int OPERATE_DELAY_TIME = 10;

    /**
     * 异步操作任务调度线程池
     */
    private ScheduledExecutorService executor = 
        SpringUtils.getBean("scheduledExecutorService");

    /**
     * 单例模式
     */
    private AsyncManager() {}

    private static AsyncManager me = new AsyncManager();

    public static AsyncManager me() {
        return me;
    }

    /**
     * 执行任务
     * 
     * @param task 任务
     */
    public void execute(TimerTask task) {
        executor.schedule(task, OPERATE_DELAY_TIME, TimeUnit.MILLISECONDS);
    }

    /**
     * 停止任务线程池
     */
    public void shutdown() {
        Threads.shutdownAndAwaitTermination(executor);
    }
}
```

**使用示例**:

```java
// 简单异步任务
AsyncManager.me().execute(() -> {
    log.info("异步任务执行中");
    // 耗时操作
});

// 使用 AsyncFactory 创建任务
AsyncManager.me().execute(
    AsyncFactory.recordLogininfor("admin", Constants.LOGIN_SUCCESS, "登录成功")
);
```

**注意**: 
- 实际使用 `me()` 方法获取单例，而非 `getInstance()`
- 接受 `TimerTask` 而非 `Runnable`
- 任务执行有 10ms 延迟
- 使用 `scheduledExecutorService` 线程池

---

## 2. AsyncFactory - 异步任务工厂

**用途**: 提供异步任务的创建方法，主要包含记录登录信息和操作日志

**核心实现**:

```java
public class AsyncFactory {
    
    private static final Logger sys_user_logger = LoggerFactory.getLogger("sys-user");
    
    /**
     * 记录登录信息
     * 
     * @param username 用户名
     * @param status 状态 (LOGIN_SUCCESS/LOGIN_FAIL/LOGOUT/REGISTER)
     * @param message 消息
     * @param args 参数
     * @return TimerTask 任务
     */
    public static TimerTask recordLogininfor(final String username, final String status, 
                                             final String message, final Object... args) {
        final String userAgent = ServletUtils.getRequest().getHeader("User-Agent");
        final String ip = IpUtils.getIpAddr();
        
        return new TimerTask() {
            @Override
            public void run() {
                String address = AddressUtils.getRealAddressByIP(ip);
                StringBuilder s = new StringBuilder();
                s.append(LogUtils.getBlock(ip));
                s.append(address);
                s.append(LogUtils.getBlock(username));
                s.append(LogUtils.getBlock(status));
                s.append(LogUtils.getBlock(message));
                
                // 打印日志
                sys_user_logger.info(s.toString(), args);
                
                // 获取客户端操作系统和浏览器
                String os = UserAgentUtils.getOperatingSystem(userAgent);
                String browser = UserAgentUtils.getBrowser(userAgent);
                
                // 封装对象
                SysLogininfor logininfor = new SysLogininfor();
                logininfor.setUserName(username);
                logininfor.setIpaddr(ip);
                logininfor.setLoginLocation(address);
                logininfor.setBrowser(browser);
                logininfor.setOs(os);
                logininfor.setMsg(message);
                
                // 设置状态
                if (StringUtils.equalsAny(status, Constants.LOGIN_SUCCESS, 
                                          Constants.LOGOUT, Constants.REGISTER)) {
                    logininfor.setStatus(Constants.SUCCESS);
                } else if (Constants.LOGIN_FAIL.equals(status)) {
                    logininfor.setStatus(Constants.FAIL);
                }
                
                // 插入数据
                SpringUtils.getBean(ISysLogininforService.class).insertLogininfor(logininfor);
            }
        };
    }
    
    /**
     * 操作日志记录
     * 
     * @param operLog 操作日志信息
     * @return TimerTask 任务
     */
    public static TimerTask recordOper(final SysOperLog operLog) {
        return new TimerTask() {
            @Override
            public void run() {
                // 远程查询操作地点
                operLog.setOperLocation(AddressUtils.getRealAddressByIP(operLog.getOperIp()));
                SpringUtils.getBean(ISysOperLogService.class).insertOperlog(operLog);
            }
        };
    }
}
```

**返回类型**: `TimerTask`（而非 Runnable）

**使用示例**:

```java
// 记录登录成功
AsyncManager.me().execute(
    AsyncFactory.recordLogininfor("admin", Constants.LOGIN_SUCCESS, "登录成功")
);

// 记录登录失败
AsyncManager.me().execute(
    AsyncFactory.recordLogininfor("admin", Constants.LOGIN_FAIL, "密码错误")
);

// 记录操作日志
SysOperLog operLog = new SysOperLog();
operLog.setTitle("用户管理");
operLog.setBusinessType(BusinessType.INSERT.ordinal());
// ... 设置其他属性
AsyncManager.me().execute(AsyncFactory.recordOper(operLog));
```

**注意**: 
- 只包含 `recordLogininfor` 和 `recordOper` 两个方法
- 不包含 `sendSms`、`sendEmail`、`exportFile`、`clearToken` 等方法
- 返回 `TimerTask` 而非 `Runnable`

---

## 3. ShutdownManager - 关闭管理器

**用途**: Spring 容器关闭时的钩子处理器，用于优雅地关闭线程池

**核心实现**:

```java
@Component
public class ShutdownManager {
    
    private static final Logger log = LoggerFactory.getLogger(ShutdownManager.class);
    
    /**
     * Spring 容器关闭前的钩子
     */
    @PreDestroy
    public void destroy() {
        log.info("==== 开始执行关闭流程 ====");
        
        // 关闭异步任务管理器
        shutdownAsyncManager();
        
        log.info("==== 关闭流程完成 ====");
    }
    
    /**
     * 关闭异步任务管理器
     */
    private void shutdownAsyncManager() {
        try {
            log.info("关闭异步任务管理器...");
            AsyncManager.me().shutdown();
        } catch (Exception e) {
            log.error("关闭异步任务管理器异常：{}", e.getMessage(), e);
        }
    }
}
```

**注意**: 
- 只包含 `shutdownAsyncManager()` 方法
- 不包含 `clearCache()` 和 `shutdownConnectionPools()` 方法

---

## 异步任务执行流程

```
主线程请求
    ↓
执行核心业务
    ↓
创建异步任务 (AsyncFactory)
    ↓
提交到 AsyncManager
    ↓
scheduledExecutorService 延迟 10ms 执行
    ↓
任务完成
    ↓
更新数据库 (登录日志/操作日志)
```

---

## 注意事项

1. **线程安全**: 异步任务中访问请求上下文会失败，需提前获取必要参数
2. **事务隔离**: 异步任务不在主事务内，需要独立事务处理
3. **异常处理**: 异步任务异常不会影响主流程，需在任务内部捕获异常
4. **资源清理**: 应用关闭时确保线程池优雅关闭
5. **任务类型**: 使用 `TimerTask` 而非 `Runnable`
6. **延迟执行**: 所有任务默认延迟 10ms 执行

---

## 最佳实践

1. **耗时操作异步化**: 日志记录等耗时操作使用异步
2. **参数传递**: 异步任务需要的参数提前获取，避免在任务中访问 request
3. **日志追踪**: 异步任务添加 TraceID，便于链路追踪
4. **优雅关闭**: 确保 ShutdownManager 在 Spring 容器关闭前执行

---

## 常见问题

### Q1: 异步任务中无法获取 request？
**A**: 异步任务在新线程执行，RequestContextHolder 已清空。需在主线程提前获取参数传递给异步任务。

### Q2: 异步任务的事务如何控制？
**A**: 异步任务独立于主事务，如需事务控制，在任务内部处理。

### Q3: 为什么使用 TimerTask 而不是 Runnable？
**A**: 使用 ScheduledExecutorService 需要 TimerTask，支持延迟执行和周期性任务。

# Datasource 动态数据源模块

## 概述

`ruoyi-framework/datasource` 包提供动态数据源切换功能，支持主从库分离和多数据源配置，通过 AOP 切面实现运行时动态切换。

## 模块结构

```
datasource/
├── DynamicDataSource.java              # 动态数据源实现
└── DynamicDataSourceContextHolder.java # 数据源上下文持有者
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/datasource/`

---

## 1. DynamicDataSource - 动态数据源实现

**用途**: 继承抽象路由数据源，根据上下文动态切换数据源

**核心实现**:

```java
public class DynamicDataSource extends AbstractRoutingDataSource {
    
    /**
     * 获取当前数据源 Key
     */
    @Override
    protected Object determineCurrentLookupKey() {
        return DynamicDataSourceContextHolder.getDataSourceType();
    }
}
```

**配置 Bean**:

```java
@Configuration
public class DynamicDataSourceConfig {
    
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.dynamic")
    public DataSource dynamicDataSource(DataSourceProperties properties) {
        DynamicDataSource dynamicDataSource = new DynamicDataSource();
        
        // 设置默认数据源（主库）
        DataSource defaultDataSource = createDataSource(properties.getDatasource().getMaster());
        dynamicDataSource.setDefaultTargetDataSource(defaultDataSource);
        
        // 设置所有数据源
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put("MASTER", defaultDataSource);
        
        // 添加从库
        properties.getDatasource().getSlave().forEach((name, dsProps) -> {
            targetDataSources.put(name.toUpperCase(), createDataSource(dsProps));
        });
        
        dynamicDataSource.setTargetDataSources(targetDataSources);
        return dynamicDataSource;
    }
}
```

---

## 2. DynamicDataSourceContextHolder - 数据源上下文持有者

**用途**: 使用 ThreadLocal 存储当前线程的数据源标识，实现线程隔离的数据源切换

**核心实现**:

```java
public class DynamicDataSourceContextHolder {
    
    private static final ThreadLocal<String> CONTEXT_HOLDER = 
        ThreadLocal.withInitial(() -> "MASTER");
    
    /**
     * 设置数据源类型
     */
    public static void setDataSourceType(String dataSourceType) {
        if (StringUtils.isEmpty(dataSourceType)) {
            dataSourceType = "MASTER";
        }
        CONTEXT_HOLDER.set(dataSourceType);
    }
    
    /**
     * 获取当前数据源类型
     */
    public static String getDataSourceType() {
        return CONTEXT_HOLDER.get();
    }
    
    /**
     * 清除数据源类型（防止内存泄漏）
     */
    public static void clearDataSourceType() {
        CONTEXT_HOLDER.remove();
    }
    
    /**
     * 判断是否是主库
     */
    public static boolean isMaster() {
        return "MASTER".equals(getDataSourceType());
    }
    
    /**
     * 判断是否是从库
     */
    public static boolean isSlave() {
        return !isMaster();
    }
}
```

**使用示例**:

```java
// 手动切换数据源
DynamicDataSourceContextHolder.setDataSourceType("SLAVE");
try {
    // 查询操作
    List<User> users = userMapper.selectList();
} finally {
    // 清理上下文
    DynamicDataSourceContextHolder.clearDataSourceType();
}
```

---

## DataSourceType 枚举

**源码位置**: `ruoyi-common/enums/DataSourceType.java`

```java
public enum DataSourceType {
    MASTER,  // 主库（写库）
    SLAVE    // 从库（读库）
}
```

---

## DataSourceAspect - 数据源切换切面

**源码位置**: `ruoyi-framework/aspectj/DataSourceAspect.java`

**用途**: 通过 `@DataSource` 注解自动切换数据源

**核心实现**:

```java
@Aspect
@Order(1) // 优先级高于事务
public class DataSourceAspect {
    
    @Around("@annotation(ds)")
    public Object around(ProceedingJoinPoint point, DataSource ds) throws Throwable {
        // 1. 获取注解配置的数据源类型
        DataSourceType dataSourceType = ds.value();
        
        // 2. 切换数据源
        DynamicDataSourceContextHolder.setDataSourceType(dataSourceType.name());
        
        try {
            // 3. 执行目标方法
            return point.proceed();
        } finally {
            // 4. 清除数据源上下文
            DynamicDataSourceContextHolder.clearDataSourceType();
        }
    }
}
```

---

## 使用示例

### 1. Service 层使用

```java
@Service
public class UserServiceImpl implements SysUserService {
    
    @Autowired
    private UserMapper userMapper;
    
    /**
     * 查询用户列表 - 使用从库
     */
    @DataSource(DataSourceType.SLAVE)
    @Override
    public List<SysUser> selectUserList(SysUser user) {
        return userMapper.selectUserList(user);
    }
    
    /**
     * 新增用户 - 使用主库
     */
    @DataSource(DataSourceType.MASTER)
    @Override
    public int insertUser(SysUser user) {
        return userMapper.insertUser(user);
    }
    
    /**
     * 修改用户 - 使用主库
     */
    @DataSource(DataSourceType.MASTER)
    @Override
    public int updateUser(SysUser user) {
        return userMapper.updateUser(user);
    }
}
```

### 2. 类级别 + 方法级别配置

```java
// 类级别默认使用从库
@DataSource(DataSourceType.SLAVE)
@Service
public class ReportServiceImpl {
    
    // 使用从库（继承类级别）
    public List<Report> selectReports() {
        return reportMapper.selectReports();
    }
    
    // 使用主库（方法级别覆盖）
    @DataSource(DataSourceType.MASTER)
    public int generateReport(Report report) {
        return reportMapper.insertReport(report);
    }
}
```

### 3. 读写分离 + 数据权限

```java
@Service
public class DeptServiceImpl implements SysDeptService {
    
    /**
     * 查询部门列表 - 同时使用数据权限和数据源切换
     */
    @DataScope(deptAlias = "d")
    @DataSource(DataSourceType.SLAVE)
    @Override
    public List<SysDept> selectDeptList(SysDept dept) {
        return deptMapper.selectDeptList(dept);
    }
}
```

---

## 数据源切换原理

```
请求 → AOP 切面拦截 (@DataSource)
        ↓
读取注解值 → DataSourceType
        ↓
设置上下文 → DynamicDataSourceContextHolder.setDataSourceType()
        ↓
路由数据源 → determineCurrentLookupKey() 返回数据源 Key
        ↓
执行 SQL → 使用对应的数据源连接
        ↓
清理上下文 → DynamicDataSourceContextHolder.clearDataSourceType()
```

---

## 事务与数据源

**注意事项**:

```java
@Service
public class OrderServiceImpl {
    
    /**
     * ✅ 正确示例：数据源切面 Order=1，优先于事务
     */
    @DataSource(DataSourceType.MASTER)
    @Transactional
    public void createOrder(Order order) {
        // 数据源已切换到 MASTER
        orderMapper.insert(order);
    }
    
    /**
     * ⚠️ 错误示例：事务注解在数据源切面之前执行
     */
    @Transactional
    @DataSource(DataSourceType.MASTER)
    public void createOrderWrong(Order order) {
        // 这里已经是事务内，数据源切换不生效
        orderMapper.insert(order);
    }
}
```

**配置建议**:

```java
@Configuration
@EnableTransactionManagement(order = 2) // 事务 Order 大于数据源切面
public class TransactionConfig {
    // ...
}
```

---

## 最佳实践

1. **读写分离**: 查询使用 SLAVE，写入使用 MASTER
2. **切面顺序**: `@DataSource` 切面 Order 必须小于事务
3. **ThreadLocal 清理**: 必须在 finally 中清理上下文
4. **默认数据源**: 未注解的方法使用默认 MASTER
5. **懒加载**: 从库配置 lazy=true，按需初始化
6. **监控**: 配置 Druid 监控，观察各数据源连接池状态
7. **数据一致性**: 主从同步延迟场景需谨慎处理

---

## 常见问题

**Q1: 切换数据源后事务失效？**

A: 确保 `@DataSource` 切面 Order 小于 `@Transactional`，先切换数据源再开启事务。

**Q2: 为什么从库查询不到刚写入的数据？**

A: 主从同步有延迟，刚写入主库的数据可能还未同步到从库。建议写入后立即查询时使用主库。

**Q3: 多数据源如何分页？**

A: PageHelper 分页插件与数据源切换独立，可以正常配合使用。

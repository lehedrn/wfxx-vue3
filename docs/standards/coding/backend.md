# 后端编码规范

本文档规定 Java 后端开发的编码规范，适用于 RuoYi-Vue 项目。

---

## 1. 命名规范

### 1.1 类名

- 使用 **PascalCase**（大驼峰命名）
- 名称应清晰表达类的职责

```java
// 正确
public class UserServiceImpl { }
public class StudentController { }
public class RuoYiApplication { }

// 错误
public class userServiceImpl { }
public class student_controller { }
```

### 1.2 方法名

- 使用 **camelCase**（小驼峰命名）
- 动词 + 名词结构，表达方法意图

```java
// 正确
public User getUserById(Long id) { }
public void createUser(User user) { }
public List<User> listUsers(UserQuery query) { }

// 错误
public User user(Long id) { }
public void add(User user) { }  // 过于简略
```

### 1.3 变量名

- 使用 **camelCase**
- 名称应有意义，避免单字母（除循环变量外）

```java
// 正确
private String userName;
private Integer userAge;
for (int i = 0; i < list.size(); i++) { }

// 错误
private String name1;
private Integer age1;
String n = "test";
```

### 1.4 常量名

- 使用 **UPPER_CASE**，单词间用下划线分隔

```java
// 正确
public static final int MAX_RETRY_COUNT = 3;
public static final String DEFAULT_CHARSET = "UTF-8";

// 错误
public static final int maxRetryCount = 3;
```

---

## 2. 代码格式

### 2.1 缩进

- 使用 **4 个空格** 缩进，不使用 Tab

```java
public class UserService {
    private String name;
    
    public void doSomething() {
        if (condition) {
            // 代码块
        }
    }
}
```

### 2.2 行宽

- 单行代码不超过 **120 字符**
- 超过时适当换行

```java
// 正确
public void method(String param1, String param2, 
                   String param3) {
}

// 错误：单行过长
public void method(String param1, String param2, String param3, String param4, String param5) {
}
```

### 2.3 空行

- 方法之间空 1 行
- 逻辑段落之间空 1 行

```java
public class UserService {
    
    private String name;
    
    public User getUser() {
        // 逻辑 1
        
        // 逻辑 2
    }
    
    public void createUser() {
        // 实现
    }
}
```

---

## 3. 注释规范

### 3.1 类注释

- 每个类应有文档注释，说明类的用途

```java
/**
 * 用户服务实现类
 * 
 * @author ruoyi
 * @since 2026-04-07
 */
public class UserServiceImpl implements UserService {
}
```

### 3.2 方法注释

- 公共方法应有注释，说明方法功能、参数和返回值

```java
/**
 * 根据 ID 查询用户信息
 * 
 * @param userId 用户 ID
 * @return 用户信息
 */
public User getUserById(Long userId) {
}
```

### 3.3 代码注释

- 复杂逻辑应有行内注释
- 使用 `//` 单行注释

```java
// 检查用户状态是否正常
if (user.getStatus().equals(UserStatus.NORMAL)) {
    // 执行正常用户逻辑
    processNormalUser(user);
}
```

---

## 4. 最佳实践

### 4.1 响应对象

统一使用 `R<T>` 作为返回结果：

```java
// 正确
public R<User> getUser(Long id) {
    return R.ok(user);
}

// 错误
public User getUser(Long id) {
    return user;
}
```

### 4.2 异常处理

- 业务异常使用 `ServiceException`
- 避免捕获 `Exception` 后不做处理

```java
// 正确
if (user == null) {
    throw new ServiceException("用户不存在");
}

// 错误
try {
    // 业务逻辑
} catch (Exception e) {
    // 空捕获
}
```

### 4.3 数据校验

- Controller 层进行参数校验
- Service 层进行业务规则校验

```java
// Controller
@PostMapping
public R<Void> add(@Valid @RequestBody User user) {
    userService.add(user);
    return R.ok();
}

// Service
public void add(User user) {
    if (exists(user.getUserName())) {
        throw new ServiceException("用户名已存在");
    }
    // 业务逻辑
}
```

### 4.4 日志使用

- 使用 SLF4J 日志框架
- 生产环境避免使用 `System.out.println`

```java
private static final Logger log = LoggerFactory.getLogger(UserService.class);

// 正确
log.info("用户登录成功：{}", userName);
log.error("用户登录失败", exception);

// 错误
System.out.println("用户登录成功");
```

---

## 5. 分层规范

### 5.1 Controller 层

- 负责参数校验和响应封装
- 不包含业务逻辑

```java
@RestController
@RequestMapping("/system/user")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/{userId}")
    public R<User> getUser(@PathVariable Long userId) {
        return R.ok(userService.getUserById(userId));
    }
}
```

### 5.2 Service 层

- 包含核心业务逻辑
- 事务控制

```java
@Service
public class UserServiceImpl implements UserService {
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addUser(User user) {
        // 业务逻辑
        userMapper.insert(user);
    }
}
```

### 5.3 Mapper 层

- 数据访问接口
- SQL 语句放在 XML 文件中

```java
public interface UserMapper {
    User selectById(Long userId);
    List<User> selectList(UserQuery query);
}
```

---

## 6. 数据库规范

### 6.1 表命名

- 使用 `sys_`、`demo_` 等前缀
- 表名使用小写，单词间用下划线分隔

```sql
-- 正确
CREATE TABLE sys_user ( );
CREATE TABLE demo_student ( );

-- 错误
CREATE TABLE User ( );
CREATE TABLE demoStudent ( );
```

### 6.2 字段命名

- 小写字母，单词间用下划线分隔
- 主键使用 `id` 或 `表名_id`

```sql
-- 正确
user_name VARCHAR(50),
create_time DATETIME,
update_by BIGINT

-- 错误
userName VARCHAR(50),
createTime DATETIME,
updateBy BIGINT
```

---

## 7. Git 提交规范

参考 [提交规范](./commit.md)

```
feat(user): 添加用户管理功能
fix(auth): 修复登录认证 bug
docs: 更新用户文档
```

---

## 参考资料

- [阿里巴巴 Java 开发手册](https://alibaba.github.io/ali-p3c/)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)

---

**最后更新**: 2026-04-07

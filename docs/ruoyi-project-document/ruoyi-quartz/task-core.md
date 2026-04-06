# 任务调度核心逻辑

## 概述

`ruoyi-quartz/util` 包包含定时任务调度的核心工具类，负责任务的创建、执行、调度策略处理。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/`

## 模块结构

```
util/
├── ScheduleUtils.java                    # 调度工具类（创建任务、策略处理）
├── CronUtils.java                        # Cron 表达式工具
├── JobInvokeUtil.java                    # 任务调用工具（反射执行）
├── AbstractQuartzJob.java                # 抽象任务基类
├── QuartzJobExecution.java               # 允许并发的任务类
├── QuartzDisallowConcurrentExecution.java # 禁止并发的任务类
└── ScheduleConstants.java                # 调度常量（ruoyi-common）
```

---

## 任务执行流程

```
┌─────────────────────────────────────────────────────────────┐
│  1. 服务启动初始化 (SysJobServiceImpl.init())                │
│     scheduler.clear() → 查询所有任务 → 逐个注册              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  2. 创建调度任务 (ScheduleUtils.createScheduleJob())         │
│  - 根据 concurrent 参数选择任务类                            │
│  - 构建 JobDetail 和 CronTrigger                             │
│  - 应用 misfire 策略                                          │
│  - 注册到 Scheduler                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  3. 任务触发执行 (QuartzJobExecution.execute())              │
│     ↓                                                        │
│  before() ─→ doExecute() ─→ after()                          │
│                ↓                                             │
│        JobInvokeUtil.invokeMethod()                          │
│                ↓                                             │
│        解析 invokeTarget → 反射调用方法                       │
└─────────────────────────────────────────────────────────────┘
```

---

## ScheduleUtils - 调度工具类

**源码**: [`ScheduleUtils.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/ScheduleUtils.java)

### 核心方法

| 方法 | 说明 |
|------|------|
| `getQuartzJobClass(SysJob)` | 根据并发配置选择任务类 |
| `getJobKey(Long, String)` | 构建 JobKey（jobId + jobGroup） |
| `getTriggerKey(Long, String)` | 构建 TriggerKey |
| `createScheduleJob(Scheduler, SysJob)` | 创建并注册定时任务 |
| `handleCronScheduleMisfirePolicy()` | 应用 misfire 策略 |
| `whiteList(String)` | 包名白名单校验 |

### 创建调度任务

[`ScheduleUtils:60-98`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/ScheduleUtils.java)

```java
public static void createScheduleJob(Scheduler scheduler, SysJob job) {
    // 1. 选择任务类（允许并发 or 禁止并发）
    Class<? extends Job> jobClass = getQuartzJobClass(job);
    
    // 2. 构建 JobDetail
    Long jobId = job.getJobId();
    String jobGroup = job.getJobGroup();
    JobDetail jobDetail = JobBuilder.newJob(jobClass)
        .withIdentity(getJobKey(jobId, jobGroup)).build();
    
    // 3. 构建 CronTrigger，应用 misfire 策略
    CronScheduleBuilder cb = CronScheduleBuilder.cronSchedule(job.getCronExpression());
    cb = handleCronScheduleMisfirePolicy(job, cb);
    CronTrigger trigger = TriggerBuilder.newTrigger()
        .withIdentity(getTriggerKey(jobId, jobGroup))
        .withSchedule(cb).build();
    
    // 4. 放入任务参数
    jobDetail.getJobDataMap().put(ScheduleConstants.TASK_PROPERTIES, job);
    
    // 5. 检查是否存在，存在则先删除
    if (scheduler.checkExists(getJobKey(jobId, jobGroup))) {
        scheduler.deleteJob(getJobKey(jobId, jobGroup));
    }
    
    // 6. 注册到调度器
    scheduler.scheduleJob(jobDetail, trigger);
    
    // 7. 如果状态为暂停，则暂停任务
    if (job.getStatus().equals(ScheduleConstants.Status.PAUSE.getValue())) {
        scheduler.pauseJob(getJobKey(jobId, jobGroup));
    }
}
```

### Misfire 策略处理

[`ScheduleUtils:103-120`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/ScheduleUtils.java)

```java
public static CronScheduleBuilder handleCronScheduleMisfirePolicy(
        SysJob job, CronScheduleBuilder cb) throws TaskException {
    switch (job.getMisfirePolicy()) {
        case MISFIRE_DEFAULT:
            return cb;
        case MISFIRE_IGNORE_MISFIRES:
            return cb.withMisfireHandlingInstructionIgnoreMisfires();
        case MISFIRE_FIRE_AND_PROCEED:
            return cb.withMisfireHandlingInstructionFireAndProceed();
        case MISFIRE_DO_NOTHING:
            return cb.withMisfireHandlingInstructionDoNothing();
        default:
            throw new TaskException("Invalid misfire policy", Code.CONFIG_ERROR);
    }
}
```

### 白名单校验

[`ScheduleUtils:128-141`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/ScheduleUtils.java)

```java
public static boolean whiteList(String invokeTarget) {
    String packageName = StringUtils.substringBefore(invokeTarget, "(");
    int count = StringUtils.countMatches(packageName, ".");
    
    if (count > 1) {
        // 普通类调用，检查包名是否在白名单内
        return StringUtils.startsWithAny(invokeTarget, Constants.JOB_WHITELIST_STR);
    }
    
    // Spring Bean 调用，获取 bean 的实际包名
    Object bean = SpringUtils.getBean(StringUtils.split(invokeTarget, ".")[0]);
    String beanPackageName = obj.getClass().getPackage().getName();
    
    return StringUtils.startsWithAny(beanPackageName, Constants.JOB_WHITELIST_STR)
            && !StringUtils.startsWithAny(beanPackageName, Constants.JOB_ERROR_STR);
}
```

> **安全说明**: 默认允许 `com.ruoyi` 和 `com.ruoyi.*` 包，禁止 `java.*`, `javax.*`, `com.sun.*` 等系统包。

---

## JobInvokeUtil - 任务调用工具

**源码**: [`JobInvokeUtil.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/JobInvokeUtil.java)

### 调用目标解析

支持的调用格式：

| 格式 | 说明 | 示例 |
|------|------|------|
| `beanName.methodName()` | 调用 Spring Bean | `myTask.execute()` |
| `beanName.methodName(params)` | 带参调用 Spring Bean | `userService.sync('all')` |
| `com.example.Class.method()` | 调用普通类 | `com.example.Util.run()` |

### 参数类型识别

[`JobInvokeUtil:106-144`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/JobInvokeUtil.java)

```java
public static List<Object[]> getMethodParams(String invokeTarget) {
    String methodStr = StringUtils.substringBetweenLast(invokeTarget, "(", ")");
    if (StringUtils.isEmpty(methodStr)) {
        return null;
    }
    
    String[] methodParams = methodStr.split(",(?=([^\"']*[\"'][^\"']*[\"'])*[^\"']*$)");
    List<Object[]> classs = new LinkedList<>();
    
    for (int i = 0; i < methodParams.length; i++) {
        String str = StringUtils.trimToEmpty(methodParams[i]);
        
        // String 类型：以'或"开头
        if (StringUtils.startsWithAny(str, "'", "\"")) {
            classs.add(new Object[] { 
                StringUtils.substring(str, 1, str.length() - 1), 
                String.class 
            });
        }
        // boolean 类型
        else if ("true".equalsIgnoreCase(str) || "false".equalsIgnoreCase(str)) {
            classs.add(new Object[] { Boolean.valueOf(str), Boolean.class });
        }
        // long 类型：以 L 结尾
        else if (StringUtils.endsWith(str, "L")) {
            classs.add(new Object[] { 
                Long.valueOf(StringUtils.substring(str, 0, str.length() - 1)), 
                Long.class 
            });
        }
        // double 类型：以 D 结尾
        else if (StringUtils.endsWith(str, "D")) {
            classs.add(new Object[] { 
                Double.valueOf(StringUtils.substring(str, 0, str.length() - 1)), 
                Double.class 
            });
        }
        // 其他类型归类为 integer
        else {
            classs.add(new Object[] { Integer.valueOf(str), Integer.class });
        }
    }
    return classs;
}
```

### 参数类型对照表

| 参数格式 | 识别为 | 示例 |
|----------|--------|------|
| `'string'` 或 `"string"` | String | `'hello'`, `"world"` |
| `true` / `false` | Boolean | `true`, `false` |
| `123L` | Long | `100L`, `999L` |
| `1.23D` | Double | `3.14D`, `0.5D` |
| `123` | Integer | `42`, `100` |

### 调用示例

```java
// 无参方法
SysJob job1 = new SysJob();
job1.setInvokeTarget("myTask.execute()");
JobInvokeUtil.invokeMethod(job1);

// 单参方法
SysJob job2 = new SysJob();
job2.setInvokeTarget("userService.sync('all')");
JobInvokeUtil.invokeMethod(job2);

// 多参方法
SysJob job3 = new SysJob();
job3.setInvokeTarget("reportService.generate(2024, 'monthly', true, 100L, 3.14D)");
JobInvokeUtil.invokeMethod(job3);
```

---

## AbstractQuartzJob - 抽象任务基类

**源码**: [`AbstractQuartzJob.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/AbstractQuartzJob.java)

### 执行流程

```
execute(SchedulerContext, JobExecutionContext)
    ↓
before(context)       -- 记录开始时间
    ↓
doExecute(context)    -- 调用 JobInvokeUtil.invokeMethod()
    ↓
after(context)        -- 记录结束时间，写入执行日志
```

### 核心方法

| 方法 | 说明 |
|------|------|
| `execute()` | Quartz 入口方法，调用 before/doExecute/after |
| `before()` | 执行前处理（记录开始时间） |
| `doExecute()` | 执行任务方法（调用 JobInvokeUtil） |
| `after()` | 执行后处理（记录时间、写入日志） |

---

## 任务类说明

### QuartzJobExecution - 允许并发

**源码**: [`QuartzJobExecution.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/QuartzJobExecution.java)

继承自 `AbstractQuartzJob`，无额外注解，允许同一任务实例同时执行多个。

### QuartzDisallowConcurrentExecution - 禁止并发

**源码**: [`QuartzDisallowConcurrentExecution.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/QuartzDisallowConcurrentExecution.java)

```java
@DisallowConcurrentExecution
public class QuartzDisallowConcurrentExecution extends AbstractQuartzJob {
    // ...
}
```

使用 `@DisallowConcurrentExecution` 注解，Quartz 会等待上一次执行完成后再触发下一次执行。

---

## CronUtils - Cron 表达式工具

**源码**: [`CronUtils.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/CronUtils.java)

### 核心方法

| 方法 | 说明 |
|------|------|
| `isValid(String)` | 校验 Cron 表达式是否有效 |
| `getNextExecution(String)` | 获取下次执行时间 |

### 使用示例

```java
// 校验 Cron 表达式
boolean valid = CronUtils.isValid("0 0/30 * * * ?"); // true
boolean invalid = CronUtils.isValid("invalid"); // false

// 获取下次执行时间
Date next = CronUtils.getNextExecution("0 0 12 * * ?"); // 今天 12:00
```

---

## 常量定义（ScheduleConstants）

**源码**: `ruoyi-common/src/main/java/com/ruoyi/common/constant/ScheduleConstants.java`

### Misfire 策略

```java
public interface MisfirePolicy {
    int MISFIRE_DEFAULT = 0;              // 默认
    int MISFIRE_IGNORE_MISFIRES = 1;      // 忽略
    int MISFIRE_FIRE_AND_PROCEED = 2;     // 执行一次
    int MISFIRE_DO_NOTHING = 3;           // 不执行
}
```

### 任务状态

```java
public enum Status {
    NORMAL(0),   // 正常
    PAUSE(1);    // 暂停
}
```

### 其他常量

```java
String TASK_CLASS_NAME = "SysJobTask";     // 任务类名
String TASK_PROPERTIES = "TASK_PROPERTIES"; // 任务参数 key
String JOB_WHITELIST_STR = "com.ruoyi";    // 白名单包名
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

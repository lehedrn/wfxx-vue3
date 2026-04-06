# Domain 实体模块

## 概述

`ruoyi-quartz/domain` 包提供定时任务相关的实体类。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/domain/`

## 模块结构

```
domain/
├── SysJob.java      # 定时任务配置实体
└── SysJobLog.java   # 任务执行日志实体
```

---

## SysJob - 定时任务配置实体

**源码**: [`SysJob.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/domain/SysJob.java)

**表名**: `sys_job`

**继承**: `BaseEntity`

### 核心字段

| 字段 | 类型 | 说明 |
|------|------|------|
| jobId | Long | 任务 ID（主键） |
| jobName | String | 任务名称 |
| jobGroup | String | 任务组名 |
| invokeTarget | String | 调用目标字符串（格式：`beanName.methodName(params)`） |
| cronExpression | String | Cron 表达式 |
| misfirePolicy | Integer | 错过执行策略（0 默认 1 忽略 2 执行一次 3 不执行） |
| concurrent | Integer | 是否并发（0 禁止 1 允许） |
| status | Integer | 状态（0 正常 1 暂停） |

### 字段详解

#### invokeTarget - 调用目标

支持的调用格式：

| 格式 | 说明 | 示例 |
|------|------|------|
| `@BeanName.methodName()` | 调用 Spring Bean | `myTask.execute()` |
| `@BeanName.methodName(params)` | 带参数调用 | `userService.sync('all')` |
| `com.example.Class.method()` | 调用普通类静态方法 | `com.example.Util.run()` |

参数支持的字面量类型：
- String: `"string"` 或 `'string'`
- Boolean: `true` / `false`
- Long: `123L`
- Double: `1.23D`
- Integer: `123`

#### misfirePolicy - 错过执行策略

| 值 | 策略 | 说明 |
|----|------|------|
| 0 | MISFIRE_DEFAULT | 默认策略（Quartz 默认行为） |
| 1 | MISFIRE_IGNORE_MISFIRES | 忽略错过的触发，按原计划继续 |
| 2 | MISFIRE_FIRE_AND_PROCEED | 立即执行一次错过的任务 |
| 3 | MISFIRE_DO_NOTHING | 不执行错过的任务，等待下次触发 |

#### concurrent - 并发控制

| 值 | 说明 | 适用场景 |
|----|------|----------|
| 0 | 禁止并发 | 数据同步、文件处理等不允许重叠执行的任务 |
| 1 | 允许并发 | 日志收集、监控上报等可并行执行的任务 |

### 使用示例

```java
// 创建任务
SysJob job = new SysJob();
job.setJobName("数据同步任务");
job.setJobGroup("DEFAULT");
job.setInvokeTarget("dataSyncService.sync()");
job.setCronExpression("0 0/30 * * * ?"); // 每 30 分钟执行一次
job.setMisfirePolicy(0); // 默认策略
job.setConcurrent(0); // 禁止并发
job.setStatus(0); // 正常

// 插入数据库
jobMapper.insertJob(job);
```

---

## SysJobLog - 任务执行日志实体

**源码**: [`SysJobLog.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/domain/SysJobLog.java)

**表名**: `sys_job_log`

**继承**: `BaseEntity`

### 核心字段

| 字段 | 类型 | 说明 |
|------|------|------|
| jobLogId | Long | 日志 ID（主键） |
| jobName | String | 任务名称 |
| jobGroup | String | 任务组名 |
| invokeTarget | String | 调用目标字符串 |
| jobMessage | String | 日志信息 |
| status | Integer | 状态（0 正常 1 失败） |
| exceptionInfo | String | 异常信息（失败时） |
| startTime | Date | 开始时间 |
| endTime | Date | 结束时间 |

### 日志记录时机

任务执行完成后自动记录日志：

- **正常执行**: status=0, exceptionInfo=null
- **执行失败**: status=1, exceptionInfo=异常堆栈

### 使用示例

```java
// 查询任务日志
SysJobLog condition = new SysJobLog();
condition.setJobName("数据同步任务");
List<SysJobLog> logs = jobLogMapper.selectJobLogList(condition);

// 查看某次执行的详细信息
SysJobLog log = jobLogMapper.selectJobLogById(1L);
if (log.getStatus() == 1) {
    System.out.println("执行失败：" + log.getExceptionInfo());
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

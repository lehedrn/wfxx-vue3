# RuoYi-Quartz 定时任务模块

## 概述

`ruoyi-quartz` 是基于 Quartz 调度器的定时任务模块，提供定时任务的配置、调度、执行和日志管理功能。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/`

## 功能特性

- ✅ 定时任务 CRUD 管理
- ✅ 任务暂停/恢复/立即执行
- ✅ Cron 表达式校验
- ✅ 多种 Misfire（错过执行）补偿策略
- ✅ 并发控制（允许/禁止并发执行）
- ✅ 任务执行日志记录
- ✅ 调用目标安全检查（白名单机制）

## 目录结构

```
ruoyi-quartz/
├── config/         # 配置类（ScheduleConfig.java）
├── controller/     # 控制器层（SysJobController, SysJobLogController）
├── domain/         # 实体类（SysJob, SysJobLog）
├── mapper/         # 数据访问层
├── service/        # 服务层 + 实现
├── task/           # 示例任务类（RyTask）
└── util/           # 工具类（调度、Cron、任务调用）
```

## 子模块文档

| 文档 | 说明 |
|------|------|
| [domain.md](ruoyi-quartz/domain.md) | 实体类详解（SysJob, SysJobLog） |
| [mapper.md](ruoyi-quartz/mapper.md) | 数据访问层（Mapper 接口 + XML） |
| [service.md](ruoyi-quartz/service.md) | 服务层（任务管理、调度操作） |
| [controller.md](ruoyi-quartz/controller.md) | API 接口层 |
| [task-core.md](ruoyi-quartz/task-core.md) | 任务调度核心逻辑（Util 工具类） |

---

## 快速入门

### 1. 创建任务类

```java
@Component("myTask")
public class MyTask {
    public void execute() {
        System.out.println("执行定时任务...");
    }
}
```

### 2. 注册任务

**API**: `POST /monitor/job`

```json
{
  "jobName": "测试任务",
  "jobGroup": "DEFAULT",
  "invokeTarget": "myTask.execute()",
  "cronExpression": "0/10 * * * * ?",
  "misfirePolicy": "0",
  "concurrent": "1"
}
```

### 3. 任务调用格式

| 格式 | 说明 | 示例 |
|------|------|------|
| `beanName.methodName()` | 调用 Spring Bean | `myTask.execute()` |
| `beanName.methodName(params)` | 带参数调用 | `myTask.doWork('hello')` |
| `com.example.Class.method()` | 调用普通类 | `com.example.MyService.run()` |

### 4. 内置测试任务

系统提供 `RyTask` 示例类用于测试：

| 方法 | 说明 | 调用示例 |
|------|------|----------|
| `ryNoParams()` | 无参方法 | `ryTask.ryNoParams()` |
| `ryParams(String)` | 单参方法 | `ryTask.ryParams('test')` |
| `ryMultipleParams(...)` | 多参方法 | `ryTask.ryMultipleParams('a', true, 100L, 3.14D, 42)` |

---

## 核心配置

### Misfire 策略

| 值 | 策略 | 说明 |
|----|------|------|
| 0 | MISFIRE_DEFAULT | 默认策略 |
| 1 | MISFIRE_IGNORE_MISFIRES | 忽略错过的触发 |
| 2 | MISFIRE_FIRE_AND_PROCEED | 立即执行一次错过的任务 |
| 3 | MISFIRE_DO_NOTHING | 不执行错过的任务 |

### 并发控制

| concurrent | 说明 |
|------------|------|
| 0 | 禁止并发（同一任务实例上一次执行完成后才能执行下一次） |
| 1 | 允许并发（任务实例可同时执行多个） |

### 任务状态

| status | 说明 |
|--------|------|
| 0 | 正常（调度中） |
| 1 | 暂停 |

---

## 安全检查

新增/修改任务时进行以下校验：

1. **Cron 表达式有效性** - 使用 `CronUtils.isValid()` 校验
2. **协议白名单** - 禁止 `rmi://`, `ldap://`, `ldaps://`, `http://`, `https://` 调用
3. **包名白名单** - 调用目标必须在允许的包名列表内（默认允许 `com.ruoyi` 和 `com.ruoyi.*` 包）

---

## 数据库表

| 表名 | 说明 | 源码 |
|------|------|------|
| sys_job | 定时任务配置表 | [`SysJobMapper.xml`](../../ruoyi-quartz/src/main/resources/mapper/quartz/SysJobMapper.xml) |
| sys_job_log | 任务执行日志表 | [`SysJobLogMapper.xml`](../../ruoyi-quartz/src/main/resources/mapper/quartz/SysJobLogMapper.xml) |

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

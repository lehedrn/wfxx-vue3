# Service 业务逻辑层

## 概述

`ruoyi-quartz/service` 包提供定时任务调度相关的业务逻辑处理。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/`  
**实现位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/`

## 模块结构

```
service/
├── ISysJobService.java        # 任务调度服务接口
├── ISysJobLogService.java     # 任务日志服务接口
└── impl/
    ├── SysJobServiceImpl.java     # 任务调度服务实现
    └── SysJobLogServiceImpl.java  # 任务日志服务实现
```

## 服务接口总览

| 服务接口 | 源码 | 实现类 | 主要功能 |
|----------|------|--------|----------|
| ISysJobService | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/ISysJobService.java) | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java) | 任务管理、调度控制、Cron 校验 |
| ISysJobLogService | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/ISysJobLogService.java) | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobLogServiceImpl.java) | 日志查询、清理 |

---

## ISysJobService - 任务调度服务

### 核心方法

| 方法 | 说明 | 异常 |
|------|------|------|
| `selectJobList(SysJob)` | 查询任务列表（带条件） | - |
| `selectJobById(Long)` | 根据 ID 查询任务 | - |
| `insertJob(SysJob)` | 新增任务并注册到调度器 | SchedulerException, TaskException |
| `updateJob(SysJob)` | 修改任务并更新调度器 | SchedulerException, TaskException |
| `pauseJob(SysJob)` | 暂停任务 | SchedulerException |
| `resumeJob(SysJob)` | 恢复任务 | SchedulerException |
| `deleteJob(SysJob)` | 删除任务及调度器注册 | SchedulerException |
| `deleteJobByIds(Long[])` | 批量删除任务 | SchedulerException |
| `changeStatus(SysJob)` | 修改任务状态（暂停/恢复） | SchedulerException |
| `run(SysJob)` | 立即执行一次任务 | SchedulerException |
| `checkCronExpressionIsValid(String)` | 校验 Cron 表达式 | - |

### 核心业务逻辑

#### 1. 服务启动时初始化任务

[`SysJobServiceImpl:37-46`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@PostConstruct
public void init() throws SchedulerException, TaskException {
    scheduler.clear();  // 清空调度器
    List<SysJob> jobList = jobMapper.selectJobAll();  // 查询所有任务
    for (SysJob job : jobList) {
        ScheduleUtils.createScheduleJob(scheduler, job);  // 重新注册
    }
}
```

> **注意**: 不能手动修改数据库中的任务 ID 和任务组名，否则会导致脏数据。

#### 2. 暂停任务

[`SysJobServiceImpl:77-90`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public int pauseJob(SysJob job) throws SchedulerException {
    Long jobId = job.getJobId();
    String jobGroup = job.getJobGroup();
    
    // 1. 修改数据库状态
    job.setStatus(ScheduleConstants.Status.PAUSE.getValue());
    int rows = jobMapper.updateJob(job);
    
    // 2. 调用调度器暂停任务
    if (rows > 0) {
        scheduler.pauseJob(ScheduleUtils.getJobKey(jobId, jobGroup));
    }
    return rows;
}
```

#### 3. 恢复任务

[`SysJobServiceImpl:97-110`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public int resumeJob(SysJob job) throws SchedulerException {
    Long jobId = job.getJobId();
    String jobGroup = job.getJobGroup();
    
    // 1. 修改数据库状态为正常
    job.setStatus(ScheduleConstants.Status.NORMAL.getValue());
    int rows = jobMapper.updateJob(job);
    
    // 2. 调用调度器恢复任务
    if (rows > 0) {
        scheduler.resumeJob(ScheduleUtils.getJobKey(jobId, jobGroup));
    }
    return rows;
}
```

#### 4. 立即执行任务

[`SysJobServiceImpl:175-193`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public boolean run(SysJob job) throws SchedulerException {
    boolean result = false;
    Long jobId = job.getJobId();
    String jobGroup = job.getJobGroup();
    
    // 查询任务配置
    SysJob properties = selectJobById(job.getJobId());
    
    // 构建参数
    JobDataMap dataMap = new JobDataMap();
    dataMap.put(ScheduleConstants.TASK_PROPERTIES, properties);
    
    JobKey jobKey = ScheduleUtils.getJobKey(jobId, jobGroup);
    
    // 检查任务是否存在
    if (scheduler.checkExists(jobKey)) {
        result = true;
        scheduler.triggerJob(jobKey, dataMap);  // 触发一次执行
    }
    return result;
}
```

#### 5. 新增任务

[`SysJobServiceImpl:200-211`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public int insertJob(SysJob job) throws SchedulerException, TaskException {
    // 新增时状态默认为暂停
    job.setStatus(ScheduleConstants.Status.PAUSE.getValue());
    
    int rows = jobMapper.insertJob(job);
    if (rows > 0) {
        // 注册到调度器
        ScheduleUtils.createScheduleJob(scheduler, job);
    }
    return rows;
}
```

#### 6. 修改任务

[`SysJobServiceImpl:218-248`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/service/impl/SysJobServiceImpl.java)

```java
@Override
@Transactional(rollbackFor = Exception.class)
public int updateJob(SysJob job) throws SchedulerException, TaskException {
    SysJob properties = selectJobById(job.getJobId());
    
    int rows = jobMapper.updateJob(job);
    if (rows > 0) {
        updateSchedulerJob(job, properties.getJobGroup());
    }
    return rows;
}

// 更新调度器中的任务配置
public void updateSchedulerJob(SysJob job, String jobGroup) throws SchedulerException, TaskException {
    Long jobId = job.getJobId();
    JobKey jobKey = ScheduleUtils.getJobKey(jobId, jobGroup);
    
    // 先删除旧的配置
    if (scheduler.checkExists(jobKey)) {
        scheduler.deleteJob(jobKey);
    }
    
    // 重新创建配置
    ScheduleUtils.createScheduleJob(scheduler, job);
}
```

---

## ISysJobLogService - 任务日志服务

### 核心方法

| 方法 | 说明 |
|------|------|
| `selectJobLogList(SysJobLog)` | 查询日志列表（带条件） |
| `selectJobLogById(Long)` | 根据 ID 查询日志 |
| `addJobLog(SysJobLog)` | 新增日志 |
| `deleteJobLogByIds(Long[])` | 批量删除日志 |
| `cleanJobLog()` | 清空日志表 |

### 使用示例

```java
@Autowired
private ISysJobLogService jobLogService;

// 查询某任务的执行日志
SysJobLog condition = new SysJobLog();
condition.setJobName("数据同步");
List<SysJobLog> logs = jobLogService.selectJobLogList(condition);

// 清理所有日志
jobLogService.cleanJobLog();
```

---

## 使用示例

### Controller 中注入 Service

```java
@RestController
@RequestMapping("/monitor/job")
public class SysJobController {
    
    @Autowired
    private ISysJobService jobService;
    
    /**
     * 查询任务列表
     */
    @GetMapping("/list")
    public TableDataInfo list(SysJob job) {
        List<SysJob> list = jobService.selectJobList(job);
        return getDataTable(list);
    }
    
    /**
     * 立即执行一次任务
     */
    @PostMapping("/run")
    public AjaxResult run(@RequestBody SysJob job) throws SchedulerException {
        jobService.run(job);
        return success();
    }
    
    /**
     * 暂停任务
     */
    @PostMapping("/pause")
    public AjaxResult pause(@RequestBody SysJob job) throws SchedulerException {
        jobService.pauseJob(job);
        return success();
    }
    
    /**
     * 恢复任务
     */
    @PostMapping("/resume")
    public AjaxResult resume(@RequestBody SysJob job) throws SchedulerException {
        jobService.resumeJob(job);
        return success();
    }
}
```

---

## 事务处理

所有涉及数据库修改和调度器操作的方法都使用 `@Transactional(rollbackFor = Exception.class)` 注解，确保：

1. 数据库操作和调度器操作要么全部成功，要么全部回滚
2. 防止出现数据库状态和调度器状态不一致的情况

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

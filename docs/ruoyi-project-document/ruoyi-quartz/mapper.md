# Mapper 数据访问层

## 概述

`ruoyi-quartz/mapper` 包提供定时任务相关的 MyBatis 数据访问接口。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/mapper/`  
**XML 位置**: `ruoyi-quartz/src/main/resources/mapper/quartz/`

## 模块结构

```
mapper/
├── SysJobMapper.java       # 定时任务数据访问
└── SysJobLogMapper.java    # 任务日志数据访问
```

## Mapper 接口总览

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| SysJobMapper | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/mapper/SysJobMapper.java) | [`🔗`](../../ruoyi-quartz/src/main/resources/mapper/quartz/SysJobMapper.xml) | 定时任务 CRUD、状态变更 |
| SysJobLogMapper | [`🔗`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/mapper/SysJobLogMapper.java) | [`🔗`](../../ruoyi-quartz/src/main/resources/mapper/quartz/SysJobLogMapper.xml) | 任务日志查询、插入、清理 |

---

## SysJobMapper - 任务数据访问

### 核心方法

| 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `selectJobList` | SysJob | List<SysJob> | 查询任务列表（带条件） |
| `selectJobById` | Long | SysJob | 根据 ID 查询任务 |
| `selectJobAll` | - | List<SysJob> | 查询所有任务（系统初始化用） |
| `insertJob` | SysJob | int | 新增任务 |
| `updateJob` | SysJob | int | 修改任务 |
| `deleteJobById` | Long | int | 删除单个任务 |
| `deleteJobByIds` | Long[] | int | 批量删除任务 |
| `updateJobStatus` | SysJob | int | 修改任务状态 |

### 使用示例

```java
@Autowired
private SysJobMapper jobMapper;

// 查询任务列表（带条件）
SysJob condition = new SysJob();
condition.setJobName("同步");
condition.setStatus(0);
List<SysJob> jobs = jobMapper.selectJobList(condition);

// 查询所有任务（系统初始化用）
List<SysJob> allJobs = jobMapper.selectJobAll();

// 修改任务状态
SysJob job = jobMapper.selectJobById(1L);
job.setStatus(1); // 暂停
jobMapper.updateJobStatus(job);

// 批量删除
Long[] jobIds = {1L, 2L, 3L};
jobMapper.deleteJobByIds(jobIds);
```

---

## SysJobLogMapper - 任务日志数据访问

### 核心方法

| 方法 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `selectJobLogList` | SysJobLog | List<SysJobLog> | 查询日志列表（带条件） |
| `selectJobLogById` | Long | SysJobLog | 根据 ID 查询日志 |
| `insertJobLog` | SysJobLog | int | 新增日志 |
| `deleteJobLogById` | Long | int | 删除单条日志 |
| `deleteJobLogByIds` | Long[] | int | 批量删除日志 |
| `cleanJobLog` | - | int | 清空日志表 |

### 使用示例

```java
@Autowired
private SysJobLogMapper jobLogMapper;

// 查询某任务的执行日志
SysJobLog condition = new SysJobLog();
condition.setJobName("数据同步任务");
List<SysJobLog> logs = jobLogMapper.selectJobLogList(condition);

// 查看执行结果
SysJobLog log = jobLogMapper.selectJobLogById(100L);
if (log.getStatus() == 1) {
    // 执行失败，查看异常信息
    System.err.println("异常：" + log.getExceptionInfo());
}

// 清理日志（保留最近 30 天）
Date thirtyDaysAgo = DateUtils.addDays(new Date(), -30);
SysJobLog condition = new SysJobLog();
condition.setStartTime(thirtyDaysAgo);
// 实际业务中可能需要自定义 SQL 实现时间范围删除
```

---

## XML 映射示例

### SysJobMapper.xml 片段

```xml
<mapper namespace="com.ruoyi.quartz.mapper.SysJobMapper">
    
    <resultMap type="SysJob" id="SysJobResult">
        <id     property="jobId"       column="job_id"       />
        <result property="jobName"     column="job_name"     />
        <result property="jobGroup"    column="job_group"    />
        <result property="invokeTarget" column="invoke_target" />
        <result property="cronExpression" column="cron_expression" />
        <result property="misfirePolicy" column="misfire_policy" />
        <result property="concurrent"    column="concurrent"    />
        <result property="status"        column="status"        />
    </resultMap>
    
    <update id="updateJobStatus" parameterType="SysJob">
        update sys_job 
        set status = #{status} 
        where job_id = #{jobId}
    </update>
    
</mapper>
```

### SysJobLogMapper.xml 片段

```xml
<mapper namespace="com.ruoyi.quartz.mapper.SysJobLogMapper">
    
    <insert id="insertJobLog" parameterType="SysJobLog">
        insert into sys_job_log (
            job_name, job_group, invoke_target, 
            job_message, status, exception_info,
            start_time, end_time
        ) values (
            #{jobName}, #{jobGroup}, #{invokeTarget}, 
            #{jobMessage}, #{status}, #{exceptionInfo},
            #{startTime}, #{endTime}
        )
    </insert>
    
</mapper>
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

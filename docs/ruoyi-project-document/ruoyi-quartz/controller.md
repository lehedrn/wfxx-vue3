# Controller 控制器层

## 概述

`ruoyi-quartz/controller` 包提供定时任务相关的 HTTP API 接口。

**源码位置**: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/controller/`

## 模块结构

```
controller/
├── SysJobController.java      # 定时任务 API 接口
└── SysJobLogController.java   # 任务日志 API 接口
```

---

## SysJobController - 任务管理接口

**源码**: [`SysJobController.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/controller/SysJobController.java)

**请求路径**: `/monitor/job`

### API 接口列表

| 方法 | 路径 | 说明 | 参数 |
|------|------|------|------|
| GET | `/list` | 查询任务列表 | SysJob 查询条件 |
| GET | `/{jobId}` | 查询任务详情 | jobId（路径参数） |
| POST | `/` | 新增任务 | SysJob 对象 |
| PUT | `/` | 修改任务 | SysJob 对象 |
| DELETE | `/{jobIds}` | 删除任务 | jobId 数组（路径参数） |
| PUT | `/changeStatus` | 修改任务状态 | SysJob（jobId + status） |
| PUT | `/run` | 立即执行一次任务 | SysJob（jobId + jobGroup） |
| POST | `/export` | 导出任务 Excel | SysJob 查询条件 |

### 请求/响应示例

#### 1. 查询任务列表

**请求**: `GET /monitor/job/list?jobName=sync&status=0`

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "total": 10,
  "rows": [
    {
      "jobId": 1,
      "jobName": "数据同步任务",
      "jobGroup": "DEFAULT",
      "invokeTarget": "syncService.sync()",
      "cronExpression": "0 0/30 * * * ?",
      "status": "0"
    }
  ]
}
```

#### 2. 新增任务

**请求**: `POST /monitor/job`

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

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功"
}
```

#### 3. 修改任务

**请求**: `PUT /monitor/job`

```json
{
  "jobId": 1,
  "jobName": "测试任务-已修改",
  "cronExpression": "0 0 * * * ?",
  "misfirePolicy": "1"
}
```

#### 4. 暂停任务

**请求**: `PUT /monitor/job/changeStatus`

```json
{
  "jobId": 1,
  "jobGroup": "DEFAULT",
  "status": "1"
}
```

#### 5. 立即执行任务

**请求**: `POST /monitor/job/run`

```json
{
  "jobId": 1,
  "jobGroup": "DEFAULT"
}
```

---

## SysJobLogController - 任务日志接口

**源码**: [`SysJobLogController.java`](../../ruoyi-quartz/src/main/java/com/ruoyi/quartz/controller/SysJobLogController.java)

**请求路径**: `/monitor/jobLog`

### API 接口列表

| 方法 | 路径 | 说明 | 参数 |
|------|------|------|------|
| GET | `/list` | 查询日志列表 | SysJobLog 查询条件 |
| GET | `/{jobLogId}` | 查询日志详情 | jobLogId（路径参数） |
| DELETE | `/{jobLogIds}` | 删除日志 | jobLogId 数组（路径参数） |
| DELETE | `/clean` | 清空日志 | - |
| POST | `/export` | 导出日志 Excel | SysJobLog 查询条件 |

### 请求/响应示例

#### 1. 查询日志列表

**请求**: `GET /monitor/jobLog/list?jobName=sync`

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "total": 50,
  "rows": [
    {
      "jobLogId": 100,
      "jobName": "数据同步任务",
      "jobGroup": "DEFAULT",
      "invokeTarget": "syncService.sync()",
      "jobMessage": "执行成功",
      "status": "0",
      "startTime": "2026-04-07 10:00:00",
      "endTime": "2026-04-07 10:00:05"
    }
  ]
}
```

#### 2. 查询日志详情

**请求**: `GET /monitor/jobLog/100`

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "jobLogId": 100,
    "jobName": "数据同步任务",
    "jobGroup": "DEFAULT",
    "invokeTarget": "syncService.sync()",
    "jobMessage": "执行失败：NullPointerException",
    "status": "1",
    "exceptionInfo": "java.lang.NullPointerException\n\tat com.example...",
    "startTime": "2026-04-07 10:00:00",
    "endTime": "2026-04-07 10:00:05"
  }
}
```

#### 3. 删除日志

**请求**: `DELETE /monitor/jobLog/100,101,102`

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功"
}
```

#### 4. 清空日志

**请求**: `DELETE /monitor/jobLog/clean`

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功"
}
```

---

## 状态码说明

| code | 说明 |
|------|------|
| 200 | 操作成功 |
| 500 | 操作失败 |
| 401 | 未授权 |
| 403 | 权限不足 |

### 错误响应示例

```json
{
  "code": 500,
  "msg": "Cron 表达式无效"
}
```

```json
{
  "code": 500,
  "msg": "调用目标字符串格式错误"
}
```

---

## 前端调用示例（Vue）

```javascript
// 查询任务列表
listJob(queryParam).then(response => {
  console.log(response.rows)
})

// 新增任务
addJob(form).then(response => {
  this.$modal.msgSuccess("新增成功")
})

// 修改任务
updateJob(form).then(response => {
  this.$modal.msgSuccess("修改成功")
})

// 暂停任务
changeStatus(job).then(response => {
  this.$modal.msgSuccess("暂停成功")
})

// 恢复任务
changeStatus(job).then(response => {
  this.$modal.msgSuccess("恢复成功")
})

// 立即执行
runJob(job).then(response => {
  this.$modal.msgSuccess("执行成功")
})
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

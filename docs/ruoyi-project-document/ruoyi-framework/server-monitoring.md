# Server Monitoring 服务器监控模块

## 概述

`ruoyi-framework/web/domain/server` 包提供服务器运行状态的监控功能，包括 CPU、内存、JVM、系统和文件系统的信息收集与展示。

## 模块结构

```
domain/server/
├── Server.java          # 服务器信息总入口
├── Cpu.java             # CPU 信息
├── Jvm.java             # JVM 信息
├── Mem.java             # 内存信息
├── Sys.java             # 系统信息
└── SysFile.java         # 文件系统信息
```

**源码位置**: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/domain/server/`

## 依赖

```xml
<dependency>
    <groupId>com.github.oshi</groupId>
    <artifactId>oshi-core</artifactId>
    <version>6.4.0</version>
</dependency>
```

---

## 1. Server - 服务器信息总入口

**用途**: 整合所有服务器相关信息，提供统一的访问入口

**核心实现**:

```java
public class Server {
    
    private static final int OSHI_WAIT_SECOND = 1000;
    
    private Cpu cpu = new Cpu();
    private Mem mem = new Mem();
    private Jvm jvm = new Jvm();
    private Sys sys = new Sys();
    private List<SysFile> sysFiles = new LinkedList<>();
    
    /**
     * 复制属性到当前对象（核心入口方法）
     * 调用此方法会自动填充所有服务器信息
     */
    public void copyTo() throws Exception {
        setCpuInfo(hal.getProcessor());
        setMemInfo(hal.getMemory());
        setSysInfo();
        setJvmInfo();
        setSysFiles(si.getOperatingSystem());
    }
    
    /**
     * 设置 CPU 信息
     */
    private void setCpuInfo(CentralProcessor processor) {
        // 等待 1 秒获取准确的 CPU 使用率
        long[] prevTicks = processor.getSystemCpuLoadTicks();
        Util.sleep(OSHI_WAIT_SECOND);
        long[] ticks = processor.getSystemCpuLoadTicks();
        
        // 计算各个状态的 CPU 时间
        long user = ticks[TickType.USER.getIndex()] - prevTicks[TickType.USER.getIndex()];
        long nice = ticks[TickType.NICE.getIndex()] - prevTicks[TickType.NICE.getIndex()];
        long cSys = ticks[TickType.SYSTEM.getIndex()] - prevTicks[TickType.SYSTEM.getIndex()];
        long idle = ticks[TickType.IDLE.getIndex()] - prevTicks[TickType.IDLE.getIndex()];
        long iowait = ticks[TickType.IOWAIT.getIndex()] - prevTicks[TickType.IOWAIT.getIndex()];
        long irq = ticks[TickType.IRQ.getIndex()] - prevTicks[TickType.IRQ.getIndex()];
        long softirq = ticks[TickType.SOFTIRQ.getIndex()] - prevTicks[TickType.SOFTIRQ.getIndex()];
        long steal = ticks[TickType.STEAL.getIndex()] - prevTicks[TickType.STEAL.getIndex()];
        
        long totalCpu = user + nice + cSys + idle + iowait + irq + softirq + steal;
        
        cpu.setCpuNum(processor.getLogicalProcessorCount());
        cpu.setTotal(totalCpu);
        cpu.setSys(cSys);
        cpu.setUsed(user);
        cpu.setWait(iowait);
        cpu.setFree(idle);
    }
    
    /**
     * 设置内存信息
     */
    private void setMemInfo(GlobalMemory memory) {
        mem.setTotal(memory.getTotal());
        mem.setUsed(memory.getTotal() - memory.getAvailable());
        mem.setFree(memory.getAvailable());
    }
    
    /**
     * 字节转换
     */
    public String convertFileSize(long size) {
        long kb = 1024;
        long mb = kb * 1024;
        long gb = mb * 1024;
        if (size >= gb) {
            return String.format("%.1f GB", (float) size / gb);
        } else if (size >= mb) {
            float f = (float) size / mb;
            return String.format(f > 100 ? "%.0f MB" : "%.1f MB", f);
        } else if (size >= kb) {
            float f = (float) size / kb;
            return String.format(f > 100 ? "%.0f KB" : "%.1f KB", f);
        } else {
            return String.format("%d B", size);
        }
    }
    
    // Getters and Setters...
}
```

**使用示例**:

```java
@RestController
@RequestMapping("/monitor/server")
public class ServerController {
    
    @PreAuthorize("@ss.hasPermi('monitor:server:list')")
    @GetMapping()
    public AjaxResult getInfo() throws Exception {
        Server server = new Server();
        server.copyTo();  // 填充所有信息
        return AjaxResult.success(server);
    }
}
```

---

## 2. Cpu - CPU 信息

**属性**:

| 字段 | 类型 | 说明 | 备注 |
|------|------|------|------|
| cpuNum | int | CPU 核心数 | - |
| total | double | 总时间片数 | getter 计算百分比 |
| sys | double | 系统使用时间 | getter 计算百分比 |
| used | double | 用户使用时间 | getter 计算百分比 |
| wait | double | IO 等待时间 | getter 计算百分比 |
| free | double | 空闲时间 | getter 计算百分比 |

**示例数据**:

```json
{
    "cpuNum": 8,
    "sys": 15.5,
    "used": 35.2,
    "wait": 2.0,
    "free": 47.3
}
```

**注意**: 字段存储原始时间片数，getter 方法自动计算百分比（除以 total 并乘以 100）

---

## 3. Jvm - JVM 信息

**属性**:

| 字段 | 类型 | 说明 | 备注 |
|------|------|------|------|
| total | double | 当前堆内存 (字节) | getter 返回 MB |
| max | double | 最大可用内存 (字节) | getter 返回 MB |
| free | double | 空闲内存 (字节) | getter 返回 MB |
| version | String | JDK 版本 | - |
| home | String | JDK 安装路径 | - |

**额外方法**:

- `getUsage()`: 内存使用率（百分比）
- `getName()`: JDK 名称
- `getStartTime()`: 启动时间（格式化字符串）
- `getRunTime()`: 运行时间（格式化字符串）
- `getInputArgs()`: 运行参数

**示例数据**:

```json
{
    "total": 2048.5,
    "max": 4096.0,
    "free": 1024.0,
    "version": "17.0.1",
    "home": "/usr/lib/jvm/java-17",
    "name": "OpenJDK 64-Bit Server VM",
    "startTime": "2024-01-01 10:00:00",
    "runTime": "1 天 2 小时 30 分钟"
}
```

---

## 4. Mem - 内存信息

**属性**:

| 字段 | 类型 | 说明 | 备注 |
|------|------|------|------|
| total | double | 内存总量 (字节) | getter 返回 GB |
| used | double | 已用内存 (字节) | getter 返回 GB |
| free | double | 剩余内存 (字节) | getter 返回 GB |

**方法**: `getUsage()` - 内存使用率（百分比）

**示例数据**:

```json
{
    "total": 16.0,
    "used": 8.5,
    "free": 7.5,
    "usage": 53.13
}
```

---

## 5. Sys - 系统信息

**属性**:

| 字段 | 类型 | 说明 |
|------|------|------|
| computerName | String | 服务器名称 |
| computerIp | String | 服务器 IP |
| userDir | String | 项目路径 |
| osName | String | 操作系统名称 |
| osArch | String | 操作系统架构 |

**示例数据**:

```json
{
    "computerName": "server-01",
    "computerIp": "192.168.1.100",
    "userDir": "/home/workspace/com/wfxx-vue3",
    "osName": "Linux",
    "osArch": "amd64"
}
```

---

## 6. SysFile - 文件系统信息

**属性**:

| 字段 | 类型 | 说明 |
|------|------|------|
| dirName | String | 盘符路径 |
| sysTypeName | String | 盘符类型（文件系统类型） |
| typeName | String | 文件类型 |
| total | String | 总大小（格式化字符串，如 "500.0 GB"） |
| free | String | 剩余大小（格式化字符串） |
| used | String | 已使用量（格式化字符串） |
| usage | double | 使用率（百分比） |

**示例数据**:

```json
{
    "dirName": "/",
    "sysTypeName": "ext4",
    "typeName": "overlay",
    "total": "500.0 GB",
    "free": "250.0 GB",
    "used": "250.0 GB",
    "usage": 50.0
}
```

---

## 监控指标说明

### CPU 指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| cpuNum | CPU 核心数 | - |
| used | 用户使用率 | < 80% |
| sys | 系统使用率 | - |
| wait | IO 等待率 | < 20% |
| free | 空闲率 | > 20% |

### 内存指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| total | 总内存 (GB) | - |
| used | 已用内存 (GB) | - |
| free | 剩余内存 (GB) | > 20% |
| usage | 使用率 | < 80% |

### JVM 指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| total | 当前堆内存 (MB) | - |
| max | 最大堆内存 (MB) | - |
| free | 剩余堆内存 (MB) | - |
| usage | 堆内存使用率 | < 80% |

---

## 最佳实践

1. **监控频率**: 建议每秒采集一次 CPU 使用率，取平均值
2. **告警阈值**: CPU/内存使用率超过 80% 触发告警
3. **磁盘监控**: 磁盘使用率超过 90% 触发紧急告警
4. **日志记录**: 定期记录 JVM 运行状态，便于问题排查

---

## 常见问题

**Q1: CPU 使用率为什么需要等待 1 秒？**

A: OSHI 需要两次采样计算差值，第一次获取基准值，等待 1 秒后获取第二次值，差值即为该时间段的使用率。

**Q2: JVM 内存使用率和系统内存使用率的区别？**

A: JVM 内存使用率是 Java 堆内存的使用情况，系统内存使用率是物理内存的使用情况。

# Server Monitoring 服务器监控模块

## 概述

`ruoyi-framework/web/domain/server` 包提供了服务器运行状态的监控功能，包括 CPU、内存、JVM、系统和文件系统的信息收集与展示。

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

## 依赖

**pom.xml**:

```xml
<!-- 系统信息 -->
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
@Component
public class Server {
    
    private static final int OSHI_WAIT_SECOND = 1000;
    
    /**
     * CPU 相关信息
     */
    private Cpu cpu = new Cpu();
    
    /**
     * 内存相关信息
     */
    private Mem mem = new Mem();
    
    /**
     * JVM 相关信息
     */
    private Jvm jvm = new Jvm();
    
    /**
     * 系统相关信息
     */
    private Sys sys = new Sys();
    
    /**
     * 文件系统相关信息
     */
    private List<SysFile> sysFiles = new ArrayList<>();
    
    /**
     * 复制属性
     */
    public void copyTo() {
        setJvm();
        setCpu();
        setMem();
        setSys();
        setSysFiles();
    }
    
    /**
     * 设置 JVM 信息
     */
    private void setJvm() {
        jvm.setTotal(Runtime.getRuntime().totalMemory());
        jvm.setMax(Runtime.getRuntime().maxMemory());
        jvm.setFree(Runtime.getRuntime().freeMemory());
        jvm.setVersion(System.getProperty("java.version"));
        jvm.setHome(System.getProperty("java.home"));
        jvm.setStartTime(new Date(ManagementFactory.getRuntimeMXBean().getStartTime()));
        jvm.setRunTime((System.currentTimeMillis() - jvm.getStartTime().getTime()) / 1000);
        
        // 获取线程信息
        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
        jvm.setThreadCount(threadMXBean.getThreadCount());
        
        // 获取类加载信息
        ClassLoadingMXBean classLoadingMXBean = ManagementFactory.getClassLoadingMXBean();
        jvm.setClassCount(classLoadingMXBean.getLoadedClassCount());
        
        // 获取垃圾回收信息
        List<GarbageCollectorMXBean> gcBeans = ManagementFactory.getGarbageCollectorMXBeans();
        StringBuilder gcInfo = new StringBuilder();
        for (GarbageCollectorMXBean gcBean : gcBeans) {
            gcInfo.append(gcBean.getName()).append(", ");
        }
        jvm.setGcInfo(gcInfo.toString());
        
        // 计算使用率
        jvm.setUsage(Arith.round(Arith.mul(
            Arith.sub(jvm.getTotal(), jvm.getFree()), 100.0 / jvm.getTotal()
        ), 2));
    }
    
    /**
     * 设置 CPU 信息
     */
    private void setCpu() {
        CentralProcessor processor = getProcessor();
        
        // CPU 核心数
        cpu.setCpuNum(processor.getPhysicalProcessorCount());
        
        // CPU 使用率
        long[] prevTicks = processor.getSystemCpuLoadTicks();
        Threads.sleep(OSHI_WAIT_SECOND);
        long[] ticks = processor.getSystemCpuLoadTicks();
        
        long user = ticks[CentralProcessor.TickType.USER.getIndex()] - 
                   prevTicks[CentralProcessor.TickType.USER.getIndex()];
        long nice = ticks[CentralProcessor.TickType.NICE.getIndex()] - 
                   prevTicks[CentralProcessor.TickType.NICE.getIndex()];
        long system = ticks[CentralProcessor.TickType.SYSTEM.getIndex()] - 
                     prevTicks[CentralProcessor.TickType.SYSTEM.getIndex()];
        long idle = ticks[CentralProcessor.TickType.IDLE.getIndex()] - 
                   prevTicks[CentralProcessor.TickType.IDLE.getIndex()];
        long iowait = ticks[CentralProcessor.TickType.IOWAIT.getIndex()] - 
                     prevTicks[CentralProcessor.TickType.IOWAIT.getIndex()];
        long irq = ticks[CentralProcessor.TickType.IRQ.getIndex()] - 
                  prevTicks[CentralProcessor.TickType.IRQ.getIndex()];
        long softirq = ticks[CentralProcessor.TickType.SOFTIRQ.getIndex()] - 
                      prevTicks[CentralProcessor.TickType.SOFTIRQ.getIndex()];
        
        long totalCpu = user + nice + system + idle + iowait + irq + softirq;
        cpu.setCombined(Arith.round(
            Arith.mul(Arith.sub(totalCpu, idle + iowait), 100.0 / totalCpu), 2
        ));
        cpu.setUser(Arith.round(Arith.mul(user, 100.0 / totalCpu), 2));
        cpu.setSys(Arith.round(Arith.mul(system, 100.0 / totalCpu), 2));
        cpu.setWait(Arith.round(Arith.mul(iowait, 100.0 / totalCpu), 2));
        cpu.setFree(Arith.round(Arith.mul(idle, 100.0 / totalCpu), 2));
    }
    
    /**
     * 设置内存信息
     */
    private void setMem() {
        GlobalMemory memory = getMemory();
        long total = memory.getTotal();
        long used = total - memory.getAvailable();
        
        mem.setTotal(total);
        mem.setUsed(used);
        mem.setFree(total - used);
        mem.setUsage(Arith.round(Arith.mul(used, 100.0 / total), 2));
    }
    
    /**
     * 设置系统信息
     */
    private void setSys() {
        OperatingSystem os = getOperatingSystem();
        
        // 操作系统信息
        sys.setComputerName(getHostName());
        sys.setComputerIp(IpUtils.getHostIp());
        sys.setOsName(os.getName());
        sys.setOsArch(System.getProperty("os.arch"));
        
        // 系统负载
        double[] loadAverage = getSystemLoadAverage();
        if (loadAverage.length > 0) {
            sys.setSysLoadAverage(loadAverage[0]);
        }
    }
    
    /**
     * 设置文件系统信息
     */
    private void setSysFiles() {
        FileSystem fileSystem = getFileSystem();
        FileStatus[] fileStatuses = fileSystem.getFileStatuses();
        
        for (FileStatus status : fileStatuses) {
            // 只关心磁盘分区
            if (status.getType() == FileSystem.TYPE_LOCAL_DRIVE) {
                SysFile sysFile = new SysFile();
                sysFile.setDirName(status.getMount());
                sysFile.setSysTypeName(status.getTypeName());
                sysFile.setTypeName(status.getType());
                
                long total = status.getTotalSpace();
                long free = status.getUsableSpace();
                long used = total - free;
                
                sysFile.setTotal(convertFileSize(total));
                sysFile.setFree(convertFileSize(free));
                sysFile.setUsed(convertFileSize(used));
                sysFile.setUsage(Arith.round(
                    Arith.mul(used, 100.0 / total), 2
                ) + "%");
                
                sysFiles.add(sysFile);
            }
        }
    }
    
    /**
     * 文件大小转换
     */
    private String convertFileSize(long size) {
        long gb = 1024 * 1024 * 1024;
        long mb = 1024 * 1024;
        long kb = 1024;
        
        if (size >= gb) {
            return String.format("%.2f GB", (float) size / gb);
        } else if (size >= mb) {
            return String.format("%.2f MB", (float) size / mb);
        } else if (size >= kb) {
            return String.format("%.2f KB", (float) size / kb);
        } else {
            return size + " B";
        }
    }
    
    // Getters
    public Cpu getCpu() { return cpu; }
    public Mem getMem() { return mem; }
    public Jvm getJvm() { return jvm; }
    public Sys getSys() { return sys; }
    public List<SysFile> getSysFiles() { return sysFiles; }
}
```

---

## 2. Cpu - CPU 信息

**用途**: 存储 CPU 相关信息

**属性**:

```java
public class Cpu {
    /**
     * 核心数
     */
    private int cpuNum;
    
    /**
     * 总使用率
     */
    private double combined;
    
    /**
     * 用户使用率
     */
    private double user;
    
    /**
     * 系统使用率
     */
    private double sys;
    
    /**
     * 等待率
     */
    private double wait;
    
    /**
     * 空闲率
     */
    private double free;
    
    // Getters and Setters
}
```

**示例数据**:

```json
{
    "cpuNum": 8,
    "combined": 45.5,
    "user": 30.2,
    "sys": 10.3,
    "wait": 2.0,
    "free": 57.5
}
```

---

## 3. Jvm - JVM 信息

**用途**: 存储 Java 虚拟机相关信息

**属性**:

```java
public class Jvm {
    /**
     * 当前 JVM 占用的内存总数 (字节)
     */
    private long total;
    
    /**
     * 最大可用内存 (字节)
     */
    private long max;
    
    /**
     * 剩余可用内存 (字节)
     */
    private long free;
    
    /**
     * JVM 版本
     */
    private String version;
    
    /**
     * JVM 安装路径
     */
    private String home;
    
    /**
     * JVM 启动时间
     */
    private Date startTime;
    
    /**
     * JVM 已运行时间 (秒)
     */
    private long runTime;
    
    /**
     * 线程数
     */
    private int threadCount;
    
    /**
     * 已加载类数量
     */
    private int classCount;
    
    /**
     * 垃圾回收器信息
     */
    private String gcInfo;
    
    /**
     * 内存使用率
     */
    private double usage;
    
    // Getters and Setters
}
```

**示例数据**:

```json
{
    "total": 2147483648,
    "max": 4294967296,
    "free": 1073741824,
    "version": "17.0.1",
    "home": "/usr/lib/jvm/java-17",
    "startTime": "2024-01-01 10:00:00",
    "runTime": 86400,
    "threadCount": 50,
    "classCount": 10000,
    "gcInfo": "G1 Young Generation, G1 Old Generation",
    "usage": 50.0
}
```

---

## 4. Mem - 内存信息

**用途**: 存储系统物理内存信息

**属性**:

```java
public class Mem {
    /**
     * 内存总量 (字节)
     */
    private long total;
    
    /**
     * 已用内存 (字节)
     */
    private long used;
    
    /**
     * 剩余内存 (字节)
     */
    private long free;
    
    /**
     * 内存使用率
     */
    private double usage;
    
    // Getters and Setters
}
```

**示例数据**:

```json
{
    "total": 17179869184,
    "used": 8589934592,
    "free": 8589934592,
    "usage": 50.0
}
```

---

## 5. Sys - 系统信息

**用途**: 存储操作系统相关信息

**属性**:

```java
public class Sys {
    /**
     * 计算机名
     */
    private String computerName;
    
    /**
     * 计算机 IP
     */
    private String computerIp;
    
    /**
     * 操作系统名称
     */
    private String osName;
    
    /**
     * 操作系统架构
     */
    private String osArch;
    
    /**
     * 系统负载平均值
     */
    private double sysLoadAverage;
    
    // Getters and Setters
}
```

**示例数据**:

```json
{
    "computerName": "server-01",
    "computerIp": "192.168.1.100",
    "osName": "Linux",
    "osArch": "amd64",
    "sysLoadAverage": 1.5
}
```

---

## 6. SysFile - 文件系统信息

**用途**: 存储磁盘分区信息

**属性**:

```java
public class SysFile {
    /**
     * 盘符路径
     */
    private String dirName;
    
    /**
     * 文件系统类型
     */
    private String sysTypeName;
    
    /**
     * 文件系统类型名称
     */
    private String typeName;
    
    /**
     * 总大小
     */
    private String total;
    
    /**
     * 剩余大小
     */
    private String free;
    
    /**
     * 已用大小
     */
    private String used;
    
    /**
     * 已用百分比
     */
    private String usage;
    
    // Getters and Setters
}
```

**示例数据**:

```json
{
    "dirName": "/",
    "sysTypeName": "ext4",
    "typeName": "local",
    "total": "500.00 GB",
    "free": "250.00 GB",
    "used": "250.00 GB",
    "usage": "50.00%"
}
```

---

## Controller 使用示例

```java
@RestController
@RequestMapping("/monitor/server")
public class ServerController {
    
    @Autowired
    private Server server;
    
    /**
     * 获取服务器信息
     */
    @PreAuthorize("@ss.hasPermi('monitor:server:list')")
    @GetMapping()
    public AjaxResult getInfo() throws Exception {
        // 刷新服务器信息
        server.copyTo();
        return AjaxResult.success(server);
    }
}
```

**响应示例**:

```json
{
    "code": 200,
    "msg": "操作成功",
    "data": {
        "cpu": {
            "cpuNum": 8,
            "combined": 45.5,
            "user": 30.2,
            "sys": 10.3,
            "wait": 2.0,
            "free": 57.5
        },
        "mem": {
            "total": 17179869184,
            "used": 8589934592,
            "free": 8589934592,
            "usage": 50.0
        },
        "jvm": {
            "total": 2147483648,
            "max": 4294967296,
            "free": 1073741824,
            "version": "17.0.1",
            "home": "/usr/lib/jvm/java-17",
            "startTime": "2024-01-01T10:00:00.000+00:00",
            "runTime": 86400,
            "threadCount": 50,
            "classCount": 10000,
            "gcInfo": "G1 Young Generation, G1 Old Generation",
            "usage": 50.0
        },
        "sys": {
            "computerName": "server-01",
            "computerIp": "192.168.1.100",
            "osName": "Linux",
            "osArch": "amd64",
            "sysLoadAverage": 1.5
        },
        "sysFiles": [
            {
                "dirName": "/",
                "sysTypeName": "ext4",
                "typeName": "local",
                "total": "500.00 GB",
                "free": "250.00 GB",
                "used": "250.00 GB",
                "usage": "50.00%"
            }
        ]
    }
}
```

---

## OSHI 工具类

**获取硬件信息的工具方法**:

```java
public class ServerInfoUtil {
    
    private static final SystemInfo SYSTEM_INFO = new SystemInfo();
    
    /**
     * 获取 CPU 信息
     */
    public static CentralProcessor getProcessor() {
        return SYSTEM_INFO.getHardware().getProcessor();
    }
    
    /**
     * 获取内存信息
     */
    public static GlobalMemory getMemory() {
        return SYSTEM_INFO.getHardware().getMemory();
    }
    
    /**
     * 获取操作系统信息
     */
    public static OperatingSystem getOperatingSystem() {
        return SYSTEM_INFO.getOperatingSystem();
    }
    
    /**
     * 获取文件系统信息
     */
    public static FileSystem getFileSystem() {
        return SYSTEM_INFO.getHardware().getFileSystem();
    }
    
    /**
     * 获取主机名
     */
    public static String getHostName() {
        return SYSTEM_INFO.getHardware().getComputerSystem().toNetIFaces().stream()
            .findFirst()
            .map(NetworkIF::getName)
            .orElse("unknown");
    }
}
```

---

## 监控指标说明

### CPU 指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| cpuNum | CPU 核心数 | - |
| combined | 总使用率 | < 80% |
| user | 用户使用率 | - |
| sys | 系统使用率 | - |
| wait | IO 等待率 | < 20% |
| free | 空闲率 | > 20% |

### 内存指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| total | 总内存 | - |
| used | 已用内存 | - |
| free | 剩余内存 | > 20% |
| usage | 使用率 | < 80% |

### JVM 指标

| 指标 | 说明 | 正常范围 |
|------|------|----------|
| total | 当前堆内存 | - |
| max | 最大堆内存 | - |
| free | 剩余堆内存 | - |
| usage | 堆内存使用率 | < 80% |
| threadCount | 线程数 | < 500 |
| runTime | 运行时间 | - |

---

## 最佳实践

1. **监控频率**: 建议每秒采集一次 CPU 使用率，取平均值
2. **告警阈值**: CPU/内存使用率超过 80% 触发告警
3. **日志记录**: 定期记录 JVM 运行状态，便于问题排查
4. **磁盘监控**: 磁盘使用率超过 90% 触发紧急告警
5. **趋势分析**: 收集历史数据，分析资源使用趋势

---

## 常见问题

### Q1: CPU 使用率为什么需要等待 1 秒？
**A**: OSHI 需要两次采样计算差值，第一次获取基准值，等待 1 秒后获取第二次值，差值即为该时间段的使用率。

### Q2: JVM 内存使用率和系统内存使用率的区别？
**A**: JVM 内存使用率是 Java 堆内存的使用情况，系统内存使用率是物理内存的使用情况。

### Q3: 为什么磁盘有多个分区信息？
**A**: SysFile 列表包含所有本地磁盘分区的信息，包括系统分区、数据分区等。

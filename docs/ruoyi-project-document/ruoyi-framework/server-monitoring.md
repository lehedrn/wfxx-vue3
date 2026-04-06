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
    private List<SysFile> sysFiles = new LinkedList<SysFile>();
    
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
     * 设置 CPU 信息（私有方法）
     */
    private void setCpuInfo(CentralProcessor processor) {
        // 等待 1 秒获取准确的 CPU 使用率
        long[] prevTicks = processor.getSystemCpuLoadTicks();
        Util.sleep(OSHI_WAIT_SECOND);
        long[] ticks = processor.getSystemCpuLoadTicks();
        
        // 计算各个状态的 CPU 时间
        long nice = ticks[TickType.NICE.getIndex()] - prevTicks[TickType.NICE.getIndex()];
        long irq = ticks[TickType.IRQ.getIndex()] - prevTicks[TickType.IRQ.getIndex()];
        long softirq = ticks[TickType.SOFTIRQ.getIndex()] - prevTicks[TickType.SOFTIRQ.getIndex()];
        long steal = ticks[TickType.STEAL.getIndex()] - prevTicks[TickType.STEAL.getIndex()];
        long cSys = ticks[TickType.SYSTEM.getIndex()] - prevTicks[TickType.SYSTEM.getIndex()];
        long user = ticks[TickType.USER.getIndex()] - prevTicks[TickType.USER.getIndex()];
        long iowait = ticks[TickType.IOWAIT.getIndex()] - prevTicks[TickType.IOWAIT.getIndex()];
        long idle = ticks[TickType.IDLE.getIndex()] - prevTicks[TickType.IDLE.getIndex()];
        
        long totalCpu = user + nice + cSys + idle + iowait + irq + softirq + steal;
        
        cpu.setCpuNum(processor.getLogicalProcessorCount());
        cpu.setTotal(totalCpu);
        cpu.setSys(cSys);
        cpu.setUsed(user);
        cpu.setWait(iowait);
        cpu.setFree(idle);
    }
    
    /**
     * 设置内存信息（私有方法）
     */
    private void setMemInfo(GlobalMemory memory) {
        mem.setTotal(memory.getTotal());
        mem.setUsed(memory.getTotal() - memory.getAvailable());
        mem.setFree(memory.getAvailable());
    }
    
    /**
     * 设置系统信息（私有方法）
     */
    private void setSysInfo() {
        Properties props = System.getProperties();
        sys.setComputerName(IpUtils.getHostName());
        sys.setComputerIp(IpUtils.getHostIp());
        sys.setOsName(props.getProperty("os.name"));
        sys.setOsArch(props.getProperty("os.arch"));
        sys.setUserDir(props.getProperty("user.dir"));
    }
    
    /**
     * 设置 JVM 信息（私有方法）
     */
    private void setJvmInfo() throws UnknownHostException {
        Properties props = System.getProperties();
        jvm.setTotal(Runtime.getRuntime().totalMemory());
        jvm.setMax(Runtime.getRuntime().maxMemory());
        jvm.setFree(Runtime.getRuntime().freeMemory());
        jvm.setVersion(props.getProperty("java.version"));
        jvm.setHome(props.getProperty("java.home"));
    }
    
    /**
     * 设置文件系统信息（私有方法）
     */
    private void setSysFiles(OperatingSystem os) {
        FileSystem fileSystem = os.getFileSystem();
        List<OSFileStore> fsArray = fileSystem.getFileStores();
        
        for (OSFileStore fs : fsArray) {
            long free = fs.getUsableSpace();
            long total = fs.getTotalSpace();
            long used = total - free;
            
            SysFile sysFile = new SysFile();
            sysFile.setDirName(fs.getMount());
            sysFile.setSysTypeName(fs.getType());
            sysFile.setTypeName(fs.getName());
            sysFile.setTotal(convertFileSize(total));
            sysFile.setFree(convertFileSize(free));
            sysFile.setUsed(convertFileSize(used));
            sysFile.setUsage(Arith.mul(Arith.div(used, total, 4), 100));
            sysFiles.add(sysFile);
        }
    }
    
    /**
     * 字节转换（公开方法）
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
    
    // Getters and Setters
    public Cpu getCpu() { return cpu; }
    public void setCpu(Cpu cpu) { this.cpu = cpu; }
    public Mem getMem() { return mem; }
    public void setMem(Mem mem) { this.mem = mem; }
    public Jvm getJvm() { return jvm; }
    public void setJvm(Jvm jvm) { this.jvm = jvm; }
    public Sys getSys() { return sys; }
    public void setSys(Sys sys) { this.sys = sys; }
    public List<SysFile> getSysFiles() { return sysFiles; }
    public void setSysFiles(List<SysFile> sysFiles) { this.sysFiles = sysFiles; }
}
```

**使用示例**:

```java
// Controller 层使用
@RestController
@RequestMapping("/monitor/server")
public class ServerController {
    
    @PreAuthorize("@ss.hasPermi('monitor:server:list')")
    @GetMapping()
    public AjaxResult getInfo() throws Exception {
        Server server = new Server();
        server.copyTo();  // 填充所有信息
        
        Map<String, Object> result = new HashMap<>();
        result.put("cpuInfo", server.getCpu());
        result.put("memInfo", server.getMem());
        result.put("jvmInfo", server.getJvm());
        result.put("sysInfo", server.getSys());
        result.put("sysFiles", server.getSysFiles());
        
        return AjaxResult.success(result);
    }
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
     * CPU 总的使用率（未格式化，getter 会格式化为百分比）
     */
    private double total;
    
    /**
     * CPU 系统使用率（未格式化，getter 会格式化为百分比）
     */
    private double sys;
    
    /**
     * CPU 用户使用率（未格式化，getter 会格式化为百分比）
     */
    private double used;
    
    /**
     * CPU 当前等待率（未格式化，getter 会格式化为百分比）
     */
    private double wait;
    
    /**
     * CPU 当前空闲率（未格式化，getter 会格式化为百分比）
     */
    private double free;
    
    // Getters and Setters
    
    /**
     * 获取系统使用率（百分比）
     */
    public double getSys() {
        return Arith.round(Arith.mul(sys / total, 100), 2);
    }
    
    /**
     * 获取用户使用率（百分比）
     */
    public double getUsed() {
        return Arith.round(Arith.mul(used / total, 100), 2);
    }
    
    /**
     * 获取等待率（百分比）
     */
    public double getWait() {
        return Arith.round(Arith.mul(wait / total, 100), 2);
    }
    
    /**
     * 获取空闲率（百分比）
     */
    public double getFree() {
        return Arith.round(Arith.mul(free / total, 100), 2);
    }
}
```

**示例数据**:

```json
{
    "cpuNum": 8,
    "total": 100.0,
    "sys": 15.5,
    "used": 35.2,
    "wait": 2.0,
    "free": 47.3
}
```

**注意**: 
- `total` 字段存储总的 CPU 时间片数，不是百分比
- `sys`、`used`、`wait`、`free` 字段存储原始时间片数
- Getter 方法会自动计算百分比（除以 total 并乘以 100）
- 所有百分比保留 2 位小数

---

## 3. Jvm - JVM 信息

**用途**: 存储 Java 虚拟机相关信息

**属性**:

```java
public class Jvm {
    /**
     * 当前 JVM 占用的内存总数 (字节，setter 会存储原始值，getter 返回 MB)
     */
    private double total;
    
    /**
     * JVM 最大可用内存 (字节，setter 会存储原始值，getter 返回 MB)
     */
    private double max;
    
    /**
     * JVM 空闲内存 (字节，setter 会存储原始值，getter 返回 MB)
     */
    private double free;
    
    /**
     * JDK 版本
     */
    private String version;
    
    /**
     * JDK 安装路径
     */
    private String home;
    
    // Getters and Setters
    
    /**
     * 获取总内存（MB）
     * 自动将字节转换为 MB，保留 2 位小数
     */
    public double getTotal() {
        return Arith.div(total, (1024 * 1024), 2);
    }
    
    /**
     * 获取最大内存（MB）
     */
    public double getMax() {
        return Arith.div(max, (1024 * 1024), 2);
    }
    
    /**
     * 获取空闲内存（MB）
     */
    public double getFree() {
        return Arith.div(free, (1024 * 1024), 2);
    }
    
    /**
     * 获取已用内存（MB）
     */
    public double getUsed() {
        return Arith.div(total - free, (1024 * 1024), 2);
    }
    
    /**
     * 获取内存使用率（百分比）
     */
    public double getUsage() {
        return Arith.mul(Arith.div(total - free, total, 4), 100);
    }
    
    /**
     * 获取 JDK 名称
     */
    public String getName() {
        return ManagementFactory.getRuntimeMXBean().getVmName();
    }
    
    /**
     * 获取 JDK 启动时间（格式化后的字符串）
     */
    public String getStartTime() {
        return DateUtils.parseDateToStr(
            DateUtils.YYYY_MM_DD_HH_MM_SS, 
            DateUtils.getServerStartDate()
        );
    }
    
    /**
     * 获取 JDK 运行时间（格式化后的字符串）
     */
    public String getRunTime() {
        return DateUtils.timeDistance(
            DateUtils.getNowDate(), 
            DateUtils.getServerStartDate()
        );
    }
    
    /**
     * 获取运行参数
     */
    public String getInputArgs() {
        return ManagementFactory.getRuntimeMXBean().getInputArguments().toString();
    }
}
```

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
    "runTime": "1 天 2 小时 30 分钟",
    "inputArgs": "[-Xms512m, -Xmx4g]"
}
```

**注意**: 
- `total`、`max`、`free` 字段存储原始字节值
- Getter 方法会自动转换为 MB（除以 1024*1024）并保留 2 位小数
- `startTime` 和 `runTime` 是格式化后的字符串，不是 Date 和 long
- 没有 `threadCount`、`classCount`、`gcInfo`、`usage` 属性（usage 是方法不是属性）

---

## 4. Mem - 内存信息

**用途**: 存储系统物理内存信息

**属性**:

```java
public class Mem {
    /**
     * 内存总量 (字节，setter 接收 long，getter 返回 GB)
     */
    private double total;
    
    /**
     * 已用内存 (字节，setter 接收 long，getter 返回 GB)
     */
    private double used;
    
    /**
     * 剩余内存 (字节，setter 接收 long，getter 返回 GB)
     */
    private double free;
    
    // Getters and Setters
    
    /**
     * 获取总内存（GB）
     * 自动将字节转换为 GB，保留 2 位小数
     */
    public double getTotal() {
        return Arith.div(total, (1024 * 1024 * 1024), 2);
    }
    
    /**
     * 获取已用内存（GB）
     */
    public double getUsed() {
        return Arith.div(used, (1024 * 1024 * 1024), 2);
    }
    
    /**
     * 获取空闲内存（GB）
     */
    public double getFree() {
        return Arith.div(free, (1024 * 1024 * 1024), 2);
    }
    
    /**
     * 获取内存使用率（百分比）
     */
    public double getUsage() {
        return Arith.mul(Arith.div(used, total, 4), 100);
    }
}
```

**示例数据**:

```json
{
    "total": 16.0,
    "used": 8.5,
    "free": 7.5,
    "usage": 53.13
}
```

**注意**: 
- `total`、`used`、`free` 字段存储原始字节值（long）
- Getter 方法会自动转换为 GB（除以 1024*1024*1024）并保留 2 位小数
- `usage` 是方法不是属性

---

## 5. Sys - 系统信息

**用途**: 存储操作系统相关信息

**属性**:

```java
public class Sys {
    /**
     * 服务器名称
     */
    private String computerName;
    
    /**
     * 服务器 IP
     */
    private String computerIp;
    
    /**
     * 项目路径
     */
    private String userDir;
    
    /**
     * 操作系统名称
     */
    private String osName;
    
    /**
     * 操作系统架构
     */
    private String osArch;
    
    // Getters and Setters
}
```

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

**注意**: 
- 没有 `sysLoadAverage` 属性
- `userDir` 是项目路径，不是用户目录

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
     * 盘符类型（文件系统类型）
     */
    private String sysTypeName;
    
    /**
     * 文件类型
     */
    private String typeName;
    
    /**
     * 总大小（格式化后的字符串，如 "500.0 GB"）
     */
    private String total;
    
    /**
     * 剩余大小（格式化后的字符串）
     */
    private String free;
    
    /**
     * 已经使用量（格式化后的字符串）
     */
    private String used;
    
    /**
     * 资源的使用率（百分比，如 50.0）
     */
    private double usage;
    
    // Getters and Setters
}
```

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

**注意**: 
- `total`、`free`、`used` 是格式化后的字符串（如 "500.0 GB"）
- `usage` 是 double 类型的百分比数值，不是字符串
- 数据由 `OSFileStore` 获取，不是 `FileStatus`

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

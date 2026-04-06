# Claude Code + RuoYi-Vue 开发实践指南

> 基于 RuoYi-Vue 3.9.2 + Spring Boot 4.0.3 + Vue 3.5.26 + Vite 6.4.1

## 一、项目概述

### 1.1 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端框架 | Spring Boot | 4.0.3 |
| 后端 JDK | JDK | 17+ |
| 持久层 | MyBatis | 4.0.1 |
| 数据库连接池 | Druid | 1.2.28 |
| 数据库 | MySQL | 5.7+ |
| 缓存 | Redis | - |
| 权限认证 | Spring Security + JWT | 0.9.1 |
| 前端框架 | Vue | 3.5.26 |
| UI 组件库 | Element Plus | 2.13.1 |
| 构建工具 | Vite | 6.4.1 |
| 包管理器 | pnpm | - |
| 状态管理 | Pinia | 3.0.4 |
| 路由管理 | Vue Router | 4.6.4 |

### 1.2 项目结构

```
com/wfxx-vue3/
├── ruoyi-admin/          # 入口服务模块
├── ruoyi-common/         # 通用工具模块
├── ruoyi-framework/      # 框架配置模块
├── ruoyi-system/         # 系统业务模块
├── ruoyi-quartz/         # 定时任务模块
├── ruoyi-generator/      # 代码生成器模块
├── ruoyi-gen-cli/        # 命令行生成工具
├── ruoyi-demo/           # 示例模块
└── ruoyi-ui/             # 前端项目
```

### 1.3 模块依赖关系

```
ruoyi-admin (主启动模块)
├── ruoyi-framework
│   ├── ruoyi-system
│   └── ruoyi-common
├── ruoyi-quartz
├── ruoyi-generator
└── ruoyi-demo
```

## 二、环境配置

### 2.1 开发环境要求

- **JDK**: 17+
- **MySQL**: 5.7+
- **Redis**: 最新稳定版
- **Node.js**: 18+ (推荐 20+)
- **pnpm**: 8+

### 2.2 后端配置

#### 2.2.1 数据库配置 (`ruoyi-admin/src/main/resources/application-druid.yml`)

```yaml
spring:
  datasource:
    druid:
      master:
        url: jdbc:mysql://localhost:3306/ry-vue?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8
        username: root
        password: your_password
```

#### 2.2.2 Redis 配置 (`ruoyi-admin/src/main/resources/application.yml`)

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: your_redis_password
      database: 0
```

#### 2.2.3 服务端口配置

- 后端服务端口：`18080`
- 前端开发端口：`3888`

### 2.3 前端配置

#### 2.3.1 开发环境配置 (`ruoyi-ui/.env.development`)

```bash
VITE_APP_TITLE = 若依管理系统
VITE_APP_ENV = 'development'
VITE_APP_BASE_API = '/dev-api'
```

#### 2.3.2 代理配置 (`ruoyi-ui/vite.config.js`)

```javascript
proxy: {
  '/dev-api': {
    target: 'http://localhost:18080',
    changeOrigin: true,
    rewrite: (p) => p.replace(/^\/dev-api/, '')
  }
}
```

## 三、快速启动

### 3.1 后端启动

```bash
# 1. 导入 SQL 脚本到 MySQL (ry-vue 数据库)
# 2. 启动 Redis
# 3. 修改数据库和 Redis 配置
# 4. Maven 构建
mvn clean install

# 5. 启动服务
cd ruoyi-admin
mvn spring-boot:run

# 或直接运行 RuoYiApplication.java
```

### 3.2 前端启动

```bash
# 1. 进入前端目录
cd ruoyi-ui

# 2. 安装依赖
pnpm install

# 3. 启动开发服务
pnpm dev

# 4. 访问 http://localhost:3888
```

### 3.3 默认登录信息

- 用户名：`admin`
- 密码：`admin123`

## 四、核心架构

### 4.1 后端核心组件

#### 4.1.1 通用模块 (ruoyi-common)

| 包名 | 说明 |
|------|------|
| `annotation` | 自定义注解（@Log、@DataScope、@Excel 等） |
| `constant` | 常量定义（CacheConstants、UserConstants 等） |
| `core/controller` | BaseController（所有 Controller 基类） |
| `core/domain` | 基础实体（BaseEntity、AjaxResult、R 等） |
| `core/page` | 分页支持（PageDomain、TableDataInfo） |
| `enums` | 枚举类（BusinessType、OperatorType 等） |
| `exception` | 异常体系（GlobalException、ServiceException） |
| `filter` | 过滤器链（XSS 过滤、重复读取等） |
| `utils` | 工具类（ServletUtils、StringUtils、DateUtils 等） |

#### 4.1.2 核心实体

```java
// BaseEntity - 所有实体基类
public class BaseEntity implements Serializable {
    private Long id;
    private Date createTime;
    private Date updateTime;
    private String createBy;
    private String updateBy;
    private String remark;
    // 搜索条件
    private String params;
}

// AjaxResult - 统一返回结果
public class AjaxResult extends HashMap<String, Object> {
    public static AjaxResult success(String msg, Object data);
    public static AjaxResult error(String msg);
}
```

#### 4.1.3 Controller 规范

```java
@RestController
@RequestMapping("/module/entity")
public class EntityController extends BaseController {
    
    @Autowired
    private IEntityService entityService;
    
    // 查询列表
    @PreAuthorize("@ss.hasPermi('module:entity:list')")
    @GetMapping("/list")
    public TableDataInfo list(Entity entity) {
        startPage(); // 分页
        List<Entity> list = entityService.selectList(entity);
        return getDataTable(list);
    }
    
    // 新增
    @PreAuthorize("@ss.hasPermi('module:entity:add')")
    @Log(title = "实体管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Entity entity) {
        return toAjax(entityService.insertEntity(entity));
    }
    
    // 修改
    @PreAuthorize("@ss.hasPermi('module:entity:edit')")
    @Log(title = "实体管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Entity entity) {
        return toAjax(entityService.updateEntity(entity));
    }
    
    // 删除
    @PreAuthorize("@ss.hasPermi('module:entity:remove')")
    @Log(title = "实体管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids) {
        return toAjax(entityService.deleteEntityByIds(ids));
    }
}
```

### 4.2 前端核心组件

#### 4.2.1 全局组件

| 组件名 | 路径 | 说明 |
|--------|------|------|
| Pagination | `@/components/Pagination` | 分页组件 |
| RightToolbar | `@/components/RightToolbar` | 右侧工具栏 |
| Editor | `@/components/Editor` | 富文本编辑器 |
| FileUpload | `@/components/FileUpload` | 文件上传 |
| ImageUpload | `@/components/ImageUpload` | 图片上传 |
| DictTag | `@/components/DictTag` | 字典标签 |

#### 4.2.2 全局方法

```javascript
// main.js 中挂载
app.config.globalProperties.useDict = useDict     // 字典加载
app.config.globalProperties.download = download    // 文件下载
app.config.globalProperties.parseTime = parseTime  // 时间格式化
app.config.globalProperties.resetForm = resetForm  // 表单重置
app.config.globalProperties.selectDictLabel = selectDictLabel // 字典翻译
```

#### 4.2.3 Vue 页面模板

```vue
<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入名称" clearable/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">搜索</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="ID" prop="id"/>
      <el-table-column label="名称" prop="name"/>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button type="primary" link @click="handleUpdate(scope.row)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <Pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList"/>

    <!-- 新增/编辑对话框 -->
    <el-dialog :title="title" v-model="open" width="500px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入名称"/>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancel">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Entity">
import { list, get, add, update, remove } from '@/api/module/entity'

const { proxy } = getCurrentInstance()

const dataList = ref([])
const open = ref(false)
const title = ref('')
const total = ref(0)
const loading = ref(true)
const multiple = ref(true)
const ids = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null
})

const form = ref({})
const rules = {
  name: [{ required: true, message: '名称不能为空', trigger: 'blur' }]
}

// CRUD 操作
function getList() {
  loading.value = true
  list(queryParams).then(res => {
    dataList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新增'
}

function handleUpdate(row) {
  reset()
  get(row.id).then(res => {
    form.value = res.data
    open.value = true
    title.value = '编辑'
  })
}

function submitForm() {
  proxy.$refs.formRef.validate(valid => {
    if (valid) {
      form.value.id ? update(form.value) : add(form.value).then(() => {
        proxy.$modal.msgSuccess('操作成功')
        open.value = false
        getList()
      })
    }
  })
}

function handleDelete(row) {
  const ids = Array.isArray(row) ? row.map(r => r.id) : [row.id]
  proxy.$modal.confirm('确认删除？').then(() => remove(ids)).then(() => {
    proxy.$modal.msgSuccess('删除成功')
    getList()
  })
}

function reset() {
  form.value = {}
  proxy.resetForm('formRef')
}

onMounted(() => getList())
</script>
```

## 五、代码生成器

### 5.1 使用步骤

1. **导入数据库表**
   - 访问：系统工具 -> 代码生成
   - 点击"导入"按钮，选择数据库中的表

2. **配置生成信息**
   - 基本信息：生成包名、作者、模块名
   - 字段信息：编辑字段类型、字典类型、显示规则
   - 生成配置：选择模板、父菜单、是否 CRUD

3. **预览与下载**
   - 预览生成的代码
   - 下载 ZIP 包

4. **集成到项目**
   - 解压到对应模块
   - 执行 SQL 脚本（如有）
   - 重启服务
   - 刷新菜单权限

### 5.2 生成文件清单

```
模块/
├── controller/     # Controller 层
├── domain/         # 实体类
├── mapper/         # Mapper 接口
├── service/        # Service 接口
├── service/impl/   # Service 实现
└── resources/
    └── mapper/     # MyBatis XML 映射文件
```

### 5.3 前端生成

```
views/模块/
├── index.vue       # 主页面
├── xxDialog.vue   # 弹窗组件（可选）
└── xxDetail.vue   # 详情组件（可选）

api/模块/
└── xx.js           # API 调用
```

## 六、常见开发任务

### 6.1 新增业务模块

**后端流程：**

1. 设计数据库表
2. 使用代码生成器生成基础代码
3. 在 `ruoyi-demo` 或新模块中放置代码
4. 根据需要修改业务逻辑

**前端流程：**

1. 在 `ruoyi-ui/src/views` 创建模块目录
2. 创建页面组件
3. 在 `ruoyi-ui/src/api` 创建 API 文件
4. 配置路由（菜单管理中添加）

### 6.2 添加数据字典

1. 系统管理 -> 字典管理 -> 新增字典类型
2. 添加字典数据项
3. 前端使用 `DictTag` 组件或 `useDict` hook

```vue
<!-- 字典标签 -->
<DictTag :options="dict.type" :value="row.status"/>

<!-- 字典下拉框 -->
<el-select v-model="form.status" placeholder="请选择状态">
  <el-option
    v-for="dict in sys_normal_disable"
    :key="dict.value"
    :label="dict.label"
    :value="dict.value"
  />
</el-select>

<script setup>
const { sys_normal_disable } = proxy.useDict('sys_normal_disable')
</script>
```

### 6.3 配置菜单权限

1. 系统管理 -> 菜单管理 -> 新增菜单
2. 填写路由信息、组件路径、权限标识
3. 角色管理 -> 分配菜单权限

## 七、开发规范

### 7.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 包名 | 小写，复数 | `com.ruoyi.demo.controller` |
| 类名 | 大驼峰 | `StudentController` |
| 方法名 | 小驼峰 | `selectStudentList` |
| 变量名 | 小驼峰 | `studentList` |
| 常量名 | 全大写 + 下划线 | `USER_STATUS_NORMAL` |
| 前端组件 | 大驼峰 | `StudentList.vue` |
| API 方法 | 小驼峰 | `listStudent` |

### 7.2 注解使用

```java
// 操作日志注解
@Log(title = "学生管理", businessType = BusinessType.INSERT)

// 数据权限注解
@DataScope(deptAlias = "d", userAlias = "u")

// Excel 导出注解
@Excel(name = "学生名称", readConverterExp = "1=钓鱼，2=写作")

// 防重复提交注解
@RepeatSubmit(interval = 5, message = "请勿重复提交")

// 限流注解
@RateLimiter(time = 60, count = 10)
```

### 7.3 异常处理

```java
// 业务异常
throw new ServiceException("业务提示信息");

// 全局异常
throw new GlobalException("全局异常信息");

// Controller 统一处理
try {
    // 业务逻辑
} catch (Exception e) {
    return AjaxResult.error("操作失败");
}
```

## 八、调试技巧

### 8.1 后端调试

- 日志级别配置：`application.yml` 中设置 `logging.level.com.ruoyi: debug`
- 慢 SQL 监控：访问 `/druid` (需配置白名单)
- API 文档：访问 `/swagger-ui.html`

### 8.2 前端调试

- 开发服务器：`pnpm dev` (端口 3888)
- 网络请求：浏览器开发者工具 -> Network
- 状态调试：Vue DevTools 插件

## 九、部署配置

### 9.1 后端打包

```bash
mvn clean package
# 生成 ruoyi-admin/target/ruoyi-admin.jar
# 启动：java -jar ruoyi-admin.jar
```

### 9.2 前端打包

```bash
cd ruoyi-ui
pnpm build:prod
# 生成 dist/ 目录，部署到 Nginx
```

### 9.3 Nginx 配置示例

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        root /path/to/ruoyi-ui/dist;
        try_files $uri $uri/ /index.html;
    }
    
    location /prod-api {
        proxy_pass http://localhost:18080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 十、问题排查

### 10.1 常见问题

| 问题 | 解决方案 |
|------|----------|
| 登录 401 | 检查 Redis 是否启动、JWT 配置 |
| 页面 403 | 检查菜单权限配置 |
| 接口 404 | 检查请求路径、跨域配置 |
| 数据库连接失败 | 检查 MySQL 服务、连接配置 |
| 前端样式不生效 | 清除缓存、重新编译 |

## 附录

- 官方文档：https://doc.ruoyi.vip/ruoyi-vue/
- 演示地址：http://vue.ruoyi.vip
- 项目版本：RuoYi 3.9.2
- 本文档版本：v1.0 (2026-04-06)

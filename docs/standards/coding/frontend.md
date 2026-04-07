# 前端编码规范

本文档基于 RuoYi-Vue 3.9.2 项目的实际编码风格制定，适用于 Vue 3 前端开发。

---

## 1. 项目结构规范

### 1.1 目录结构

```
ruoyi-ui/
├── src/
│   ├── api/              # API 接口封装
│   │   ├── system/       # 系统模块
│   │   ├── demo/         # 示例模块
│   │   └── monitor/      # 监控模块
│   ├── components/       # 通用组件（22+ 个）
│   ├── directive/        # 自定义指令
│   ├── layout/           # 布局组件
│   ├── store/            # 状态管理 (Pinia)
│   │   └── modules/      # 模块 stores
│   ├── utils/            # 工具函数
│   ├── views/            # 页面组件
│   │   ├── system/       # 系统管理页面
│   │   ├── demo/         # 示例页面
│   │   └── monitor/      # 监控页面
│   ├── App.vue           # 根组件
│   └── main.js           # 应用入口
```

### 1.2 页面组件结构

```
views/system/user/
└── index.vue      # 主页面（列表 + 增删改查）
```

---

## 2. 命名规范

### 2.1 文件命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 页面组件 | `camelCase` | `index.vue`, `detail.vue` |
| API 文件 | `camelCase` | `user.js`, `customer.js` |
| 通用组件 | `PascalCase` | `TreePanel.vue`, `RightToolbar.vue` |

```bash
# 正确
src/views/system/user/index.vue
src/api/system/user.js
src/components/TreePanel.vue

# 错误
src/views/system/User/index.vue
src/api/system/User.js
src/components/treePanel.vue
```

### 2.2 组件命名

- 使用 **PascalCase**
- 在 `<script setup>` 中使用 `name` 属性

```vue
<script setup name="User">
// 组件逻辑
</script>
```

### 2.3 变量命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 列表数据 | 名词 + List | `userList`, `customerList` |
| 查询参数 | `queryParams` | `queryParams` |
| 表单数据 | `form` | `form` |
| 校验规则 | `rules` | `rules` |
| 加载状态 | `loading` | `loading` |
| 对话框开关 | `open` | `open` |
| 搜索显示 | `showSearch` | `showSearch` |
| 选中 IDs | `ids` | `ids` |
| 总数 | `total` | `total` |
| 标题 | `title` | `title` |

```javascript
// 正确 - 符合项目规范
const userList = ref([])
const queryParams = ref({ pageNum: 1, pageSize: 10 })
const form = ref({})
const rules = ref({ userName: [{ required: true }] })
const loading = ref(true)
const open = ref(false)
const showSearch = ref(true)
const ids = ref([])
const total = ref(0)
const title = ref("")

// 错误 - 不符合项目规范
const users = ref([])
const query = ref({})
const formData = ref({})
const isLoading = ref(true)
const isDialogOpen = ref(false)
```

### 2.4 函数命名

| 操作 | 命名前缀 | 示例 |
|------|---------|------|
| 查询列表 | `get` / `list` | `getList`, `listUser` |
| 查询单个 | `get` | `getUser`, `getDeptTree` |
| 新增 | `add` | `handleAdd`, `addUser` |
| 修改 | `update` | `handleUpdate`, `updateUser` |
| 删除 | `delete` | `handleDelete`, `delUser` |
| 搜索 | `handle` + 动作 | `handleQuery`, `handleSelectionChange` |
| 重置 | `reset` | `resetQuery`, `resetForm` |

```javascript
// 列表查询
function getList() {
  loading.value = true
  listUser(queryParams.value).then(res => {
    userList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

// 搜索/重置
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

// 新增/修改/删除
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加用户"
}

function handleUpdate(row) {
  reset()
  const userId = row.userId || ids.value
  getUser(userId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改用户"
  })
}

function handleDelete(row) {
  const userIds = row.userId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(function () {
    return delUser(userIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}
```

---

## 3. 代码格式规范

### 3.1 组件结构

```vue
<template>
  <div class="app-container">
    <!-- 查询表单 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <!-- 表单项 -->
    </el-form>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['system:user:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="list">
      <el-table-column prop="name" label="名称" />
    </el-table>

    <!-- 分页 -->
    <pagination v-show="total > 0" :total="total" v-model:page="pageNum" v-model:limit="pageSize" @pagination="getList" />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" v-model="open" width="600px">
      <el-form :model="form" :rules="rules" ref="formRef">
        <!-- 表单项 -->
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="ComponentName">
// 脚本内容
</script>

<style lang="scss" scoped>
/* 样式内容 */
</style>
```

### 3.2 缩进

- 使用 **2 个空格** 缩进

```vue
<template>
  <div class="container">
    <el-form :model="form">
      <el-form-item label="名称">
        <el-input v-model="form.name" />
      </el-form-item>
    </el-form>
  </div>
</template>
```

### 3.3 引号

- 字符串使用 **单引号**

```javascript
// 正确
const title = '添加用户'
const msg = `Hello, ${name}`

// 错误
const title = "添加用户"
```

### 3.4 响应式数据

- 使用 `ref` 和 `reactive`
- 优先使用 `ref`
- 使用 `toRefs` 解构

```vue
<script setup name="User">
import { ref, reactive, toRefs, getCurrentInstance } from 'vue'

const { proxy } = getCurrentInstance()

const userList = ref([])
const loading = ref(true)
const open = ref(false)

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10
  },
  rules: {
    userName: [{ required: true, message: "用户名称不能为空", trigger: "blur" }]
  }
})

const { queryParams, form, rules } = toRefs(data)
</script>
```

---

## 4. API 调用规范

### 4.1 API 文件结构

```javascript
// src/api/system/user.js
import request from '@/utils/request'

// 查询用户列表
export function listUser(query) {
  return request({
    url: '/system/user/list',
    method: 'get',
    params: query
  })
}

// 查询用户详细
export function getUser(userId) {
  return request({
    url: '/system/user/' + userId,
    method: 'get'
  })
}

// 新增用户
export function addUser(data) {
  return request({
    url: '/system/user',
    method: 'post',
    data: data
  })
}

// 修改用户
export function updateUser(data) {
  return request({
    url: '/system/user',
    method: 'put',
    data: data
  })
}

// 删除用户
export function delUser(userIds) {
  return request({
    url: '/system/user/' + userIds,
    method: 'delete'
  })
}
```

### 4.2 组件内 API 调用

```vue
<script setup name="User">
import { listUser, getUser, addUser, updateUser, delUser } from "@/api/system/user"

// 查询列表
function getList() {
  loading.value = true
  listUser(queryParams.value).then(res => {
    userList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

// 新增
function submitForm() {
  if (form.value.userId != undefined) {
    updateUser(form.value).then(() => {
      proxy.$modal.msgSuccess("修改成功")
      open.value = false
      getList()
    })
  } else {
    addUser(form.value).then(() => {
      proxy.$modal.msgSuccess("新增成功")
      open.value = false
      getList()
    })
  }
}
</script>
```

---

## 5. 状态管理

### 5.1 Pinia Store 使用

```vue
<script setup name="User">
import useAppStore from '@/store/modules/app'
import { useUserStore } from '@/store/modules/user'

const appStore = useAppStore()
const userStore = useUserStore()

// 获取用户信息
await userStore.getInfo()

// 登出
await userStore.logOut()
</script>
```

### 5.2 字典使用

```vue
<script setup name="User">
const { proxy } = getCurrentInstance()
const { sys_normal_disable, sys_user_sex } = proxy.useDict("sys_normal_disable", "sys_user_sex")
</script>

<template>
  <!-- 下拉框使用字典 -->
  <el-select v-model="form.sex" placeholder="请选择">
    <el-option v-for="dict in sys_user_sex" :key="dict.value" :label="dict.label" :value="dict.value" />
  </el-select>

  <!-- 表格列使用字典标签 -->
  <dict-tag :options="sys_user_sex" :value="scope.row.sex" />
</template>
```

---

## 6. 权限控制

### 6.1 按钮权限

```vue
<template>
  <!-- 使用 v-hasPermi 指令 -->
  <el-button v-hasPermi="['system:user:add']">新增</el-button>
  <el-button v-hasPermi="['system:user:edit']">修改</el-button>
  <el-button v-hasPermi="['system:user:remove']">删除</el-button>
</template>
```

### 6.2 角色权限

```vue
<template>
  <el-button v-hasRole="['admin']">管理</el-button>
</template>
```

---

## 7. 通用组件使用

### 7.1 分页组件

```vue
<template>
  <pagination
    v-show="total > 0"
    :total="total"
    v-model:page="queryParams.pageNum"
    v-model:limit="queryParams.pageSize"
    @pagination="getList"
  />
</template>
```

### 7.2 右侧工具栏

```vue
<template>
  <right-toolbar 
    v-model:showSearch="showSearch" 
    @queryTable="getList" 
    :columns="columns"
  />
</template>
```

### 7.3 树形面板

```vue
<template>
  <tree-panel 
    title="组织机构" 
    :tree-data="deptOptions" 
    @node-click="handleNodeClick" 
    @refresh="getDeptTree" 
  />
</template>
```

### 7.4 Excel 导入组件

```vue
<template>
  <excel-import-dialog 
    ref="importUserRef" 
    title="用户导入" 
    action="/system/user/importData"
    @success="getList" 
  />
</template>
```

---

## 8. 注释规范

### 8.1 函数注释

```javascript
/** 查询用户列表 */
function getList() {
  // ...
}

/** 搜索按钮操作 */
function handleQuery() {
  // ...
}

/** 重置按钮操作 */
function resetQuery() {
  // ...
}

/** 新增按钮操作 */
function handleAdd() {
  // ...
}

/** 修改按钮操作 */
function handleUpdate(row) {
  // ...
}

/** 删除按钮操作 */
function handleDelete(row) {
  // ...
}

/** 提交按钮 */
function submitForm() {
  // ...
}

/** 取消按钮 */
function cancel() {
  // ...
}
```

---

## 9. 最佳实践

### 9.1 表格列显隐控制

```vue
<script setup>
const columns = ref({
  userId: { label: '用户编号', visible: true },
  userName: { label: '用户名称', visible: true },
  nickName: { label: '用户昵称', visible: true }
})
</script>

<template>
  <el-table-column 
    label="用户名称" 
    key="userName" 
    prop="userName" 
    v-if="columns.userName.visible" 
  />
</template>
```

### 9.2 表格行选择

```javascript
// 多选框选中数据
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.userId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}
```

### 9.3 表单重置

```javascript
function reset() {
  form.value = {
    userId: undefined,
    userName: undefined,
    nickName: undefined
  }
  proxy.resetForm("userRef")
}
```

### 9.4 对话框取消

```javascript
function cancel() {
  open.value = false
  reset()
}
```

### 9.5 日期范围处理

```javascript
const dateRange = ref([])

// 查询时传入日期范围
listUser(proxy.addDateRange(queryParams.value, dateRange.value))
```

### 9.6 导出文件命名

```javascript
function handleExport() {
  proxy.download("system/user/export", {
    ...queryParams.value,
  }, `user_${new Date().getTime()}.xlsx`)
}
```

---

## 10. 目录结构示例

```
views/system/user/
└── index.vue              # 用户管理主页面

api/system/
└── user.js                # 用户管理 API

store/modules/
├── user.js                # 用户状态
└── app.js                 # 应用状态
```

---

## 参考资料

- [Vue 3 官方文档](https://cn.vuejs.org/)
- [RuoYi-UI 项目文档](../../ruoyi-project-document/ruoyi-ui.md)
- [Element Plus 文档](https://element-plus.org/zh-CN/)

---

**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

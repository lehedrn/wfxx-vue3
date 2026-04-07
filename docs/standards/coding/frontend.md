# 前端编码规范

本文档规定 Vue 3 前端开发的编码规范，适用于 RuoYi-Vue 项目。

---

## 1. 命名规范

### 1.1 文件命名

- 组件文件：**PascalCase**
- 工具函数、API 文件：**camelCase**
- 视图文件：**camelCase**

```bash
# 正确
src/views/system/user/index.vue
src/components/DialogBox.vue
src/utils/request.js
src/api/system/user.js

# 错误
src/views/system/User/index.vue
src/components/dialogBox.vue
```

### 1.2 组件命名

- 多单词组成，使用 **PascalCase**
- 名称应清晰表达组件用途

```vue
<!-- 正确 -->
<template>
  <UserDialog />
  <DataTable />
</template>

<!-- 错误 -->
<template>
  <user_dialog />
  <Data />
</template>
```

### 1.3 变量命名

- 使用 **camelCase**
- 布尔值使用 `is`、`has`、`should` 等前缀

```javascript
// 正确
const userName = ref('')
const isLoading = ref(false)
const hasPermission = computed(() => ...)

// 错误
const name1 = ref('')
const loading = ref(false)  // 不够明确
```

### 1.4 函数命名

- 使用 **camelCase**
- 动词 + 名词结构

```javascript
// 正确
function getUserList() { }
function handle_submit() { }
function format_date(date) { }

// 错误
function user() { }
function submit() { }  // 不够明确
```

---

## 2. 代码格式

### 2.1 缩进

- 使用 **2 个空格** 缩进

```vue
<template>
  <div class="container">
    <el-table :data="list">
      <el-table-column prop="name" label="姓名" />
    </el-table>
  </div>
</template>
```

### 2.2 引号

- 字符串使用 **单引号**

```javascript
// 正确
const name = '张三'
const msg = `Hello, ${name}`

// 错误
const name = "张三"
```

### 2.3 行宽

- 单行代码不超过 **120 字符**

```javascript
// 正确
const longText = '这是一段非常长的文本，超过了 120 字符需要换行' +
  '这是第二段内容'

// 错误
const longText = '这是一段非常长的文本，超过了 120 字符需要换行这是第二段内容这是一段非常长的文本...'
```

---

## 3. Vue 组件规范

### 3.1 组件结构

```vue
<template>
  <!-- 模板内容 -->
</template>

<script setup>
// 脚本内容
</script>

<style scoped>
/* 样式内容 */
</style>
```

### 3.2 Props 定义

- 使用 `defineProps` 宏
- 指定类型和默认值

```vue
<script setup>
const props = defineProps({
  userId: {
    type: Number,
    required: true
  },
  userName: {
    type: String,
    default: ''
  }
})
</script>
```

### 3.3 Emits 定义

- 使用 `defineEmits` 宏

```vue
<script setup>
const emit = defineEmits(['update', 'delete', 'submit'])

function handleSubmit() {
  emit('submit', formData)
}
</script>
```

### 3.4 响应式数据

- 使用 `ref` 和 `reactive`
- 优先使用 `ref`

```vue
<script setup>
import { ref, computed } from 'vue'

// 正确
const list = ref([])
const loading = ref(false)

// 避免
const state = reactive({ list: [], loading: false })
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
```

### 4.2 请求方法

- 使用封装的 `request` 工具
- 不直接使用 `axios`

```javascript
// 正确
import request from '@/utils/request'
const res = await request({ url: '/api/user', method: 'get' })

// 错误
import axios from 'axios'
const res = await axios.get('/api/user')
```

---

## 5. 状态管理

### 5.1 Pinia Store 定义

```javascript
// src/store/modules/user.js
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', () => {
  const token = ref('')
  const userName = ref('')

  const setToken = (newToken) => {
    token.value = newToken
  }

  const logout = () => {
    token.value = ''
    userName.value = ''
  }

  return { token, userName, setToken, logout }
})
```

### 5.2 Store 使用

```vue
<script setup>
import { useUserStore } from '@/store/modules/user'

const userStore = useUserStore()
const { token, userName } = storeToRefs(userStore)

function handleLogin() {
  userStore.setToken('new-token')
}
</script>
```

---

## 6. 注释规范

### 6.1 文件注释

```javascript
/**
 * 用户管理 API
 * @module system/user
 */
```

### 6.2 函数注释

```javascript
/**
 * 查询用户列表
 * @param {Object} query - 查询参数
 * @returns {Promise} 用户列表
 */
export function listUser(query) {
}
```

### 6.3 代码注释

```javascript
// 检查用户权限
if (hasPermission('system:user:list')) {
  // 加载用户列表
  await loadUserList()
}
```

---

## 7. 最佳实践

### 7.1 解构 props

```vue
<script setup>
const props = defineProps({ foo: String })
const { foo } = toRefs(props)  // 需要响应式时使用

// 不需要响应式时直接使用 props.foo
</script>
```

### 7.2 事件处理

```vue
<template>
  <!-- 正确 -->
  <el-button @click="handleSubmit">提交</el-button>
  
  <!-- 错误 -->
  <el-button @click="handleSubmit()">提交</el-button>
</template>
```

### 7.3 条件渲染

```vue
<template>
  <!-- 正确：使用 v-if -->
  <div v-if="visible">内容</div>
  
  <!-- 避免：v-if 和 v-for 同时使用 -->
  <div v-for="item in list" v-if="item.visible">
    {{ item.name }}
  </div>
</template>
```

### 7.4 键值绑定

```vue
<template>
  <!-- 正确：使用唯一 id -->
  <div v-for="item in list" :key="item.id">
    {{ item.name }}
  </div>
  
  <!-- 错误：使用 index -->
  <div v-for="(item, index) in list" :key="index">
    {{ item.name }}
  </div>
</template>
```

---

## 8. CSS 规范

### 8.1 样式作用域

- 组件样式使用 `scoped`

```vue
<style scoped>
.container {
  padding: 20px;
}
</style>
```

### 8.2 类名命名

- 使用 **kebab-case**（短横线命名）

```vue
<template>
  <div class="user-container">
    <div class="user-info-item">
      <div class="user-name-text">张三</div>
    </div>
  </div>
</template>
```

### 8.3 嵌套层级

- 不超过 **3 层**

```scss
// 正确
.user-container {
  .user-info {
    .user-name {
      color: #333;
    }
  }
}

// 错误
.user-container {
  .user-info {
    .user-name {
      .user-name-text {
        .user-name-text-inner {
          // 过深嵌套
        }
      }
    }
  }
}
```

---

## 9. 目录结构

```
src/
├── api/              # API 接口
│   └── system/       # 系统模块
│       └── user.js   # 用户 API
├── components/       # 公共组件
├── directives/       # 自定义指令
├── layout/           # 布局组件
├── router/           # 路由配置
├── store/            # 状态管理
├── utils/            # 工具函数
├── views/            # 页面组件
│   └── system/       # 系统模块
│       └── user/     # 用户管理
│           └── index.vue
└── App.vue
```

---

## 参考资料

- [Vue 3 官方文档](https://cn.vuejs.org/)
- [Vue 3 风格指南](https://cn.vuejs.org/style-guide/)
- [Element Plus 文档](https://element-plus.org/zh-CN/)

---

**最后更新**: 2026-04-07

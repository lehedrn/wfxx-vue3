# API 接口层

## 概述

若依前端的 API 接口层采用 Axios 封装，统一管理 HTTP 请求，包含请求拦截、响应拦截、错误处理等功能。

**目录结构**:

```
src/api/
├── login.js              # 登录/用户信息/验证码接口
├── menu.js               # 菜单路由接口
├── system/               # 系统管理接口
│   ├── config.js         # 参数配置
│   ├── dept.js           # 部门管理
│   ├── dict/             # 字典管理
│   ├── menu.js           # 菜单管理
│   ├── notice.js         # 通知公告
│   ├── post.js           # 岗位管理
│   ├── role.js           # 角色管理
│   └── user.js           # 用户管理
├── monitor/              # 系统监控接口
│   ├── cache.js          # 缓存监控
│   ├── job.js            # 定时任务
│   ├── jobLog.js         # 任务日志
│   ├── logininfor.js     # 登录日志
│   ├── online.js         # 在线用户
│   ├── operlog.js        # 操作日志
│   └── server.js         # 服务器监控
└── tool/                 # 系统工具接口
    └── gen.js            # 代码生成
```

---

## request.js - Axios 封装

**源码**: [`src/utils/request.js`](../../ruoyi-ui/src/utils/request.js)

### 核心配置

```javascript
import axios from 'axios'

const service = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API,  // API 基础路径
  timeout: 10000  // 超时时间
})
```

### 请求拦截器

```javascript
service.interceptors.request.use(config => {
  // 是否需要设置 token
  const isToken = (config.headers || {}).isToken === false
  
  // 是否需要防止数据重复提交
  const isRepeatSubmit = (config.headers || {}).repeatSubmit === false
  
  // 添加 token
  if (getToken() && !isToken) {
    config.headers['Authorization'] = 'Bearer ' + getToken()
  }
  
  // GET 请求参数映射
  if (config.method === 'get' && config.params) {
    let url = config.url + '?' + tansParams(config.params)
    url = url.slice(0, -1)
    config.params = {}
    config.url = url
  }
  
  // 防重复提交检查
  if (!isRepeatSubmit && (config.method === 'post' || config.method === 'put')) {
    const requestObj = {
      url: config.url,
      data: typeof config.data === 'object' ? JSON.stringify(config.data) : config.data,
      time: new Date().getTime()
    }
    
    const sessionObj = cache.session.getJSON('sessionObj')
    if (sessionObj) {
      const interval = (config.headers || {}).interval || 1000
      if (sessionObj.data === requestObj.data && 
          requestObj.time - sessionObj.time < interval && 
          sessionObj.url === requestObj.url) {
        return Promise.reject(new Error('数据正在处理，请勿重复提交'))
      }
    }
    cache.session.setJSON('sessionObj', requestObj)
  }
  
  return config
}, error => {
  return Promise.reject(error)
})
```

### 响应拦截器

```javascript
service.interceptors.response.use(res => {
  const code = res.data.code || 200
  const msg = errorCode[code] || res.data.msg || errorCode['default']
  
  // 二进制数据直接返回
  if (res.request.responseType === 'blob' || res.request.responseType === 'arraybuffer') {
    return res.data
  }
  
  // 401 未授权
  if (code === 401) {
    ElMessageBox.confirm('登录状态已过期，您可以继续留在该页面，或者重新登录', '系统提示', {
      confirmButtonText: '重新登录',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      useUserStore().logOut().then(() => {
        location.href = '/index'
      })
    })
    return Promise.reject('无效的会话，或者会话已过期，请重新登录。')
  }
  
  // 500 服务器错误
  if (code === 500) {
    ElMessage({ message: msg, type: 'error' })
    return Promise.reject(new Error(msg))
  }
  
  // 成功
  if (code !== 200) {
    ElNotification({ title: msg, type: 'error' })
    return Promise.reject(new Error(msg))
  }
  
  return res.data
}, error => {
  ElMessage({ message: error.message, type: 'error' })
  return Promise.reject(error)
})
```

---

## 请求配置项

### 特殊配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `isToken` | Boolean | true | 是否需要 token（设为 false 则不添加 token） |
| `repeatSubmit` | Boolean | true | 是否允许重复提交（设为 false 则开启防重提交） |
| `interval` | Number | 1000 | 防重提交时间间隔（ms） |

### 使用示例

```javascript
// 不添加 token（登录接口）
request({
  url: '/login',
  method: 'post',
  headers: { isToken: false }
})

// 开启防重提交
request({
  url: '/system/user',
  method: 'post',
  data: userData,
  headers: { repeatSubmit: false }
})

// 自定义防重提交间隔
request({
  url: '/system/user',
  method: 'post',
  data: userData,
  headers: { repeatSubmit: false, interval: 2000 }
})
```

---

## 登录模块 API

**源码**: [`api/login.js`](../../ruoyi-ui/src/api/login.js)

| 方法 | 说明 | 参数 |
|------|------|------|
| `login(username, password, code, uuid)` | 用户登录 | 用户名、密码、验证码、UUID |
| `register(data)` | 用户注册 | 注册信息对象 |
| `getInfo()` | 获取用户信息 | - |
| `logout()` | 退出登录 | - |
| `getCodeImg()` | 获取验证码 | - |
| `unlockScreen(password)` | 解锁屏幕 | 密码 |

**使用示例**:

```javascript
import { login, getInfo, logout, getCodeImg } from '@/api/login'

// 登录
const { token } = await login('admin', 'admin123', '1234', 'uuid')

// 获取用户信息
const { user, roles, permissions } = await getInfo()

// 获取验证码
const { captchaEnabled, uuid, img } = await getCodeImg()

// 退出登录
await logout()
```

---

## 系统管理 API

### user.js - 用户管理

**源码**: [`api/system/user.js`](../../ruoyi-ui/src/api/system/user.js)

| 方法 | 说明 | 参数 |
|------|------|------|
| `listUser(query)` | 查询用户列表 | 查询条件对象 |
| `getUser(userId)` | 查询用户详情 | 用户 ID |
| `addUser(data)` | 新增用户 | 用户信息对象 |
| `updateUser(data)` | 修改用户 | 用户信息对象 |
| `delUser(userId)` | 删除用户 | 用户 ID |
| `resetUserPwd(userId, password)` | 重置密码 | 用户 ID、新密码 |
| `changeUserStatus(userId, status)` | 修改用户状态 | 用户 ID、状态 |
| `getUserProfile()` | 获取个人信息 | - |
| `updateUserProfile(data)` | 修改个人信息 | 用户信息对象 |
| `updateUserProfilePwd(password)` | 修改个人密码 | 新密码 |
| `uploadAvatar(data)` | 上传头像 | 头像文件 |

**使用示例**:

```vue
<script setup name="UserList">
import { listUser, addUser, updateUser, delUser } from '@/api/system/user'

// 查询用户列表
const { rows, total } = await listUser({ pageNum: 1, pageSize: 10 })

// 新增用户
await addUser({
  userName: 'test',
  nickName: '测试用户',
  deptId: 100
})

// 修改用户
await updateUser({
  userId: 1,
  userName: 'test',
  status: '0'
})

// 删除用户
await delUser(1)
</script>
```

### role.js - 角色管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listRole(query)` | 查询角色列表 | 查询条件对象 |
| `getRole(roleId)` | 查询角色详情 | 角色 ID |
| `addRole(data)` | 新增角色 | 角色信息对象 |
| `updateRole(data)` | 修改角色 | 角色信息对象 |
| `delRole(roleId)` | 删除角色 | 角色 ID |
| `changeRoleStatus(roleId, status)` | 修改角色状态 | 角色 ID、状态 |
| `getAuthRole(userId)` | 获取用户角色信息 | 用户 ID |
| `updateAuthRole(data)` | 保存用户角色授权 | `{ userId, roleIds }` |
| `getRoleMenuTreeselect(roleId)` | 获取角色菜单树 | 角色 ID |
| `allocatedUserList(query)` | 查询已分配的用户列表 | 查询条件对象 |
| `unallocatedUserList(query)` | 查询未分配的用户列表 | 查询条件对象 |
| `authUserCancel(data)` | 取消用户授权 | `{ userId, roleId }` |
| `authUserCancelAll(data)` | 批量取消用户授权 | `{ userIds, roleId }` |
| `authUserSelectAll(data)` | 批量选择用户授权 | 角色信息对象 |
| `deptTreeSelect(roleId)` | 根据角色 ID 查询部门树 | 角色 ID |
| `dataScope(data)` | 设置角色数据权限 | 角色信息对象 |

### menu.js - 菜单管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listMenu(query)` | 查询菜单列表 | 查询条件对象 |
| `getMenu(menuId)` | 查询菜单详情 | 菜单 ID |
| `addMenu(data)` | 新增菜单 | 菜单信息对象 |
| `updateMenu(data)` | 修改菜单 | 菜单信息对象 |
| `delMenu(menuId)` | 删除菜单 | 菜单 ID |
| `getMenuTreeselect()` | 获取菜单树 | - |
| `getRoleMenuTreeselect(roleId)` | 获取角色菜单树 | 角色 ID |
| `updateMenuSort(data)` | 修改菜单排序 | 菜单信息对象 |

### dept.js - 部门管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listDept(query)` | 查询部门列表 | 查询条件对象 |
| `getDept(deptId)` | 查询部门详情 | 部门 ID |
| `addDept(data)` | 新增部门 | 部门信息对象 |
| `updateDept(data)` | 修改部门 | 部门信息对象 |
| `delDept(deptId)` | 删除部门 | 部门 ID |
| `getDeptTreeselect(deptId)` | 获取部门树 | 排除的部门 ID |
| `updateDeptSort(data)` | 修改部门排序 | 部门信息对象 |
| `listDeptExcludeChild(deptId)` | 排除指定部门后的部门树 | 部门 ID |

### config.js - 参数配置

| 方法 | 说明 | 参数 |
|------|------|------|
| `listConfig(query)` | 查询参数列表 | 查询条件对象 |
| `getConfig(configId)` | 查询参数详情 | 参数 ID |
| `addConfig(data)` | 新增参数 | 参数信息对象 |
| `updateConfig(data)` | 修改参数 | 参数信息对象 |
| `delConfig(configId)` | 删除参数 | 参数 ID |
| `delConfig(ids)` | 批量删除参数 | 参数 ID 数组 |
| `getConfigKey(key)` | 根据参数键名查询参数 | 参数键名 |
| `refreshCache()` | 刷新参数缓存 | - |

### dict/type.js - 字典类型管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listType(query)` | 查询字典类型列表 | 查询条件对象 |
| `getType(dictId)` | 查询字典类型详情 | 字典 ID |
| `addType(data)` | 新增字典类型 | 字典类型信息对象 |
| `updateType(data)` | 修改字典类型 | 字典类型信息对象 |
| `delType(dictId)` | 删除字典类型 | 字典 ID |
| `delType(ids)` | 批量删除字典类型 | 字典 ID 数组 |
| `refreshCache()` | 刷新字典缓存 | - |
| `optionselect()` | 查询字典下拉选项 | - |

### dict/data.js - 字典数据管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listData(query)` | 查询字典数据列表 | 查询条件对象 |
| `getData(dictCode)` | 查询字典数据详情 | 字典编码 |
| `addData(data)` | 新增字典数据 | 字典数据信息对象 |
| `updateData(data)` | 修改字典数据 | 字典数据信息对象 |
| `delData(dictCode)` | 删除字典数据 | 字典编码 |
| `delData(ids)` | 批量删除字典数据 | 字典编码数组 |

### notice.js - 通知公告

| 方法 | 说明 | 参数 |
|------|------|------|
| `listNotice(query)` | 查询公告列表 | 查询条件对象 |
| `getNotice(noticeId)` | 查询公告详情 | 公告 ID |
| `addNotice(data)` | 新增公告 | 公告信息对象 |
| `updateNotice(data)` | 修改公告 | 公告信息对象 |
| `delNotice(noticeId)` | 删除公告 | 公告 ID |
| `delNotice(ids)` | 批量删除公告 | 公告 ID 数组 |
| `listNoticeTop()` | 获取顶置公告列表 | - |
| `markNoticeRead(id)` | 标记已读公告 | 公告 ID |
| `markNoticeReadAll()` | 批量标记已读 | - |

---

## 系统监控 API

### cache.js - 缓存监控

**源码**: [`api/monitor/cache.js`](../../ruoyi-ui/src/api/monitor/cache.js)

| 方法 | 说明 | 参数 |
|------|------|------|
| `listCacheName()` | 获取缓存列表 | - |
| `listCacheKey(cacheName)` | 获取缓存键列表 | 缓存名称 |
| `getCacheValue(cacheName, cacheKey)` | 获取缓存值 | 缓存名称、键 |
| `clearCacheName(cacheName)` | 清理指定缓存 | 缓存名称 |
| `clearCacheKey(cacheKey)` | 清理缓存键 | 缓存键 |
| `clearCacheAll()` | 清理所有缓存 | - |

### server.js - 服务器监控

**源码**: [`api/monitor/server.js`](../../ruoyi-ui/src/api/monitor/server.js)

| 方法 | 说明 | 参数 |
|------|------|------|
| `getServer()` | 获取服务器信息 | - |

**返回数据**:
```javascript
{
  cpu: { cpuNum: 8, used: 45.5 },
  mem: { total: '16GB', used: '8GB' },
  sys: { osName: 'Linux', osArch: 'x86_64' },
  disk: [{ dirName: '/', total: '500GB', free: '200GB' }],
  jvm: { version: '17.0.1', total: '4GB', used: '2GB' }
}
```

### job.js - 定时任务管理

| 方法 | 说明 | 参数 |
|------|------|------|
| `listJob(query)` | 查询任务列表 | 查询条件对象 |
| `getJob(jobId)` | 查询任务详情 | 任务 ID |
| `addJob(data)` | 新增任务 | 任务信息对象 |
| `updateJob(data)` | 修改任务 | 任务信息对象 |
| `delJob(jobId)` | 删除任务 | 任务 ID |
| `changeJobStatus(jobId, status)` | 修改任务状态 | 任务 ID、状态 |
| `runJob(jobId, jobGroup)` | 立即执行任务 | 任务 ID、任务组 |

---

## 文件下载

**源码**: [`utils/request.js`](../../ruoyi-ui/src/utils/request.js)

```javascript
import { download } from '@/utils/request'

// 导出用户数据
download('/system/user/export', {
  pageNum: 1,
  pageSize: 10
}, 'user_export.xlsx')
```

**实现**:
```javascript
export function download(url, params, filename) {
  downloadLoadingInstance = ElLoading.service({ text: '正在下载数据，请稍候', background: 'rgba(0, 0, 0, 0.7)' })
  
  request({
    url: url,
    method: 'post',
    params: params,
    responseType: 'blob'
  }).then(async data => {
    const blob = new Blob([data])
    saveAs(blob, filename)
    downloadLoadingInstance.close()
  }).catch(() => {
    downloadLoadingInstance.close()
  })
}
```

---

## 错误码映射

**源码**: [`utils/errorCode.js`](../../ruoyi-ui/src/utils/errorCode.js)

```javascript
export default {
  '200': '操作成功',
  '401': '用户未登录或登录已过期，请重新登录',
  '403': '您没有权限访问，如有疑问，请联系管理员',
  '404': '请求地址不存在',
  '500': '系统错误，请联系管理员',
  '601': '演示模式，不允许操作',
  'default': '系统未知错误，请反馈给管理员'
}
```

---

## 典型使用场景

### 列表查询

```vue
<script setup name="UserList">
import { listUser } from '@/api/system/user'

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  userName: '',
  status: ''
})

const userList = ref([])
const total = ref(0)

const getList = async () => {
  const { rows, total: count } = await listUser(queryParams.value)
  userList.value = rows
  total.value = count
}

getList()
</script>
```

### 新增操作

```vue
<script setup name="UserAdd">
import { addUser } from '@/api/system/user'
import { ElMessage } from 'element-plus'

const form = ref({
  userName: '',
  nickName: '',
  deptId: ''
})

const handleSubmit = async () => {
  try {
    await addUser(form.value)
    ElMessage.success('新增成功')
    // 刷新列表或关闭弹窗
  } catch (error) {
    // 错误已在拦截器处理
  }
}
</script>
```

### 导出操作

```vue
<script setup>
import { download } from '@/utils/request'

const handleExport = () => {
  download('/system/user/export', {
    pageNum: 1,
    pageSize: 10
  }, '用户数据.xlsx')
}
</script>
```

---

## 最佳实践

### 1. 统一错误处理

Axios 响应拦截器已统一处理错误，无需在每个请求中重复处理。

### 2. 防重复提交

对于表单提交操作，建议开启防重提交：

```javascript
request({
  url: '/system/user',
  method: 'post',
  data: formData,
  headers: { repeatSubmit: false }
})
```

### 3. 使用解构赋值

```javascript
// 推荐
const { rows, total } = await listUser(query)

// 不推荐
const result = await listUser(query)
const rows = result.rows
const total = result.total
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

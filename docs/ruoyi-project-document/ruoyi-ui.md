# RuoYi-UI 前端管理系统

## 概述

**ruoyi-ui** 是若依管理系统的前端部分，基于 Vue 3 + Vite + Element Plus 技术栈构建的企业级中后台管理系统前端解决方案。

**版本**: 3.9.2  
**源码位置**: `ruoyi-ui/`

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.5.26 | 核心框架 |
| Vite | 6.4.1 | 构建工具 |
| Element Plus | 2.13.1 | UI 组件库 |
| Pinia | 3.0.4 | 状态管理 |
| Vue Router | 4.6.4 | 路由管理 |
| Axios | 1.13.2 | HTTP 客户端 |
| ECharts | 5.6.0 | 数据可视化 |
| @vueuse/core | 14.1.0 | Vue 工具函数库 |
| Sass | 1.97.2 | CSS 预处理器 |

## 特性

- ✅ 基于 Vue 3 + Vite 的现代前端架构
- ✅ Element Plus UI 组件库
- ✅ Pinia 状态管理
- ✅ 动态路由（后端返回菜单树）
- ✅ 按钮级权限控制（`v-hasPermi` / `v-hasRole`）
- ✅ 多主题支持（深色/浅色）
- ✅ 多布局模式（左侧/混合/顶部）
- ✅ 标签页导航（支持持久化）
- ✅ 丰富的通用组件（22+ 个）
- ✅ 完整的系统管理功能
- ✅ 代码生成功能
- ✅ 系统监控（缓存、任务、日志、服务器）

---

## 目录结构

```
ruoyi-ui/
├── bin/                          # 构建脚本
├── html/                         # 静态 HTML 模板
├── public/                       # 公共静态资源
├── src/                          # 源代码
│   ├── api/                      # API 接口封装
│   ├── assets/                   # 静态资源（图片/样式）
│   ├── components/               # 通用组件（22 个）
│   ├── directive/                # 自定义指令
│   ├── layout/                   # 布局组件
│   ├── plugins/                  # 插件封装
│   ├── router/                   # 路由配置
│   ├── store/                    # 状态管理 (Pinia)
│   ├── utils/                    # 工具函数
│   ├── views/                    # 页面组件
│   ├── App.vue                   # 根组件
│   ├── main.js                   # 应用入口
│   ├── permission.js             # 路由守卫
│   └── settings.js               # 系统配置
├── vite/                         # Vite 配置插件
├── .env.development              # 开发环境配置
├── .env.production               # 生产环境配置
├── index.html                    # HTML 入口
├── package.json                  # 依赖配置
└── vite.config.js                # Vite 构建配置
```

---

## 快速入门

### 环境要求

- Node.js 18+ 
- pnpm / npm / yarn

### 安装依赖

```bash
cd ruoyi-ui
pnpm install
# 或
npm install
```

### 启动开发服务器

```bash
pnpm dev
# 或
npm run dev
```

访问 http://localhost:5173

### 构建生产版本

```bash
pnpm build:prod
# 或
npm run build:prod
```

### 构建预发布版本

```bash
pnpm build:stage
# 或
npm run build:stage
```

### 预览生产构建

```bash
pnpm preview
```

---

## 核心模块

### 1. 路由系统

- **动态路由**: 后端返回菜单树，前端动态生成可访问路由
- **路由守卫**: 登录验证、权限验证
- **标签页**: 支持页签持久化、右键菜单操作

详细文档：[03-路由系统.md](ruoyi-ui/03-路由系统.md)

### 2. 状态管理 (Pinia)

| Store | 职责 |
|-------|------|
| `user` | 用户信息、token、角色、权限 |
| `permission` | 动态路由生成、路由表管理 |
| `settings` | 系统设置（主题、布局、页签） |
| `app` | 应用状态（侧边栏、设备类型） |
| `tagsView` | 标签页管理 |
| `dict` | 数据字典缓存 |
| `lock` | 锁屏状态管理 |

详细文档：[04-状态管理.md](ruoyi-ui/04-状态管理.md)

### 3. API 接口层

| 模块 | 说明 |
|------|------|
| `login.js` | 登录/用户信息接口 |
| `menu.js` | 菜单路由接口 |
| `system/` | 系统管理 API（用户/角色/菜单等） |
| `monitor/` | 系统监控 API（缓存/任务/日志等） |
| `tool/` | 系统工具 API（代码生成） |

详细文档：[05-API_接口层.md](ruoyi-ui/05-API_接口层.md)

### 4. 通用组件

**22+ 个通用组件**:
- 布局组件（Sidebar/Navbar/TagsView/AppMain）
- 业务组件（Pagination/RightToolbar/DictTag）
- 上传组件（FileUpload/ImageUpload）
- 富文本编辑器（Editor）
- 图标组件（SvgIcon/IconSelect）
- 其他组件（Crontab/Screenfull/HeaderSearch）

详细文档：[06-通用组件.md](ruoyi-ui/06-通用组件.md)

### 5. 页面模块

| 页面 | 路径 | 说明 |
|------|------|------|
| 首页 | `/` | 仪表盘 |
| 登录 | `/login` | 用户登录 |
| 注册 | `/register` | 用户注册 |
| 锁屏 | `/lock` | 锁屏页面 |
| 系统管理 | `/system` | 用户/角色/菜单等管理 |
| 系统监控 | `/monitor` | 缓存/任务/日志等监控 |
| 系统工具 | `/tool` | 代码生成/表单构建 |

详细文档：[07-页面模块.md](ruoyi-ui/07-页面模块.md)

---

## 系统配置

### settings.js - 系统参数配置

```javascript
export default {
  title: '若依管理系统',         // 网页标题
  sideTheme: 'theme-dark',      // 侧边栏主题（theme-dark/theme-light）
  showSettings: true,           // 是否显示设置面板
  navType: 1,                   // 导航模式（1 左侧 2 混合 3 顶部）
  tagsView: true,               // 是否显示标签页
  tagsViewPersist: false,       // 是否持久化标签页
  tagsIcon: false,              // 是否显示页签图标
  fixedHeader: true,            // 是否固定头部
  sidebarLogo: true,            // 是否显示侧边栏 logo
  dynamicTitle: false,          // 是否显示动态标题
  footerVisible: false,         // 是否显示底部版权
  footerContent: 'Copyright © 2018-2026 RuoYi.' // 版权文本
}
```

详细文档：[02-核心配置.md](ruoyi-ui/02-核心配置.md)

---

## 权限控制

### 指令方式

```vue
<!-- 操作权限 -->
<el-button v-hasPermi="['system:user:add']">新增</el-button>

<!-- 角色权限 -->
<el-button v-hasRole="['admin']">管理</el-button>
```

### 函数方式

```javascript
import { hasPermi, hasRole } from '@/utils/permission'

if (hasPermi('system:user:list')) {
  // 有权限执行操作
}

if (hasRole('admin')) {
  // 有角色权限
}
```

详细文档：[09-自定义指令.md](ruoyi-ui/09-自定义指令.md)

---

## 开发规范

### 组件开发

```vue
<template>
  <div class="my-component">
    <!-- 模板内容 -->
  </div>
</template>

<script setup name="MyComponent">
import { ref } from 'vue'

// 组件逻辑
</script>

<style lang="scss" scoped>
.my-component {
  // 样式
}
</style>
```

### API 调用

```javascript
import { listUser, addUser, updateUser } from '@/api/system/user'

// 查询列表
const { data } = await listUser(queryParam)

// 新增
await addUser(form)
```

### 状态管理

```javascript
import { useUserStore } from '@/store/modules/user'

const userStore = useUserStore()

// 获取用户信息
await userStore.getInfo()

// 登出
await userStore.logOut()
```

---

## 子模块文档

| 文档 | 说明 |
|------|------|
| [01-工程概述.md](ruoyi-ui/01-工程概述.md) | 技术栈、环境配置、快速开始 |
| [02-核心配置.md](ruoyi-ui/02-核心配置.md) | settings.js, vite.config.js, 环境变量 |
| [03-路由系统.md](ruoyi-ui/03-路由系统.md) | router, permission.js, 动态路由机制 |
| [04-状态管理.md](ruoyi-ui/04-状态管理.md) | Pinia stores (user/permission/settings 等) |
| [05-API_接口层.md](ruoyi-ui/05-API_接口层.md) | API 目录结构和调用规范 |
| [06-通用组件.md](ruoyi-ui/06-通用组件.md) | components 和 layout |
| [07-页面模块.md](ruoyi-ui/07-页面模块.md) | views 页面组件 |
| [08-工具函数.md](ruoyi-ui/08-工具函数.md) | utils 工具类 |
| [09-自定义指令.md](ruoyi-ui/09-自定义指令.md) | directive (hasPermi/hasRole/copyText) |
| [10-插件扩展.md](ruoyi-ui/10-插件扩展.md) | plugins (auth/cache/modal/tab/download) |

---

## 环境变量配置

### .env.development

```
# 开发环境
VITE_APP_TITLE = '若依管理系统'
VITE_APP_BASE_API = '/dev-api'
```

### .env.production

```
# 生产环境
VITE_APP_TITLE = '若依管理系统'
VITE_APP_BASE_API = '/prod-api'
```

---

## 常用命令

```bash
# 开发模式
pnpm dev

# 构建生产环境
pnpm build:prod

# 构建预发布环境
pnpm build:stage

# 预览生产构建
pnpm preview

# 代码格式化
pnpm lint
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYI v3.9.2

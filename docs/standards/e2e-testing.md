# 前后端联调测试规范（Playwright E2E）

## 概述

本规范定义 RuoYi 项目使用 Playwright 进行前后端联调测试的编写标准、目录结构和最佳实践。

**目标**：
- 验证前后端完整业务流程
- 提供可复用的 E2E 测试脚本模板
- 确保测试的可维护性和稳定性
- 支持持续集成中的自动化测试

---

## 1. 目录结构

```
scripts/test/
├── curl/                        # 后端 API 测试
│   ├── test-login.sh           # 登录认证 API 测试
│   └── test-demo-api.sh        # Demo 模块 API 测试
└── e2e/                         # 前后端联调测试
    ├── package.json            # 测试项目依赖
    ├── playwright.config.js    # Playwright 配置
    ├── tests/
    │   ├── login.spec.js       # 登录认证测试
    │   ├── demo/
    │   │   ├── student.spec.js # 学生管理（简单 CRUD）
    │   │   ├── product.spec.js # 产品管理（树形列表）
    │   │   └── customer.spec.js# 客户管理（主子表）
    │   └── fixtures/
    │       └── auth.js         # 认证 fixture
    └── reports/                # 测试报告输出
```

---

## 2. 环境要求

| 依赖 | 版本 | 说明 |
|------|------|------|
| Node.js | 18.x+ | 运行环境 |
| pnpm | 8.x+ | 包管理器 |
| Playwright | 1.50.x+ | E2E 测试框架 |
| Chrome | 最新版 | 测试浏览器 |

### 安装步骤

```bash
cd scripts/test/e2e
pnpm install
pnpm exec playwright install chrome
```

---

## 3. 核心配置

### 3.1 playwright.config.js

```javascript
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  timeout: 30000,
  expect: {
    timeout: 5000,
  },
  use: {
    baseURL: 'http://localhost:3888',
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chrome',
      use: {
        channel: 'chrome',
      },
    },
  ],
  reporter: [
    ['html', { outputFolder: './reports/html' }],
    ['list'],
  ],
  outputDir: './reports/results',
})
```

### 3.2 package.json

```json
{
  "name": "ruoyi-e2e-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "playwright test",
    "test:ui": "playwright test --ui",
    "test:student": "playwright test tests/demo/student.spec.js",
    "test:product": "playwright test tests/demo/product.spec.js",
    "test:customer": "playwright test tests/demo/customer.spec.js",
    "test:login": "playwright test tests/login.spec.js",
    "report": "playwright show-report reports/html"
  },
  "devDependencies": {
    "@playwright/test": "^1.50.0"
  }
}
```

---

## 4. 元素定位规范（Locator）

### 4.1 定位器优先级

Playwright 提供多种元素定位方式，按推荐优先级从高到低排列：

| 优先级 | 定位方式 | 示例 | 稳定性 |
|--------|----------|------|--------|
| 1 | 角色选择器 | `getByRole('button')` | ⭐⭐⭐⭐⭐ |
| 2 | 文本选择器 | `getByText('新增')` | ⭐⭐⭐⭐ |
| 3 | 标签选择器 | `getByLabel('学生名称')` | ⭐⭐⭐⭐ |
| 4 | 占位符选择器 | `getByPlaceholder('请输入...')` | ⭐⭐⭐⭐ |
| 5 | 测试 ID | `getByTestId('submit-btn')` | ⭐⭐⭐⭐⭐ |
| 6 | CSS 选择器 | `locator('.el-button')` | ⭐⭐⭐ |
| 7 | XPath | `locator('//button')` | ⭐⭐ |

---

### 4.2 菜单导航定位

#### 侧边栏菜单定位

若依系统侧边栏菜单结构：

```javascript
// 方式 1：通过菜单文本定位（推荐）
await page.click('text=系统管理')
await page.click('text=用户管理')

// 方式 2：通过角色定位（语义化）
await page.getByRole('link', { name: '用户管理' }).click()

// 方式 3：通过 URL 导航（最可靠）
await page.goto('/system/user')

// 方式 4：通过菜单项属性定位
await page.click('.el-menu-item:has-text("用户管理")')
```

**完整菜单定位示例**：

```javascript
test('访问学生管理菜单', async ({ authenticatedPage }) => {
  // 方式 1：直接访问 URL（推荐，最可靠）
  await authenticatedPage.goto('/demo/student')
  await authenticatedPage.waitForLoadState('networkidle')
  
  // 验证当前页面标题
  await expect(authenticatedPage.locator('.app-container h2')).toContainText('学生管理')
})

test('通过菜单导航访问', async ({ authenticatedPage }) => {
  // 展开菜单（如果需要）
  const demoMenu = authenticatedPage.locator('.el-submenu:has-text("Demo 模块")')
  const isExpanded = await demoMenu.getAttribute('class')
  if (!isExpanded?.includes('is-opened')) {
    await demoMenu.click()
    await authenticatedPage.waitForTimeout(300)
  }
  
  // 点击子菜单
  await authenticatedPage.click('.el-menu-item:has-text("学生管理")')
  await authenticatedPage.waitForURL(/\/demo\/student/)
})
```

#### 顶部导航定位

```javascript
// 退出登录（通过右上角用户菜单）
test('退出登录', async ({ authenticatedPage }) => {
  // 点击用户头像下拉
  await authenticatedPage.click('.avatar-container')
  
  // 等待下拉菜单显示
  await authenticatedPage.waitForSelector('.el-dropdown-menu')
  
  // 点击退出登录
  await authenticatedPage.click('text=退出登录')
  
  // 验证跳转到登录页
  await authenticatedPage.waitForURL(/\/login/)
})

// 访问个人中心
test('访问个人中心', async ({ authenticatedPage }) => {
  await authenticatedPage.click('.avatar-container')
  await authenticatedPage.click('text=个人中心')
  await authenticatedPage.waitForURL(/\/user\/profile/)
})
```

---

### 4.3 按钮定位

#### 工具栏按钮

若依系统的按钮通常包含图标和文本，使用以下方式进行定位：

```javascript
// 方式 1：通过文本定位（推荐）
await page.click('button:has-text("新增")')
await page.click('button:has-text("修改")')
await page.click('button:has-text("删除")')
await page.click('button:has-text("搜索")')
await page.click('button:has-text("重置")')
await page.click('button:has-text("导出")')

// 方式 2：通过角色定位
await page.getByRole('button', { name: '新增' }).click()

// 方式 3：通过类型 + 文本组合
await page.click('button.el-button--primary:has-text("新增")')
```

#### 行内操作按钮

表格行内的操作按钮（修改/删除）：

```javascript
// 定位第一行的修改按钮
const row = page.locator('tbody tr').first()
await row.click('button:has-text("修改")')

// 定位特定数据的行并操作
const targetRow = page.locator('tbody tr:has-text("张三")')
await targetRow.click('button:has-text("删除")')

// 定位表格中所有修改按钮
const editButtons = page.locator('tbody button:has-text("修改")')
```

---

### 4.4 表单元素定位

#### 输入框

```javascript
// 方式 1：通过占位符定位（推荐）
await page.fill('input[placeholder="请输入学生名称"]', '张三')

// 方式 2：通过标签定位
await page.getByLabel('学生名称').fill('张三')

// 方式 3：通过 CSS 属性定位
await page.fill('input[name="name"]', '张三')
```

#### 下拉选择框

```javascript
// 方式 1：selectOption（推荐）
await page.selectOption('.el-select', '0')
await page.selectOption('select[name="sex"]', { label: '男' })

// 方式 2：点击后选择选项
await page.click('.el-select')
await page.click('.el-select-dropdown__item:has-text("男")')

// 方式 3：使用角色选择器
await page.getByRole('combobox').selectOption('0')
```

#### 日期选择器

```javascript
// 直接填充日期（ISO 格式）
await page.fill('input[type="date"]', '2006-01-15')

// 点击日期选择器并选择
await page.click('.el-date-editor')
await page.click('.el-date-table td:not(.disabled):has-text("15")')
```

#### 单选框

```javascript
// 通过标签点击
await page.click('el-radio:has-text("正常")')

// 通过 value 定位
await page.click('input[type="radio"][value="0"]')
```

#### 复选框

```javascript
// 单个复选框
await page.check('input[type="checkbox"]')
await page.uncheck('input[type="checkbox"]')

// 复选框组
await page.check('text=阅读')
await page.check('text=运动')
```

---

### 4.5 表格元素定位

#### 表格数据定位

```javascript
// 获取表格行数
const rowCount = await page.locator('tbody tr').count()

// 定位特定行
const firstRow = page.locator('tbody tr').first()
const lastRow = page.locator('tbody tr').last()
const thirdRow = page.locator('tbody tr').nth(2)

// 定位包含特定文本的行
const targetRow = page.locator('tbody tr:has-text("张三")')

// 获取单元格内容
const cellText = await page.locator('tbody tr').first().locator('td').nth(1).textContent()

// 验证表格内容
await expect(page.locator('tbody')).toContainText('张三')
```

#### 分页定位

```javascript
// 页码输入
await page.fill('.el-pagination input', '2')
await page.keyboard.press('Enter')

// 点击下一页
await page.click('.el-pagination button:has-text("下一页")')

// 验证分页信息
await expect(page.locator('.el-pagination__total')).toContainText('共')
```

---

### 4.6 对话框定位

```javascript
// 等待对话框打开
await page.waitForSelector('.el-dialog__title')

// 验证对话框标题
await expect(page.locator('.el-dialog__title')).toContainText('新增')

// 点击确定按钮
await page.click('.el-dialog__footer button:has-text("确定")')

// 点击取消按钮
await page.click('.el-dialog__footer button:has-text("取消")')

// 关闭对话框（ESC 键）
await page.keyboard.press('Escape')
```

---

### 4.7 消息提示定位

```javascript
// 成功消息
await expect(page.locator('.el-message--success')).toBeVisible()

// 错误消息
await expect(page.locator('.el-message--error')).toBeVisible()

// 警告消息
await expect(page.locator('.el-message--warning')).toBeVisible()

// 等待消息消失
await page.waitForSelector('.el-message', { state: 'detached' })
```

---

### 4.8 确认对话框定位

```javascript
// 确认删除操作
await page.click('button:has-text("删除")')
await page.waitForSelector('.el-message-box')

// 点击确认
await page.click('.el-message-box__btns button:has-text("确定")')

// 点击取消
await page.click('.el-message-box__btns button:has-text("取消")')
```

---

### 4.9 综合示例

```javascript
import { test, expect } from '../../fixtures/auth'

test('完整的新增流程', async ({ authenticatedPage }) => {
  // 1. 访问页面（URL 导航）
  await authenticatedPage.goto('/demo/student')
  await authenticatedPage.waitForLoadState('networkidle')
  
  // 2. 点击新增按钮（文本定位）
  await authenticatedPage.click('button:has-text("新增")')
  await authenticatedPage.waitForSelector('.el-dialog__title')
  
  // 3. 填写表单（占位符定位）
  await authenticatedPage.fill(
    'input[placeholder="请输入学生名称"]', 
    '测试学生_' + Date.now()
  )
  
  // 4. 选择下拉（角色定位）
  await authenticatedPage.getByRole('combobox').first().click()
  await authenticatedPage.click('.el-select-dropdown__item:has-text("男")')
  
  // 5. 选择日期（CSS 定位）
  await authenticatedPage.fill('input[type="date"]', '2006-01-15')
  
  // 6. 提交（文本定位）
  await authenticatedPage.click('button:has-text("确定")')
  
  // 7. 验证成功消息
  await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  
  // 8. 验证列表包含新数据（表格定位）
  await expect(authenticatedPage.locator('tbody')).toContainText('测试学生')
})
```

---

## 5. 测试脚本规范

### 4.1 认证 Fixture

**文件**: `tests/fixtures/auth.js`

```javascript
import { test as base } from '@playwright/test'

export const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    // 访问登录页
    await page.goto('/login')
    
    // 填写登录表单
    await page.fill('input[name="username"]', 'admin')
    await page.fill('input[name="password"]', 'admin123')
    
    // 处理验证码（如果启用）
    const captchaInput = page.locator('input[name="code"]')
    if (await captchaInput.isVisible()) {
      await captchaInput.fill('8') // 或使用 OCR 识别
    }
    
    // 提交登录
    await page.click('button[type="submit"]')
    
    // 等待登录成功，跳转到首页
    await page.waitForURL(/\/index/)
    await page.waitForLoadState('networkidle')
    
    await use(page)
  }
})

export { expect } from '@playwright/test'
```

**使用方式**：
```javascript
import { test, expect } from '../fixtures/auth'

test('需要认证的测试', async ({ authenticatedPage }) => {
  // authenticatedPage 已自动登录
})
```

---

### 4.2 登录认证测试

**文件**: `tests/login.spec.js`

```javascript
import { test, expect } from '../fixtures/auth'

test.describe('登录认证', () => {
  test('成功登录', async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[name="username"]', 'admin')
    await page.fill('input[name="password"]', 'admin123')
    
    // 处理验证码
    const captchaInput = page.locator('input[name="code"]')
    if (await captchaInput.isVisible()) {
      await captchaInput.fill('8')
    }
    
    await page.click('button[type="submit"]')
    await page.waitForURL(/\/index/)
    
    // 验证登录后跳转到首页
    await expect(page).toHaveURL(/\/index/)
    
    // 验证页面包含欢迎信息
    await expect(page.locator('.welcome')).toContainText('欢迎')
  })

  test('密码错误', async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[name="username"]', 'admin')
    await page.fill('input[name="password"]', 'wrongpassword')
    await page.click('button[type="submit"]')
    
    // 验证显示错误提示
    await expect(page.locator('.el-message--error')).toBeVisible()
  })

  test('退出登录', async ({ authenticatedPage }) => {
    // 已登录状态
    await authenticatedPage.goto('/index')
    
    // 点击退出
    await authenticatedPage.click('.el-dropdown-link')
    await authenticatedPage.click('text=退出登录')
    
    // 验证跳转到登录页
    await authenticatedPage.waitForURL(/\/login/)
    await expect(authenticatedPage).toHaveURL(/\/login/)
  })
})
```

---

### 4.3 学生管理测试（简单 CRUD）

**文件**: `tests/demo/student.spec.js`

```javascript
import { test, expect } from '../../fixtures/auth'

test.describe('学生管理 - 简单 CRUD', () => {
  const testData = {
    name: `测试学生_${Date.now()}`,
    age: 20,
    sex: '0',
    status: '0',
    birthday: '2006-01-15',
    hobby: ['1']
  }

  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/demo/student')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('新增学生', async ({ authenticatedPage }) => {
    // 点击新增按钮
    await authenticatedPage.click('button:has-text("新增")')
    
    // 等待对话框打开
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 填写表单
    await authenticatedPage.fill('input[placeholder="请输入学生名称"]', testData.name)
    await authenticatedPage.selectOption('.el-select', testData.sex)
    await authenticatedPage.fill('input[type="date"]', testData.birthday)
    
    // 提交
    await authenticatedPage.click('button:has-text("确定")')
    
    // 验证成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
    
    // 验证列表中包含新增数据
    await expect(authenticatedPage.locator('tbody')).toContainText(testData.name)
  })

  test('查询学生', async ({ authenticatedPage }) => {
    // 在查询框输入
    await authenticatedPage.fill('input[placeholder="请输入学生名称"]', testData.name)
    await authenticatedPage.click('button:has-text("搜索")')
    
    // 验证查询结果
    await expect(authenticatedPage.locator('tbody')).toContainText(testData.name)
  })

  test('修改学生', async ({ authenticatedPage }) => {
    // 找到要修改的行并点击修改按钮
    const row = authenticatedPage.locator('tbody tr').first()
    await row.click('button:has-text("修改")')
    
    // 等待对话框
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 修改数据
    const newName = testData.name + '_修改'
    await authenticatedPage.fill('input[placeholder="请输入学生名称"]', newName)
    
    // 提交
    await authenticatedPage.click('button:has-text("确定")')
    
    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
    await expect(authenticatedPage.locator('tbody')).toContainText(newName)
  })

  test('删除学生', async ({ authenticatedPage }) => {
    // 点击删除按钮
    await authenticatedPage.click('button:has-text("删除")')
    
    // 确认删除
    await authenticatedPage.click('.el-message-box__btns button:has-text("确定")')
    
    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })

  test('导出学生数据', async ({ authenticatedPage }) => {
    // 监听下载事件
    const downloadPromise = authenticatedPage.waitForEvent('download')
    
    // 点击导出按钮
    await authenticatedPage.click('button:has-text("导出")')
    
    // 验证文件开始下载
    const download = await downloadPromise
    expect(download.suggestedFilename()).toMatch(/.*\.xlsx/)
  })
})
```

---

### 4.4 产品管理测试（树形列表）

**文件**: `tests/demo/product.spec.js`

```javascript
import { test, expect } from '../../fixtures/auth'

test.describe('产品管理 - 树形列表', () => {
  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/demo/product')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('树形列表展示', async ({ authenticatedPage }) => {
    // 验证树形结构展示
    const treeRows = authenticatedPage.locator('tbody tr')
    expect(await treeRows.count()).toBeGreaterThan(0)
    
    // 验证存在展开/收起按钮
    const expandButtons = authenticatedPage.locator('.el-table__expand-icon')
    expect(await expandButtons.count()).toBeGreaterThan(0)
  })

  test('展开树形节点', async ({ authenticatedPage }) => {
    // 点击展开按钮
    const expandButton = authenticatedPage.locator('.el-table__expand-icon').first()
    if (await expandButton.isVisible()) {
      await expandButton.click()
      
      // 验证子节点显示
      await authenticatedPage.waitForTimeout(500)
      const rows = authenticatedPage.locator('tbody tr')
      const initialCount = await rows.count()
      
      // 展开后行数应该增加或不变
      expect(await rows.count()).toBeGreaterThanOrEqual(initialCount)
    }
  })

  test('新增产品（树形）', async ({ authenticatedPage }) => {
    // 点击新增
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 填写表单
    const productName = `测试产品_${Date.now()}`
    await authenticatedPage.fill('input[placeholder="请输入产品名称"]', productName)
    
    // 选择父节点（树形选择器）
    // await authenticatedPage.click('.el-tree')
    // await authenticatedPage.click('.el-tree-node__content:has-text("电子产品")')
    
    // 提交
    await authenticatedPage.click('button:has-text("确定")')
    
    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })
})
```

---

### 4.5 客户管理测试（主子表）

**文件**: `tests/demo/customer.spec.js`

```javascript
import { test, expect } from '../../fixtures/auth'

test.describe('客户管理 - 主子表', () => {
  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/demo/customer')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('新增客户（含商品列表）', async ({ authenticatedPage }) => {
    // 点击新增
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 填写客户基本信息
    const customerName = `测试客户_${Date.now()}`
    await authenticatedPage.fill('input[placeholder="请输入客户姓名"]', customerName)
    await authenticatedPage.fill('input[placeholder="请输入手机号"]', '13800138000')
    
    // 添加商品子表
    await authenticatedPage.click('button:has-text("添加商品")')
    
    // 填写第一行商品
    await authenticatedPage.fill('input[placeholder="商品名称"]', '测试商品 A')
    await authenticatedPage.fill('input[type="number"]', '99')
    
    // 提交
    await authenticatedPage.click('button:has-text("确定")')
    
    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
    
    // 验证列表中包含新客户
    await expect(authenticatedPage.locator('tbody')).toContainText(customerName)
  })

  test('修改客户（更新商品列表）', async ({ authenticatedPage }) => {
    // 点击修改
    await authenticatedPage.click('button:has-text("修改")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 修改客户信息
    // ...
    
    // 添加/修改商品
    // ...
    
    // 提交
    await authenticatedPage.click('button:has-text("确定")')
    
    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })

  test('查看客户详情（主子表数据）', async ({ authenticatedPage }) => {
    // 点击详情或修改按钮
    await authenticatedPage.click('button:has-text("修改")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    
    // 验证客户基本信息
    // ...
    
    // 验证商品列表
    const goodsRows = authenticatedPage.locator('.goods-table tbody tr')
    expect(await goodsRows.count()).toBeGreaterThan(0)
  })
})
```

---

## 6. 运行规范

### 6.1 运行测试

```bash
# 进入测试目录
cd scripts/test/e2e

# 安装依赖（首次）
pnpm install

# 运行所有测试
pnpm test

# 运行指定模块
pnpm test:login
pnpm test:student
pnpm test:product
pnpm test:customer

# 有头模式运行（打开浏览器）
pnpm exec playwright test --headed

# 调试模式
pnpm exec playwright test --debug
```

### 5.2 查看报告

```bash
# 生成并打开 HTML 报告
pnpm report

# 报告位置：scripts/test/e2e/reports/html/index.html
```

### 5.3 CI/CD 集成

```yaml
# GitHub Actions 示例
name: E2E Tests
on: [push, pull_request]
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm install -g pnpm
      - run: cd scripts/test/e2e && pnpm install && pnpm exec playwright install --with-deps chrome
      - run: cd scripts/test/e2e && pnpm test
      - uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: playwright-report
          path: scripts/test/e2e/reports/
```

---

## 7. 最佳实践

### 6.1 测试数据管理

**原则**：
- 测试数据使用唯一标识（如时间戳）
- 测试完成后清理创建的数据
- 避免依赖特定数据状态

**示例**：
```javascript
const testData = {
  name: `测试学生_${Date.now()}`, // 唯一标识
}

// 测试完成后清理
test.afterEach(async ({ authenticatedPage }) => {
  // 删除创建的数据
  // ...
})
```

### 6.2 选择器规范

**优先顺序**：
1. 角色选择器（`getByRole`）
2. 文本选择器（`getByText`）
3. 测试 ID（`[data-testid="xxx"]`）
4. CSS 选择器

**示例**：
```javascript
// 推荐
await page.getByRole('button', { name: '新增' }).click()
await page.getByPlaceholder('请输入学生名称').fill('张三')

// 不推荐（过于依赖具体实现）
await page.click('.el-button--primary:nth-child(1)')
```

### 6.3 断言规范

**常用断言**：
```javascript
// 验证 URL
await expect(page).toHaveURL(/\/index/)

// 验证元素可见
await expect(page.locator('.el-message')).toBeVisible()

// 验证文本内容
await expect(page.locator('tbody')).toContainText('张三')

// 验证元素数量
const rows = page.locator('tbody tr')
expect(await rows.count()).toBeGreaterThan(0)

// 验证元素状态
await expect(page.locator('button')).toBeEnabled()
await expect(page.locator('.loading')).not.toBeVisible()
```

### 6.4 等待策略

**避免硬编码等待**：
```javascript
// 不推荐
await page.waitForTimeout(3000)

// 推荐
await page.waitForLoadState('networkidle')
await expect(page.locator('.result')).toBeVisible()
```

---

## 8. 与 curl 测试的对比

| 维度 | curl 测试 | Playwright E2E 测试 |
|------|----------|-------------------|
| 测试对象 | 后端 API | 前后端完整流程 |
| 验证内容 | API 响应码/数据 | UI 交互 + 数据 + 路由 |
| 运行环境 | 后端服务 | 前端 + 后端 + 浏览器 |
| 输出报告 | 终端日志 | HTML 报告 + 截图 + 录像 |
| 调试方式 | 日志分析 | 浏览器 DevTools + 录像回放 |
| 执行速度 | 快（秒级） | 慢（分钟级） |
| 稳定性 | 高 | 受 UI 变化影响 |

---

## 9. 示例分类

| 示例类型 | 对应模块 | 测试文件 | 说明 |
|----------|----------|----------|------|
| 简单 CRUD | 学生管理 | `student.spec.js` | 单表增删改查 |
| 树形列表 | 产品管理 | `product.spec.js` | 树形结构操作 |
| 主子表 | 客户管理 | `customer.spec.js` | 主表 + 子表（商品列表） |

---

## 参考文档

- [Playwright 官方文档](https://playwright.dev)
- [后端接口自动化测试规范](testing.md)
- [API 设计规范](api-design.md)

---

## 10. 附录：定位器速查表

### 若依系统常用元素定位

| 元素类型 | 定位器 | 示例 |
|----------|--------|------|
| **菜单导航** | | |
| 侧边栏菜单项 | `.el-menu-item:has-text()` | `click('text=学生管理')` |
| 菜单展开 | `.el-submenu:has-text()` | `click('text=Demo 模块')` |
| 直接导航 | `goto('/path')` | `goto('/demo/student')` |
| **按钮** | | |
| 新增按钮 | `button:has-text("新增")` | `click()` |
| 修改按钮 | `button:has-text("修改")` | `click()` |
| 删除按钮 | `button:has-text("删除")` | `click()` |
| 搜索按钮 | `button:has-text("搜索")` | `click()` |
| 重置按钮 | `button:has-text("重置")` | `click()` |
| 导出按钮 | `button:has-text("导出")` | `click()` |
| 确定按钮 | `button:has-text("确定")` | `click()` |
| 取消按钮 | `button:has-text("取消")` | `click()` |
| **表单** | | |
| 文本输入框 | `input[placeholder="..."]` | `fill('value')` |
| 下拉选择框 | `.el-select` | `selectOption('0')` |
| 日期选择器 | `input[type="date"]` | `fill('2024-01-01')` |
| 单选框 | `input[type="radio"]` | `check()` |
| 复选框 | `input[type="checkbox"]` | `check()` |
| **表格** | | |
| 表格行 | `tbody tr` | `count()`, `nth(0)` |
| 表格单元格 | `tbody tr td` | `textContent()` |
| 包含文本的行 | `tbody tr:has-text("xxx")` | `click()` |
| 第一行 | `tbody tr.first()` | `click()` |
| **对话框** | | |
| 对话框标题 | `.el-dialog__title` | `waitForSelector()` |
| 对话框确定 | `.el-dialog__footer button:has-text("确定")` | `click()` |
| 对话框取消 | `.el-dialog__footer button:has-text("取消")` | `click()` |
| **消息提示** | | |
| 成功消息 | `.el-message--success` | `toBeVisible()` |
| 错误消息 | `.el-message--error` | `toBeVisible()` |
| 警告消息 | `.el-message--warning` | `toBeVisible()` |
| **确认框** | | |
| 确认对话框 | `.el-message-box` | `waitForSelector()` |
| 确认按钮 | `.el-message-box__btns button:has-text("确定")` | `click()` |
| 取消按钮 | `.el-message-box__btns button:has-text("取消")` | `click()` |
| **用户菜单** | | |
| 用户头像 | `.avatar-container` | `click()` |
| 退出登录 | `text=退出登录` | `click()` |
| 个人中心 | `text=个人中心` | `click()` |

---

**文档版本**: 1.0  
**最后更新**: 2026-04-08  
**基于版本**: RuoYi v3.9.2

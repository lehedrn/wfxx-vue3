import { test, expect } from '../fixtures/auth'

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

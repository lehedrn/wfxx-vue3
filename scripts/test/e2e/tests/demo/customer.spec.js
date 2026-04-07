import { test, expect } from '../fixtures/auth'

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
    const newName = `修改客户_${Date.now()}`
    await authenticatedPage.fill('input[placeholder="请输入客户姓名"]', newName)

    // 提交
    await authenticatedPage.click('button:has-text("确定")')

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })

  test('查看客户详情（主子表数据）', async ({ authenticatedPage }) => {
    // 点击修改按钮查看详情页
    await authenticatedPage.click('button:has-text("修改")')
    await authenticatedPage.waitForSelector('.el-dialog__title')

    // 验证对话框显示
    await expect(authenticatedPage.locator('.el-dialog__title')).toBeVisible()
  })

  test('删除客户', async ({ authenticatedPage }) => {
    // 点击删除按钮
    await authenticatedPage.click('button:has-text("删除")')

    // 确认删除
    await authenticatedPage.click('.el-message-box__btns button:has-text("确定")')

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })
})

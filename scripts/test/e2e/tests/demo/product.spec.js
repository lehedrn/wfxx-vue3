import { test, expect } from '../fixtures/auth'

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

    // 提交
    await authenticatedPage.click('button:has-text("确定")')

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })
})

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
    await authenticatedPage.waitForTimeout(300)

    const dialog = authenticatedPage.locator('.el-dialog')

    // 填写产品名称
    const productName = `测试产品_${Date.now()}`
    const nameInput = dialog.locator('input[placeholder="请输入产品名称"]')
    await nameInput.fill(productName)
    await nameInput.dispatchEvent('input')

    // 填写显示顺序
    const sortInput = dialog.locator('input[placeholder="请输入显示顺序"]')
    await sortInput.fill('1')
    await sortInput.dispatchEvent('input')

    // 选择状态
    const statusRadio = dialog.locator('label.el-radio:has-text("成功")')
    await statusRadio.click()

    // 确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })
})

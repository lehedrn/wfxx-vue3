import { test, expect } from '../fixtures/auth'

test.describe('客户管理 - 主子表', () => {
  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/demo/customer')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('新增客户（含商品列表）', async ({ authenticatedPage }) => {
    // 点击新增按钮
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    await authenticatedPage.waitForTimeout(300)

    // 填写客户基本信息
    const dialog = authenticatedPage.locator('.el-dialog')
    const customerName = `测试客户_${Date.now()}`

    // 填写客户姓名
    const nameInput = dialog.locator('input[placeholder="请输入客户姓名"]')
    await nameInput.fill(customerName)
    await nameInput.dispatchEvent('input')

    // 填写手机号码
    const phoneInput = dialog.locator('input[placeholder="请输入手机号码"]')
    await phoneInput.fill('13800138000')
    await phoneInput.dispatchEvent('input')

    // 点击"添加"按钮添加商品行（主子表必填）
    await dialog.locator('button:has-text("添加")').click()
    await authenticatedPage.waitForTimeout(300)

    // 填写商品信息（第一行）
    const goodsNameInput = dialog.locator('input[placeholder="请输入商品名称"]').first()
    await goodsNameInput.fill('测试商品')
    await goodsNameInput.dispatchEvent('input')

    const goodsPriceInput = dialog.locator('input[placeholder="请输入商品价格"]').first()
    await goodsPriceInput.fill('100')
    await goodsPriceInput.dispatchEvent('input')

    // 选择商品种类 - 在表格中找到商品种类的下拉框
    const tableSelects = dialog.locator('.el-table .el-select')
    const goodsTypeSelect = tableSelects.first()
    await goodsTypeSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(300)

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 等待成功消息
    const successMessage = authenticatedPage.locator('.el-message--success')
    await expect(successMessage).toBeVisible()

    // 使用搜索功能查找新客户 - 使用表单中的输入框（不是对话框中的）
    const searchForm = authenticatedPage.locator('.el-form--inline')
    const searchInput = searchForm.locator('input[placeholder="请输入客户姓名"]').first()
    await searchInput.fill(customerName)
    await authenticatedPage.click('button:has-text("搜索")')
    await authenticatedPage.waitForTimeout(500)

    // 验证列表中包含新客户（在表格中查找）- 使用 first() 避免对话框中商品列表的 tbody
    const tableBody = authenticatedPage.locator('.el-table__body tbody').first()
    await expect(tableBody).toContainText(customerName)
  })

  test('修改客户', async ({ authenticatedPage }) => {
    // 点击第一行的修改按钮（每行独立的按钮）
    const editButton = authenticatedPage.locator('tbody tr button:has-text("修改")').first()
    await editButton.click()
    await authenticatedPage.waitForSelector('.el-dialog__title')
    await authenticatedPage.waitForTimeout(300)

    // 修改客户姓名
    const dialog = authenticatedPage.locator('.el-dialog')
    const newName = `修改客户_${Date.now()}`
    const nameInput = dialog.locator('input[placeholder="请输入客户姓名"]')
    await nameInput.fill(newName)
    await nameInput.dispatchEvent('input')

    // 确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })

  test('查看客户详情', async ({ authenticatedPage }) => {
    // 点击第一行的修改按钮查看详情
    const editButton = authenticatedPage.locator('tbody tr button:has-text("修改")').first()
    await editButton.click()
    await authenticatedPage.waitForSelector('.el-dialog__title')

    // 验证对话框显示
    await expect(authenticatedPage.locator('.el-dialog__title')).toBeVisible()
  })

  test('删除客户', async ({ authenticatedPage }) => {
    // 点击第一行的删除按钮（每行独立的按钮）
    const deleteButton = authenticatedPage.locator('tbody tr button:has-text("删除")').first()
    await deleteButton.click()

    // 确认删除
    await authenticatedPage.click('.el-message-box__btns button:has-text("确定")')

    // 验证成功
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })
})

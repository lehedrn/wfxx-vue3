import { test, expect } from '../fixtures/auth'

test.describe('区划管理 - 树形结构', () => {
  const testData = {
    name: `测试区县_${Date.now()}`,
    code: '999999',
    areaLevel: '3',
    sort: 1
  }

  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/system/area')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('页面加载与树形数据展示', async ({ authenticatedPage }) => {
    // 检查表格是否存在（注意使用 CSS 类选择器 .el-table）
    await expect(authenticatedPage.locator('.el-table').first()).toBeVisible()

    // 检查树形表格是否有数据
    const rows = authenticatedPage.locator('.el-table__row')
    const rowCount = await rows.count()
    expect(rowCount).toBeGreaterThan(0)
    console.log(`表格行数: ${rowCount}`)
  })

  test('展开/折叠树形节点', async ({ authenticatedPage }) => {
    // 点击展开/折叠按钮
    await authenticatedPage.click('button:has-text("展开/折叠")')

    // 等待树形展开
    await authenticatedPage.waitForTimeout(500)

    // 检查是否有子节点展开
    const expandedRows = authenticatedPage.locator('.el-table__row')
    const expandedCount = await expandedRows.count()
    expect(expandedCount).toBeGreaterThan(0)
    console.log(`展开后表格行数: ${expandedCount}`)
  })

  test('搜索功能 - 按名称', async ({ authenticatedPage }) => {
    // 输入搜索条件
    await authenticatedPage.fill('input[placeholder="请输入区划名称"]', '北京')

    // 点击搜索按钮
    await authenticatedPage.click('button:has-text("搜索")')
    await authenticatedPage.waitForTimeout(500)

    // 检查表格是否返回结果
    const rows = authenticatedPage.locator('.el-table__row')
    const rowCount = await rows.count()
    expect(rowCount).toBeGreaterThan(0)
    console.log(`搜索 "北京" 返回 ${rowCount} 条结果`)
  })

  test('搜索功能 - 重置', async ({ authenticatedPage }) => {
    // 先输入搜索条件
    await authenticatedPage.fill('input[placeholder="请输入区划名称"]', '北京')
    await authenticatedPage.click('button:has-text("搜索")')
    await authenticatedPage.waitForTimeout(500)

    // 点击重置按钮
    await authenticatedPage.click('button:has-text("重置")')
    await authenticatedPage.waitForTimeout(500)

    // 检查搜索框是否被清空
    const searchInput = authenticatedPage.locator('input[placeholder="请输入区划名称"]')
    const inputValue = await searchInput.inputValue()
    expect(inputValue).toBe('')
  })

  test('新增区划', async ({ authenticatedPage }) => {
    // 点击新增按钮
    await authenticatedPage.click('button:has-text("新增")')

    // 等待对话框打开
    await authenticatedPage.waitForSelector('.el-dialog')

    const dialog = authenticatedPage.locator('.el-dialog')

    // 填写区划名称
    const nameInput = dialog.locator('input[placeholder="请输入区划名称"]')
    await nameInput.fill(testData.name)

    // 填写区划编码
    const codeInput = dialog.locator('input[placeholder="请输入区划编码"]')
    await codeInput.fill(testData.code)

    // 选择层级（radio - 县/区）
    const levelRadio = dialog.locator(`label.el-radio:has-text("县/区")`)
    if (await levelRadio.count() > 0) {
      await levelRadio.first().click()
    }

    // 填写排序号
    const sortInput = dialog.locator('input[placeholder="请输入排序号"]')
    await sortInput.fill(String(testData.sort))

    // 确保名称字段值正确
    await nameInput.click()
    await nameInput.fill(testData.name)
    await nameInput.dispatchEvent('input')

    // 点击对话框标题区域失去焦点
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 截图保存提交前状态
    await authenticatedPage.screenshot({ path: 'reports/debug/area-before-submit.png' })

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 等待对话框关闭或显示错误
    await authenticatedPage.waitForTimeout(1000)

    // 检查对话框是否还存在
    const dialogStillVisible = await dialog.count()
    if (dialogStillVisible > 0) {
      // 如果对话框仍然存在，检查是否有验证错误
      const errorCount = await authenticatedPage.locator('.el-form-item__error').count()
      if (errorCount > 0) {
        const errorMsg = await authenticatedPage.locator('.el-form-item__error').first().textContent()
        console.log('表单验证错误:', errorMsg)
      } else {
        console.log('对话框仍未关闭，等待...')
        await authenticatedPage.waitForTimeout(2000)
      }
    }

    // 检查成功消息
    const successMsg = authenticatedPage.locator('.el-message--success')
    await expect(successMsg).toBeVisible({ timeout: 10000 })
    const msgText = await successMsg.textContent()
    console.log('新增响应:', msgText)

    // 刷新页面检查新增数据
    await authenticatedPage.reload()
    await authenticatedPage.waitForLoadState('networkidle')
    await authenticatedPage.waitForTimeout(500)

    // 搜索新增的数据
    await authenticatedPage.fill('input[placeholder="请输入区划名称"]', testData.name)
    await authenticatedPage.click('button:has-text("搜索")')
    await authenticatedPage.waitForTimeout(500)

    const rows = authenticatedPage.locator('.el-table__row')
    const rowCount = await rows.count()
    expect(rowCount).toBeGreaterThan(0)
    console.log('✅ 新增区划成功并在列表中验证')
  })

  test('修改区划', async ({ authenticatedPage }) => {
    // 等待表格加载
    await authenticatedPage.waitForSelector('.el-table__row')

    // 点击第一行的修改按钮
    await authenticatedPage.click('.el-table__row button:has-text("修改")')

    // 等待对话框打开
    await authenticatedPage.waitForSelector('.el-dialog')

    const dialog = authenticatedPage.locator('.el-dialog')

    // 修改排序号
    const sortInput = dialog.locator('input[placeholder="请输入排序号"]')
    await sortInput.click()
    await sortInput.fill('10')

    // 点击标题区域失去焦点
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 等待成功消息
    const successMsg = authenticatedPage.locator('.el-message--success')
    await expect(successMsg).toBeVisible({ timeout: 5000 })

    console.log('✅ 修改区划成功')
  })

  test('删除区划', async ({ authenticatedPage }) => {
    // 等待表格加载
    await authenticatedPage.waitForSelector('.el-table__row')

    // 查找最后一条数据
    const rows = authenticatedPage.locator('.el-table__row')
    const rowCount = await rows.count()

    if (rowCount > 0) {
      // 点击最后一行的删除按钮
      const lastRow = rows.last()
      await lastRow.locator('button:has-text("删除")').click()

      // 等待确认对话框出现
      await authenticatedPage.waitForSelector('.el-message-box', { timeout: 5000 })

      // 点击确认按钮 - 使用多种选择器尝试
      const confirmBtn = authenticatedPage.locator('.el-message-box__btns button.el-button--primary')
      if (await confirmBtn.count() > 0) {
        await confirmBtn.first().click()
      } else {
        // 备选：按文本查找
        await authenticatedPage.locator('button:has-text("确定")').first().click()
      }

      // 等待成功消息
      const successMsg = authenticatedPage.locator('.el-message--success')
      await expect(successMsg).toBeVisible({ timeout: 10000 })

      console.log('✅ 删除区划成功')
    }
  })
})

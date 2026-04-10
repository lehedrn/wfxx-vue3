import { test, expect } from '../fixtures/auth'

test.describe('设备型号管理', () => {
  const testData = {
    name: `测试设备型号_${Date.now()}`,
    deviceType: '边缘计算盒子',
    memory: 16,
    disk: 512,
    os: 'Linux',
    cpuModel: 'RK3588',
    gpuModel: 'Jetson Nano JEPCK4.6'
  }

  test.beforeEach(async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/base/deviceModel')
    await authenticatedPage.waitForLoadState('networkidle')
  })

  test('新增设备型号', async ({ authenticatedPage }) => {
    // 点击新增按钮
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')

    const dialog = authenticatedPage.locator('.el-dialog')

    // 选择设备类型（使用键盘操作，参考 student.spec.js 成功模式）
    const deviceTypeSelect = dialog.locator('.el-form-item:has-text("设备类型") .el-select').first()
    await deviceTypeSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.waitForTimeout(100)
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 填写设备型号名称
    const nameInput = dialog.locator('input[placeholder="请输入设备型号名称"]')
    await nameInput.fill(testData.name)

    // 填写内存
    const memoryInput = dialog.locator('input[placeholder="请输入内存(GB)"]')
    await memoryInput.fill(String(testData.memory))

    // 填写硬盘容量
    const diskInput = dialog.locator('input[placeholder="请输入硬盘容量(GB)"]')
    await diskInput.fill(String(testData.disk))

    // 选择操作系统
    const osSelect = dialog.locator('.el-form-item:has-text("操作系统") .el-select').first()
    await osSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.waitForTimeout(100)
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 选择CPU型号
    const cpuSelect = dialog.locator('.el-form-item:has-text("CPU型号") .el-select').first()
    await cpuSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.waitForTimeout(100)
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 选择GPU型号
    const gpuSelect = dialog.locator('.el-form-item:has-text("GPU型号") .el-select').first()
    await gpuSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.waitForTimeout(100)
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 选择状态（radio - 成功）
    const statusRadio = dialog.locator('label.el-radio:has-text("成功")')
    if (await statusRadio.count() > 0) {
      await statusRadio.first().click()
    }

    // 让输入框失去焦点，确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 截图保存提交前状态
    await authenticatedPage.screenshot({ path: 'reports/debug/deviceModel-before-submit.png' })

    // 提交
    await dialog.locator('button:has-text("确 定")').click()
    await authenticatedPage.waitForTimeout(1000)

    // 检查是否有错误消息
    const errorMessage = authenticatedPage.locator('.el-message--error')
    if (await errorMessage.count() > 0) {
      const errorText = await errorMessage.first().textContent()
      console.log('提交失败:', errorText)
      throw new Error('提交失败：' + errorText)
    }

    // 验证成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 验证列表中包含新增数据
    const tableBody = authenticatedPage.locator('.el-table__body tbody')
    await expect(tableBody).toContainText(testData.name)
  })

  test('查询设备型号', async ({ authenticatedPage }) => {
    // 先创建一个用于查询
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')

    const dialog = authenticatedPage.locator('.el-dialog')
    const queryTestName = `查询测试_${Date.now()}`

    const nameInput = dialog.locator('input[placeholder="请输入设备型号名称"]')
    await nameInput.fill(queryTestName)

    // 选择设备类型（使用键盘操作）
    const deviceTypeSelect = dialog.locator('.el-form-item:has-text("设备类型") .el-select').first()
    await deviceTypeSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.waitForTimeout(100)
    await authenticatedPage.press('body', 'Enter')
    await authenticatedPage.waitForTimeout(200)

    // 填写内存
    const memoryInput = dialog.locator('input[placeholder="请输入内存(GB)"]')
    await memoryInput.fill('8')

    // 选择状态
    const statusRadio = dialog.locator('label.el-radio:has-text("成功")')
    if (await statusRadio.count() > 0) {
      await statusRadio.first().click()
    }

    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    await dialog.locator('button:has-text("确 定")').click()
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 在查询框输入名称
    await authenticatedPage.fill('input[placeholder="请输入设备型号名称"]', queryTestName)
    await authenticatedPage.click('button:has-text("搜索")')

    // 验证查询结果
    const tableBody = authenticatedPage.locator('.el-table__body tbody')
    await expect(tableBody).toContainText(queryTestName)
  })

  test('修改设备型号', async ({ authenticatedPage }) => {
    // 点击第一行的修改按钮
    const row = authenticatedPage.locator('tbody tr').first()
    const editButton = row.locator('button:has-text("修改")')
    await editButton.click()

    await authenticatedPage.waitForSelector('.el-dialog__title')
    await authenticatedPage.waitForTimeout(300)

    const dialog = authenticatedPage.locator('.el-dialog')
    const newName = `修改测试_${Date.now()}`

    // 修改名称
    const nameInput = dialog.locator('input[placeholder="请输入设备型号名称"]')
    await nameInput.fill(newName)
    await nameInput.dispatchEvent('input')

    // 确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 提交
    await authenticatedPage.click('button:has-text("确 定")')

    // 等待成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 验证列表中包含修改后的数据
    const dataTable = authenticatedPage.locator('.el-table__body')
    await expect(dataTable).toContainText(newName)
  })

  test('删除设备型号', async ({ authenticatedPage }) => {
    // 点击第一行的删除按钮
    const deleteButton = authenticatedPage.locator('tbody tr button:has-text("删除")').first()
    await deleteButton.click()

    // 确认删除
    await authenticatedPage.click('.el-message-box__btns button:has-text("确定")')

    // 验证成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()
  })

  test('导出设备型号数据', async ({ authenticatedPage }) => {
    // 监听下载事件
    const downloadPromise = authenticatedPage.waitForEvent('download')

    // 点击导出按钮
    await authenticatedPage.click('button:has-text("导出")')

    // 验证文件开始下载
    const download = await downloadPromise
    expect(download.suggestedFilename()).toMatch(/.*\.xlsx/)
  })
})

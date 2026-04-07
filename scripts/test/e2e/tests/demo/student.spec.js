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

    // 填写学生名称
    await authenticatedPage.fill('input[placeholder="请输入学生名称"]', testData.name)

    // 选择性别 - 通过 label 定位到性别字段，然后找到 el-select
    const dialog = authenticatedPage.locator('.el-dialog')
    const sexFormItem = dialog.locator('.el-form-item:has-text("性别")').first()
    const sexSelect = sexFormItem.locator('.el-select').first()
    await sexSelect.click()

    // 使用键盘操作：按下方向键选择第一个选项（男），然后回车
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

    // 选择生日（点击输入框弹出日期选择器）
    const birthdayInput = dialog.locator('input[placeholder="请选择生日"]')
    await birthdayInput.click()

    // 等待日期选择器面板出现并选择日期
    await authenticatedPage.waitForTimeout(300)

    // 尝试多种选择器查找日期单元格
    const dateCell = authenticatedPage.locator('.el-date-table td:has-text("15"):not(.disabled)').first()
    const dateCellAlt = authenticatedPage.locator('td:has-text("15")').first()

    if (await dateCell.count() > 0) {
      await dateCell.click({ force: true })
    } else if (await dateCellAlt.count() > 0) {
      await dateCellAlt.click({ force: true })
    }

    // 等待日期选择器关闭
    await authenticatedPage.waitForTimeout(300)

    // 选择爱好（checkbox - 钓鱼）
    const hobbyCheckbox = dialog.locator('label.el-checkbox:has-text("钓鱼")')
    if (await hobbyCheckbox.count() > 0) {
      await hobbyCheckbox.first().click()
    }

    // 重新填写学生名称（防止被清空）- 使用 type 模拟真实输入
    const nameInput = dialog.locator('input[placeholder="请输入学生名称"]')
    await nameInput.click()
    await nameInput.fill(testData.name)

    // 触发 input 事件确保 Vue 响应式系统捕获值
    await nameInput.dispatchEvent('input')
    await authenticatedPage.waitForTimeout(100)

    // 验证学生名称已填写
    const nameValue = await nameInput.inputValue()
    console.log('学生名称:', nameValue)

    // 点击对话框标题区域让输入框失去焦点，确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 截图保存提交前状态
    await authenticatedPage.screenshot({ path: 'reports/debug/student-before-submit.png' })

    // 提交
    await dialog.locator('button:has-text("确 定")').click()

    // 等待更长时间让对话框关闭
    await authenticatedPage.waitForTimeout(1000)

    // 检查对话框是否还存在
    const dialogStillVisible = await dialog.count()
    console.log('对话框是否还在:', dialogStillVisible)

    // 检查是否有错误消息
    const errorMessage = authenticatedPage.locator('.el-message--error')
    if (await errorMessage.count() > 0) {
      const errorText = await errorMessage.first().textContent()
      console.log('提交失败:', errorText)
      // 截图保存错误消息
      await authenticatedPage.screenshot({ path: 'reports/debug/student-submit-error.png' })
      throw new Error('提交失败：' + errorText)
    }

    // 验证成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 验证列表中包含新增数据（使用表格的 tbody，不是日期选择器的）
    const tableBody = authenticatedPage.locator('.el-table__body tbody')
    await expect(tableBody).toContainText(testData.name)
  })

  test('查询学生', async ({ authenticatedPage }) => {
    // 先创建一个学生用于查询
    await authenticatedPage.click('button:has-text("新增")')
    await authenticatedPage.waitForSelector('.el-dialog__title')
    const queryTestName = `查询测试_${Date.now()}`

    const dialog = authenticatedPage.locator('.el-dialog')

    // 选择性别
    const sexSelect = dialog.locator('.el-select').first()
    await sexSelect.click()
    await authenticatedPage.waitForTimeout(300)
    await authenticatedPage.press('body', 'ArrowDown')
    await authenticatedPage.press('body', 'Enter')

    // 选择状态
    const statusRadio = dialog.locator('label.el-radio:has-text("成功")')
    await statusRadio.click()

    // 选择爱好
    const hobbyCheckbox = dialog.locator('label.el-checkbox:has-text("钓鱼")')
    await hobbyCheckbox.click()

    // 填写学生名称（最后填写，确保值已同步）
    const nameInput = dialog.locator('input[placeholder="请输入学生名称"]')
    await nameInput.fill(queryTestName)
    await nameInput.dispatchEvent('input')
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    await authenticatedPage.click('button:has-text("确 定")')
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 在查询框输入
    await authenticatedPage.fill('input[placeholder="请输入学生名称"]', queryTestName)
    await authenticatedPage.click('button:has-text("搜索")')

    // 验证查询结果
    const tableBody = authenticatedPage.locator('.el-table__body tbody')
    await expect(tableBody).toContainText(queryTestName)
  })

  test('修改学生', async ({ authenticatedPage }) => {
    // 点击第一行的修改按钮
    const row = authenticatedPage.locator('tbody tr').first()
    const editButton = row.locator('button:has-text("修改")')
    await editButton.click()

    // 等待对话框和表单加载
    await authenticatedPage.waitForSelector('.el-dialog__title')
    await authenticatedPage.waitForTimeout(300)

    // 修改数据
    const dialog = authenticatedPage.locator('.el-dialog')
    const newName = testData.name + '_修改'
    const nameInput = dialog.locator('input[placeholder="请输入学生名称"]')
    await nameInput.fill(newName)
    await nameInput.dispatchEvent('input')

    // 确保值已同步
    await dialog.locator('.el-dialog__title').click()
    await authenticatedPage.waitForTimeout(200)

    // 提交
    await authenticatedPage.click('button:has-text("确 定")')

    // 等待成功提示
    await expect(authenticatedPage.locator('.el-message--success')).toBeVisible()

    // 验证列表中包含修改后的数据（使用数据表的选择器）
    const dataTable = authenticatedPage.locator('.el-table__body')
    await expect(dataTable).toContainText(newName)
  })

  test('删除学生', async ({ authenticatedPage }) => {
    // 点击第一行的删除按钮
    const deleteButton = authenticatedPage.locator('tbody tr button:has-text("删除")').first()
    await deleteButton.click()

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

import { test, expect } from './fixtures/auth'

test.describe('登录认证', () => {
  test('成功登录', async ({ page }) => {
    await page.goto('/login')
    await page.waitForLoadState('networkidle')

    await page.fill('input[placeholder="账号"]', 'admin')
    await page.fill('input[placeholder="密码"]', 'admin123')

    // 处理验证码（如果启用）
    const captchaInput = page.locator('input[placeholder="验证码"]')
    if (await captchaInput.isVisible()) {
      await captchaInput.fill('8')
    }

    await page.click('button:has-text("登 录")')
    await page.waitForURL(/\/index/)

    // 验证登录后跳转到首页
    await expect(page).toHaveURL(/\/index/)
  })

  test('密码错误', async ({ page }) => {
    await page.goto('/login')
    await page.waitForLoadState('networkidle')

    await page.fill('input[placeholder="账号"]', 'admin')
    await page.fill('input[placeholder="密码"]', 'wrongpassword')
    await page.click('button:has-text("登 录")')

    // 验证显示错误提示
    await expect(page.locator('.el-message--error')).toBeVisible()
  })

  test('退出登录', async ({ authenticatedPage }) => {
    // 已登录状态
    await authenticatedPage.goto('/index')

    // 点击用户头像下拉
    await authenticatedPage.click('.avatar-container')
    await authenticatedPage.waitForTimeout(500)

    // 点击退出登录
    await authenticatedPage.click('li.el-dropdown-menu__item:has-text("退出登录")')

    // 等待确认对话框并点击确定
    await authenticatedPage.waitForSelector('.el-message-box')
    await authenticatedPage.click('.el-message-box__btns button:has-text("确定")')

    // 验证跳转到登录页
    await authenticatedPage.waitForURL(/\/login/)
    await expect(authenticatedPage).toHaveURL(/\/login/)
  })
})

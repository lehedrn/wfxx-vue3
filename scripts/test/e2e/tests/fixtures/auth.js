import { test as base } from '@playwright/test'

export const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    // 访问登录页
    await page.goto('/login')

    // 等待页面加载
    await page.waitForLoadState('networkidle')

    // 填写登录表单（使用 placeholder 定位）
    await page.fill('input[placeholder="账号"]', 'admin')
    await page.fill('input[placeholder="密码"]', 'admin123')

    // 处理验证码（如果启用）
    const captchaInput = page.locator('input[placeholder="验证码"]')
    if (await captchaInput.isVisible()) {
      await captchaInput.fill('8') // 或使用 OCR 识别
    }

    // 提交登录
    await page.click('button:has-text("登 录")')

    // 等待登录成功，跳转到首页
    await page.waitForURL(/\/index/)
    await page.waitForLoadState('networkidle')

    await use(page)
  }
})

export { expect } from '@playwright/test'

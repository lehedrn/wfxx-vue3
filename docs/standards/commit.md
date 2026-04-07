# Git 提交规范

本文档规定 RuoYi-Vue 3.9.2 项目的 Git 提交信息规范，确保提交历史清晰、可读、可追溯。

---

## 1. 提交信息格式

### 1.1 基本格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**说明**：
- `type`：提交类型（必填）
- `scope`：影响范围（可选）
- `subject`：简短描述（必填）
- `body`：详细描述（可选）
- `footer`：脚注（可选，用于关联 Issue 或 Breaking Changes）

### 1.2 示例

```bash
# 单行提交
git commit -m "feat(user): 新增用户导入功能"

# 多行提交
git commit -m "feat(user): 新增用户导入功能

- 支持 Excel 文件导入
- 支持批量导入（最大 1000 条）
- 导入失败时显示错误详情

Closes #123"
```

---

## 2. 提交类型（type）

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(user): 新增用户导入功能` |
| `fix` | 修复 Bug | `fix(login): 修复登录验证码不显示问题` |
| `docs` | 文档变更 | `docs(readme): 更新快速开始说明` |
| `style` | 代码格式（不影响功能） | `style(user): 格式化用户列表代码` |
| `refactor` | 重构（非新功能、非 Bug 修复） | `refactor(auth): 重构认证逻辑` |
| `perf` | 性能优化 | `perf(query): 优化查询语句提升响应速度` |
| `test` | 添加或修改测试 | `test(user): 添加用户服务单元测试` |
| `chore` | 构建过程或辅助工具变更 | `chore(deps): 升级 Element Plus 版本` |
| `ci` | CI/CD 配置变更 | `ci(github): 添加 GitHub Actions 配置` |
| `build` | 构建系统或外部依赖变更 | `build(maven): 升级 Maven 插件版本` |
| `revert` | 回滚提交 | `revert: 回滚 "feat(user): 新增用户导入"` |

---

## 3. 影响范围（scope）

### 3.1 后端模块

| 范围 | 说明 |
|------|------|
| `admin` | ruoyi-admin 模块 |
| `common` | ruoyi-common 模块 |
| `framework` | ruoyi-framework 模块 |
| `system` | ruoyi-system 模块 |
| `quartz` | ruoyi-quartz 模块 |
| `generator` | ruoyi-generator 模块 |
| `demo` | ruoyi-demo 模块 |

### 3.2 前端模块

| 范围 | 说明 |
|------|------|
| `ui` | ruoyi-ui 前端整体 |
| `ui-api` | 前端 API 接口 |
| `ui-components` | 前端组件 |
| `ui-views` | 前端页面视图 |
| `ui-store` | 前端状态管理 |
| `ui-utils` | 前端工具函数 |

### 3.3 通用范围

| 范围 | 说明 |
|------|------|
| `deps` | 依赖升级 |
| `config` | 配置文件 |
| `scripts` | 脚本工具 |
| `docs` | 项目文档 |

---

## 4. 提交主题（subject）

### 4.1 书写规则

1. **使用祈使句**（现在时态）
   - ✅ `feat(user): 新增用户导入功能`
   - ❌ `feat(user): 新增了用户导入功能`
   - ❌ `feat(user): 新增用户导入功能的实现`

2. **首字母小写**（中文不适用）
   - ✅ `fix(login): fix captcha display issue`
   - ❌ `fix(login): Fix captcha display issue`

3. **结尾不加句号**
   - ✅ `feat(user): 新增用户导入功能`
   - ❌ `feat(user): 新增用户导入功能。`

4. **长度限制**
   - 单行不超过 72 个字符（英文）或 50 个汉字

### 4.2 常用动词

| 操作 | 动词 |
|------|------|
| 新增 | 新增、添加、创建 |
| 修改 | 修改、更新、优化 |
| 删除 | 删除、移除 |
| 修复 | 修复、修正 |
| 重构 | 重构、调整、整理 |

---

## 5. 详细描述（body）

### 5.1 何时需要 body

以下情况建议添加 body：

1. **复杂的变更**：需要说明变更原因和实现方式
2. **影响范围大的变更**：需要列出受影响的模块
3. **Breaking Changes**：需要说明迁移方案
4. **Bug 修复**：需要说明问题原因和解决方案

### 5.2 body 格式

```bash
git commit -m "feat(user): 新增用户导入功能

## 变更内容
- 支持 Excel 文件导入（.xlsx/.xls）
- 支持批量导入（最大 1000 条）
- 导入失败时显示错误详情

## 技术实现
- 使用 Apache POI 解析 Excel 文件
- 异步处理导入任务，避免阻塞主线程
- 导入结果通过消息通知用户

## 测试情况
- 已测试 100 条、500 条、1000 条数据导入
- 已测试格式错误、数据重复等异常场景"
```

---

## 6. 脚注（footer）

### 6.1 关联 Issue

```bash
git commit -m "fix(login): 修复登录验证码不显示

Closes #123
Related to #456"
```

### 6.2 Breaking Changes

```bash
git commit -m "refactor(auth): 重构认证模块

## Breaking Changes
- 移旧的 `TokenUtil` 类，请使用新的 `JwtUtil`
- `login()` 方法参数顺序变更，请使用命名参数

Migration:
1. 替换所有 `TokenUtil` 引用为 `JwtUtil`
2. 更新 `login()` 方法调用"
```

### 6.3 联合署名

```bash
git commit -m "feat(user): 新增用户导入功能

Co-Authored-By: Zhang San <zhangsan@example.com>
Co-Authored-By: Li Si <lisi@example.com>"
```

---

## 7. 提交规范示例

### 7.1 新功能

```bash
# 简单新功能
git commit -m "feat(user): 新增用户导入功能"

# 复杂新功能
git commit -m "feat(user): 新增用户导入功能

- 支持 Excel 文件导入（.xlsx/.xls）
- 支持批量导入（最大 1000 条）
- 导入失败时显示错误详情

Closes #123"
```

### 7.2 Bug 修复

```bash
# 简单 Bug 修复
git commit -m "fix(login): 修复登录验证码不显示问题"

# 复杂 Bug 修复
git commit -m "fix(query): 修复分页查询结果不准确问题

问题原因：PageHelper 在多线程环境下上下文污染
解决方案：使用 ThreadLocal 隔离线程上下文

Closes #456"
```

### 7.3 文档变更

```bash
git commit -m "docs(readme): 更新快速开始说明

- 补充环境要求说明
- 添加常见问题解答
- 更新配置文件说明"
```

### 7.4 依赖升级

```bash
git commit -m "chore(deps): 升级 Element Plus 至 2.13.1

变更内容：
- Element Plus: 2.9.0 → 2.13.1
- Vue: 3.5.12 → 3.5.26

修复了以下问题：
- 表格组件在大数据量下的性能问题
- 日期选择器的时区问题"
```

### 7.5 重构

```bash
git commit -m "refactor(auth): 重构认证逻辑

## 重构原因
- 原有代码耦合度高，难以测试
- 认证流程分散在多个类中

## 重构内容
- 提取认证接口 `AuthenticationService`
- 统一认证流程到 `AuthManager` 类
- 添加认证结果封装类 `AuthResult`

## 影响范围
- 修改 `SysLoginService` 类
- 修改 `JwtAuthenticationTokenFilter` 类
- 新增 `AuthService` 接口及实现

## 测试情况
- 已有单元测试全部通过
- 添加 5 个新的单元测试用例"
```

### 7.6 回滚提交

```bash
git commit -m "revert: 回滚 \"feat(user): 新增用户导入功能\"

回滚原因：导入功能导致内存泄漏
原提交：abc123def"
```

---

## 8. 分支命名规范

### 8.1 分支类型

| 分支类型 | 命名格式 | 说明 |
|----------|----------|------|
| 主分支 | `master` / `main` | 生产环境代码 |
| 开发分支 | `develop` | 开发环境代码 |
| 功能分支 | `feature/xxx` | 新功能开发 |
| 修复分支 | `fix/xxx` | Bug 修复 |
| 发布分支 | `release/v1.0.0` | 发布版本 |
| 热修复分支 | `hotfix/xxx` | 紧急修复 |

### 8.2 分支命名示例

```bash
# 功能分支
feature/user-import
feature/login-captcha

# 修复分支
fix/login-issue
fix/query-pagination

# 发布分支
release/v3.9.2
release/v4.0.0

# 热修复分支
hotfix/security-patch
hotfix/memory-leak
```

---

## 9. Git 工作流

### 9.1 功能开发流程

```bash
# 1. 从 develop 分支创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/user-import

# 2. 开发功能并提交
git add .
git commit -m "feat(user): 新增用户导入功能"

# 3. 推送到远程
git push origin feature/user-import

# 4. 创建 Pull Request
# 5. 代码审查通过后合并到 develop
```

### 9.2 Bug 修复流程

```bash
# 1. 从 develop 分支创建修复分支
git checkout develop
git pull origin develop
git checkout -b fix/login-issue

# 2. 修复 Bug 并提交
git add .
git commit -m "fix(login): 修复登录验证码不显示问题"

# 3. 推送到远程并创建 PR
git push origin fix/login-issue
```

---

## 10. 工具配置

### 10.1 Commitlint 配置

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'chore', 'ci', 'build', 'revert'
    ]],
    'subject-full-stop': [2, 'never'],
    'subject-max-length': [2, 'always', 72]
  }
};
```

### 10.2 Husky 配置

```json
// package.json
{
  "husky": {
    "hooks": {
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  }
}
```

### 10.3 提交模板

```bash
# .gitmessage
# <type>(<scope>): <subject>
# |<----  使用最多 72 个字符  ---->|


# 详细描述（可选）
# - 变更内容 1
# - 变更内容 2


# 关联 Issue（可选）
# Closes #123
```

```bash
# 配置提交模板
git config commit.template .gitmessage
```

---

## 11. 检查清单

提交前请检查：

- [ ] 提交类型是否正确
- [ ] 影响范围是否明确（如适用）
- [ ] 主题是否简洁清晰（不超过 72 字符）
- [ ] 主题是否使用祈使句
- [ ] 主题结尾是否没有句号
- [ ] 是否添加了必要的详细描述
- [ ] 是否关联了相关 Issue（如适用）
- [ ] 代码是否通过了测试
- [ ] 是否遵循了项目编码规范

---

## 12. 参考资料

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Git Commit 规范](https://github.com/zhuanzhuanfe/git-commit-specification)

---

**创建时间**: 2026-04-08  
**基于版本**: RuoYi v3.9.2

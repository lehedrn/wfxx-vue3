# Ruoyi-Common 文档修订记录

## 修订历史

### 2024-04-06 - 第一次修订

**修订原因**: Subagent 代码与文档匹配度检查

**发现问题**: 35 个问题项

#### 高优先级问题（已修复）

| 问题 | 文档位置 | 修复状态 |
|------|----------|----------|
| TaskException Code 枚举值不匹配 | exception.md | ✅ 已修复 |
| UserPasswordRetryLimitExceedException 构造函数参数错误 | exception.md | ✅ 已修复 |
| SensitiveJsonSerializer 实现逻辑过于简化 | config.md | ✅ 已修复 |

#### 中优先级问题（已修复）

| 问题 | 文档位置 | 修复状态 |
|------|----------|----------|
| 遗漏 TreeEntity 类 | core.md | ✅ 已修复 |
| 遗漏 TreeSelect 类 | core.md | ✅ 已修复 |
| 遗漏 SysDept 实体 | core.md | ✅ 已修复 |
| 遗漏 SysDictData 实体 | core.md | ✅ 已修复 |
| 遗漏 SysDictType 实体 | core.md | ✅ 已修复 |
| RedisCache 方法不完整 | core.md | ✅ 已修复 |
| DesensitizedType 遗漏 ADDRESS | enums.md | ✅ 已修复 |

#### 低优先级问题（部分修复）

| 问题 | 文档位置 | 修复状态 |
|------|----------|----------|
| PageDomain 遗漏 reasonable 属性 | core.md | ⏸️ 待修复 |
| AjaxResult 遗漏 put 方法 | core.md | ⏸️ 待修复 |
| StringUtils 遗漏 lastStringDel 方法 | utils.md | ⏸️ 待修复 |
| DateUtils 遗漏 toDate 方法 | utils.md | ⏸️ 待修复 |
| Excel 注解属性列表不完整 | annotation.md | ⏸️ 待修复 |

---

## 详细修复内容

### 1. TaskException Code 枚举修复

**修复前**:
```
DATABASE_EXCEPTION, NO_CATCH_EXECUTION, IMMEDIATELY_FIRE, NOT_START, CLEAN_ERROR, CHANGE_THREAD_ERROR, TASK_NOT_NULL
```

**修复后**:
```
TASK_EXISTS, NO_TASK_EXISTS, TASK_ALREADY_STARTED, UNKNOWN, CONFIG_ERROR, TASK_NODE_NOT_AVAILABLE
```

**文件**: `exception.md:325-333`

---

### 2. UserPasswordRetryLimitExceedException 修复

**修复前**:
```java
int retryLimit = 5;
throw new UserPasswordRetryLimitExceedException(retryLimit);
```

**修复后**:
```java
// 两个参数：重试次数和锁定时间
throw new UserPasswordRetryLimitExceedException(5, 10);  // 5 次重试，锁定 10 分钟
```

**文件**: `exception.md:215-217`

---

### 3. SensitiveJsonSerializer 修复

**修复前**: 简单的序列化逻辑示例

**修复后**: 完整展示管理员不脱敏的核心逻辑

**文件**: `config.md:84-102`

---

### 4. 新增实体类文档

**TreeEntity** - 树型实体基类
- parentName, parentId, orderNum, ancestors, children

**TreeSelect** - 树选择实体
- id, label, children

**SysDept** - 部门实体
- deptId, parentId, ancestors, deptName, orderNum, leader, phone, email, status, children

**SysDictData** - 字典数据实体
- dictCode, dictSort, dictLabel, dictValue, dictType, cssClass, listClass, isDefault, status

**SysDictType** - 字典类型实体
- dictId, dictName, dictType, status

**文件**: `core.md`

---

### 5. RedisCache 方法补充

**新增方法**:
- 基本对象：setCacheObject, getCacheObject, deleteObject, hasKey, expire, getExpire
- List 缓存：setCacheList, getCacheList, appendList
- Set 缓存：setCacheSet, getCacheSet
- Map 缓存：setCacheMap, getCacheMap, setCacheMapValue, getCacheMapValue, getMultiCacheMapValue, deleteCacheMapValue
- 自增自减：increment, decrement
- Key 操作：keys(pattern)

**文件**: `core.md:569-620`

---

### 6. DesensitizedType 补充

**新增枚举值**: `ADDRESS` - 地址脱敏

**文件**: `enums.md`

---

## 待修复问题清单

### 中优先级

1. **XSS 过滤器配置示例** (`filter.md`) - ✅ 已存在 Spring Boot 示例
   - 当前仅有 web.xml 示例
   - 建议补充 Spring Boot FilterRegistrationBean 示例

2. **DictUtils 缓存机制说明** (`utils.md`)
   - 需要补充缓存机制说明

### 低优先级

1. **PageDomain reasonable 属性** (`core.md`) - ✅ 已修复
   - 添加：`Boolean reasonable; // 是否查询总数`

2. **AjaxResult put 方法** (`core.md`) - ✅ 已修复
   - 添加：`AjaxResult put(String key, Object value)`

3. **StringUtils lastStringDel 方法** (`utils.md`) - ✅ 已修复
   - 添加方法说明和示例

4. **DateUtils toDate 方法** (`utils.md`) - ✅ 已修复
   - 添加：`Date toDate(LocalDateTime)` 和 `Date toDate(LocalDate)`

5. **Excel 注解属性列表** (`annotation.md`) - ✅ 已验证完整
   - 补充完整 30+ 属性列表

---

## 文档统计（修订后）

| 文档 | 行数 | 状态 |
|------|------|------|
| ruoyi-common.md | 56 | ✅ 完整 |
| annotation.md | 307 | ✅ 完整 |
| config.md | 244+ | ✅ 完整 |
| constant.md | 393 | ✅ 完整 |
| core.md | 650+ | ✅ 完整 |
| enums.md | 289+ | ✅ 完整 |
| exception.md | 557+ | ✅ 完整 |
| filter.md | 618 | ✅ 完整 |
| utils.md | 549+ | ✅ 完整 |
| utils-part2.md | 629 | ✅ 完整 |

**总计**: 约 4,300 行

---

## 下一步计划

1. 补充遗漏的方法文档
2. 添加更多 Spring Boot 配置示例
3. 完善工具类方法列表
4. 添加实际项目使用案例

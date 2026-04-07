# 后端接口自动化测试规范

## 概述

本规范定义 RuoYi 项目后端接口自动化测试的编写标准、脚本结构和最佳实践。

**目标**：
- 提供可复用的接口测试脚本模板
- 确保测试脚本的可读性和可维护性
- 支持持续集成中的自动化测试

---

## 测试脚本位置

```
scripts/
├── test.sh                # 测试入口脚本
└── test/
    ├── curl/              # curl 测试脚本
    │   ├── test-login.sh          # 登录认证测试脚本
    │   └── test-demo-api.sh       # Demo 模块接口测试脚本
    └── junit/             # JUnit 单元测试脚本（待创建）
```

### 示例分类

| 示例 | 脚本 | 对应模块 | 说明 |
|------|------|----------|------|
| 简单 CRUD | `test-demo-api.sh` 学生管理 | `demo_student` | 单表增查改删示例 |
| 树形列表 | `test-demo-api.sh` 产品管理 | `demo_product` | 树形结构查询示例 |
| 主子表 | `test-demo-api.sh` 客户管理 | `demo_customer` | 主表 + 子表（商品列表）操作示例 |

---

## 脚本结构规范

### 基本结构

```bash
#!/bin/bash

# ==========================================
# 模块名称
# 功能描述
# ==========================================

set -e  # 遇到错误立即退出

# 配置
BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }
module() { echo -e "${CYAN}[MODULE]${NC} $1"; }
```

### 配置项规范

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `BASE_URL` | `http://localhost:18080` | 后端服务地址 |
| `TOKEN_FILE` | `/tmp/ruoyi_token.txt` | Token 临时存储文件 |
| `USERNAME` | `admin` | 测试账号用户名 |
| `PASSWORD` | `admin123` | 测试账号密码 |

**要求**：
- 所有配置项必须使用大写字母命名
- 敏感信息（密码）应通过环境变量覆盖
- Token 文件应存储在临时目录

---

## 核心函数规范

### 登录函数

```bash
# 全局变量
TOKEN=""

# 登录函数
login() {
    step "用户登录..."
    local login_response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")

    local login_code=$(echo "$login_response" | jq -r '.code')
    if [ "$login_code" != "200" ]; then
        error "登录失败：$(echo "$login_response" | jq -r '.msg')"
        exit 1
    fi

    TOKEN=$(echo "$login_response" | jq -r '.token')
    info "登录成功"
}
```

**要求**：
- 登录函数必须返回 Token 并存储到全局变量
- 登录失败必须退出脚本（`exit 1`）
- 必须使用 `local` 声明局部变量

---

### 模块测试函数

```bash
test_student_module() {
    module "=========================================="
    module "学生管理模块测试"
    module "=========================================="

    # 1. 查询列表
    step "1. 查询学生列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/student/list" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询学生列表失败"
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "学生总数：$total"

    # 2. 新增
    step "2. 新增学生..."
    local add_data='{
        "name": "张三",
        "age": 20,
        "sex": "0",
        "status": "0",
        "birthday": "2006-01-15",
        "studentHobby": "3"
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')

    if [ "$add_code" != "200" ]; then
        warn "新增学生响应：$(echo "$add_response" | jq -r '.msg')"
    else
        info "新增学生成功：$add_msg"
    fi

    # ... 其他测试步骤

    info "学生管理模块测试完成"
    echo ""
}
```

**要求**：
- 每个模块一个独立测试函数
- 函数命名：`test_<module>_module`
- 每个步骤使用 `step()` 输出说明
- 关键结果使用 `info()` 输出
- 非致命错误使用 `warn()`，致命错误使用 `error()`

---

## HTTP 请求规范

### GET 请求

```bash
# 简单 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/list" \
    -H "Authorization: $TOKEN")

# 带分页 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
    -H "Authorization: $TOKEN")

# 带参数 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/1" \
    -H "Authorization: $TOKEN")
```

### POST 请求

```bash
# 简单 POST
local response=$(curl -s -X POST "$BASE_URL/demo/student" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data")
```

### PUT 请求

```bash
# 修改操作
local response=$(curl -s -X PUT "$BASE_URL/demo/student" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data")
```

### DELETE 请求

```bash
# 删除操作
local response=$(curl -s -X DELETE "$BASE_URL/demo/student/1" \
    -H "Authorization: $TOKEN")
```

---

## JSON 数据处理规范

### 解析响应

```bash
# 提取 code
local code=$(echo "$response" | jq -r '.code')

# 提取 msg
local msg=$(echo "$response" | jq -r '.msg')

# 提取 data 字段
local data=$(echo "$response" | jq -r '.data')

# 提取嵌套字段
local user_name=$(echo "$response" | jq -r '.user.userName')

# 提取数组元素
local first_id=$(echo "$response" | jq -r '.rows[0].id // null')

# 检查字段是否存在
local has_goods=$(echo "$response" | jq -r '.data.goodsList // null')
```

### 构造请求体

```bash
# 简单 JSON 对象
local add_data='{
    "name": "张三",
    "age": 20,
    "status": "0"
}'

# 包含变量的 JSON（使用双引号）
local update_data="{
    \"id\": $first_id,
    \"name\": \"$new_name\",
    \"status\": \"0\"
}"

# 使用 jq 构造 JSON（推荐用于复杂场景）
local data=$(jq -n \
    --arg name "$name" \
    --arg age "$age" \
    '{name: $name, age: ($age | tonumber)}')
```

---

## 错误处理规范

### 响应码检查

```bash
local code=$(echo "$response" | jq -r '.code')
if [ "$code" != "200" ]; then
    error "操作失败：$(echo "$response" | jq -r '.msg')"
    return 1  # 或 exit 1
fi
```

### 空值检查

```bash
local first_id=$(echo "$response" | jq -r '.rows[0].id // null')

if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
    # 有数据时继续测试
    info "获取到 ID: $first_id"
else
    warn "暂无数据，跳过后续测试"
fi
```

### 服务可用性检查

```bash
step "检查后端服务状态..."
if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
    error "后端服务未运行"
    exit 1
fi
info "后端服务运行正常"
```

---

## 完整示例

### 示例 1：简单 CRUD（学生管理模块）

**场景**：单表增删改查，无关联数据

**测试脚本**: `scripts/test/curl/test-demo-api.sh`

```bash
#!/bin/bash

set -e

BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 登录
TOKEN=""
login() {
    step "用户登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "登录失败"
        exit 1
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    info "登录成功"
}

# 测试学生模块（简单 CRUD）
test_student() {
    # 1. 查询列表（分页）
    step "查询学生列表..."
    local response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    [ "$code" != "200" ] && error "查询失败" && exit 1
    local total=$(echo "$response" | jq -r '.total')
    info "学生总数：$total"

    # 2. 新增
    step "新增学生..."
    local add_data='{
        "name": "张三",
        "age": 20,
        "sex": "0",
        "status": "0",
        "birthday": "2006-01-15",
        "studentHobby": "3"
    }'
    response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "新增成功" || info "新增响应：$(echo "$response" | jq -r '.msg')"

    # 3. 查询详情
    step "查询学生详情..."
    response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$response" | jq -r '.rows[0].id // null')
    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        response=$(curl -s -X GET "$BASE_URL/demo/student/$first_id" \
            -H "Authorization: $TOKEN")
        code=$(echo "$response" | jq -r '.code')
        [ "$code" == "200" ] && info "查询详情成功"
    fi

    # 4. 修改
    step "修改学生..."
    local update_data="{
        \"id\": $first_id,
        \"name\": \"张三修改\",
        \"age\": 21,
        \"sex\": \"0\",
        \"status\": \"0\",
        \"birthday\": \"2006-01-15\",
        \"studentHobby\": \"1\"
    }"
    response=$(curl -s -X PUT "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "修改成功"

    # 5. 删除
    step "删除学生..."
    response=$(curl -s -X DELETE "$BASE_URL/demo/student/$first_id" \
        -H "Authorization: $TOKEN")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "删除成功"

    info "学生模块测试完成"
}

# 主流程
main() {
    if ! curl -s "$BASE_URL/actuator/health" | grep -q "200"; then
        error "服务未运行"
        exit 1
    fi
    
    login
    test_student
    
    info "所有测试完成"
}

main
```

**响应格式**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "total": 10,
  "rows": [{"id": 1, "name": "张三", "age": 20, ...}]
}
```

---

### 示例 2：树形列表（产品管理模块）

**场景**：树形结构数据，不支持分页，按树形展示

**关键差异**：
- 列表接口返回格式：`{code: 200, data: [...]}`（不是 `rows`）
- 通常不需要分页（树形数据量一般不大）
- 包含 `parentId` 字段维护树形关系

```bash
# 查询产品列表（树形，不分页）
step "查询产品列表..."
local response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
    -H "Authorization: $TOKEN")
local code=$(echo "$response" | jq -r '.code')
[ "$code" != "200" ] && error "查询失败" && exit 1

# 注意：树形列表返回的是 .data 而不是 .rows
local product_count=$(echo "$response" | jq -r '.data | length')
info "产品总数：$product_count"

# 提取第一个产品 ID（使用 .data[0]）
local first_id=$(echo "$response" | jq -r '.data[0].id // null')

# 新增产品（需要指定 parentId）
step "新增产品..."
local add_data='{
    "name": "测试产品 A",
    "status": "0",
    "parentId": 0,
    "orderNum": 1
}'
response=$(curl -s -X POST "$BASE_URL/demo/product" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$add_data")
```

**响应格式**：
```json
{
  "code": 200,
  "msg": "查询成功",
  "data": [
    {"id": 1, "name": "电子产品", "parentId": 0, "children": [...]},
    {"id": 2, "name": "食品饮料", "parentId": 0, "children": [...]}
  ]
}
```

---

### 示例 3：主子表（客户管理模块）

**场景**：主表（客户）+ 子表（商品列表），新增/修改时需要同时处理子表数据

**关键差异**：
- 实体类包含 `List<Goods> goodsList` 字段
- 新增/修改时需要构造子表数据
- 删除主表时子表数据级联删除

```bash
# 新增客户（包含商品列表）
step "新增客户..."
local add_data='{
    "customerName": "测试客户",
    "phonenumber": "13800138000",
    "sex": "0",
    "birthday": "1990-01-01",
    "remark": "测试客户备注",
    "goodsList": [
        {
            "goodsName": "商品 A",
            "price": 99.00,
            "stock": 100
        },
        {
            "goodsName": "商品 B",
            "price": 199.00,
            "stock": 50
        }
    ]
}'
response=$(curl -s -X POST "$BASE_URL/demo/customer" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$add_data")
code=$(echo "$response" | jq -r '.code')
[ "$code" == "200" ] && info "新增成功"

# 查询详情（检查子表数据）
step "查询客户详情..."
response=$(curl -s -X GET "$BASE_URL/demo/customer/$customer_id" \
    -H "Authorization: $TOKEN")
code=$(echo "$response" | jq -r '.code')
if [ "$code" == "200" ]; then
    # 检查是否有商品列表
    local has_goods=$(echo "$response" | jq -r '.data.goodsList // null')
    if [ "$has_goods" != "null" ]; then
        local goods_count=$(echo "$response" | jq -r '.data.goodsList | length')
        info "客户包含商品信息，共 $goods_count 个商品"
    fi
fi

# 修改客户（更新商品列表）
step "修改客户（更新商品列表）..."
local update_data="{
    \"customerId\": $customer_id,
    \"customerName\": \"测试客户修改\",
    \"phonenumber\": \"13800138001\",
    \"sex\": \"1\",
    \"birthday\": \"1991-02-02\",
    \"remark\": \"修改后的备注\",
    \"goodsList\": [
        {
            \"goodsId\": 1,
            \"goodsName\": \"商品 A 修改\",
            \"price\": 109.00,
            \"stock\": 90
        }
    ]
}"
response=$(curl -s -X PUT "$BASE_URL/demo/customer" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$update_data")
```

**响应格式**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "customerId": 1,
    "customerName": "张晨曦",
    "phonenumber": "13800138000",
    "goodsList": [
      {"goodsId": 1, "goodsName": "商品 A", "price": 99.00},
      {"goodsId": 2, "goodsName": "商品 B", "price": 199.00}
    ]
  }
}
```

---

## 运行规范

### 执行权限

```bash
chmod +x scripts/test-xxx.sh
```

### 运行测试

```bash
# 直接运行
./scripts/test-xxx.sh

# 指定后端地址
BASE_URL="http://192.168.1.100:18080" ./scripts/test-xxx.sh

# 使用测试账号
USERNAME="test" PASSWORD="test123" ./scripts/test-xxx.sh
```

### 输出重定向

```bash
# 保存日志
./scripts/test-xxx.sh > logs/test-$(date +%Y%m%d).log 2>&1

# 仅查看错误
./scripts/test-xxx.sh 2>&1 | grep ERROR
```

---

## 最佳实践

### 1. 模块化设计

- 每个功能模块一个测试函数
- 登录逻辑复用一个函数
- 使用 `return` 而非 `exit` 在模块函数内

### 2. 清晰的日志输出

- 使用颜色区分日志级别
- 每个步骤有明确说明
- 关键数据（如 ID）要输出便于追踪

### 3. 健壮的错误处理

- 检查服务可用性
- 检查登录状态
- 检查响应码
- 区分致命错误和警告

### 4. 数据隔离

- 测试数据使用独立标识
- 测试完成后清理数据
- 避免依赖特定数据状态

### 5. 可配置性

- 使用环境变量覆盖默认配置
- Token 存储使用临时文件
- 支持自定义测试参数

---

## 附录：响应格式参考

### 成功响应

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { ... }
}
```

### 列表响应

```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 10,
  "rows": [ ... ]
}
```

### 错误响应

```json
{
  "code": 400,
  "msg": "参数错误：name 不能为空"
}
```

### 未授权响应

```json
{
  "code": 401,
  "msg": "登录状态已过期，请重新登录"
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-08  
**基于版本**: RuoYi v3.9.2

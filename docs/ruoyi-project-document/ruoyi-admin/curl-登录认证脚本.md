# RuoYi 登录认证 curl 测试脚本

本文档提供完整的登录认证流程 curl 测试脚本。

---

## 环境配置

```bash
# 基础配置
BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"

# 测试账号
USERNAME="admin"
PASSWORD="admin123"
```

---

## 1. 获取验证码

**接口**: `GET /captchaImage`

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"

# 获取验证码
response=$(curl -s -X GET "$BASE_URL/captchaImage")

# 解析响应
uuid=$(echo "$response" | jq -r '.uuid')
img=$(echo "$response" | jq -r '.img')

echo "=========================================="
echo "验证码获取成功"
echo "=========================================="
echo "UUID: $uuid"
echo "验证码图片 (Base64): ${img:0:50}..."
echo ""
echo "请将 Base64 图片数据导入图片查看器查看验证码"
echo "然后使用获取的验证码进行登录测试"
```

**响应示例**:
```json
{
  "code": 200,
  "captchaEnabled": true,
  "uuid": "a3f5d8e9c2b1",
  "img": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

---

## 2. 用户登录

**接口**: `POST /login`

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"

# 登录参数
USERNAME="admin"
PASSWORD="admin123"
CAPTCHA_CODE="8"      # 替换为实际验证码
CAPTCHA_UUID="a3f5d8e9c2b1"  # 替换为实际 UUID

# 登录请求
response=$(curl -s -X POST "$BASE_URL/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"$USERNAME\",
        \"password\": \"$PASSWORD\",
        \"code\": \"$CAPTCHA_CODE\",
        \"uuid\": \"$CAPTCHA_UUID\"
    }")

echo "=========================================="
echo "登录响应"
echo "=========================================="
echo "$response" | jq '.'

# 提取 Token
token=$(echo "$response" | jq -r '.token')

if [ "$token" != "null" ] && [ -n "$token" ]; then
    echo ""
    echo "=========================================="
    echo "登录成功！"
    echo "=========================================="
    echo "Token: $token"
    
    # 保存 Token 到文件
    echo "$token" > "$TOKEN_FILE"
    echo "Token 已保存到：$TOKEN_FILE"
else
    echo ""
    echo "=========================================="
    echo "登录失败！"
    echo "=========================================="
    echo "请检查用户名、密码、验证码是否正确"
fi
```

**请求体**:
```json
{
  "username": "admin",
  "password": "admin123",
  "code": "8",
  "uuid": "a3f5d8e9c2b1"
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 3. 获取用户信息

**接口**: `GET /getInfo`

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"

# 读取 Token
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "错误：未找到 Token，请先登录"
    exit 1
fi

# 获取用户信息
response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $TOKEN")

echo "=========================================="
echo "用户信息"
echo "=========================================="
echo "$response" | jq '.'

# 解析用户信息
user_name=$(echo "$response" | jq -r '.user.userName')
nick_name=$(echo "$response" | jq -r '.user.nickName')
email=$(echo "$response" | jq -r '.user.email')
roles=$(echo "$response" | jq -r '.roles')
permissions=$(echo "$response" | jq -r '.permissions')

echo ""
echo "=========================================="
echo "用户详情"
echo "=========================================="
echo "用户名：$user_name"
echo "昵称：$nick_name"
echo "邮箱：$email"
echo "角色：$roles"
echo "权限：$permissions"
```

**响应示例**:
```json
{
  "code": 200,
  "user": {
    "userId": 1,
    "userName": "admin",
    "nickName": "管理员",
    "email": "admin@ruoyi.vip",
    "phonenumber": "15888888888",
    "sex": "0",
    "avatar": "https://..."
  },
  "roles": ["admin"],
  "permissions": ["*:*:*"],
  "isDefaultModifyPwd": false,
  "isPasswordExpired": false
}
```

---

## 4. 获取菜单路由

**接口**: `GET /getRouters`

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"

# 读取 Token
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "错误：未找到 Token，请先登录"
    exit 1
fi

# 获取路由信息
response=$(curl -s -X GET "$BASE_URL/getRouters" \
    -H "Authorization: $TOKEN")

echo "=========================================="
echo "菜单路由"
echo "=========================================="
echo "$response" | jq '.data[] | {name: .name, path: .path, title: .meta.title}'
```

**响应示例**:
```json
{
  "code": 200,
  "data": [
    {
      "name": "System",
      "path": "/system",
      "component": "Layout",
      "children": [
        {
          "path": "user",
          "component": "system/user/index",
          "meta": { "title": "用户管理", "icon": "user" }
        }
      ]
    }
  ]
}
```

---

## 5. 退出登录

**接口**: `POST /logout`

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"

# 读取 Token
TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "错误：未找到 Token，请先登录"
    exit 1
fi

# 退出登录
response=$(curl -s -X POST "$BASE_URL/logout" \
    -H "Authorization: $TOKEN")

echo "=========================================="
echo "退出登录"
echo "=========================================="
echo "$response" | jq '.'

# 删除本地 Token
rm -f "$TOKEN_FILE"
echo "本地 Token 已清除"
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "退出成功"
}
```

---

## 6. 完整登录测试脚本

```bash
#!/bin/bash

# ==========================================
# RuoYi 登录认证完整测试脚本
# ==========================================

set -e

# 配置
BASE_URL="http://localhost:18080"
TOKEN_FILE="/tmp/ruoyi_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 步骤 1: 获取验证码
info "步骤 1: 获取验证码..."
captcha_response=$(curl -s -X GET "$BASE_URL/captchaImage")
uuid=$(echo "$captcha_response" | jq -r '.uuid')

if [ "$uuid" == "null" ] || [ -z "$uuid" ]; then
    error "获取验证码失败"
    exit 1
fi
info "验证码 UUID: $uuid"

# 注意：实际使用时需要手动输入验证码
# 这里假设验证码为 "8"（仅用于测试环境）
warn "测试环境假设验证码为：8"
CAPTCHA_CODE="8"

# 步骤 2: 登录
info "步骤 2: 用户登录..."
login_response=$(curl -s -X POST "$BASE_URL/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"$USERNAME\",
        \"password\": \"$PASSWORD\",
        \"code\": \"$CAPTCHA_CODE\",
        \"uuid\": \"$uuid\"
    }")

login_code=$(echo "$login_response" | jq -r '.code')

if [ "$login_code" != "200" ]; then
    error "登录失败：$(echo "$login_response" | jq -r '.msg')"
    exit 1
fi

token=$(echo "$login_response" | jq -r '.token')
echo "$token" > "$TOKEN_FILE"
info "登录成功！Token: ${token:0:30}..."

# 步骤 3: 获取用户信息
info "步骤 3: 获取用户信息..."
user_response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $token")

user_name=$(echo "$user_response" | jq -r '.user.userName')
nick_name=$(echo "$user_response" | jq -r '.user.nickName')
info "用户：$user_name ($nick_name)"

# 步骤 4: 获取路由信息
info "步骤 4: 获取菜单路由..."
routers_response=$(curl -s -X GET "$BASE_URL/getRouters" \
    -H "Authorization: $token")

menu_count=$(echo "$routers_response" | jq '.data | length')
info "可访问菜单数：$menu_count"

# 步骤 5: 退出登录
info "步骤 5: 退出登录..."
logout_response=$(curl -s -X POST "$BASE_URL/logout" \
    -H "Authorization: $token")

rm -f "$TOKEN_FILE"
info "已退出登录，Token 已清除"

info "=========================================="
info "登录认证流程测试完成！"
info "=========================================="
```

---

## 7. 错误处理测试

### 7.1 验证码错误测试

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"

# 错误的验证码
response=$(curl -s -X POST "$BASE_URL/login" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "admin",
        "password": "admin123",
        "code": "0000",
        "uuid": "test-uuid"
    }')

echo "验证码错误测试:"
echo "$response" | jq '.'
```

**预期响应**:
```json
{
  "code": 400,
  "msg": "验证码错误"
}
```

### 7.2 密码错误测试

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"

# 先获取正确的验证码
captcha=$(curl -s -X GET "$BASE_URL/captchaImage" | jq -r '.')
uuid=$(echo "$captcha" | jq -r '.uuid')

# 错误的密码
response=$(curl -s -X POST "$BASE_URL/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"admin\",
        \"password\": \"wrongpassword\",
        \"code\": \"8\",
        \"uuid\": \"$uuid\"
    }")

echo "密码错误测试:"
echo "$response" | jq '.'
```

**预期响应**:
```json
{
  "code": 400,
  "msg": "密码错误"
}
```

### 7.3 Token 过期测试

```bash
#!/bin/bash

BASE_URL="http://localhost:18080"
EXPIRED_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired"

response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $EXPIRED_TOKEN")

echo "Token 过期测试:"
echo "$response" | jq '.'
```

**预期响应**:
```json
{
  "code": 401,
  "msg": "登录状态已过期，请重新登录"
}
```

---

## 8. Postman 集合

```json
{
  "info": {
    "name": "RuoYi Login API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "1. 获取验证码",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "http://localhost:18080/captchaImage",
          "protocol": "http",
          "host": ["localhost"],
          "port": "18080",
          "path": ["captchaImage"]
        }
      }
    },
    {
      "name": "2. 用户登录",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"username\": \"admin\",\n  \"password\": \"admin123\",\n  \"code\": \"8\",\n  \"uuid\": \"{{captcha_uuid}}\"\n}"
        },
        "url": {
          "raw": "http://localhost:18080/login",
          "protocol": "http",
          "host": ["localhost"],
          "port": "18080",
          "path": ["login"]
        }
      },
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "var jsonData = pm.response.json();",
              "if (jsonData.token) {",
              "    pm.environment.set('token', jsonData.token);",
              "}"
            ]
          }
        }
      ]
    },
    {
      "name": "3. 获取用户信息",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "{{token}}"
          }
        ],
        "url": {
          "raw": "http://localhost:18080/getInfo",
          "protocol": "http",
          "host": ["localhost"],
          "port": "18080",
          "path": ["getInfo"]
        }
      }
    },
    {
      "name": "4. 获取菜单路由",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "{{token}}"
          }
        ],
        "url": {
          "raw": "http://localhost:18080/getRouters",
          "protocol": "http",
          "host": ["localhost"],
          "port": "18080",
          "path": ["getRouters"]
        }
      }
    },
    {
      "name": "5. 退出登录",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "{{token}}"
          }
        ],
        "url": {
          "raw": "http://localhost:18080/logout",
          "protocol": "http",
          "host": ["localhost"],
          "port": "18080",
          "path": ["logout"]
        }
      }
    }
  ]
}
```

---

## 9. 依赖安装

```bash
# 安装 jq (JSON 解析工具)
# Ubuntu/Debian
sudo apt-get install -y jq

# CentOS/RHEL
sudo yum install -y jq

# macOS
brew install jq
```

---

## 10. 使用说明

1. **确保后端服务已启动**
   ```bash
   scripts/run-backend.sh
   ```

2. **运行单步测试**
   ```bash
   # 获取验证码
   curl -X GET http://localhost:18080/captchaImage | jq '.'
   
   # 登录（替换验证码和 UUID）
   curl -X POST http://localhost:18080/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"admin123","code":"8","uuid":"xxx"}' | jq '.'
   ```

3. **运行完整测试**
   ```bash
   # 测试脚本位于 scripts/test/curl/ 目录
   chmod +x scripts/test/curl/test-login.sh
   ./scripts/test/curl/test-login.sh
   ```

---

## 11. Demo 模块接口测试示例

### 学生管理模块

**测试脚本**: `scripts/test/curl/test-demo-api.sh`

#### 新增学生

```bash
BASE_URL="http://localhost:18080"
TOKEN="your_token_here"

# 新增学生
add_data='{
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

echo "$response" | jq '.'
```

#### 查询学生列表

```bash
# 查询列表（分页）
response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
    -H "Authorization: $TOKEN")

echo "$response" | jq '.'

# 提取学生总数
total=$(echo "$response" | jq -r '.total')
echo "学生总数：$total"

# 提取第一个学生 ID
first_id=$(echo "$response" | jq -r '.rows[0].id // null')
echo "第一个学生 ID: $first_id"
```

#### 查询学生详情

```bash
# 查询详情
student_id="1"
response=$(curl -s -X GET "$BASE_URL/demo/student/$student_id" \
    -H "Authorization: $TOKEN")

echo "$response" | jq '.'

# 提取学生姓名
name=$(echo "$response" | jq -r '.data.name')
echo "学生姓名：$name"
```

#### 修改学生

```bash
# 修改学生
update_data='{
    "id": 1,
    "name": "张三修改",
    "age": 21,
    "sex": "0",
    "status": "0",
    "birthday": "2006-01-15",
    "studentHobby": "1"
}'

response=$(curl -s -X PUT "$BASE_URL/demo/student" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$update_data")

echo "$response" | jq '.'
```

#### 删除学生

```bash
# 删除学生
student_id="1"
response=$(curl -s -X DELETE "$BASE_URL/demo/student/$student_id" \
    -H "Authorization: $TOKEN")

echo "$response" | jq '.'
```

---

### 产品管理模块

**接口前缀**: `/demo/product`

#### 新增产品

```bash
add_data='{
    "name": "测试产品 A",
    "status": "0",
    "parentId": 0,
    "orderNum": 1
}'

response=$(curl -s -X POST "$BASE_URL/demo/product" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$add_data")

echo "$response" | jq '.'
```

#### 查询产品列表

```bash
# 产品列表返回格式：{code: 200, data: [...]}
response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
    -H "Authorization: $TOKEN")

echo "$response" | jq '.'

# 提取第一个产品 ID
first_id=$(echo "$response" | jq -r '.data[0].id // null')
```

---

### 客户管理模块

**接口前缀**: `/demo/customer`

#### 新增客户（含商品列表）

```bash
add_data='{
    "customerName": "测试客户",
    "phonenumber": "13800138000",
    "sex": "0",
    "birthday": "1990-01-01",
    "remark": "测试客户备注",
    "goodsList": []
}'

response=$(curl -s -X POST "$BASE_URL/demo/customer" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$add_data")

echo "$response" | jq '.'
```

#### 修改客户（更新商品列表）

```bash
update_data='{
    "customerId": 1,
    "customerName": "测试客户修改",
    "phonenumber": "13800138001",
    "sex": "1",
    "birthday": "1991-02-02",
    "remark": "修改后的备注",
    "goodsList": [
        {
            "goodsName": "商品 A",
            "price": 99.00,
            "stock": 100
        }
    ]
}'

response=$(curl -s -X PUT "$BASE_URL/demo/customer" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$update_data")

echo "$response" | jq '.'
```

---

### 完整测试流程

运行完整的 Demo 模块测试：

```bash
chmod +x scripts/test/curl/test-demo-api.sh
./scripts/test/curl/test-demo-api.sh
```

**测试统计**：
- 学生管理模块：7 个接口（简单 CRUD 示例）
- 产品管理模块：7 个接口（树形列表示例）
- 客户管理模块：7 个接口（主子表示例）
- 总计：21 个接口调用

**输出示例**：
```
==========================================
  RuoYi Demo 模块 API 测试
  包含：学生管理、产品管理、客户管理
==========================================

[STEP] 检查后端服务状态...
[INFO] 后端服务运行正常
[STEP] 用户登录...
[INFO] 登录成功

[MODULE] ==========================================
[MODULE] 学生管理模块测试
[MODULE] ==========================================
[STEP] 1. 查询学生列表...
[INFO] 学生总数：3
[STEP] 2. 新增学生...
[INFO] 新增学生成功：操作成功
...
[INFO] 所有模块测试完成！
```

---

## 12. 参考文档

- [后端接口自动化测试规范](../../standards/testing.md)
- [登录认证流程详解](03-登录认证流程.md)
- [API 设计规范](../../standards/api-design.md)

---

**创建时间**: 2026-04-08  
**基于版本**: RuoYi v3.9.2

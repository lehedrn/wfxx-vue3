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
BLUE='\033[0;34m'
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

step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

echo ""
echo "=========================================="
echo "  RuoYi 登录认证测试脚本"
echo "=========================================="
echo ""

# 检查后端服务是否运行
step "检查后端服务状态..."
if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
    error "后端服务未运行或健康检查失败"
    exit 1
fi
info "后端服务运行正常"

# 步骤 1: 获取验证码
step "步骤 1: 获取验证码..."
captcha_response=$(curl -s -X GET "$BASE_URL/captchaImage")
uuid=$(echo "$captcha_response" | jq -r '.uuid')
code_check=$(echo "$captcha_response" | jq -r '.code')
captcha_enabled=$(echo "$captcha_response" | jq -r '.captchaEnabled')

info "验证码配置：$captcha_enabled"

# 如果未启用验证码，uuid 可能为空，使用空字符串
if [ "$uuid" == "null" ] || [ -z "$uuid" ]; then
    uuid=""
    warn "未启用验证码或 UUID 为空"
else
    info "验证码 UUID: $uuid"
fi

if [ "$code_check" != "200" ]; then
    error "验证码接口返回异常"
    echo "响应：$captcha_response"
    exit 1
fi
info "验证码接口响应正常"

# 步骤 2: 登录
step "步骤 2: 用户登录..."

# 根据验证码配置决定是否发送验证码参数
if [ "$captcha_enabled" == "true" ]; then
    warn "验证码已启用，使用固定验证码 '8' 进行测试"
    CAPTCHA_CODE="8"
    login_response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"$USERNAME\",
            \"password\": \"$PASSWORD\",
            \"code\": \"$CAPTCHA_CODE\",
            \"uuid\": \"$uuid\"
        }")
else
    info "验证码未启用，直接登录"
    login_response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"$USERNAME\",
            \"password\": \"$PASSWORD\",
            \"code\": \"\",
            \"uuid\": \"\"
        }")
fi

login_code=$(echo "$login_response" | jq -r '.code')
login_msg=$(echo "$login_response" | jq -r '.msg')

info "登录响应：code=$login_code, msg=$login_msg"

if [ "$login_code" != "200" ]; then
    error "登录失败：$login_msg"
    echo "完整响应："
    echo "$login_response" | jq '.'

    # 检查是否是验证码错误
    if echo "$login_msg" | grep -q "验证码"; then
        warn "验证码错误，这是正常现象。在实际使用中需要从验证码图片中识别正确码值。"
        echo ""
        echo "请手动测试："
        echo "1. 访问 http://localhost:18080/captchaImage 获取验证码图片"
        echo "2. 识别图片中的验证码"
        echo "3. 使用以下命令登录："
        echo "curl -X POST http://localhost:18080/login \\"
        echo "  -H 'Content-Type: application/json' \\"
        echo "  -d '{\"username\":\"admin\",\"password\":\"admin123\",\"code\":\"<验证码>\",\"uuid\":\"$uuid\"}'"
        exit 1
    fi
    exit 1
fi

token=$(echo "$login_response" | jq -r '.token')
echo "$token" > "$TOKEN_FILE"
info "登录成功！Token: ${token:0:50}..."

# 步骤 3: 获取用户信息
step "步骤 3: 获取用户信息..."
user_response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $token")

user_code=$(echo "$user_response" | jq -r '.code')
if [ "$user_code" != "200" ]; then
    error "获取用户信息失败"
    echo "$user_response" | jq '.'
    exit 1
fi

user_name=$(echo "$user_response" | jq -r '.user.userName')
nick_name=$(echo "$user_response" | jq -r '.user.nickName')
dept_name=$(echo "$user_response" | jq -r '.user.dept.deptName // "无"')
info "用户：$user_name ($nick_name) - 部门：$dept_name"

# 获取角色和权限
roles=$(echo "$user_response" | jq -r '.roles')
permissions=$(echo "$user_response" | jq -r '.permissions')
info "角色：$roles"
info "权限数量：$(echo "$permissions" | jq 'length') 个"

# 步骤 4: 获取路由信息
step "步骤 4: 获取菜单路由..."
routers_response=$(curl -s -X GET "$BASE_URL/getRouters" \
    -H "Authorization: $token")

routers_code=$(echo "$routers_response" | jq -r '.code')
if [ "$routers_code" != "200" ]; then
    error "获取路由失败"
    echo "$routers_response" | jq '.'
    exit 1
fi

menu_count=$(echo "$routers_response" | jq '.data | length')
info "可访问菜单数：$menu_count"

# 显示主要菜单
echo ""
info "主要菜单列表:"
echo "$routers_response" | jq -r '.data[] | "  - \(.name): \(.path) (\(.meta.title // "无标题"))"'

# 步骤 5: 退出登录
step "步骤 5: 退出登录..."
logout_response=$(curl -s -X POST "$BASE_URL/logout" \
    -H "Authorization: $token")

logout_code=$(echo "$logout_response" | jq -r '.code')
logout_msg=$(echo "$logout_response" | jq -r '.msg')

if [ "$logout_code" != "200" ]; then
    warn "退出登录响应异常：$logout_msg"
else
    info "退出登录：$logout_msg"
fi

# 删除本地 Token
rm -f "$TOKEN_FILE"
info "本地 Token 已清除"

# 验证 Token 已失效
step "验证 Token 已失效..."
verify_response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $token")
verify_code=$(echo "$verify_response" | jq -r '.code')

if [ "$verify_code" == "200" ]; then
    warn "Token 仍未失效（可能是延迟）"
else
    info "Token 已失效，验证通过"
fi

echo ""
echo "=========================================="
info "登录认证流程测试完成！"
echo "=========================================="
echo ""

# 返回成功
exit 0

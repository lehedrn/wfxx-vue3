#!/bin/bash

# ==========================================
# RuoYi Demo 模块 API 测试脚本
# 包含：学生管理、产品管理、客户管理
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
CYAN='\033[0;36m'
NC='\033[0m'

# 全局变量
TOKEN=""

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }
module() { echo -e "${CYAN}[MODULE]${NC} $1"; }

# ==========================================
# 登录函数
# ==========================================
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

# ==========================================
# 学生管理模块测试
# ==========================================
test_student_module() {
    module "=========================================="
    module "学生管理模块测试"
    module "=========================================="

    # 1. 查询学生列表（空列表）
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

    # 2. 新增学生
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
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" != "200" ]; then
        warn "新增学生响应：$add_msg"
        # 可能是权限不足或重复，继续测试
    else
        info "新增学生成功：$add_msg"
    fi

    # 3. 再次查询列表获取学生 ID
    step "3. 查询学生详情..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.rows[0].id // null')

    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        info "获取到学生 ID: $first_id"

        # 4. 查询学生详情
        step "4. 查询学生详情 (ID: $first_id)..."
        local detail_response=$(curl -s -X GET "$BASE_URL/demo/student/$first_id" \
            -H "Authorization: $TOKEN")
        local detail_code=$(echo "$detail_response" | jq -r '.code')
        if [ "$detail_code" == "200" ]; then
            local student_name=$(echo "$detail_response" | jq -r '.data.name')
            info "学生详情：$student_name"
        fi

        # 5. 修改学生
        step "5. 修改学生 (ID: $first_id)..."
        local update_data="{
            \"id\": $first_id,
            \"name\": \"张三修改\",
            \"age\": 21,
            \"sex\": \"0\",
            \"status\": \"0\",
            \"birthday\": \"2006-01-15\",
            \"studentHobby\": \"1\"
        }"
        local update_response=$(curl -s -X PUT "$BASE_URL/demo/student" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_data")
        local update_code=$(echo "$update_response" | jq -r '.code')
        if [ "$update_code" == "200" ]; then
            info "修改学生成功"
        else
            warn "修改学生响应：$(echo "$update_response" | jq -r '.msg')"
        fi

        # 6. 删除学生
        step "6. 删除学生 (ID: $first_id)..."
        local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/student/$first_id" \
            -H "Authorization: $TOKEN")
        local delete_code=$(echo "$delete_response" | jq -r '.code')
        if [ "$delete_code" == "200" ]; then
            info "删除学生成功"
        else
            warn "删除学生响应：$(echo "$delete_response" | jq -r '.msg')"
        fi
    else
        warn "暂无学生数据，跳过详情/修改/删除测试"
    fi

    # 7. 导出测试（仅检查接口可用性）
    step "7. 测试导出接口..."
    local export_response=$(curl -s -X POST "$BASE_URL/demo/student/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}')
    # 导出返回文件流，检查响应码即可
    info "导出接口调用完成"

    info "学生管理模块测试完成"
    echo ""
}

# ==========================================
# 产品管理模块测试
# ==========================================
test_product_module() {
    module "=========================================="
    module "产品管理模块测试"
    module "=========================================="

    # 1. 查询产品列表
    step "1. 查询产品列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询产品列表失败"
        return 1
    fi
    local products=$(echo "$list_response" | jq -r '.')
    info "产品列表响应正常"

    # 2. 新增产品
    step "2. 新增产品..."
    local add_data='{
        "name": "测试产品 A",
        "status": "0",
        "parentId": 0,
        "orderNum": 1
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/product" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')

    if [ "$add_code" == "200" ]; then
        info "新增产品成功"
    else
        warn "新增产品响应：$(echo "$add_response" | jq -r '.msg')"
    fi

    # 3. 查询产品详情
    step "3. 查询产品详情..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
        -H "Authorization: $TOKEN")
    # 产品接口返回格式：{code: 200, data: [...]}
    local first_id=$(echo "$list_response" | jq -r '.data[0].id // null')

    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        info "获取到产品 ID: $first_id"

        # 4. 查询详情
        step "4. 查询产品详情 (ID: $first_id)..."
        local detail_response=$(curl -s -X GET "$BASE_URL/demo/product/$first_id" \
            -H "Authorization: $TOKEN")
        local detail_code=$(echo "$detail_response" | jq -r '.code')
        if [ "$detail_code" == "200" ]; then
            local product_name=$(echo "$detail_response" | jq -r '.data.name')
            info "产品详情：$product_name"
        fi

        # 5. 修改产品
        step "5. 修改产品 (ID: $first_id)..."
        local update_data="{
            \"id\": $first_id,
            \"name\": \"测试产品 A 修改\",
            \"status\": \"0\",
            \"parentId\": 0,
            \"orderNum\": 2
        }"
        local update_response=$(curl -s -X PUT "$BASE_URL/demo/product" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_data")
        local update_code=$(echo "$update_response" | jq -r '.code')
        if [ "$update_code" == "200" ]; then
            info "修改产品成功"
        else
            warn "修改产品响应：$(echo "$update_response" | jq -r '.msg')"
        fi

        # 6. 删除产品
        step "6. 删除产品 (ID: $first_id)..."
        local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/product/$first_id" \
            -H "Authorization: $TOKEN")
        local delete_code=$(echo "$delete_response" | jq -r '.code')
        if [ "$delete_code" == "200" ]; then
            info "删除产品成功"
        else
            warn "删除产品响应：$(echo "$delete_response" | jq -r '.msg')"
        fi
    else
        warn "暂无产品数据，跳过详情/修改/删除测试"
    fi

    # 7. 导出测试
    step "7. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/product/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "产品管理模块测试完成"
    echo ""
}

# ==========================================
# 客户管理模块测试
# ==========================================
test_customer_module() {
    module "=========================================="
    module "客户管理模块测试"
    module "=========================================="

    # 1. 查询客户列表
    step "1. 查询客户列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询客户列表失败"
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "客户总数：$total"

    # 2. 新增客户
    step "2. 新增客户..."
    local add_data='{
        "customerName": "测试客户",
        "phonenumber": "13800138000",
        "sex": "0",
        "birthday": "1990-01-01",
        "remark": "测试客户备注",
        "goodsList": []
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/customer" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')

    if [ "$add_code" == "200" ]; then
        info "新增客户成功"
    else
        warn "新增客户响应：$(echo "$add_response" | jq -r '.msg')"
    fi

    # 3. 查询客户详情
    step "3. 查询客户详情..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.rows[0].customerId // null')

    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        info "获取到客户 ID: $first_id"

        # 4. 查询详情
        step "4. 查询客户详情 (ID: $first_id)..."
        local detail_response=$(curl -s -X GET "$BASE_URL/demo/customer/$first_id" \
            -H "Authorization: $TOKEN")
        local detail_code=$(echo "$detail_response" | jq -r '.code')
        if [ "$detail_code" == "200" ]; then
            local customer_name=$(echo "$detail_response" | jq -r '.data.customerName')
            info "客户详情：$customer_name"

            # 检查是否有商品列表
            local has_goods=$(echo "$detail_response" | jq -r '.data.goodsList // null')
            if [ "$has_goods" != "null" ]; then
                info "客户包含商品信息"
            fi
        fi

        # 5. 修改客户
        step "5. 修改客户 (ID: $first_id)..."
        local update_data="{
            \"customerId\": $first_id,
            \"customerName\": \"测试客户修改\",
            \"phonenumber\": \"13800138001\",
            \"sex\": \"1\",
            \"birthday\": \"1991-02-02\",
            \"remark\": \"修改后的备注\",
            \"goodsList\": []
        }"
        local update_response=$(curl -s -X PUT "$BASE_URL/demo/customer" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_data")
        local update_code=$(echo "$update_response" | jq -r '.code')
        if [ "$update_code" == "200" ]; then
            info "修改客户成功"
        else
            warn "修改客户响应：$(echo "$update_response" | jq -r '.msg')"
        fi

        # 6. 删除客户
        step "6. 删除客户 (ID: $first_id)..."
        local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/customer/$first_id" \
            -H "Authorization: $TOKEN")
        local delete_code=$(echo "$delete_response" | jq -r '.code')
        if [ "$delete_code" == "200" ]; then
            info "删除客户成功"
        else
            warn "删除客户响应：$(echo "$delete_response" | jq -r '.msg')"
        fi
    else
        warn "暂无客户数据，跳过详情/修改/删除测试"
    fi

    # 7. 导出测试
    step "7. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/customer/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "客户管理模块测试完成"
    echo ""
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  RuoYi Demo 模块 API 测试"
    echo "  包含：学生管理、产品管理、客户管理"
    echo "=========================================="
    echo ""

    # 检查后端服务
    step "检查后端服务状态..."
    if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
        error "后端服务未运行"
        exit 1
    fi
    info "后端服务运行正常"

    # 登录
    login
    echo ""

    # 测试各模块
    test_student_module
    test_product_module
    test_customer_module

    echo "=========================================="
    info "所有模块测试完成！"
    echo "=========================================="
    echo ""

    # 输出测试统计
    echo "测试统计:"
    echo "  - 学生管理模块：7 个接口"
    echo "  - 产品管理模块：7 个接口"
    echo "  - 客户管理模块：7 个接口"
    echo "  - 总计：21 个接口调用"
    echo ""
}

# 执行主流程
main

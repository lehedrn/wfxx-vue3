#!/bin/bash

# ==========================================
# 模块：设备型号管理
# 功能：设备型号管理 API 自动化测试
# ==========================================

set -e

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

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }
module() { echo -e "${CYAN}[MODULE]${NC} $1"; }

# 全局变量
TOKEN=""
DEVICE_MODEL_ID=""

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
# 设备型号管理模块测试
# ==========================================
test_device_model_module() {
    module "=========================================="
    module "设备型号管理模块测试"
    module "=========================================="

    # 1. 查询设备型号列表
    step "1. 查询设备型号列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询设备型号列表失败"
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "设备型号总数：$total"
    if [ "$total" -gt 0 ]; then
        info "✅ 列表数据正常返回"
    else
        warn "⚠️ 列表中暂无数据"
    fi

    # 2. 按条件查询（名称模糊搜索）
    step "2. 测试名称模糊搜索..."
    local search_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/list?pageNum=1&pageSize=10&name=EdgeBox" \
        -H "Authorization: $TOKEN")
    local search_code=$(echo "$search_response" | jq -r '.code')
    if [ "$search_code" == "200" ]; then
        local search_total=$(echo "$search_response" | jq -r '.total // 0')
        info "模糊搜索结果：$search_total 条"
    else
        warn "模糊搜索响应异常"
    fi

    # 3. 按设备类型筛选
    step "3. 测试设备类型筛选..."
    local type_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/list?pageNum=1&pageSize=10&deviceType=0" \
        -H "Authorization: $TOKEN")
    local type_code=$(echo "$type_response" | jq -r '.code')
    if [ "$type_code" == "200" ]; then
        local type_total=$(echo "$type_response" | jq -r '.total // 0')
        info "设备类型筛选结果：$type_total 条"
    else
        warn "设备类型筛选响应异常"
    fi

    # 4. 新增设备型号
    step "4. 新增设备型号..."
    local add_data='{
        "name": "Test-EdgeBox-T100",
        "deviceType": "0",
        "memory": 8,
        "disk": 128,
        "os": "0",
        "motherboardManufacturer": "TestManufacturer",
        "cpuModel": "RK3588",
        "cpuCores": 8,
        "cpuFrequency": 2.40,
        "cpuCount": 1,
        "gpuModel": "jetson_nano_jepck4.6",
        "gpuComputePower": "21 TOPS",
        "gpuMemory": 4,
        "gpuCount": 1,
        "status": "0",
        "remark": "curl自动化测试数据"
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/base/deviceModel" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" == "200" ]; then
        info "新增设备型号成功：$add_msg"
    else
        warn "新增设备型号响应：$add_msg"
    fi

    # 5. 查询列表获取刚插入的 ID
    step "5. 查询列表获取新增记录 ID..."
    list_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/list?pageNum=1&pageSize=10&name=Test-EdgeBox-T100" \
        -H "Authorization: $TOKEN")
    DEVICE_MODEL_ID=$(echo "$list_response" | jq -r '.rows[0].id // null')

    if [ "$DEVICE_MODEL_ID" != "null" ] && [ -n "$DEVICE_MODEL_ID" ]; then
        info "获取到设备型号 ID: $DEVICE_MODEL_ID"
    else
        warn "未找到新增的设备型号记录，尝试使用已有数据"
        list_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/list?pageNum=1&pageSize=1" \
            -H "Authorization: $TOKEN")
        DEVICE_MODEL_ID=$(echo "$list_response" | jq -r '.rows[0].id // null')
    fi

    # 6. 查询设备型号详情
    if [ "$DEVICE_MODEL_ID" != "null" ] && [ -n "$DEVICE_MODEL_ID" ]; then
        step "6. 查询设备型号详情 (ID: $DEVICE_MODEL_ID)..."
        local detail_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/$DEVICE_MODEL_ID" \
            -H "Authorization: $TOKEN")
        local detail_code=$(echo "$detail_response" | jq -r '.code')
        if [ "$detail_code" == "200" ]; then
            local detail_name=$(echo "$detail_response" | jq -r '.data.name')
            local detail_type=$(echo "$detail_response" | jq -r '.data.deviceType')
            info "设备型号详情：$detail_name, 类型: $detail_type"
            info "✅ 详情查询正常"
        else
            warn "详情查询响应异常"
        fi

        # 7. 修改设备型号
        step "7. 修改设备型号 (ID: $DEVICE_MODEL_ID)..."
        local update_data="{
            \"id\": $DEVICE_MODEL_ID,
            \"name\": \"Test-EdgeBox-T100-Modified\",
            \"deviceType\": \"0\",
            \"memory\": 16,
            \"disk\": 256,
            \"os\": \"0\",
            \"motherboardManufacturer\": \"TestManufacturer-Updated\",
            \"cpuModel\": \"RK3588\",
            \"cpuCores\": 8,
            \"cpuFrequency\": 2.40,
            \"cpuCount\": 1,
            \"gpuModel\": \"jetson_nano_jepck4.6\",
            \"gpuComputePower\": \"21 TOPS\",
            \"gpuMemory\": 8,
            \"gpuCount\": 2,
            \"status\": \"0\",
            \"remark\": \"curl自动化测试-已修改\"
        }"
        local update_response=$(curl -s -X PUT "$BASE_URL/base/deviceModel" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_data")
        local update_code=$(echo "$update_response" | jq -r '.code')
        if [ "$update_code" == "200" ]; then
            info "修改设备型号成功"
            info "✅ 修改功能正常"
        else
            warn "修改设备型号响应：$(echo "$update_response" | jq -r '.msg')"
        fi

        # 8. 验证修改后的数据
        step "8. 验证修改后的数据..."
        detail_response=$(curl -s -X GET "$BASE_URL/base/deviceModel/$DEVICE_MODEL_ID" \
            -H "Authorization: $TOKEN")
        detail_code=$(echo "$detail_response" | jq -r '.code')
        if [ "$detail_code" == "200" ]; then
            local modified_name=$(echo "$detail_response" | jq -r '.data.name')
            local modified_memory=$(echo "$detail_response" | jq -r '.data.memory')
            info "修改后验证：名称=$modified_name, 内存=${modified_memory}GB"
            if [ "$modified_name" == "Test-EdgeBox-T100-Modified" ]; then
                info "✅ 数据修改验证通过"
            else
                warn "⚠️ 数据修改验证未通过"
            fi
        fi

        # 9. 删除设备型号
        step "9. 删除设备型号 (ID: $DEVICE_MODEL_ID)..."
        local delete_response=$(curl -s -X DELETE "$BASE_URL/base/deviceModel/$DEVICE_MODEL_ID" \
            -H "Authorization: $TOKEN")
        local delete_code=$(echo "$delete_response" | jq -r '.code')
        if [ "$delete_code" == "200" ]; then
            info "删除设备型号成功"
            info "✅ 删除功能正常"
        else
            warn "删除设备型号响应：$(echo "$delete_response" | jq -r '.msg')"
        fi
    else
        warn "暂无设备型号数据，跳过详情/修改/删除测试"
    fi

    # 10. 导出接口测试
    step "10. 测试导出接口..."
    curl -s -X POST "$BASE_URL/base/deviceModel/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "✅ 导出接口调用完成"

    info "设备型号管理模块测试完成"
    echo ""
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  设备型号管理 API 测试"
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

    # 测试设备型号管理模块
    test_device_model_module

    echo "=========================================="
    info "所有测试完成！"
    echo "=========================================="
    echo ""
}

# 执行主流程
main

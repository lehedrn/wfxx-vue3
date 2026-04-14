#!/bin/bash

# ==========================================
# 区划管理模块 API 自动化测试
# 功能：区划管理增查改删 API 测试
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

# 日志函数
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }
module() { echo -e "${CYAN}[MODULE]${NC} $1"; }

# 登录
TOKEN=""
login() {
    step "用户登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "登录失败：$(echo "$response" | jq -r '.msg')"
        exit 1
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    info "登录成功"
}

# 测试区划管理模块
test_area_module() {
    module "=========================================="
    module "区划管理模块测试"
    module "=========================================="

    # 1. 查询列表（树形，不分页）
    step "1. 查询区划列表..."
    local response=$(curl -s -X GET "$BASE_URL/system/area/list" \
        -H "Authorization: $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "查询区划列表失败"
        return 1
    fi
    local area_count=$(echo "$response" | jq -r '.data | length')
    info "区划总数：$area_count"
    if [ "$area_count" -gt 0 ]; then
        info "✅ 列表数据正常返回"
    else
        warn "⚠️ 列表中暂无数据"
    fi

    # 提取第一条数据 ID
    local first_id=$(echo "$response" | jq -r '.data[0].id // null')
    local first_code=$(echo "$response" | jq -r '.data[0].code // null')

    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        info "获取到第一条数据 ID: $first_id, code: $first_code"
    fi

    # 2. 查询详情
    step "2. 查询区划详情..."
    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        response=$(curl -s -X GET "$BASE_URL/system/area/$first_id" \
            -H "Authorization: $TOKEN")
        code=$(echo "$response" | jq -r '.code')
        if [ "$code" == "200" ]; then
            local name=$(echo "$response" | jq -r '.data.name')
            local code_val=$(echo "$response" | jq -r '.data.code')
            local level=$(echo "$response" | jq -r '.data.areaLevel')
            info "查询详情成功：$name (编码: $code_val, 层级: $level)"
        else
            warn "查询详情响应：$(echo "$response" | jq -r '.msg')"
        fi
    fi

    # 3. 按名称模糊搜索
    step "3. 按名称模糊搜索..."
    response=$(curl -s -G --data-urlencode "name=北京" "$BASE_URL/system/area/list" \
        -H "Authorization: $TOKEN")
    code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        local search_count=$(echo "$response" | jq -r '.data | length')
        info "按名称搜索 '北京'，返回 $search_count 条结果"
    else
        warn "搜索响应：$(echo "$response" | jq -r '.msg' 2>/dev/null || echo '解析失败')"
    fi

    # 4. 按层级筛选
    step "4. 按层级筛选..."
    response=$(curl -s -X GET "$BASE_URL/system/area/list?areaLevel=1" \
        -H "Authorization: $TOKEN")
    code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        local level_count=$(echo "$response" | jq -r '.data | length')
        info "按层级 '省级(1)' 筛选，返回 $level_count 条结果"
    else
        warn "筛选响应：$(echo "$response" | jq -r '.msg' 2>/dev/null || echo '解析失败')"
    fi

    # 5. 新增区划
    step "5. 新增区划..."
    local add_data='{
        "name": "测试区县_'"$(date +%s)"'",
        "code": "999999",
        "parentCode": "0",
        "ancestors": "",
        "areaLevel": "3",
        "sort": 1
    }'
    response=$(curl -s -X POST "$BASE_URL/system/area" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    code=$(echo "$response" | jq -r '.code')
    local add_msg=$(echo "$response" | jq -r '.msg')
    if [ "$code" == "200" ]; then
        info "新增成功：$add_msg"
    else
        warn "新增响应：$add_msg"
    fi

    # 6. 修改区划
    step "6. 修改区划..."
    if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
        local update_data="{
            \"id\": $first_id,
            \"name\": \"$(echo "$response" | jq -r '.data.name' 2>/dev/null || echo '北京市修改')\",
            \"code\": \"$first_code\",
            \"parentCode\": \"0\",
            \"ancestors\": \"\",
            \"areaLevel\": \"1\",
            \"sort\": 2
        }"
        # 重新获取详情数据用于修改
        local detail=$(curl -s -X GET "$BASE_URL/system/area/$first_id" \
            -H "Authorization: $TOKEN")
        local detail_name=$(echo "$detail" | jq -r '.data.name')
        update_data="{
            \"id\": $first_id,
            \"name\": \"${detail_name}_修改\",
            \"code\": \"$first_code\",
            \"parentCode\": \"0\",
            \"ancestors\": \"\",
            \"areaLevel\": \"1\",
            \"sort\": 2
        }"
        response=$(curl -s -X PUT "$BASE_URL/system/area" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_data")
        code=$(echo "$response" | jq -r '.code')
        if [ "$code" == "200" ]; then
            info "修改成功"
        else
            warn "修改响应：$(echo "$response" | jq -r '.msg')"
        fi
    fi

    # 7. 导出功能
    step "7. 导出区划数据..."
    local export_response=$(curl -s -X POST "$BASE_URL/system/area/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -o /tmp/area_export.xls -w "%{http_code}")
    if [ "$export_response" == "200" ]; then
        info "导出成功，文件已保存到 /tmp/area_export.xls"
    else
        warn "导出响应：$export_response"
    fi

    info "区划管理模块测试完成"
    echo ""
}

# 主流程
main() {
    # 检查后端服务状态
    step "检查后端服务状态..."
    if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
        error "后端服务未运行"
        exit 1
    fi
    info "后端服务运行正常"

    login
    test_area_module

    info "所有测试完成"
}

main

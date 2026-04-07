#!/bin/bash

# =============================================================================
# run-frontend.sh - 运行前端服务脚本
# =============================================================================
# 用法：scripts/run-frontend.sh [选项]
# 示例：scripts/run-frontend.sh             # 前台运行
#       scripts/run-frontend.sh --daemon    # 后台运行
#       scripts/run-frontend.sh --stop      # 停止服务
#       scripts/run-frontend.sh --restart   # 重启服务
#       scripts/run-frontend.sh --health    # 健康检查
# =============================================================================

# 获取项目根目录绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 前端目录
FRONTEND_DIR="${PROJECT_ROOT}/ruoyi-ui"

# 服务配置
SERVER_PORT=3888

# 日志配置
LOG_DIR="${PROJECT_ROOT}/logs/frontend"
LOG_FILE="${LOG_DIR}/frontend-$(date +%Y%m%d).log"

# PID 文件
PID_DIR="${PROJECT_ROOT}/.pid"
PID_FILE="${PID_DIR}/frontend.pid"

# 确保目录存在
mkdir -p "$LOG_DIR"
mkdir -p "$PID_DIR"

# 检查 pnpm 是否安装
check_pnpm() {
    if command -v pnpm &> /dev/null; then
        return 0
    fi
    # 尝试使用 npm 安装 pnpm
    echo "警告：未找到 pnpm"
    echo "正在安装 pnpm..."
    if command -v npm &> /dev/null; then
        npm install -g pnpm
        if [ $? -eq 0 ]; then
            echo "pnpm 安装成功"
            return 0
        fi
    fi
    echo "错误：请先安装 pnpm"
    echo "  npm install -g pnpm"
    echo "或参考：https://pnpm.io/installation"
    return 1
}

# 检查端口是否被占用
check_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    if [ -n "$pid" ]; then
        echo "$pid"
        return 0
    fi
    return 1
}

# 杀死占用端口的进程
kill_port() {
    local port=$1
    local pid=$(check_port $port)
    if [ -n "$pid" ]; then
        echo "  发现进程占用端口 $port (PID: $pid)，正在终止..."
        kill -9 $pid 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  已终止进程 (PID: $pid)"
            return 0
        else
            echo "  终止进程失败，请手动处理"
            return 1
        fi
    fi
    return 1
}

# 检查服务是否运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            return 0
        fi
    fi
    # 检查端口是否被占用
    if check_port $SERVER_PORT > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# 获取运行 PID
get_running_pid() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            echo "$pid"
            return
        fi
    fi
    check_port $SERVER_PORT
}

# 等待服务启动（检测 Vite 启动标志）
wait_for_startup() {
    local max_wait=${1:-30}  # 默认最多等待 30 秒
    local count=0
    local log_file="$LOG_FILE"

    echo "  等待服务启动..."

    while [ $count -lt $max_wait ]; do
        # 检查日志中是否出现 Vite 启动成功标志
        if grep -qE "ready in|Local:|VITE.*ready" "$log_file" 2>/dev/null; then
            echo "  服务启动成功！"
            return 0
        fi

        # 检查是否有启动失败的错误
        if grep -qE "EADDRINUSE|Port.*already in use|error|Error" "$log_file" 2>/dev/null; then
            echo "  服务启动失败，请检查日志：$log_file"
            return 1
        fi

        sleep 1
        count=$((count + 1))
        echo -ne "  启动中... ($count/${max_wait})\033[0K\r"
    done

    echo ""
    # 超时后检查端口是否被占用
    if check_port $SERVER_PORT > /dev/null 2>&1; then
        echo "  服务启动失败：端口被占用但未见启动成功标志"
        return 1
    else
        echo "  服务启动失败：未在 ${max_wait} 秒内完成启动"
        return 1
    fi
}

# 健康检查（HTTP 请求）
health_check() {
    local url="http://localhost:$SERVER_PORT/"
    local response

    # 尝试使用 curl 检查
    if command -v curl &> /dev/null; then
        response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" 2>/dev/null)
        if [ "$response" = "200" ]; then
            echo "健康检查：通过 (HTTP 200)"
            return 0
        else
            echo "健康检查：失败 (HTTP $response)"
            return 1
        fi
    fi

    # 如果没有 curl，尝试使用 wget
    if command -v wget &> /dev/null; then
        if wget -q --spider --timeout=5 "$url" 2>/dev/null; then
            echo "健康检查：通过"
            return 0
        else
            echo "健康检查：失败"
            return 1
        fi
    fi

    echo "健康检查：未找到 curl 或 wget 工具"
    return 1
}

# 启动服务
start_service() {
    local daemon=$1

    echo "=========================================="
    echo "        启动前端服务"
    echo "=========================================="
    echo "项目根目录：$FRONTEND_DIR"
    echo "服务端口：$SERVER_PORT"
    echo "日志文件：$LOG_FILE"
    echo "运行模式：$([ "$daemon" = true ] && echo '后台' || echo '前台')"
    echo "=========================================="
    echo ""

    # 检查 pnpm
    if ! check_pnpm; then
        return 1
    fi

    # 检查是否已有服务运行
    if is_running; then
        local pid=$(get_running_pid)
        echo "警告：服务已在运行 (PID: $pid)"
        echo ""
        echo "操作建议："
        echo "  - 重启服务：scripts/run-frontend.sh --restart"
        echo "  - 停止服务：scripts/run-frontend.sh --stop"
        echo "  - 查看日志：tail -f $LOG_FILE"
        return 1
    fi

    # 检查并清理占用端口的进程
    local port_pid=$(check_port $SERVER_PORT)
    if [ -n "$port_pid" ]; then
        echo "警告：端口 $SERVER_PORT 被占用 (PID: $port_pid)，正在终止..."
        kill -9 $port_pid 2>/dev/null
        sleep 1
        # 验证端口是否已释放
        if check_port $SERVER_PORT > /dev/null 2>&1; then
            echo "错误：端口 $SERVER_PORT 仍被占用，请手动处理"
            return 1
        fi
        echo "  已释放端口 $SERVER_PORT"
    fi

    # 检查 node_modules
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        echo "提示：未找到 node_modules，正在安装依赖..."
        cd "$FRONTEND_DIR"
        pnpm install
        if [ $? -ne 0 ]; then
            echo "错误：依赖安装失败"
            return 1
        fi
        echo "依赖安装完成"
        echo ""
    fi

    if [ "$daemon" = true ]; then
        # 后台运行
        cd "$FRONTEND_DIR"
        nohup pnpm dev --port $SERVER_PORT > "$LOG_FILE" 2>&1 &
        local pid=$!
        echo "$pid" > "$PID_FILE"
        echo "服务已启动 (PID: $pid)"
        echo ""

        # 等待服务启动完成
        if wait_for_startup 30; then
            echo ""
            echo "查看日志：tail -f $LOG_FILE"
            echo "停止服务：scripts/run-frontend.sh --stop"
            echo "健康检查：scripts/run-frontend.sh --health"
        else
            echo ""
            echo "服务启动失败，请检查日志：$LOG_FILE"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        # 前台运行
        echo "正在启动服务..."
        echo "按 Ctrl+C 停止服务"
        echo ""
        cd "$FRONTEND_DIR"
        pnpm dev --port $SERVER_PORT 2>&1 | tee -a "$LOG_FILE"
    fi
}

# 停止服务
stop_service() {
    echo "=========================================="
    echo "        停止前端服务"
    echo "=========================================="

    if ! is_running; then
        echo "服务未运行"
        return 0
    fi

    local pid=$(get_running_pid)
    echo "正在停止服务 (PID: $pid)..."

    # 尝试优雅关闭
    kill $pid 2>/dev/null

    # 等待进程结束
    local count=0
    while ps -p $pid > /dev/null 2>&1 && [ $count -lt 30 ]; do
        sleep 1
        count=$((count + 1))
        echo "  等待服务停止... ($count/30)"
    done

    # 强制终止
    if ps -p $pid > /dev/null 2>&1; then
        echo "  优雅关闭超时，强制终止..."
        kill -9 $pid 2>/dev/null
    fi

    # 清理 PID 文件
    rm -f "$PID_FILE"

    # 清理端口占用
    local port_pid=$(check_port $SERVER_PORT)
    if [ -n "$port_pid" ]; then
        echo "  端口仍被占用 (PID: $port_pid)，正在清理..."
        kill -9 $port_pid 2>/dev/null
    fi

    echo "服务已停止"
    echo "=========================================="
}

# 重启服务
restart_service() {
    stop_service
    sleep 2
    start_service false
}

# 显示状态
show_status() {
    echo "=========================================="
    echo "        前端服务状态"
    echo "=========================================="

    if is_running; then
        local pid=$(get_running_pid)
        echo "服务状态：运行中"
        echo "进程 PID: $pid"
        echo "服务端口：$SERVER_PORT"
        echo "日志文件：$LOG_FILE"
        echo ""
        echo "操作："
        echo "  - 查看日志：tail -f $LOG_FILE"
        echo "  - 停止服务：scripts/run-frontend.sh --stop"
        echo "  - 重启服务：scripts/run-frontend.sh --restart"
    else
        echo "服务状态：未运行"
        echo ""
        echo "启动服务：scripts/run-frontend.sh"
    fi
    echo "=========================================="
}

# 安装依赖
install_deps() {
    echo "=========================================="
    echo "        安装前端依赖"
    echo "=========================================="

    if ! check_pnpm; then
        return 1
    fi

    cd "$FRONTEND_DIR"
    echo "项目目录：$FRONTEND_DIR"
    echo ""
    echo "正在安装依赖..."
    pnpm install
    if [ $? -eq 0 ]; then
        echo ""
        echo "依赖安装完成"
        echo "=========================================="
    else
        echo ""
        echo "依赖安装失败"
        echo "=========================================="
        return 1
    fi
}

# =============================================================================
# 主流程
# =============================================================================

ACTION="start"
DAEMON=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --daemon|-d)
            DAEMON=true
            ACTION="start"
            shift
            ;;
        --stop|-s)
            ACTION="stop"
            shift
            ;;
        --restart|-r)
            ACTION="restart"
            shift
            ;;
        --status)
            ACTION="status"
            shift
            ;;
        --health)
            ACTION="health"
            shift
            ;;
        --install|-i)
            ACTION="install"
            shift
            ;;
        --help|-h)
            echo "用法：scripts/run-frontend.sh [选项]"
            echo ""
            echo "选项："
            echo "  --daemon, -d     后台运行（守护进程）"
            echo "  --stop, -s       停止服务"
            echo "  --restart, -r    重启服务"
            echo "  --status         显示服务状态"
            echo "  --health         检查服务健康状态"
            echo "  --install, -i    安装依赖"
            echo "  --help, -h       显示帮助"
            echo ""
            echo "示例："
            echo "  scripts/run-frontend.sh           # 前台运行"
            echo "  scripts/run-frontend.sh -d        # 后台运行"
            echo "  scripts/run-frontend.sh -s        # 停止服务"
            echo "  scripts/run-frontend.sh -r        # 重启服务"
            echo "  scripts/run-frontend.sh --health  # 健康检查"
            echo "  scripts/run-frontend.sh -i        # 安装依赖"
            exit 0
            ;;
        *)
            echo "未知参数：$1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 执行操作
case $ACTION in
    start)
        start_service $DAEMON
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        show_status
        ;;
    health)
        health_check
        ;;
    install)
        install_deps
        ;;
esac

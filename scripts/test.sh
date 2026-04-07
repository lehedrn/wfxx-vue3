#!/bin/bash

# =============================================================================
# test.sh - 运行测试脚本
# =============================================================================
# 用法：scripts/test.sh [选项]
# 示例：scripts/test.sh                    # 运行所有测试
#       scripts/test.sh --unit             # 运行单元测试
#       scripts/test.sh --integration      # 运行集成测试
#       scripts/test.sh --file XxxTest     # 运行指定测试类
# =============================================================================

# 获取项目根目录绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 日志目录
LOG_DIR="${PROJECT_ROOT}/logs/backend"
LOG_FILE="${LOG_DIR}/test-$(date +%Y%m%d-%H%M%S).log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# Maven 命令
MVN_CMD="mvn"

# 测试类型
TEST_TYPE="all"
TEST_FILE=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --unit|-u)
            TEST_TYPE="unit"
            shift
            ;;
        --integration|-i)
            TEST_TYPE="integration"
            shift
            ;;
        --file|-f)
            TEST_TYPE="file"
            TEST_FILE="$2"
            shift 2
            ;;
        --help|-h)
            echo "用法：scripts/test.sh [选项]"
            echo ""
            echo "选项："
            echo "  --unit, -u       运行单元测试"
            echo "  --integration, -i 运行集成测试"
            echo "  --file, -f       运行指定测试类"
            echo "  --help, -h       显示帮助"
            echo ""
            echo "示例："
            echo "  scripts/test.sh                    # 运行所有测试"
            echo "  scripts/test.sh -u                 # 运行单元测试"
            echo "  scripts/test.sh -f UserServiceTest # 运行指定测试类"
            exit 0
            ;;
        *)
            echo "未知参数：$1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 构建 Maven 测试命令
build_test_command() {
    case $TEST_TYPE in
        unit)
            echo "mvn test -Dtest='**/*Test.java' -DfailIfNoTests=false"
            ;;
        integration)
            echo "mvn test -Dtest='**/*IT.java' -DfailIfNoTests=false"
            ;;
        file)
            if [ -z "$TEST_FILE" ]; then
                echo "错误：请指定测试类名"
                echo "示例：scripts/test.sh -f UserServiceTest"
                exit 1
            fi
            echo "mvn test -Dtest='$TEST_FILE' -DfailIfNoTests=false"
            ;;
        *)
            echo "mvn test"
            ;;
    esac
}

TEST_CMD=$(build_test_command)

# =============================================================================
# 主流程
# =============================================================================

echo "=========================================="
echo "        若依项目 - 运行测试"
echo "=========================================="
echo "项目根目录：$PROJECT_ROOT"
echo "测试类型："
case $TEST_TYPE in
    unit)
        echo "  - 单元测试"
        ;;
    integration)
        echo "  - 集成测试"
        ;;
    file)
        echo "  - 指定测试：$TEST_FILE"
        ;;
    *)
        echo "  - 所有测试"
        ;;
esac
echo "------------------------------------------"
echo "测试命令：$TEST_CMD"
echo "日志文件：$LOG_FILE"
echo "=========================================="
echo ""

# 检查 Maven 是否安装
if ! command -v mvn &> /dev/null; then
    echo "错误：未找到 Maven"
    echo "请先安装 Maven 或设置 PATH 环境变量"
    exit 1
fi

# 显示 Maven 版本
echo "Maven 版本："
mvn --version
echo ""

# 执行测试
echo "开始运行测试..."
echo "测试日志将同时输出到屏幕和文件：$LOG_FILE"
echo ""

{
    echo "测试开始时间：$(date)"
    echo "命令：$TEST_CMD"
    echo "测试类型：$TEST_TYPE"
    echo "------------------------------------------"

    cd "$PROJECT_ROOT"
    eval "$TEST_CMD" 2>&1

    TEST_STATUS=$?

    echo "------------------------------------------"
    echo "测试结束时间：$(date)"
    if [ $TEST_STATUS -eq 0 ]; then
        echo "测试状态：通过"
    else
        echo "测试状态：失败 (退出码：$TEST_STATUS)"
    fi
} | tee -a "$LOG_FILE"

TEST_STATUS=${PIPESTATUS[0]}

# =============================================================================
# 测试结果
# =============================================================================

echo ""
if [ $TEST_STATUS -eq 0 ]; then
    echo "=========================================="
    echo "        测试通过！"
    echo "=========================================="
    echo ""
    echo "下一步操作："
    echo "  - 构建项目：scripts/build.sh"
    echo "  - 运行后端：scripts/run-backend.sh"
    echo "  - 代码生成：scripts/gen-code.sh demo student"
    echo "=========================================="
else
    echo "=========================================="
    echo "        测试失败！"
    echo "=========================================="
    echo ""
    echo "请查看日志文件：$LOG_FILE"
    echo ""
    echo "常见原因："
    echo "  - 测试代码错误：检查测试用例"
    echo "  - 环境问题：检查数据库、Redis 连接"
    echo "  - 依赖问题：运行 scripts/build.sh 重新构建"
    echo "=========================================="
    exit 1
fi

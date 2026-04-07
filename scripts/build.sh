#!/bin/bash

# =============================================================================
# build.sh - 构建后端项目脚本
# =============================================================================
# 用法：scripts/build.sh [选项]
# 示例：scripts/build.sh                    # 完整构建（包含测试）
#       scripts/build.sh --skip-tests       # 跳过测试构建
#       scripts/build.sh --clean            # 清理后构建
#       scripts/build.sh --quick            # 快速构建（清理 + 跳过测试）
#       scripts/build.sh --install          # 安装到本地 Maven 仓库
#       scripts/build.sh --module ruoyi-admin  # 构建指定模块
# =============================================================================

# 获取项目根目录绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 日志目录
LOG_DIR="${PROJECT_ROOT}/logs/backend"
LOG_FILE="${LOG_DIR}/build-$(date +%Y%m%d-%H%M%S).log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 默认参数
SKIP_TESTS=false
CLEAN=false
QUICK=false
INSTALL=false
MODULE=""

# Maven 命令
MVN_CMD="mvn"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests|-st)
            SKIP_TESTS=true
            shift
            ;;
        --clean|-c)
            CLEAN=true
            shift
            ;;
        --quick|-q)
            QUICK=true
            CLEAN=true
            SKIP_TESTS=true
            shift
            ;;
        --install|-i)
            INSTALL=true
            shift
            ;;
        --module|-m)
            MODULE="$2"
            shift 2
            ;;
        --help|-h)
            echo "用法：scripts/build.sh [选项]"
            echo ""
            echo "选项："
            echo "  --skip-tests, -st    跳过测试"
            echo "  --clean, -c          清理后构建"
            echo "  --quick, -q          快速构建（清理 + 跳过测试）"
            echo "  --install, -i        安装到本地 Maven 仓库"
            echo "  --module, -m         构建指定模块"
            echo "  --help, -h           显示帮助"
            echo ""
            echo "示例："
            echo "  scripts/build.sh                    # 完整构建"
            echo "  scripts/build.sh -q                 # 快速构建"
            echo "  scripts/build.sh -q -i              # 快速构建并安装"
            echo "  scripts/build.sh -m ruoyi-admin     # 构建指定模块"
            exit 0
            ;;
        *)
            echo "未知参数：$1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 构建 Maven 命令
MVN_ARGS=()
if [ "$CLEAN" = true ]; then
    MVN_ARGS+=("clean")
fi

# 根据模式添加构建目标
if [ "$INSTALL" = true ]; then
    MVN_ARGS+=("install")
else
    MVN_ARGS+=("package")
fi

# 跳过测试
if [ "$SKIP_TESTS" = true ] || [ "$QUICK" = true ]; then
    MVN_ARGS+=("-DskipTests")
fi

# 指定模块构建
if [ -n "$MODULE" ]; then
    MVN_ARGS+=("-pl" "$MODULE")
    # 如果需要依赖模块，同时构建依赖
    MVN_ARGS+=("-am")
fi

# 构建命令字符串
MVN_CMD_FULL="${MVN_CMD} ${MVN_ARGS[*]}"

# =============================================================================
# 主流程
# =============================================================================

echo "=========================================="
echo "        若依项目 - 后端构建"
echo "=========================================="
echo "项目根目录：$PROJECT_ROOT"
echo "构建模式："
if [ "$QUICK" = true ]; then
    echo "  - 快速构建（清理 + 跳过测试）"
elif [ "$SKIP_TESTS" = true ] && [ "$CLEAN" = true ]; then
    echo "  - 清理后构建（跳过测试）"
elif [ "$SKIP_TESTS" = true ]; then
    echo "  - 跳过测试"
elif [ "$CLEAN" = true ]; then
    echo "  - 清理后构建"
elif [ "$INSTALL" = true ]; then
    echo "  - 安装到本地 Maven 仓库"
else
    echo "  - 完整构建（包含测试）"
fi
if [ -n "$MODULE" ]; then
    echo "  - 指定模块：$MODULE"
fi
echo "------------------------------------------"
echo "构建命令：$MVN_CMD_FULL"
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

# 执行构建
echo "开始构建..."
echo "构建日志将同时输出到屏幕和文件：$LOG_FILE"
echo ""

# 使用 tee 同时输出到屏幕和文件
{
    echo "构建开始时间：$(date)"
    echo "命令：$MVN_CMD_FULL"
    echo "------------------------------------------"

    cd "$PROJECT_ROOT"
    eval "$MVN_CMD_FULL" 2>&1

    BUILD_STATUS=$?

    echo "------------------------------------------"
    echo "构建结束时间：$(date)"
    if [ $BUILD_STATUS -eq 0 ]; then
        echo "构建状态：成功"
    else
        echo "构建状态：失败 (退出码：$BUILD_STATUS)"
    fi
} | tee -a "$LOG_FILE"

BUILD_STATUS=${PIPESTATUS[0]}

# =============================================================================
# 构建结果
# =============================================================================

echo ""
if [ $BUILD_STATUS -eq 0 ]; then
    echo "=========================================="
    echo "        构建完成！"
    echo "=========================================="
    echo ""
    echo "生成的 JAR 文件："
    if [ -n "$MODULE" ]; then
        # 指定模块构建，只显示该模块的 JAR
        find "$PROJECT_ROOT/$MODULE/target" -name "*.jar" -type f 2>/dev/null | grep -v "/maven-repo/" | grep -v ".jar.original" | while read jar; do
            echo "  - $jar"
        done
    else
        # 全量构建，显示主要 JAR 文件
        find "$PROJECT_ROOT" -name "*.jar" -type f 2>/dev/null | grep -v "/maven-repo/" | grep -v ".jar.original" | while read jar; do
            echo "  - $jar"
        done
    fi
    echo ""
    echo "下一步操作："
    echo "  1. 运行后端服务：scripts/run-backend.sh"
    echo "  2. 运行代码生成：scripts/gen-code.sh demo student"
    echo "  3. 运行测试：scripts/test.sh"
    echo "=========================================="
else
    echo "=========================================="
    echo "        构建失败！"
    echo "=========================================="
    echo ""
    echo "请检查日志文件：$LOG_FILE"
    echo ""
    echo "常见问题："
    echo "  - 依赖下载失败：检查网络连接，配置 Maven 镜像"
    echo "  - 编译错误：检查代码语法错误"
    echo "  - 测试失败：使用 --skip-tests 跳过测试"
    echo "=========================================="
    exit 1
fi

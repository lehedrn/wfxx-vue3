#!/bin/bash

# =============================================================================
# clean.sh - 清理构建产物脚本
# =============================================================================
# 用法：scripts/clean.sh [选项]
# 示例：scripts/clean.sh                    # 清理所有
#       scripts/clean.sh --maven            # 仅清理 Maven 构建产物
#       scripts/clean.sh --logs             # 仅清理日志
#       scripts/clean.sh --node             # 仅清理前端 node_modules
#       scripts/clean.sh --dist             # 仅清理前端构建产物
#       scripts/clean.sh --generate         # 仅清理代码生成输出
#       scripts/clean.sh --dry-run          # 预览清理内容
# =============================================================================

# 获取项目根目录绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 目录配置
CLEAN_MAVEN=false
CLEAN_LOGS=false
CLEAN_NODE=false
CLEAN_DIST=false
CLEAN_GENERATE=false
CLEAN_ALL=true

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --maven|-m)
            CLEAN_MAVEN=true
            CLEAN_ALL=false
            shift
            ;;
        --logs|-l)
            CLEAN_LOGS=true
            CLEAN_ALL=false
            shift
            ;;
        --node|-n)
            CLEAN_NODE=true
            CLEAN_ALL=false
            shift
            ;;
        --dist)
            CLEAN_DIST=true
            CLEAN_ALL=false
            shift
            ;;
        --generate)
            CLEAN_GENERATE=true
            CLEAN_ALL=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "用法：scripts/clean.sh [选项]"
            echo ""
            echo "选项："
            echo "  --maven, -m    仅清理 Maven 构建产物 (target/)"
            echo "  --logs, -l     仅清理日志文件"
            echo "  --node, -n     仅清理前端 node_modules"
            echo "  --dist         仅清理前端构建产物 (dist/)"
            echo "  --generate     仅清理代码生成输出 (generate/output/)"
            echo "  --dry-run      仅显示，不实际删除"
            echo "  --help, -h     显示帮助"
            echo ""
            echo "示例："
            echo "  scripts/clean.sh              # 清理所有"
            echo "  scripts/clean.sh -m           # 仅清理 Maven"
            echo "  scripts/clean.sh -m -l        # 清理 Maven 和日志"
            echo "  scripts/clean.sh --dist       # 清理前端构建产物"
            echo "  scripts/clean.sh --generate   # 清理代码生成输出"
            echo "  scripts/clean.sh --dry-run    # 预览将删除的内容"
            exit 0
            ;;
        *)
            echo "未知参数：$1"
            echo "使用 --help 查看用法"
            exit 1
            ;;
    esac
done

# 如果未指定任何选项，默认清理所有
if [ "$CLEAN_ALL" = true ]; then
    CLEAN_MAVEN=true
    CLEAN_LOGS=true
    CLEAN_NODE=true
    CLEAN_DIST=true
    CLEAN_GENERATE=true
fi

# 干运行模式
if [ "$DRY_RUN" = true ]; then
    echo "=========================================="
    echo "        清理预览（干运行）"
    echo "=========================================="
    echo "项目根目录：$PROJECT_ROOT"
    echo "------------------------------------------"
    echo "以下文件/目录将被删除："
    echo ""
fi

# 清理函数
do_clean() {
    local path=$1
    local desc=$2

    if [ -e "$path" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "  [预览] $desc: $path"
        else
            echo "  删除：$desc"
            rm -rf "$path"
        fi
        return 0
    else
        if [ "$DRY_RUN" = true ]; then
            echo "  [跳过] 不存在：$path"
        fi
        return 1
    fi
}

# =============================================================================
# 主流程
# =============================================================================

if [ "$DRY_RUN" = true ]; then
    ACTION_TEXT="预览"
else
    ACTION_TEXT="清理"
fi

echo "=========================================="
echo "        若依项目 - $ACTION_TEXT 构建产物"
echo "=========================================="
echo "项目根目录：$PROJECT_ROOT"
echo "清理范围："
[ "$CLEAN_MAVEN" = true ] && echo "  - Maven 构建产物 (target/)"
[ "$CLEAN_LOGS" = true ] && echo "  - 日志文件 (logs/)"
[ "$CLEAN_NODE" = true ] && echo "  - 前端依赖 (node_modules/)"
[ "$CLEAN_DIST" = true ] && echo "  - 前端构建产物 (dist/)"
[ "$CLEAN_GENERATE" = true ] && echo "  - 代码生成输出 (generate/output/)"
echo "=========================================="
echo ""

DELETED_COUNT=0

# 清理 Maven 构建产物
if [ "$CLEAN_MAVEN" = true ]; then
    echo "[$ACTION_TEXT] Maven 构建产物..."

    # 根目录 target
    do_clean "$PROJECT_ROOT/target" "根目录 target" && ((DELETED_COUNT++))

    # 各模块 target
    for module in ruoyi-admin ruoyi-common ruoyi-framework ruoyi-generator ruoyi-gen-cli ruoyi-quartz ruoyi-system ruoyi-demo; do
        do_clean "$PROJECT_ROOT/$module/target" "$module/target" && ((DELETED_COUNT++))
    done

    # ruoyi-ui target (如果有)
    do_clean "$PROJECT_ROOT/ruoyi-ui/target" "ruoyi-ui/target" && ((DELETED_COUNT++))

    echo ""
fi

# 清理日志文件
if [ "$CLEAN_LOGS" = true ]; then
    echo "[$ACTION_TEXT] 日志文件..."

    # 删除整个 logs 目录（包括根目录下的日志文件）
    do_clean "$PROJECT_ROOT/logs" "logs 目录" && ((DELETED_COUNT++))

    # 重建空目录
    mkdir -p "$PROJECT_ROOT/logs/backend"
    mkdir -p "$PROJECT_ROOT/logs/frontend"
    echo "  重建：logs/backend/ logs/frontend/"

    echo ""
fi

# 清理前端 node_modules
if [ "$CLEAN_NODE" = true ]; then
    echo "[$ACTION_TEXT] 前端依赖..."

    do_clean "$PROJECT_ROOT/ruoyi-ui/node_modules" "ruoyi-ui/node_modules" && ((DELETED_COUNT++))
    do_clean "$PROJECT_ROOT/ruoyi-ui/package-lock.json" "ruoyi-ui/package-lock.json" && ((DELETED_COUNT++))
    do_clean "$PROJECT_ROOT/ruoyi-ui/pnpm-lock.yaml" "ruoyi-ui/pnpm-lock.yaml" && ((DELETED_COUNT++))

    echo ""
fi

# 清理前端构建产物
if [ "$CLEAN_DIST" = true ]; then
    echo "[$ACTION_TEXT] 前端构建产物..."

    do_clean "$PROJECT_ROOT/ruoyi-ui/dist" "ruoyi-ui/dist" && ((DELETED_COUNT++))

    echo ""
fi

# 清理代码生成输出
if [ "$CLEAN_GENERATE" = true ]; then
    echo "[$ACTION_TEXT] 代码生成输出..."

    # 清理 generate/output 下的所有内容（ZIP 文件和解压后的文件夹）
    if [ -d "$PROJECT_ROOT/generate/output" ]; then
        do_clean "$PROJECT_ROOT/generate/output" "generate/output 目录" && ((DELETED_COUNT++))
        mkdir -p "$PROJECT_ROOT/generate/output"
        echo "  重建：generate/output/"
    fi

    echo ""
fi

# 清理临时文件（仅在实际清理时执行）
if [ "$DRY_RUN" = false ]; then
    echo "[$ACTION_TEXT] 临时文件..."

    # 清理 PID 文件
    if [ -d "$PROJECT_ROOT/.pid" ]; then
        rm -rf "$PROJECT_ROOT/.pid"
        echo "  删除：.pid/"
    fi

    echo ""
fi

# 完成
echo "=========================================="
if [ "$DRY_RUN" = true ]; then
    echo "        预览完成"
    echo "=========================================="
    echo "总计：将删除 $DELETED_COUNT 个项目"
    echo ""
    echo "实际执行清理：scripts/clean.sh"
else
    echo "        清理完成"
    echo "=========================================="
    echo "总计：已删除 $DELETED_COUNT 个项目"
    echo ""
    echo "下一步操作："
    echo "  - 重新构建：scripts/build.sh --clean"
    echo "  - 运行后端：scripts/run-backend.sh"
    echo "=========================================="
fi

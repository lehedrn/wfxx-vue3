#!/bin/bash

# =============================================================================
# gen-code.sh - 代码生成脚本
# =============================================================================
# 用法：scripts/gen-code.sh <module> <submodule> [配置文件名]
# 示例：scripts/gen-code.sh demo student
#       scripts/gen-code.sh demo student student  # 指定配置文件名
#       scripts/gen-code.sh --list                # 列出可用配置
# =============================================================================

# 获取项目根目录绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 代码生成目录
GENERATE_CONFIG_DIR="${PROJECT_ROOT}/generate/config"
GENERATE_OUTPUT_DIR="${PROJECT_ROOT}/generate/output"

# ruoyi-gen-cli.jar 绝对路径
JAR_PATH="${PROJECT_ROOT}/ruoyi-gen-cli/target/ruoyi-gen-cli.jar"

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法：scripts/gen-code.sh <module> <submodule> [配置文件名]"
    echo "示例："
    echo "  scripts/gen-code.sh demo student"
    echo "  scripts/gen-code.sh demo student student"
    echo "  scripts/gen-code.sh --list"
    exit 1
fi

# 特殊选项处理
case "$1" in
    --help|-h)
        echo "用法：scripts/gen-code.sh [选项]"
        echo ""
        echo "选项："
        echo "  --help, -h       显示帮助"
        echo "  --list, -l       列出可用的代码生成配置"
        echo ""
        echo "用法：scripts/gen-code.sh <module> <submodule> [配置文件名]"
        echo ""
        echo "参数："
        echo "  module       模块名（如 demo）"
        echo "  submodule    子模块名（如 student）"
        echo "  配置文件名    可选，默认为 submodule 名"
        echo ""
        echo "示例："
        echo "  scripts/gen-code.sh demo student            # 使用默认配置名"
        echo "  scripts/gen-code.sh demo student student    # 指定配置名"
        echo "  scripts/gen-code.sh --list                  # 列出所有配置"
        exit 0
        ;;
    --list|-l)
        echo "=========================================="
        echo "        可用的代码生成配置"
        echo "=========================================="
        echo "配置目录：$GENERATE_CONFIG_DIR"
        echo "------------------------------------------"
        if [ -d "$GENERATE_CONFIG_DIR" ]; then
            count=0
            for module_dir in "$GENERATE_CONFIG_DIR"/*/; do
                if [ -d "$module_dir" ]; then
                    module=$(basename "$module_dir")
                    for subdir in "$module_dir"*/; do
                        if [ -d "$subdir" ]; then
                            submodule=$(basename "$subdir")
                            # 查找配置文件
                            configs=$(ls "$subdir"/*.yml 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.yml$//' | tr '\n' ', ' | sed 's/,$//')
                            if [ -n "$configs" ]; then
                                echo "  $module/$submodule [$configs]"
                                count=$((count + 1))
                            fi
                        fi
                    done
                fi
            done
            if [ $count -eq 0 ]; then
                echo "  暂无可用配置"
            fi
            echo "------------------------------------------"
            echo "总计：$count 个配置"
        else
            echo "  配置目录不存在：$GENERATE_CONFIG_DIR"
        fi
        echo "=========================================="
        exit 0
        ;;
esac

MODULE="$1"
SUBMODULE="$2"
CONFIG_NAME="${3:-$SUBMODULE}"  # 默认使用 submodule 名作为配置文件名

# 配置文件路径
SQL_FILE="${GENERATE_CONFIG_DIR}/${MODULE}/${SUBMODULE}/${CONFIG_NAME}.sql"
CONFIG_FILE="${GENERATE_CONFIG_DIR}/${MODULE}/${SUBMODULE}/${CONFIG_NAME}.yml"

# 输出目录和文件
OUTPUT_DIR="${GENERATE_OUTPUT_DIR}/${MODULE}/${SUBMODULE}"
OUTPUT_FILE="${OUTPUT_DIR}/${CONFIG_NAME}.zip"

# 检查 JAR 文件是否存在
if [ ! -f "$JAR_PATH" ]; then
    echo "错误：未找到 ruoyi-gen-cli.jar"
    echo "路径：$JAR_PATH"
    echo "请先执行：mvn clean package -DskipTests"
    exit 1
fi

# 检查配置文件是否存在
if [ ! -f "$SQL_FILE" ]; then
    echo "错误：SQL 文件不存在：$SQL_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误：配置文件不存在：$CONFIG_FILE"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 执行代码生成
echo "=========================================="
echo "        若依代码生成器"
echo "=========================================="
echo "项目根目录：$PROJECT_ROOT"
echo "模块：$MODULE"
echo "子模块：$SUBMODULE"
echo "配置文件：$CONFIG_NAME"
echo "------------------------------------------"
echo "SQL 文件：$SQL_FILE"
echo "配置文件：$CONFIG_FILE"
echo "输出目录：$OUTPUT_DIR"
echo "输出文件：$OUTPUT_FILE"
echo "JAR 路径：$JAR_PATH"
echo "=========================================="
echo ""
echo "正在生成代码..."

java -jar "$JAR_PATH" \
    --sql="$SQL_FILE" \
    --config="$CONFIG_FILE" \
    --output="$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "        代码生成完成！"
    echo "=========================================="
    echo "输出文件：$OUTPUT_FILE"
    echo ""

    # 自动解压 ZIP 文件
    if command -v unzip &> /dev/null; then
        echo "正在解压 ZIP 文件..."
        UNZIP_DIR="${OUTPUT_DIR}/${CONFIG_NAME}"
        rm -rf "$UNZIP_DIR"  # 删除旧的解压目录（直接覆盖）
        mkdir -p "$UNZIP_DIR"
        unzip -q "$OUTPUT_FILE" -d "$UNZIP_DIR"
        if [ $? -eq 0 ]; then
            echo "解压完成：$UNZIP_DIR"
            echo ""
            echo "生成的代码结构："
            ls -la "$UNZIP_DIR"
            echo ""
        fi
    else
        echo "提示：未找到 unzip 命令，跳过自动解压"
        echo ""
    fi

    echo "下一步操作："
    echo "  1. 查看生成的代码：ls -la ${OUTPUT_DIR}/${CONFIG_NAME}"
    echo "  2. 将后端代码复制到项目对应目录"
    echo "  3. 将前端代码复制到 ruoyi-ui 对应目录"
    echo "  4. 执行菜单 SQL 注册功能"
    echo "  5. 编写业务逻辑"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "        代码生成失败！"
    echo "=========================================="
    exit 1
fi

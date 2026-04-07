#!/bin/bash

# =============================================================================
# gen-code.sh - 代码生成脚本
# =============================================================================
# 用法：scripts/gen-code.sh <sql 文件> <配置文件> [输出文件]
# 示例：scripts/gen-code.sh student.sql student.yml output.zip
#       scripts/gen-code.sh student.sql student.yml  # 输出到默认的 generated.zip
# =============================================================================

# 参数检查
if [ $# -lt 2 ]; then
    echo "用法：scripts/gen-code.sh <sql 文件> <配置文件> [输出文件]"
    echo "示例：scripts/gen-code.sh student.sql student.yml output.zip"
    exit 1
fi

SQL_FILE="$1"
CONFIG_FILE="$2"
OUTPUT="${3:-./generated.zip}"

# 检查文件是否存在
if [ ! -f "$SQL_FILE" ]; then
    echo "错误：SQL 文件不存在：$SQL_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误：配置文件不存在：$CONFIG_FILE"
    exit 1
fi

# 查找 ruoyi-gen-cli.jar
JAR_PATH=""
if [ -f "ruoyi-gen-cli/target/ruoyi-gen-cli.jar" ]; then
    JAR_PATH="ruoyi-gen-cli/target/ruoyi-gen-cli.jar"
elif [ -f "../ruoyi-gen-cli/target/ruoyi-gen-cli.jar" ]; then
    JAR_PATH="../ruoyi-gen-cli/target/ruoyi-gen-cli.jar"
elif [ -f "target/ruoyi-gen-cli.jar" ]; then
    JAR_PATH="target/ruoyi-gen-cli.jar"
fi

if [ -z "$JAR_PATH" ]; then
    echo "错误：未找到 ruoyi-gen-cli.jar，请先执行 mvn clean package -DskipTests"
    exit 1
fi

# 执行代码生成
echo "正在生成代码..."
echo "  SQL 文件：$SQL_FILE"
echo "  配置文件：$CONFIG_FILE"
echo "  输出文件：$OUTPUT"

java -jar "$JAR_PATH" \
    --sql="$SQL_FILE" \
    --config="$CONFIG_FILE" \
    --output="$OUTPUT"

if [ $? -eq 0 ]; then
    echo "代码生成完成！输出文件：$OUTPUT"
else
    echo "代码生成失败！"
    exit 1
fi

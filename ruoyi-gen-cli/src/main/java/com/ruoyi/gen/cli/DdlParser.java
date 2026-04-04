package com.ruoyi.gen.cli;

import java.util.ArrayList;
import java.util.List;
import com.alibaba.druid.sql.SQLUtils;
import com.alibaba.druid.sql.ast.SQLDataType;
import com.alibaba.druid.sql.ast.SQLExpr;
import com.alibaba.druid.sql.ast.SQLStatement;
import com.alibaba.druid.sql.ast.statement.SQLColumnDefinition;
import com.alibaba.druid.sql.ast.statement.SQLTableElement;
import com.alibaba.druid.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import com.alibaba.druid.util.JdbcConstants;
import com.ruoyi.common.constant.GenConstants;
import com.ruoyi.generator.domain.GenTable;
import com.ruoyi.generator.domain.GenTableColumn;
import com.ruoyi.generator.util.GenUtils;

/**
 * DDL SQL 解析器
 * <p>
 * 使用 Druid SQL Parser 解析 CREATE TABLE 语句，
 * 在内存中构造 GenTable + GenTableColumn 对象，无需数据库连接。
 */
public class DdlParser
{
    /**
     * 解析 DDL SQL 文本，返回 GenTable 列表
     *
     * @param ddlSql 包含一条或多条 CREATE TABLE 语句的 SQL 文本
     * @param operName 操作人名称（用于 createBy）
     * @return GenTable 列表
     */
    public static List<GenTable> parse(String ddlSql, String operName)
    {
        List<GenTable> tables = new ArrayList<>();
        List<SQLStatement> statements = SQLUtils.parseStatements(ddlSql, JdbcConstants.MYSQL);

        for (SQLStatement stmt : statements)
        {
            if (!(stmt instanceof MySqlCreateTableStatement))
            {
                continue;
            }
            MySqlCreateTableStatement createStmt = (MySqlCreateTableStatement) stmt;
            GenTable genTable = parseTable(createStmt, operName);
            tables.add(genTable);
        }
        return tables;
    }

    private static GenTable parseTable(MySqlCreateTableStatement createStmt, String operName)
    {
        GenTable genTable = new GenTable();

        // 表名（去除反引号）
        String tableName = cleanName(createStmt.getTableSource().getName().getSimpleName());
        genTable.setTableName(tableName);

        // 表注释
        SQLExpr commentExpr = createStmt.getComment();
        if (commentExpr != null)
        {
            genTable.setTableComment(cleanComment(commentExpr.toString()));
        }
        else
        {
            genTable.setTableComment(tableName);
        }

        // 默认模板类型
        genTable.setTplCategory(GenConstants.TPL_CRUD);
        genTable.setTplWebType("element-plus");

        // 使用 GenUtils 初始化包名、模块名、类名等
        GenUtils.initTable(genTable, operName);

        // 收集主键列名
        List<String> pkColumnNames = new ArrayList<>();
        if (createStmt.findPrimaryKey() != null)
        {
            createStmt.findPrimaryKey().getColumns().forEach(
                    expr -> pkColumnNames.add(cleanName(expr.toString()))
            );
        }

        // 解析列
        List<GenTableColumn> columns = new ArrayList<>();
        int sort = 0;
        for (SQLTableElement element : createStmt.getTableElementList())
        {
            if (!(element instanceof SQLColumnDefinition))
            {
                continue;
            }
            SQLColumnDefinition colDef = (SQLColumnDefinition) element;
            GenTableColumn column = parseColumn(colDef, pkColumnNames);
            column.setSort(sort++);

            // 使用 GenUtils 初始化列的 Java 字段名、类型、HTML 类型等
            GenUtils.initColumnField(column, genTable);
            columns.add(column);
        }

        genTable.setColumns(columns);
        return genTable;
    }

    private static GenTableColumn parseColumn(SQLColumnDefinition colDef, List<String> pkColumnNames)
    {
        GenTableColumn column = new GenTableColumn();

        // 列名
        String columnName = cleanName(colDef.getColumnName());
        column.setColumnName(columnName);

        // 列类型（如 varchar(100)、bigint、decimal(10,2)）
        SQLDataType dataType = colDef.getDataType();
        column.setColumnType(buildColumnType(dataType));

        // 列注释
        if (colDef.getComment() != null)
        {
            column.setColumnComment(cleanComment(colDef.getComment().toString()));
        }
        else
        {
            column.setColumnComment(columnName);
        }

        // 是否主键
        boolean isPk = pkColumnNames.contains(columnName) || colDef.isPrimaryKey();
        column.setIsPk(isPk ? "1" : "0");

        // 是否自增
        boolean isAutoIncrement = colDef.isAutoIncrement();
        column.setIsIncrement(isAutoIncrement ? "1" : "0");

        // 是否必填（NOT NULL）
        boolean isNotNull = colDef.containsNotNullConstaint();
        column.setIsRequired(isNotNull ? "1" : "0");

        return column;
    }

    /**
     * 构建列类型字符串，如 varchar(100)、decimal(10,2)、bigint
     */
    private static String buildColumnType(SQLDataType dataType)
    {
        StringBuilder sb = new StringBuilder(dataType.getName().toLowerCase());
        List<SQLExpr> arguments = dataType.getArguments();
        if (arguments != null && !arguments.isEmpty())
        {
            sb.append("(");
            for (int i = 0; i < arguments.size(); i++)
            {
                if (i > 0)
                {
                    sb.append(",");
                }
                sb.append(arguments.get(i).toString());
            }
            sb.append(")");
        }
        return sb.toString();
    }

    /**
     * 清理名称中的反引号
     */
    private static String cleanName(String name)
    {
        if (name == null)
        {
            return "";
        }
        return name.replace("`", "").trim();
    }

    /**
     * 清理注释中的引号
     */
    private static String cleanComment(String comment)
    {
        if (comment == null)
        {
            return "";
        }
        return comment.replace("'", "").replace("\"", "").trim();
    }
}
package com.ruoyi.gen.cli;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.apache.commons.io.IOUtils;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.generator.domain.GenTable;
import com.ruoyi.generator.domain.GenTableColumn;
import com.ruoyi.generator.util.VelocityInitializer;
import com.ruoyi.generator.util.VelocityUtils;

/**
 * 代码生成器
 * <p>
 * 复用现有 Velocity 模板渲染逻辑，将 GenTable 渲染为代码文件并输出到 ZIP。
 */
public class CodeGenerator
{
    private static final Logger log = LoggerFactory.getLogger(CodeGenerator.class);

    /**
     * 为多张表生成代码并写入 ZIP 文件
     *
     * @param tables 已解析的 GenTable 列表
     * @param outputPath ZIP 输出路径
     */
    public static void generateToZip(List<GenTable> tables, String outputPath) throws IOException
    {
        // 建立主子表关联
        linkSubTables(tables);

        // 收集所有作为子表的表名
        java.util.Set<String> subTableNames = new java.util.HashSet<>();
        for (GenTable table : tables)
        {
            if (table.getSubTableName() != null && !table.getSubTableName().isEmpty())
            {
                subTableNames.add(table.getSubTableName());
            }
        }

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ZipOutputStream zip = new ZipOutputStream(bos);

        for (GenTable table : tables)
        {
            // 跳过作为子表的表（它们的代码会在主表生成时一起生成）
            if (subTableNames.contains(table.getTableName()))
            {
                log.info("跳过子表 {} 的独立代码生成（将在主表中生成）", table.getTableName());
                continue;
            }
            generateTable(table, zip);
        }

        IOUtils.closeQuietly(zip);

        // 写入文件
        File outputFile = new File(outputPath);
        File parentDir = outputFile.getParentFile();
        if (parentDir != null && !parentDir.exists())
        {
            parentDir.mkdirs();
        }
        try (FileOutputStream fos = new FileOutputStream(outputFile))
        {
            fos.write(bos.toByteArray());
        }
    }

    /**
     * 为单张表生成代码写入 ZIP
     */
    private static void generateTable(GenTable table, ZipOutputStream zip)
    {
        log.info("开始生成表 {} 的代码，tplCategory={}, subTableName={}, subTable={}",
                table.getTableName(),
                table.getTplCategory(),
                table.getSubTableName(),
                table.getSubTable() != null ? table.getSubTable().getTableName() : "null");

        // 设置主键列
        setPkColumn(table);

        // 初始化 Velocity
        VelocityInitializer.initVelocity();

        // 构建模板上下文
        VelocityContext context = VelocityUtils.prepareContext(table);

        // 获取模板列表
        List<String> templates = VelocityUtils.getTemplateList(table.getTplCategory(), table.getTplWebType());

        for (String template : templates)
        {
            StringWriter sw = new StringWriter();
            Template tpl = Velocity.getTemplate(template, Constants.UTF8);
            tpl.merge(context, sw);
            try
            {
                String fileName = VelocityUtils.getFileName(template, table);
                zip.putNextEntry(new ZipEntry(fileName));
                IOUtils.write(sw.toString(), zip, Constants.UTF8);
                IOUtils.closeQuietly(sw);
                zip.flush();
                zip.closeEntry();
            }
            catch (IOException e)
            {
                log.error("渲染模板失败，表名：" + table.getTableName(), e);
            }
        }
    }

    /**
     * 建立主子表关联
     * <p>
     * 遍历所有表，如果表配置了 subTableName，则从 tables 列表中查找对应的子表对象并关联。
     */
    private static void linkSubTables(List<GenTable> tables)
    {
        for (GenTable table : tables)
        {
            String subTableName = table.getSubTableName();
            log.info("检查表 {} 的子表配置: subTableName={}", table.getTableName(), subTableName);
            if (subTableName != null && !subTableName.isEmpty())
            {
                // 从 tables 列表中查找子表
                for (GenTable subTable : tables)
                {
                    log.info("  比较子表: {} vs {}", subTable.getTableName(), subTableName);
                    if (subTable.getTableName().equals(subTableName))
                    {
                        log.info("  ✓ 找到子表，建立关联");
                        table.setSubTable(subTable);
                        break;
                    }
                }
                if (table.getSubTable() == null)
                {
                    log.warn("  ✗ 未找到子表 {}", subTableName);
                }
            }
        }
    }

    /**
     * 设置主键列信息（复用 GenTableServiceImpl 中的逻辑）
     */
    private static void setPkColumn(GenTable table)
    {
        for (GenTableColumn column : table.getColumns())
        {
            if (column.isPk())
            {
                table.setPkColumn(column);
                break;
            }
        }
        if (table.getPkColumn() == null && !table.getColumns().isEmpty())
        {
            table.setPkColumn(table.getColumns().get(0));
        }
    }
}
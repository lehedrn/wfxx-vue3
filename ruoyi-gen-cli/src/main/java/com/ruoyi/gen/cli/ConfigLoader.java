package com.ruoyi.gen.cli;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.constant.GenConstants;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.generator.config.GenConfig;
import com.ruoyi.generator.domain.GenTable;
import com.ruoyi.generator.domain.GenTableColumn;
import com.ruoyi.generator.util.GenUtils;

/**
 * 配置加载器
 * <p>
 * 读取 YAML 配置文件，按三层优先级覆盖 GenTable / GenTableColumn：
 * <ol>
 *   <li>DDL 解析自动推断（DdlParser + GenUtils）</li>
 *   <li>YAML 全局配置（global）</li>
 *   <li>YAML 表级/列级配置（tables.xxx / tables.xxx.columns.xxx）</li>
 * </ol>
 */
public class ConfigLoader
{
    private static final Logger log = LoggerFactory.getLogger(ConfigLoader.class);

    /**
     * 从 YAML 文件加载配置
     */
    public static GenTableConfig load(String configPath) throws IOException
    {
        File file = new File(configPath);
        if (!file.exists())
        {
            throw new IOException("配置文件不存在: " + file.getAbsolutePath());
        }
        Yaml yaml = new Yaml();
        try (InputStream is = new FileInputStream(file))
        {
            return yaml.loadAs(is, GenTableConfig.class);
        }
    }

    /**
     * 将全局配置应用到 GenConfig 静态字段（影响 GenUtils.initTable 的行为）
     * <p>
     * 必须在 DdlParser.parse() 之前调用。
     */
    public static void applyGlobalToGenConfig(GenTableConfig config)
    {
        if (config == null || config.getGlobal() == null)
        {
            return;
        }
        GenTableConfig.GlobalConfig g = config.getGlobal();
        if (StringUtils.isNotEmpty(g.getAuthor()))
        {
            GenConfig.author = g.getAuthor();
        }
        if (StringUtils.isNotEmpty(g.getPackageName()))
        {
            GenConfig.packageName = g.getPackageName();
        }
        if (g.getAutoRemovePre() != null)
        {
            GenConfig.autoRemovePre = g.getAutoRemovePre();
        }
        if (StringUtils.isNotEmpty(g.getTablePrefix()))
        {
            GenConfig.tablePrefix = g.getTablePrefix();
        }
    }

    /**
     * 将 YAML 配置覆盖应用到已解析的 GenTable 列表
     * <p>
     * 在 DdlParser.parse() 之后调用。按优先级：全局默认 → 表级覆盖 → 列级覆盖。
     */
    public static void applyConfig(List<GenTable> tables, GenTableConfig config)
    {
        if (config == null)
        {
            return;
        }
        GenTableConfig.GlobalConfig g = config.getGlobal();
        Map<String, GenTableConfig.TableConfig> tableConfigs = config.getTables();

        for (GenTable table : tables)
        {
            // --- 第一层：全局默认 ---
            applyGlobalDefaults(table, g);

            // --- 第二层：表级覆盖 ---
            GenTableConfig.TableConfig tc = null;
            if (tableConfigs != null)
            {
                tc = tableConfigs.get(table.getTableName());
            }
            if (tc != null)
            {
                applyTableConfig(table, tc);
            }

            // 确保 moduleName 有值（从 packageName 提取末段）
            if (StringUtils.isEmpty(table.getModuleName()) && StringUtils.isNotEmpty(table.getPackageName()))
            {
                table.setModuleName(GenUtils.getModuleName(table.getPackageName()));
            }

            // 确保 businessName 有值（从 tableName 提取末段）
            if (StringUtils.isEmpty(table.getBusinessName()) && StringUtils.isNotEmpty(table.getTableName()))
            {
                table.setBusinessName(GenUtils.getBusinessName(table.getTableName()));
            }

            // --- 构建 options JSON（树表/主子表/parentMenuId） ---
            buildOptions(table, g, tc);

            // --- 第三层：列级覆盖 ---
            Map<String, GenTableConfig.ColumnConfig> colConfigs = (tc != null) ? tc.getColumns() : null;
            if (colConfigs != null && table.getColumns() != null)
            {
                for (GenTableColumn column : table.getColumns())
                {
                    GenTableConfig.ColumnConfig cc = colConfigs.get(column.getColumnName());
                    if (cc != null)
                    {
                        applyColumnConfig(column, cc);
                    }
                }
            }
        }
    }

    /**
     * 应用全局默认值到 GenTable
     */
    private static void applyGlobalDefaults(GenTable table, GenTableConfig.GlobalConfig g)
    {
        if (g == null)
        {
            return;
        }
        // tplCategory
        if (StringUtils.isNotEmpty(g.getTplCategory()))
        {
            table.setTplCategory(g.getTplCategory());
        }
        // tplWebType
        if (StringUtils.isNotEmpty(g.getTplWebType()))
        {
            table.setTplWebType(g.getTplWebType());
        }
        // moduleName（全局）
        if (StringUtils.isNotEmpty(g.getModuleName()))
        {
            table.setModuleName(g.getModuleName());
        }
    }

    /**
     * 应用表级配置到 GenTable（基本信息 + 生成信息）
     */
    private static void applyTableConfig(GenTable table, GenTableConfig.TableConfig tc)
    {
        // -- 基本信息 --
        if (StringUtils.isNotEmpty(tc.getTableComment()))
        {
            table.setTableComment(tc.getTableComment());
            // 同步更新 functionName（如果 functionName 未单独设置）
            if (StringUtils.isEmpty(tc.getFunctionName()))
            {
                table.setFunctionName(GenUtils.replaceText(tc.getTableComment()));
            }
        }
        if (StringUtils.isNotEmpty(tc.getClassName()))
        {
            table.setClassName(tc.getClassName());
        }
        if (StringUtils.isNotEmpty(tc.getFunctionAuthor()))
        {
            table.setFunctionAuthor(tc.getFunctionAuthor());
        }
        if (StringUtils.isNotEmpty(tc.getRemark()))
        {
            table.setRemark(tc.getRemark());
        }

        // -- 生成信息 --
        if (StringUtils.isNotEmpty(tc.getTplCategory()))
        {
            table.setTplCategory(tc.getTplCategory());
        }
        if (StringUtils.isNotEmpty(tc.getTplWebType()))
        {
            table.setTplWebType(tc.getTplWebType());
        }
        if (StringUtils.isNotEmpty(tc.getPackageName()))
        {
            table.setPackageName(tc.getPackageName());
        }
        if (StringUtils.isNotEmpty(tc.getModuleName()))
        {
            table.setModuleName(tc.getModuleName());
        }
        if (StringUtils.isNotEmpty(tc.getBusinessName()))
        {
            table.setBusinessName(tc.getBusinessName());
        }
        if (StringUtils.isNotEmpty(tc.getFunctionName()))
        {
            table.setFunctionName(tc.getFunctionName());
        }
        if (null != tc.getFormColNum()) {
            table.setFormColNum(tc.getFormColNum());
        }

        // -- 树表 --
        if (StringUtils.isNotEmpty(tc.getTreeCode()))
        {
            table.setTreeCode(tc.getTreeCode());
        }
        if (StringUtils.isNotEmpty(tc.getTreeParentCode()))
        {
            table.setTreeParentCode(tc.getTreeParentCode());
        }
        if (StringUtils.isNotEmpty(tc.getTreeName()))
        {
            table.setTreeName(tc.getTreeName());
        }

        // -- 主子表 --
        if (StringUtils.isNotEmpty(tc.getSubTableName()))
        {
            table.setSubTableName(tc.getSubTableName());
        }
        if (StringUtils.isNotEmpty(tc.getSubTableFkName()))
        {
            table.setSubTableFkName(tc.getSubTableFkName());
        }
    }

    /**
     * 构建 options JSON，供 VelocityUtils 读取（树编码、父编码、树名称、上级菜单ID）
     */
    private static void buildOptions(GenTable table, GenTableConfig.GlobalConfig g, GenTableConfig.TableConfig tc)
    {
        JSONObject options = new JSONObject();

        // parentMenuId：表级 > 全局 > 默认
        Long parentMenuId = null;
        if (tc != null && tc.getParentMenuId() != null)
        {
            parentMenuId = tc.getParentMenuId();
        }
        else if (g != null && g.getParentMenuId() != null)
        {
            parentMenuId = g.getParentMenuId();
        }
        if (parentMenuId != null)
        {
            options.put(GenConstants.PARENT_MENU_ID, String.valueOf(parentMenuId));
        }

        // 树表字段
        if (GenConstants.TPL_TREE.equals(table.getTplCategory()))
        {
            if (StringUtils.isNotEmpty(table.getTreeCode()))
            {
                options.put(GenConstants.TREE_CODE, table.getTreeCode());
            }
            if (StringUtils.isNotEmpty(table.getTreeParentCode()))
            {
                options.put(GenConstants.TREE_PARENT_CODE, table.getTreeParentCode());
            }
            if (StringUtils.isNotEmpty(table.getTreeName()))
            {
                options.put(GenConstants.TREE_NAME, table.getTreeName());
            }
        }

        if (!options.isEmpty())
        {
            table.setOptions(options.toJSONString());
        }
    }

    /**
     * 应用列级配置到 GenTableColumn（字段信息）
     */
    private static void applyColumnConfig(GenTableColumn column, GenTableConfig.ColumnConfig cc)
    {
        if (StringUtils.isNotEmpty(cc.getColumnComment()))
        {
            column.setColumnComment(cc.getColumnComment());
        }
        if (StringUtils.isNotEmpty(cc.getJavaType()))
        {
            column.setJavaType(cc.getJavaType());
        }
        if (StringUtils.isNotEmpty(cc.getJavaField()))
        {
            column.setJavaField(cc.getJavaField());
        }
        if (cc.getIsInsert() != null)
        {
            column.setIsInsert(cc.getIsInsert() ? "1" : "0");
        }
        if (cc.getIsEdit() != null)
        {
            column.setIsEdit(cc.getIsEdit() ? "1" : "0");
        }
        if (cc.getIsList() != null)
        {
            column.setIsList(cc.getIsList() ? "1" : "0");
        }
        if (cc.getIsQuery() != null)
        {
            column.setIsQuery(cc.getIsQuery() ? "1" : "0");
        }
        if (cc.getIsRequired() != null)
        {
            column.setIsRequired(cc.getIsRequired() ? "1" : "0");
        }
        if (StringUtils.isNotEmpty(cc.getQueryType()))
        {
            column.setQueryType(cc.getQueryType());
        }
        if (StringUtils.isNotEmpty(cc.getHtmlType()))
        {
            column.setHtmlType(cc.getHtmlType());
        }
        if (cc.getDictType() != null)
        {
            column.setDictType(cc.getDictType());
        }
    }
}
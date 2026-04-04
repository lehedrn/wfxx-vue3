package com.ruoyi.gen.cli;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 代码生成 YAML 配置模型
 * <p>
 * 对齐 RuoYi 代码生成的三层配置：全局默认 → 表级配置（基本信息 + 生成信息） → 列级配置（字段信息）。
 * <p>
 * 配置文件示例：
 * <pre>
 * # ==================== 全局默认配置 ====================
 * global:
 *   author: ruoyi                    # 作者
 *   packageName: com.ruoyi.system    # 生成包路径
 *   moduleName: system               # 模块名（默认从 packageName 提取末段）
 *   autoRemovePre: true              # 自动去除表前缀
 *   tablePrefix: sys_                # 表前缀（多个逗号分隔）
 *   tplCategory: crud                # 模板类型: crud / tree / sub
 *   tplWebType: element-plus         # 前端类型: element-ui / element-plus
 *   parentMenuId: 3                  # 上级菜单ID
 *
 * # ==================== 表级配置 ====================
 * # 按表名配置，覆盖全局默认。每张表可配置：
 * #   基本信息：tableName, tableComment, className, functionAuthor, remark
 * #   生成信息：tplCategory, tplWebType, packageName, moduleName, businessName,
 * #            functionName, parentMenuId, treeCode, treeParentCode, treeName,
 * #            subTableName, subTableFkName
 * #   字段信息：columns 下按列名配置
 * tables:
 *   sys_product:
 *     # -- 基本信息 --
 *     className: Product              # 实体类名（默认自动转换）
 *     functionAuthor: zhangsan        # 覆盖全局 author
 *     remark: 产品管理模块
 *
 *     # -- 生成信息 --
 *     tplCategory: crud
 *     tplWebType: element-plus
 *     packageName: com.ruoyi.product  # 覆盖全局包名
 *     moduleName: product
 *     businessName: product
 *     functionName: 产品管理
 *     parentMenuId: 3
 *
 *     # -- 字段信息（按列名配置） --
 *     columns:
 *       product_type:
 *         columnComment: 产品类型      # 字段描述
 *         javaType: String             # Java类型: String/Integer/Long/Double/BigDecimal/Date/Boolean
 *         javaField: productType       # Java属性名
 *         isInsert: true               # 插入字段
 *         isEdit: true                 # 编辑字段
 *         isList: true                 # 列表字段
 *         isQuery: true                # 查询字段
 *         isRequired: false            # 必填
 *         queryType: EQ                # 查询方式: EQ/NE/GT/GTE/LT/LTE/LIKE/BETWEEN
 *         htmlType: select             # 显示类型: input/textarea/select/radio/checkbox/datetime/imageUpload/fileUpload/editor
 *         dictType: sys_product_type   # 字典类型
 *       status:
 *         dictType: sys_normal_disable
 *         htmlType: radio
 *         queryType: EQ
 *
 *   sys_category:
 *     # -- 树表配置 --
 *     tplCategory: tree
 *     treeCode: category_id
 *     treeParentCode: parent_id
 *     treeName: category_name
 * </pre>
 */
public class GenTableConfig
{
    /** 全局默认配置 */
    private GlobalConfig global;

    /** 表级配置，key = 表名 */
    private Map<String, TableConfig> tables;

    public GlobalConfig getGlobal()
    {
        return global;
    }

    public void setGlobal(GlobalConfig global)
    {
        this.global = global;
    }

    public Map<String, TableConfig> getTables()
    {
        return tables;
    }

    public void setTables(Map<String, TableConfig> tables)
    {
        this.tables = tables;
    }

    // ========== 全局配置 ==========

    public static class GlobalConfig
    {
        /** 作者 */
        private String author;
        /** 生成包路径 */
        private String packageName;
        /** 模块名（默认从 packageName 末段提取） */
        private String moduleName;
        /** 自动去除表前缀 */
        private Boolean autoRemovePre;
        /** 表前缀（多个逗号分隔） */
        private String tablePrefix;
        /** 模板类型: crud / tree / sub */
        private String tplCategory;
        /** 前端类型: element-ui / element-plus */
        private String tplWebType;
        /** 上级菜单ID */
        private Long parentMenuId;

        public String getAuthor()
        {
            return author;
        }

        public void setAuthor(String author)
        {
            this.author = author;
        }

        public String getPackageName()
        {
            return packageName;
        }

        public void setPackageName(String packageName)
        {
            this.packageName = packageName;
        }

        public String getModuleName()
        {
            return moduleName;
        }

        public void setModuleName(String moduleName)
        {
            this.moduleName = moduleName;
        }

        public Boolean getAutoRemovePre()
        {
            return autoRemovePre;
        }

        public void setAutoRemovePre(Boolean autoRemovePre)
        {
            this.autoRemovePre = autoRemovePre;
        }

        public String getTablePrefix()
        {
            return tablePrefix;
        }

        public void setTablePrefix(String tablePrefix)
        {
            this.tablePrefix = tablePrefix;
        }

        public String getTplCategory()
        {
            return tplCategory;
        }

        public void setTplCategory(String tplCategory)
        {
            this.tplCategory = tplCategory;
        }

        public String getTplWebType()
        {
            return tplWebType;
        }

        public void setTplWebType(String tplWebType)
        {
            this.tplWebType = tplWebType;
        }

        public Long getParentMenuId()
        {
            return parentMenuId;
        }

        public void setParentMenuId(Long parentMenuId)
        {
            this.parentMenuId = parentMenuId;
        }
    }

    // ========== 表级配置（基本信息 + 生成信息 + 字段信息） ==========

    public static class TableConfig
    {
        // --- 基本信息 ---

        /** 表描述（覆盖 DDL 中的 COMMENT） */
        private String tableComment;
        /** 实体类名（覆盖自动转换） */
        private String className;
        /** 作者（覆盖全局 author） */
        private String functionAuthor;
        /** 备注 */
        private String remark;

        // --- 生成信息 ---

        /** 模板类型: crud / tree / sub */
        private String tplCategory;
        /** 前端类型: element-ui / element-plus */
        private String tplWebType;
        /** 生成包路径 */
        private String packageName;
        /** 模块名 */
        private String moduleName;
        /** 业务名 */
        private String businessName;
        /** 功能名（菜单显示名） */
        private String functionName;
        /** 上级菜单ID */
        private Long parentMenuId;

        // --- 树表配置（tplCategory=tree 时有效） ---

        /** 树编码字段（列名，如 dept_id） */
        private String treeCode;
        /** 树父编码字段（列名，如 parent_id） */
        private String treeParentCode;
        /** 树名称字段（列名，如 dept_name） */
        private String treeName;

        // --- 主子表配置（tplCategory=sub 时有效） ---

        /** 关联子表的表名 */
        private String subTableName;
        /** 子表关联的外键名 */
        private String subTableFkName;

        // --- 字段信息 ---

        /** 列级配置，key = 列名 */
        private Map<String, ColumnConfig> columns;

        // Getters and Setters

        public String getTableComment()
        {
            return tableComment;
        }

        public void setTableComment(String tableComment)
        {
            this.tableComment = tableComment;
        }

        public String getClassName()
        {
            return className;
        }

        public void setClassName(String className)
        {
            this.className = className;
        }

        public String getFunctionAuthor()
        {
            return functionAuthor;
        }

        public void setFunctionAuthor(String functionAuthor)
        {
            this.functionAuthor = functionAuthor;
        }

        public String getRemark()
        {
            return remark;
        }

        public void setRemark(String remark)
        {
            this.remark = remark;
        }

        public String getTplCategory()
        {
            return tplCategory;
        }

        public void setTplCategory(String tplCategory)
        {
            this.tplCategory = tplCategory;
        }

        public String getTplWebType()
        {
            return tplWebType;
        }

        public void setTplWebType(String tplWebType)
        {
            this.tplWebType = tplWebType;
        }

        public String getPackageName()
        {
            return packageName;
        }

        public void setPackageName(String packageName)
        {
            this.packageName = packageName;
        }

        public String getModuleName()
        {
            return moduleName;
        }

        public void setModuleName(String moduleName)
        {
            this.moduleName = moduleName;
        }

        public String getBusinessName()
        {
            return businessName;
        }

        public void setBusinessName(String businessName)
        {
            this.businessName = businessName;
        }

        public String getFunctionName()
        {
            return functionName;
        }

        public void setFunctionName(String functionName)
        {
            this.functionName = functionName;
        }

        public Long getParentMenuId()
        {
            return parentMenuId;
        }

        public void setParentMenuId(Long parentMenuId)
        {
            this.parentMenuId = parentMenuId;
        }

        public String getTreeCode()
        {
            return treeCode;
        }

        public void setTreeCode(String treeCode)
        {
            this.treeCode = treeCode;
        }

        public String getTreeParentCode()
        {
            return treeParentCode;
        }

        public void setTreeParentCode(String treeParentCode)
        {
            this.treeParentCode = treeParentCode;
        }

        public String getTreeName()
        {
            return treeName;
        }

        public void setTreeName(String treeName)
        {
            this.treeName = treeName;
        }

        public String getSubTableName()
        {
            return subTableName;
        }

        public void setSubTableName(String subTableName)
        {
            this.subTableName = subTableName;
        }

        public String getSubTableFkName()
        {
            return subTableFkName;
        }

        public void setSubTableFkName(String subTableFkName)
        {
            this.subTableFkName = subTableFkName;
        }

        public Map<String, ColumnConfig> getColumns()
        {
            return columns;
        }

        public void setColumns(Map<String, ColumnConfig> columns)
        {
            this.columns = columns;
        }
    }

    // ========== 列级配置（字段信息） ==========

    public static class ColumnConfig
    {
        /** 字段描述 */
        private String columnComment;
        /** Java类型: String / Integer / Long / Double / BigDecimal / Date / Boolean */
        private String javaType;
        /** Java属性名（camelCase） */
        private String javaField;
        /** 是否插入字段 */
        private Boolean isInsert;
        /** 是否编辑字段 */
        private Boolean isEdit;
        /** 是否列表字段 */
        private Boolean isList;
        /** 是否查询字段 */
        private Boolean isQuery;
        /** 是否必填 */
        private Boolean isRequired;
        /** 查询方式: EQ / NE / GT / GTE / LT / LTE / LIKE / BETWEEN */
        private String queryType;
        /** 显示类型: input / textarea / select / radio / checkbox / datetime / imageUpload / fileUpload / editor */
        private String htmlType;
        /** 字典类型编码 */
        private String dictType;

        // Getters and Setters

        public String getColumnComment()
        {
            return columnComment;
        }

        public void setColumnComment(String columnComment)
        {
            this.columnComment = columnComment;
        }

        public String getJavaType()
        {
            return javaType;
        }

        public void setJavaType(String javaType)
        {
            this.javaType = javaType;
        }

        public String getJavaField()
        {
            return javaField;
        }

        public void setJavaField(String javaField)
        {
            this.javaField = javaField;
        }

        public Boolean getIsInsert()
        {
            return isInsert;
        }

        public void setIsInsert(Boolean isInsert)
        {
            this.isInsert = isInsert;
        }

        public Boolean getIsEdit()
        {
            return isEdit;
        }

        public void setIsEdit(Boolean isEdit)
        {
            this.isEdit = isEdit;
        }

        public Boolean getIsList()
        {
            return isList;
        }

        public void setIsList(Boolean isList)
        {
            this.isList = isList;
        }

        public Boolean getIsQuery()
        {
            return isQuery;
        }

        public void setIsQuery(Boolean isQuery)
        {
            this.isQuery = isQuery;
        }

        public Boolean getIsRequired()
        {
            return isRequired;
        }

        public void setIsRequired(Boolean isRequired)
        {
            this.isRequired = isRequired;
        }

        public String getQueryType()
        {
            return queryType;
        }

        public void setQueryType(String queryType)
        {
            this.queryType = queryType;
        }

        public String getHtmlType()
        {
            return htmlType;
        }

        public void setHtmlType(String htmlType)
        {
            this.htmlType = htmlType;
        }

        public String getDictType()
        {
            return dictType;
        }

        public void setDictType(String dictType)
        {
            this.dictType = dictType;
        }
    }
}
package com.ruoyi.system.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.TreeEntity;

/**
 * 区划管理对象 sys_area
 * 
 * @author coderleehd
 * @date 2026-04-14
 */
public class Area extends TreeEntity
{
    private static final long serialVersionUID = 1L;

    /** 编号 */
    private Long id;

    /** 区划名称 */
    @Excel(name = "区划名称")
    private String name;

    /** 区划编码（2/4/6/9/12位） */
    @Excel(name = "区划编码", readConverterExp = "2=/4/6/9/12位")
    private String code;

    /** 父区域编码（0 为根节点） */
    private String parentCode;

    /** 层级 */
    @Excel(name = "层级")
    private String areaLevel;

    /** 排序号 */
    @Excel(name = "排序号")
    private Integer sort;

    /** 删除标志（0 正常 1 删除） */
    private String delFlag;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setName(String name) 
    {
        this.name = name;
    }

    public String getName() 
    {
        return name;
    }

    public void setCode(String code) 
    {
        this.code = code;
    }

    public String getCode() 
    {
        return code;
    }

    public void setParentCode(String parentCode) 
    {
        this.parentCode = parentCode;
    }

    public String getParentCode() 
    {
        return parentCode;
    }

    public void setAreaLevel(String areaLevel) 
    {
        this.areaLevel = areaLevel;
    }

    public String getAreaLevel() 
    {
        return areaLevel;
    }

    public void setSort(Integer sort) 
    {
        this.sort = sort;
    }

    public Integer getSort() 
    {
        return sort;
    }

    public void setDelFlag(String delFlag) 
    {
        this.delFlag = delFlag;
    }

    public String getDelFlag() 
    {
        return delFlag;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("name", getName())
            .append("code", getCode())
            .append("parentCode", getParentCode())
            .append("ancestors", getAncestors())
            .append("areaLevel", getAreaLevel())
            .append("sort", getSort())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("createBy", getCreateBy())
            .append("updateBy", getUpdateBy())
            .append("remark", getRemark())
            .append("delFlag", getDelFlag())
            .toString();
    }
}

package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.AreaMapper;
import com.ruoyi.system.domain.Area;
import com.ruoyi.system.service.IAreaService;

/**
 * 区划管理Service业务层处理
 *
 * @author coderleehd
 * @date 2026-04-14
 */
@Service
public class AreaServiceImpl implements IAreaService
{
    @Autowired
    private AreaMapper areaMapper;

    /**
     * 查询区划管理
     *
     * @param id 区划管理主键
     * @return 区划管理
     */
    @Override
    public Area selectAreaById(Long id)
    {
        return areaMapper.selectAreaById(id);
    }

    /**
     * 查询区划管理列表
     *
     * @param area 区划管理
     * @return 区划管理
     */
    @Override
    public List<Area> selectAreaList(Area area)
    {
        return areaMapper.selectAreaList(area);
    }

    /**
     * 新增区划管理
     *
     * @param area 区划管理
     * @return 结果
     */
    @Override
    public int insertArea(Area area)
    {
        area.setCreateTime(DateUtils.getNowDate());
        // 自动计算 ancestors
        calculateAncestors(area);
        return areaMapper.insertArea(area);
    }

    /**
     * 修改区划管理
     *
     * @param area 区划管理
     * @return 结果
     */
    @Override
    public int updateArea(Area area)
    {
        area.setUpdateTime(DateUtils.getNowDate());
        // 根据 parentCode 重新计算 ancestors
        calculateAncestors(area);
        return areaMapper.updateArea(area);
    }

    /**
     * 根据 parentCode 自动计算并设置 ancestors
     * 格式：0,省级code,市级code,县级code（逗号分隔，不包含自身编码）
     */
    private void calculateAncestors(Area area)
    {
        String parentCode = area.getParentCode();
        if (parentCode == null || "0".equals(parentCode))
        {
            // 顶级节点（省级），ancestors 为 '0'
            area.setAncestors("0");
            return;
        }
        // 查询父级区划，获取其 ancestors
        Area parent = areaMapper.selectAreaByCode(parentCode);
        if (parent != null && parent.getAncestors() != null)
        {
            // ancestors = 父级ancestors + "," + 父级code
            area.setAncestors(parent.getAncestors() + "," + parentCode);
        }
    }

    /**
     * 批量删除区划管理
     *
     * @param ids 需要删除的区划管理主键
     * @return 结果
     */
    @Override
    public int deleteAreaByIds(Long[] ids)
    {
        return areaMapper.deleteAreaByIds(ids);
    }

    /**
     * 删除区划管理信息
     *
     * @param id 区划管理主键
     * @return 结果
     */
    @Override
    public int deleteAreaById(Long id)
    {
        return areaMapper.deleteAreaById(id);
    }

    /**
     * 根据父级编码查询子节点列表（用于懒加载）
     *
     * @param parentCode 父区域编码
     * @return 子节点集合
     */
    @Override
    public List<Area> selectAreasByParentCode(String parentCode)
    {
        return areaMapper.selectAreasByParentCode(parentCode);
    }

    /**
     * 根据区划编码查询区划信息
     *
     * @param code 区划编码
     * @return 区划信息
     */
    @Override
    public Area selectAreaByCode(String code)
    {
        return areaMapper.selectAreaByCode(code);
    }
}

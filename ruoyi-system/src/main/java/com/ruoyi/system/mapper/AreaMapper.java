package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.Area;

/**
 * 区划管理Mapper接口
 * 
 * @author coderleehd
 * @date 2026-04-14
 */
public interface AreaMapper 
{
    /**
     * 查询区划管理
     * 
     * @param id 区划管理主键
     * @return 区划管理
     */
    public Area selectAreaById(Long id);

    /**
     * 查询区划管理列表
     * 
     * @param area 区划管理
     * @return 区划管理集合
     */
    public List<Area> selectAreaList(Area area);

    /**
     * 新增区划管理
     * 
     * @param area 区划管理
     * @return 结果
     */
    public int insertArea(Area area);

    /**
     * 修改区划管理
     * 
     * @param area 区划管理
     * @return 结果
     */
    public int updateArea(Area area);

    /**
     * 删除区划管理
     * 
     * @param id 区划管理主键
     * @return 结果
     */
    public int deleteAreaById(Long id);

    /**
     * 批量删除区划管理
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteAreaByIds(Long[] ids);

    /**
     * 根据父级编码查询子节点列表
     *
     * @param parentCode 父区域编码
     * @return 子节点集合
     */
    public List<Area> selectAreasByParentCode(String parentCode);

    /**
     * 根据区划编码查询区划信息
     *
     * @param code 区划编码
     * @return 区划信息
     */
    public Area selectAreaByCode(String code);
}

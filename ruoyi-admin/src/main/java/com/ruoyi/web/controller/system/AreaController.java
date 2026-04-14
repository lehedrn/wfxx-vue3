package com.ruoyi.web.controller.system;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.Area;
import com.ruoyi.system.service.IAreaService;
import com.ruoyi.common.utils.poi.ExcelUtil;

/**
 * 区划管理Controller
 * 
 * @author coderleehd
 * @date 2026-04-14
 */
@RestController
@RequestMapping("/system/area")
public class AreaController extends BaseController
{
    @Autowired
    private IAreaService areaService;

    /**
     * 查询区划管理列表
     * 初始加载只返回省级数据，搜索时返回匹配结果
     */
    @PreAuthorize("@ss.hasPermi('system:area:list')")
    @GetMapping("/list")
    public AjaxResult list(Area area)
    {
        List<Area> list;
        // 无查询条件时只返回省级数据（初始加载）
        if (area.getName() == null && area.getCode() == null && area.getAreaLevel() == null)
        {
            list = areaService.selectAreasByParentCode("0");
        }
        else
        {
            list = areaService.selectAreaList(area);
        }
        return success(list);
    }

    /**
     * 懒加载子节点数据
     */
    @PreAuthorize("@ss.hasPermi('system:area:list')")
    @GetMapping("/listTree/{parentCode}")
    public AjaxResult listTree(@PathVariable("parentCode") String parentCode)
    {
        List<Area> list = areaService.selectAreasByParentCode(parentCode);
        return success(list);
    }

    /**
     * 导出区划管理列表
     */
    @PreAuthorize("@ss.hasPermi('system:area:export')")
    @Log(title = "区划管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Area area)
    {
        List<Area> list = areaService.selectAreaList(area);
        ExcelUtil<Area> util = new ExcelUtil<Area>(Area.class);
        util.exportExcel(response, list, "区划管理数据");
    }

    /**
     * 获取区划管理详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:area:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(areaService.selectAreaById(id));
    }

    /**
     * 根据区划编码查询区划信息
     */
    @PreAuthorize("@ss.hasPermi('system:area:query')")
    @GetMapping(value = "/code/{code}")
    public AjaxResult getByCode(@PathVariable("code") String code)
    {
        return success(areaService.selectAreaByCode(code));
    }

    /**
     * 新增区划管理
     */
    @PreAuthorize("@ss.hasPermi('system:area:add')")
    @Log(title = "区划管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Area area)
    {
        return toAjax(areaService.insertArea(area));
    }

    /**
     * 修改区划管理
     */
    @PreAuthorize("@ss.hasPermi('system:area:edit')")
    @Log(title = "区划管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Area area)
    {
        return toAjax(areaService.updateArea(area));
    }

    /**
     * 删除区划管理
     */
    @PreAuthorize("@ss.hasPermi('system:area:remove')")
    @Log(title = "区划管理", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(areaService.deleteAreaByIds(ids));
    }
}

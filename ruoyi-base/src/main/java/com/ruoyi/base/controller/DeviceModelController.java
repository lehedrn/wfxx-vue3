package com.ruoyi.base.controller;

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
import com.ruoyi.base.domain.DeviceModel;
import com.ruoyi.base.service.IDeviceModelService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 设备型号管理Controller
 * 
 * @author coderleehd
 * @date 2026-04-10
 */
@RestController
@RequestMapping("/base/deviceModel")
public class DeviceModelController extends BaseController
{
    @Autowired
    private IDeviceModelService deviceModelService;

    /**
     * 查询设备型号管理列表
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:list')")
    @GetMapping("/list")
    public TableDataInfo list(DeviceModel deviceModel)
    {
        startPage();
        List<DeviceModel> list = deviceModelService.selectDeviceModelList(deviceModel);
        return getDataTable(list);
    }

    /**
     * 导出设备型号管理列表
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:export')")
    @Log(title = "设备型号管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, DeviceModel deviceModel)
    {
        List<DeviceModel> list = deviceModelService.selectDeviceModelList(deviceModel);
        ExcelUtil<DeviceModel> util = new ExcelUtil<DeviceModel>(DeviceModel.class);
        util.exportExcel(response, list, "设备型号管理数据");
    }

    /**
     * 获取设备型号管理详细信息
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(deviceModelService.selectDeviceModelById(id));
    }

    /**
     * 新增设备型号管理
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:add')")
    @Log(title = "设备型号管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DeviceModel deviceModel)
    {
        return toAjax(deviceModelService.insertDeviceModel(deviceModel));
    }

    /**
     * 修改设备型号管理
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:edit')")
    @Log(title = "设备型号管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DeviceModel deviceModel)
    {
        return toAjax(deviceModelService.updateDeviceModel(deviceModel));
    }

    /**
     * 删除设备型号管理
     */
    @PreAuthorize("@ss.hasPermi('base:deviceModel:remove')")
    @Log(title = "设备型号管理", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(deviceModelService.deleteDeviceModelByIds(ids));
    }
}

package com.ruoyi.base.mapper;

import java.util.List;
import com.ruoyi.base.domain.DeviceModel;

/**
 * 设备型号管理Mapper接口
 * 
 * @author coderleehd
 * @date 2026-04-10
 */
public interface DeviceModelMapper 
{
    /**
     * 查询设备型号管理
     * 
     * @param id 设备型号管理主键
     * @return 设备型号管理
     */
    public DeviceModel selectDeviceModelById(Long id);

    /**
     * 查询设备型号管理列表
     * 
     * @param deviceModel 设备型号管理
     * @return 设备型号管理集合
     */
    public List<DeviceModel> selectDeviceModelList(DeviceModel deviceModel);

    /**
     * 新增设备型号管理
     * 
     * @param deviceModel 设备型号管理
     * @return 结果
     */
    public int insertDeviceModel(DeviceModel deviceModel);

    /**
     * 修改设备型号管理
     * 
     * @param deviceModel 设备型号管理
     * @return 结果
     */
    public int updateDeviceModel(DeviceModel deviceModel);

    /**
     * 删除设备型号管理
     * 
     * @param id 设备型号管理主键
     * @return 结果
     */
    public int deleteDeviceModelById(Long id);

    /**
     * 批量删除设备型号管理
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDeviceModelByIds(Long[] ids);
}

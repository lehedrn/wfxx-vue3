package com.ruoyi.base.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.base.mapper.DeviceModelMapper;
import com.ruoyi.base.domain.DeviceModel;
import com.ruoyi.base.service.IDeviceModelService;

/**
 * 设备型号管理Service业务层处理
 * 
 * @author coderleehd
 * @date 2026-04-10
 */
@Service
public class DeviceModelServiceImpl implements IDeviceModelService 
{
    @Autowired
    private DeviceModelMapper deviceModelMapper;

    /**
     * 查询设备型号管理
     * 
     * @param id 设备型号管理主键
     * @return 设备型号管理
     */
    @Override
    public DeviceModel selectDeviceModelById(Long id)
    {
        return deviceModelMapper.selectDeviceModelById(id);
    }

    /**
     * 查询设备型号管理列表
     * 
     * @param deviceModel 设备型号管理
     * @return 设备型号管理
     */
    @Override
    public List<DeviceModel> selectDeviceModelList(DeviceModel deviceModel)
    {
        return deviceModelMapper.selectDeviceModelList(deviceModel);
    }

    /**
     * 新增设备型号管理
     * 
     * @param deviceModel 设备型号管理
     * @return 结果
     */
    @Override
    public int insertDeviceModel(DeviceModel deviceModel)
    {
        deviceModel.setCreateTime(DateUtils.getNowDate());
        deviceModel.setDelFlag("0");
        return deviceModelMapper.insertDeviceModel(deviceModel);
    }

    /**
     * 修改设备型号管理
     * 
     * @param deviceModel 设备型号管理
     * @return 结果
     */
    @Override
    public int updateDeviceModel(DeviceModel deviceModel)
    {
        deviceModel.setUpdateTime(DateUtils.getNowDate());
        return deviceModelMapper.updateDeviceModel(deviceModel);
    }

    /**
     * 批量删除设备型号管理
     * 
     * @param ids 需要删除的设备型号管理主键
     * @return 结果
     */
    @Override
    public int deleteDeviceModelByIds(Long[] ids)
    {
        return deviceModelMapper.deleteDeviceModelByIds(ids);
    }

    /**
     * 删除设备型号管理信息
     * 
     * @param id 设备型号管理主键
     * @return 结果
     */
    @Override
    public int deleteDeviceModelById(Long id)
    {
        return deviceModelMapper.deleteDeviceModelById(id);
    }
}

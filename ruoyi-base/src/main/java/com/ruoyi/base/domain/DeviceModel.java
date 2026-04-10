package com.ruoyi.base.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 设备型号管理对象 base_device_model
 * 
 * @author coderleehd
 * @date 2026-04-10
 */
public class DeviceModel extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 编号 */
    private Long id;

    /** 设备型号名称 */
    @Excel(name = "设备型号名称")
    private String name;

    /** 设备类型 */
    @Excel(name = "设备类型")
    private String deviceType;

    /** 内存(GB) */
    private Integer memory;

    /** 硬盘容量(GB) */
    private Integer disk;

    /** 操作系统 */
    private String os;

    /** 主板厂家 */
    private String motherboardManufacturer;

    /** CPU型号 */
    @Excel(name = "CPU型号")
    private String cpuModel;

    /** CPU核心数 */
    private Integer cpuCores;

    /** 主频(GHz) */
    private BigDecimal cpuFrequency;

    /** CPU数量 */
    private Integer cpuCount;

    /** GPU型号 */
    @Excel(name = "GPU型号")
    private String gpuModel;

    /** GPU算力 */
    private String gpuComputePower;

    /** 显存(GB) */
    private Integer gpuMemory;

    /** GPU数量 */
    private Integer gpuCount;

    /** 状态 */
    @Excel(name = "状态")
    private String status;

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

    public void setDeviceType(String deviceType) 
    {
        this.deviceType = deviceType;
    }

    public String getDeviceType() 
    {
        return deviceType;
    }

    public void setMemory(Integer memory) 
    {
        this.memory = memory;
    }

    public Integer getMemory() 
    {
        return memory;
    }

    public void setDisk(Integer disk) 
    {
        this.disk = disk;
    }

    public Integer getDisk() 
    {
        return disk;
    }

    public void setOs(String os) 
    {
        this.os = os;
    }

    public String getOs() 
    {
        return os;
    }

    public void setMotherboardManufacturer(String motherboardManufacturer) 
    {
        this.motherboardManufacturer = motherboardManufacturer;
    }

    public String getMotherboardManufacturer() 
    {
        return motherboardManufacturer;
    }

    public void setCpuModel(String cpuModel) 
    {
        this.cpuModel = cpuModel;
    }

    public String getCpuModel() 
    {
        return cpuModel;
    }

    public void setCpuCores(Integer cpuCores) 
    {
        this.cpuCores = cpuCores;
    }

    public Integer getCpuCores() 
    {
        return cpuCores;
    }

    public void setCpuFrequency(BigDecimal cpuFrequency) 
    {
        this.cpuFrequency = cpuFrequency;
    }

    public BigDecimal getCpuFrequency() 
    {
        return cpuFrequency;
    }

    public void setCpuCount(Integer cpuCount) 
    {
        this.cpuCount = cpuCount;
    }

    public Integer getCpuCount() 
    {
        return cpuCount;
    }

    public void setGpuModel(String gpuModel) 
    {
        this.gpuModel = gpuModel;
    }

    public String getGpuModel() 
    {
        return gpuModel;
    }

    public void setGpuComputePower(String gpuComputePower) 
    {
        this.gpuComputePower = gpuComputePower;
    }

    public String getGpuComputePower() 
    {
        return gpuComputePower;
    }

    public void setGpuMemory(Integer gpuMemory) 
    {
        this.gpuMemory = gpuMemory;
    }

    public Integer getGpuMemory() 
    {
        return gpuMemory;
    }

    public void setGpuCount(Integer gpuCount) 
    {
        this.gpuCount = gpuCount;
    }

    public Integer getGpuCount() 
    {
        return gpuCount;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
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
            .append("deviceType", getDeviceType())
            .append("memory", getMemory())
            .append("disk", getDisk())
            .append("os", getOs())
            .append("motherboardManufacturer", getMotherboardManufacturer())
            .append("cpuModel", getCpuModel())
            .append("cpuCores", getCpuCores())
            .append("cpuFrequency", getCpuFrequency())
            .append("cpuCount", getCpuCount())
            .append("gpuModel", getGpuModel())
            .append("gpuComputePower", getGpuComputePower())
            .append("gpuMemory", getGpuMemory())
            .append("gpuCount", getGpuCount())
            .append("status", getStatus())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("createBy", getCreateBy())
            .append("updateBy", getUpdateBy())
            .append("remark", getRemark())
            .append("delFlag", getDelFlag())
            .toString();
    }
}

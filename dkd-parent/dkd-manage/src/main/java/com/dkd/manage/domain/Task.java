package com.dkd.manage.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.dkd.common.core.domain.BaseEntity;

/**
 * 工单对象 tb_task
 */
public class Task extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 工单ID */
    private Long taskId;

    /** 工单编号 */
    private String taskCode;

    /** 工单状态 */
    private Long taskStatus;

    /** 创建类型 0：自动 1：手动 */
    private Long createType;

    /** 售货机编码 */
    private String innerCode;

    /** 执行人id */
    private Long userId;

    /** 执行人名称 */
    private String userName;

    /** 所属区域Id */
    private Long regionId;

    /** 备注 */
    private String desc;

    /** 工单类型id */
    private Long productTypeId;

    /** 指派人Id */
    private Long assignorId;

    /** 地址 */
    private String addr;

    public void setTaskId(Long taskId) 
    {
        this.taskId = taskId;
    }

    public Long getTaskId() 
    {
        return taskId;
    }
    public void setTaskCode(String taskCode) 
    {
        this.taskCode = taskCode;
    }

    public String getTaskCode() 
    {
        return taskCode;
    }
    public void setTaskStatus(Long taskStatus) 
    {
        this.taskStatus = taskStatus;
    }

    public Long getTaskStatus() 
    {
        return taskStatus;
    }
    public void setCreateType(Long createType) 
    {
        this.createType = createType;
    }

    public Long getCreateType() 
    {
        return createType;
    }
    public void setInnerCode(String innerCode) 
    {
        this.innerCode = innerCode;
    }

    public String getInnerCode() 
    {
        return innerCode;
    }
    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }
    public void setUserName(String userName) 
    {
        this.userName = userName;
    }

    public String getUserName() 
    {
        return userName;
    }
    public void setRegionId(Long regionId) 
    {
        this.regionId = regionId;
    }

    public Long getRegionId() 
    {
        return regionId;
    }
    public void setDesc(String desc) 
    {
        this.desc = desc;
    }

    public String getDesc() 
    {
        return desc;
    }
    public void setProductTypeId(Long productTypeId) 
    {
        this.productTypeId = productTypeId;
    }

    public Long getProductTypeId() 
    {
        return productTypeId;
    }
    public void setAssignorId(Long assignorId) 
    {
        this.assignorId = assignorId;
    }

    public Long getAssignorId() 
    {
        return assignorId;
    }
    public void setAddr(String addr) 
    {
        this.addr = addr;
    }

    public String getAddr() 
    {
        return addr;
    }
}

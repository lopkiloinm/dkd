package com.dkd.manage.service;

import java.util.List;
import com.dkd.manage.domain.TaskDetails;

/**
 * 工单详情Service接口
 */
public interface ITaskDetailsService 
{
    /**
     * 批量新增工单详情
     */
    public int insertBatch(List<TaskDetails> taskDetailsList);
}

package com.dkd.manage.mapper;

import java.util.List;
import com.dkd.manage.domain.TaskDetails;

/**
 * 工单详情Mapper接口
 */
public interface TaskDetailsMapper 
{
    /**
     * 批量新增工单详情
     * 
     * @param taskDetailsList 工单详情列表
     * @return 结果
     */
    public int insertBatch(List<TaskDetails> taskDetailsList);

    /**
     * List replenish details for a task.
     */
    public List<TaskDetails> listByTaskId(Long taskId);
}

package com.dkd.manage.service;

import java.util.List;
import com.dkd.manage.domain.Task;
import com.dkd.manage.domain.dto.TaskDto;

/**
 * 工单Service接口
 */
public interface ITaskService 
{
    /**
     * 查询工单
     */
    public Task selectTaskByTaskId(Long taskId);

    /**
     * 查询工单列表
     */
    public List<Task> selectTaskList(Task task);

    /**
     * 新增工单
     */
    public int insertTaskDto(TaskDto taskDto);

}

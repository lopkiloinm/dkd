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

    /**
     * 修改工单
     */
    public int updateTask(Task task);

    /**
     * 删除工单信息
     */
    public int deleteTaskByTaskId(Long taskId);

    /**
     * 批量删除工单
     */
    public int deleteTaskByTaskIds(Long[] taskIds);

    /**
     * Accept a pending task (status 1 → 2).
     */
    public int acceptTask(Long taskId);

    /**
     * Reject / cancel a task with an optional reason.
     */
    public int rejectTask(Long taskId, String reason);

    /**
     * Complete a task. For replenish tasks (TASK_TYPE_SUPPLY)
     * this also refills matching channels to their expect_capacity.
     */
    public int completeTask(Long taskId);
}

package com.dkd.manage.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dkd.manage.mapper.TaskDetailsMapper;
import com.dkd.manage.domain.TaskDetails;
import com.dkd.manage.service.ITaskDetailsService;

/**
 * 工单详情Service业务层处理
 */
@Service
public class TaskDetailsServiceImpl implements ITaskDetailsService 
{
    @Autowired
    private TaskDetailsMapper taskDetailsMapper;

    @Override
    public int insertBatch(List<TaskDetails> taskDetailsList)
    {
        return taskDetailsMapper.insertBatch(taskDetailsList);
    }

    @Override
    public List<TaskDetails> listByTaskId(Long taskId)
    {
        return taskDetailsMapper.listByTaskId(taskId);
    }
}

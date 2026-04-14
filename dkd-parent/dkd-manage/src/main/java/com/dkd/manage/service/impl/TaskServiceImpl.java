package com.dkd.manage.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import com.dkd.common.constant.DkdContants;
import com.dkd.common.exception.ServiceException;
import com.dkd.common.utils.DateUtils;
import com.dkd.manage.domain.Emp;
import com.dkd.manage.domain.Task;
import com.dkd.manage.domain.TaskDetails;
import com.dkd.manage.domain.VendingMachine;
import com.dkd.manage.domain.dto.TaskDto;
import com.dkd.manage.mapper.TaskMapper;
import com.dkd.manage.service.IEmpService;
import com.dkd.manage.service.ITaskDetailsService;
import com.dkd.manage.service.ITaskService;
import com.dkd.manage.service.IVendingMachineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TaskServiceImpl implements ITaskService {
    @Autowired
    private TaskMapper taskMapper;
    @Autowired
    private IVendingMachineService vendingMachineService;
    @Autowired
    private IEmpService empService;
    @Autowired
    private ITaskDetailsService taskDetailsService;

    @Override
    public Task selectTaskByTaskId(Long taskId) {
        return taskMapper.selectTaskByTaskId(taskId);
    }

    @Override
    public List<Task> selectTaskList(Task task) {
        return taskMapper.selectTaskList(task);
    }

    @Transactional
    @Override
    public int insertTaskDto(TaskDto taskDto) {
        //1. 查询售货机是否存在
        VendingMachine vm = vendingMachineService.selectVendingMachineByInnerCode(taskDto.getInnerCode());
        if (vm == null) {
            throw new ServiceException("设备不存在");
        }
        //2. 校验售货机状态与工单类型是否相符
        checkCreateTask(vm.getVmStatus(), taskDto.getProductTypeId());
        //3. 校验这台设备是否有未完成的同类型工单，如果存在则不能创建
        hasTask(taskDto.getInnerCode(), taskDto.getProductTypeId());
        //4. 校验员工是否存在
        Emp emp = empService.selectEmpById(taskDto.getUserId());
        if (emp == null) {
            throw new ServiceException("员工不存在");
        }
        // 5. 校验非同区域下的工作人员不能接受工单
        if (!emp.getRegionId().equals(vm.getRegionId())) {
            throw new ServiceException("非同区域下的工作人员不能接受工单");
        }
        //6. 保存工单信息
        Task task = new Task();
        BeanUtil.copyProperties(taskDto, task);// 属性赋值
        task.setCreateTime(DateUtils.getNowDate());// 创建时间
        task.setTaskCode(generateTaskCode());// 工单编号
        task.setTaskStatus(DkdContants.TASK_STATUS_CREATE);// 创建工单
        task.setAddr(vm.getAddr());
        task.setRegionId(vm.getRegionId());
        task.setUserName(emp.getUserName());
        int taskResult = taskMapper.insertTask(task);
        //7. 如果是补货工单，向工单明细表插入记录
        if (task.getProductTypeId().equals(DkdContants.TASK_TYPE_SUPPLY)) {
            if (CollUtil.isEmpty(taskDto.getDetails())) {
                throw new ServiceException("补货工单明细不能为空");
            }
            List<TaskDetails> taskDetailsList = taskDto.getDetails().stream().map(details -> {
                TaskDetails taskDetails = BeanUtil.copyProperties(details, TaskDetails.class);
                taskDetails.setTaskId(task.getTaskId());
                return taskDetails;
            }).collect(Collectors.toList());
            taskDetailsService.insertBatch(taskDetailsList);
        }
        return taskResult;
    }

    private void checkCreateTask(Long vmStatus, Long productTypeId) {
        if (productTypeId.equals(DkdContants.TASK_TYPE_DEPLOY) && vmStatus.equals(DkdContants.VM_STATUS_RUNNING)) {
            throw new ServiceException("该设备状态是运行中，无法进行投放");
        }
        if (productTypeId.equals(DkdContants.TASK_TYPE_SUPPLY) && !vmStatus.equals(DkdContants.VM_STATUS_RUNNING)) {
            throw new ServiceException("该设备状态不是运行中，无法进行补货");
        }
        if (productTypeId.equals(DkdContants.TASK_TYPE_REPAIR) && !vmStatus.equals(DkdContants.VM_STATUS_RUNNING)) {
            throw new ServiceException("该设备状态不是运行中，无法进行维修");
        }
        if (productTypeId.equals(DkdContants.TASK_TYPE_REVOKE) && !vmStatus.equals(DkdContants.VM_STATUS_RUNNING)) {
            throw new ServiceException("该设备状态不是运行中，无法进行撤机");
        }
    }

    private void hasTask(String innerCode, Long productTypeId) {
        Task task = new Task();
        task.setInnerCode(innerCode);
        task.setProductTypeId(productTypeId);
        task.setTaskStatus(DkdContants.TASK_STATUS_PROGRESS);
        List<Task> taskList = taskMapper.selectTaskList(task);
        if (taskList != null && taskList.size() > 0) {
            throw new ServiceException("这台设备已有未完成的同类型工单，不能重复创建");
        }
        task.setTaskStatus(DkdContants.TASK_STATUS_CREATE);
        taskList = taskMapper.selectTaskList(task);
        if (taskList != null && taskList.size() > 0) {
            throw new ServiceException("这台设备已有未完成的同类型工单，不能重复创建");
        }
    }

    private String generateTaskCode() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        return LocalDateTime.now().format(formatter) + (int)(Math.random() * 9000 + 1000);
    }
}

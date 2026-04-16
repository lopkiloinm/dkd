package com.dkd.manage.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dkd.manage.mapper.ReportMapper;
import com.dkd.manage.service.IReportService;

/**
 * 报表统计Service业务层处理
 */
@Service
public class ReportServiceImpl implements IReportService
{
    @Autowired
    private ReportMapper reportMapper;

    /**
     * 获取仪表盘统计数据
     */
    @Override
    public Map<String, Object> getDashboardStats()
    {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRevenue", reportMapper.getTotalRevenue());
        stats.put("totalOrders", reportMapper.getTotalOrders());
        stats.put("activeMachines", reportMapper.getActiveMachines());
        stats.put("pendingTasks", reportMapper.getPendingTasks());
        return stats;
    }

    /**
     * 获取热销商品统计
     */
    @Override
    public List<Map<String, Object>> getHotProducts()
    {
        return reportMapper.getHotProducts();
    }

    /**
     * 获取异常设备统计
     */
    @Override
    public List<Map<String, Object>> getAbnormalEquipment()
    {
        return reportMapper.getAbnormalEquipment();
    }

    /**
     * 获取工单统计
     */
    @Override
    public Map<String, Object> getTaskStats()
    {
        Map<String, Object> taskStats = new HashMap<>();
        taskStats.put("completedOrders", reportMapper.getCompletedOrders());
        taskStats.put("inProgressOrders", reportMapper.getInProgressOrders());
        taskStats.put("cancelledOrders", reportMapper.getCancelledOrders());
        return taskStats;
    }

    /**
     * 获取商品库存统计
     */
    @Override
    public Map<String, Object> getProductStats()
    {
        Map<String, Object> productStats = new HashMap<>();
        productStats.put("totalProducts", reportMapper.getTotalProducts());
        productStats.put("lowStockCount", reportMapper.getLowStockCount());
        return productStats;
    }

    // Admin dashboard new methods

    /**
     * 获取设备状态统计
     */
    @Override
    public Map<String, Object> getMachineStatusStats()
    {
        return reportMapper.getMachineStatusStats();
    }

    /**
     * 获取实时告警列表
     */
    @Override
    public List<Map<String, Object>> getRealTimeAlerts()
    {
        return reportMapper.getRealTimeAlerts();
    }

    /**
     * 获取最近任务列表
     */
    @Override
    public List<Map<String, Object>> getRecentTasks()
    {
        return reportMapper.getRecentTasks();
    }

    /**
     * 获取库存水平列表
     */
    @Override
    public List<Map<String, Object>> getInventoryLevels()
    {
        return reportMapper.getInventoryLevels();
    }

    /**
     * 获取团队工作负载
     */
    @Override
    public List<Map<String, Object>> getTeamWorkload()
    {
        return reportMapper.getTeamWorkload();
    }

    /**
     * 获取财务指标
     */
    @Override
    public Map<String, Object> getFinancialMetrics()
    {
        return reportMapper.getFinancialMetrics();
    }

    /**
     * 获取成本明细
     */
    @Override
    public List<Map<String, Object>> getCostBreakdown()
    {
        return reportMapper.getCostBreakdown();
    }

    /**
     * 获取按位置的收入
     */
    @Override
    public List<Map<String, Object>> getRevenueByLocation()
    {
        return reportMapper.getRevenueByLocation();
    }

    /**
     * 获取合作伙伴业绩
     */
    @Override
    public List<Map<String, Object>> getPartnerPerformance()
    {
        return reportMapper.getPartnerPerformance();
    }

    /**
     * 获取性能KPI
     */
    @Override
    public Map<String, Object> getPerformanceKPIs()
    {
        return reportMapper.getPerformanceKPIs();
    }
}

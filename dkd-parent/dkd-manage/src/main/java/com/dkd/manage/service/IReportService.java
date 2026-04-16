package com.dkd.manage.service;

import java.util.List;
import java.util.Map;

/**
 * 报表统计Service接口
 */
public interface IReportService
{
    /**
     * 获取仪表盘统计数据
     */
    Map<String, Object> getDashboardStats();

    /**
     * 获取热销商品统计
     */
    List<Map<String, Object>> getHotProducts();

    /**
     * 获取异常设备统计
     */
    List<Map<String, Object>> getAbnormalEquipment();

    /**
     * 获取工单统计
     */
    Map<String, Object> getTaskStats();

    /**
     * 获取商品库存统计
     */
    Map<String, Object> getProductStats();

    // Admin dashboard new methods

    /**
     * 获取设备状态统计
     */
    Map<String, Object> getMachineStatusStats();

    /**
     * 获取实时告警列表
     */
    List<Map<String, Object>> getRealTimeAlerts();

    /**
     * 获取最近任务列表
     */
    List<Map<String, Object>> getRecentTasks();

    /**
     * 获取库存水平列表
     */
    List<Map<String, Object>> getInventoryLevels();

    /**
     * 获取团队工作负载
     */
    List<Map<String, Object>> getTeamWorkload();

    /**
     * 获取财务指标
     */
    Map<String, Object> getFinancialMetrics();

    /**
     * 获取成本明细
     */
    List<Map<String, Object>> getCostBreakdown();

    /**
     * 获取按位置的收入
     */
    List<Map<String, Object>> getRevenueByLocation();

    /**
     * 获取合作伙伴业绩
     */
    List<Map<String, Object>> getPartnerPerformance();

    /**
     * 获取性能KPI
     */
    Map<String, Object> getPerformanceKPIs();
}

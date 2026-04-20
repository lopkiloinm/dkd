package com.dkd.manage.mapper;

import java.util.List;
import java.util.Map;

/**
 * 报表统计Mapper接口
 */
public interface ReportMapper
{
    /**
     * 获取总收入
     */
    Long getTotalRevenue();

    /**
     * 获取总订单数
     */
    Long getTotalOrders();

    /**
     * 获取活跃设备数
     */
    Long getActiveMachines();

    /**
     * 获取待处理工单数
     */
    Long getPendingTasks();

    /**
     * 获取热销商品统计
     */
    List<Map<String, Object>> getHotProducts();

    /**
     * 获取异常设备统计
     */
    List<Map<String, Object>> getAbnormalEquipment();

    /**
     * 获取已完成工单数
     */
    Long getCompletedOrders();

    /**
     * 获取进行中工单数
     */
    Long getInProgressOrders();

    /**
     * 获取已取消工单数
     */
    Long getCancelledOrders();

    /**
     * 获取商品总数
     */
    Long getTotalProducts();

    /**
     * 获取低库存商品数
     */
    Long getLowStockCount();

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

    /**
     * 本周按星期几汇总已完成订单金额（MySQL WEEKDAY：周一=0 … 周日=6）
     */
    List<Map<String, Object>> getRevenueByWeekdayCurrentWeek();
}

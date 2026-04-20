package com.dkd.manage.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dkd.common.core.controller.BaseController;
import com.dkd.common.core.domain.AjaxResult;
import com.dkd.manage.service.IReportService;

/**
 * 报表统计Controller
 */
@RestController
@RequestMapping("/report")
public class ReportController extends BaseController
{
    @Autowired
    private IReportService reportService;

    /**
     * 获取仪表盘统计数据
     */
    @PreAuthorize("@ss.hasPermi('report:dashboard:stats')")
    @GetMapping("/dashboard/stats")
    public AjaxResult getDashboardStats()
    {
        Map<String, Object> stats = reportService.getDashboardStats();
        return AjaxResult.success(stats);
    }

    /**
     * 获取热销商品统计
     */
    @PreAuthorize("@ss.hasPermi('report:hotProducts')")
    @GetMapping("/hotProducts")
    public AjaxResult getHotProducts()
    {
        List<Map<String, Object>> hotProducts = reportService.getHotProducts();
        return AjaxResult.success(hotProducts);
    }

    /**
     * 获取异常设备统计
     */
    @PreAuthorize("@ss.hasPermi('report:abnormalEquipment')")
    @GetMapping("/abnormalEquipment")
    public AjaxResult getAbnormalEquipment()
    {
        List<Map<String, Object>> abnormalEquipment = reportService.getAbnormalEquipment();
        return AjaxResult.success(abnormalEquipment);
    }

    /**
     * 获取工单统计
     */
    @PreAuthorize("@ss.hasPermi('report:taskStats')")
    @GetMapping("/taskStats")
    public AjaxResult getTaskStats()
    {
        Map<String, Object> taskStats = reportService.getTaskStats();
        return AjaxResult.success(taskStats);
    }

    /**
     * 获取商品库存统计
     */
    @PreAuthorize("@ss.hasPermi('report:productStats')")
    @GetMapping("/productStats")
    public AjaxResult getProductStats()
    {
        Map<String, Object> productStats = reportService.getProductStats();
        return AjaxResult.success(productStats);
    }

    // Admin dashboard new endpoints

    /**
     * 获取设备状态统计
     */
    @PreAuthorize("@ss.hasPermi('report:machineStatusStats')")
    @GetMapping("/machineStatusStats")
    public AjaxResult getMachineStatusStats()
    {
        Map<String, Object> stats = reportService.getMachineStatusStats();
        return AjaxResult.success(stats);
    }

    /**
     * 获取实时告警列表
     */
    @PreAuthorize("@ss.hasPermi('report:realTimeAlerts')")
    @GetMapping("/realTimeAlerts")
    public AjaxResult getRealTimeAlerts()
    {
        List<Map<String, Object>> alerts = reportService.getRealTimeAlerts();
        return AjaxResult.success(alerts);
    }

    /**
     * 获取最近任务列表
     */
    @PreAuthorize("@ss.hasPermi('report:recentTasks')")
    @GetMapping("/recentTasks")
    public AjaxResult getRecentTasks()
    {
        List<Map<String, Object>> tasks = reportService.getRecentTasks();
        return AjaxResult.success(tasks);
    }

    /**
     * 获取库存水平列表
     */
    @PreAuthorize("@ss.hasPermi('report:inventoryLevels')")
    @GetMapping("/inventoryLevels")
    public AjaxResult getInventoryLevels()
    {
        List<Map<String, Object>> levels = reportService.getInventoryLevels();
        return AjaxResult.success(levels);
    }

    /**
     * 获取团队工作负载
     */
    @PreAuthorize("@ss.hasPermi('report:teamWorkload')")
    @GetMapping("/teamWorkload")
    public AjaxResult getTeamWorkload()
    {
        List<Map<String, Object>> workload = reportService.getTeamWorkload();
        return AjaxResult.success(workload);
    }

    /**
     * 获取财务指标
     */
    @PreAuthorize("@ss.hasPermi('report:financialMetrics')")
    @GetMapping("/financialMetrics")
    public AjaxResult getFinancialMetrics()
    {
        Map<String, Object> metrics = reportService.getFinancialMetrics();
        return AjaxResult.success(metrics);
    }

    /**
     * 获取成本明细
     */
    @PreAuthorize("@ss.hasPermi('report:costBreakdown')")
    @GetMapping("/costBreakdown")
    public AjaxResult getCostBreakdown()
    {
        List<Map<String, Object>> breakdown = reportService.getCostBreakdown();
        return AjaxResult.success(breakdown);
    }

    /**
     * 获取按位置的收入
     */
    @PreAuthorize("@ss.hasPermi('report:revenueByLocation')")
    @GetMapping("/revenueByLocation")
    public AjaxResult getRevenueByLocation()
    {
        List<Map<String, Object>> revenue = reportService.getRevenueByLocation();
        return AjaxResult.success(revenue);
    }

    /**
     * 获取合作伙伴业绩
     */
    @PreAuthorize("@ss.hasPermi('report:partnerPerformance')")
    @GetMapping("/partnerPerformance")
    public AjaxResult getPartnerPerformance()
    {
        List<Map<String, Object>> performance = reportService.getPartnerPerformance();
        return AjaxResult.success(performance);
    }

    /**
     * 获取性能KPI
     */
    @PreAuthorize("@ss.hasPermi('report:performanceKPIs')")
    @GetMapping("/performanceKPIs")
    public AjaxResult getPerformanceKPIs()
    {
        Map<String, Object> kpis = reportService.getPerformanceKPIs();
        return AjaxResult.success(kpis);
    }

    /**
     * 本周按星期几的收入（已完成订单），供首页柱状图
     */
    @PreAuthorize("@ss.hasPermi('report:dashboard:stats')")
    @GetMapping("/revenueByWeekday")
    public AjaxResult getRevenueByWeekday()
    {
        List<Map<String, Object>> series = reportService.getRevenueByWeekdayCurrentWeek();
        return AjaxResult.success(series);
    }
}

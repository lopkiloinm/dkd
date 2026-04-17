package com.dkd.manage.controller;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dkd.common.annotation.Log;
import com.dkd.common.core.controller.BaseController;
import com.dkd.common.core.domain.AjaxResult;
import com.dkd.common.core.page.TableDataInfo;
import com.dkd.common.enums.BusinessType;
import com.dkd.common.utils.poi.ExcelUtil;
import com.dkd.manage.domain.Order;
import com.dkd.manage.service.IOrderService;

/**
 * Order (read-only) controller
 */
@RestController
@RequestMapping("/manage/order")
public class OrderController extends BaseController
{
    @Autowired
    private IOrderService orderService;

    /**
     * List orders (paged, filtered).
     */
    @PreAuthorize("@ss.hasPermi('manage:order:list')")
    @GetMapping("/list")
    public TableDataInfo list(Order order)
    {
        startPage();
        List<Order> list = orderService.selectOrderList(order);
        return getDataTable(list);
    }

    /**
     * Export orders to Excel.
     */
    @PreAuthorize("@ss.hasPermi('manage:order:export')")
    @Log(title = "Order", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Order order)
    {
        List<Order> list = orderService.selectOrderList(order);
        ExcelUtil<Order> util = new ExcelUtil<Order>(Order.class);
        util.exportExcel(response, list, "orders");
    }

    /**
     * Get order detail by id.
     */
    @PreAuthorize("@ss.hasPermi('manage:order:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(orderService.selectOrderById(id));
    }

    /**
     * Get order by orderNo.
     */
    @PreAuthorize("@ss.hasPermi('manage:order:query')")
    @GetMapping(value = "/no/{orderNo}")
    public AjaxResult getByOrderNo(@PathVariable("orderNo") String orderNo)
    {
        return success(orderService.selectOrderByOrderNo(orderNo));
    }
}

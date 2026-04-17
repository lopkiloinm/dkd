package com.dkd.manage.controller;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dkd.common.annotation.Log;
import com.dkd.common.core.controller.BaseController;
import com.dkd.common.core.domain.AjaxResult;
import com.dkd.common.core.page.TableDataInfo;
import com.dkd.common.enums.BusinessType;
import com.dkd.common.utils.poi.ExcelUtil;
import com.dkd.manage.domain.Policy;
import com.dkd.manage.service.IPolicyService;

/**
 * Pricing policy controller
 */
@RestController
@RequestMapping("/manage/policy")
public class PolicyController extends BaseController
{
    @Autowired
    private IPolicyService policyService;

    @PreAuthorize("@ss.hasPermi('manage:policy:list')")
    @GetMapping("/list")
    public TableDataInfo list(Policy policy)
    {
        startPage();
        List<Policy> list = policyService.selectPolicyList(policy);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('manage:policy:export')")
    @Log(title = "Policy", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Policy policy)
    {
        List<Policy> list = policyService.selectPolicyList(policy);
        ExcelUtil<Policy> util = new ExcelUtil<Policy>(Policy.class);
        util.exportExcel(response, list, "policies");
    }

    @PreAuthorize("@ss.hasPermi('manage:policy:query')")
    @GetMapping(value = "/{policyId}")
    public AjaxResult getInfo(@PathVariable("policyId") Long policyId)
    {
        return success(policyService.selectPolicyById(policyId));
    }

    @PreAuthorize("@ss.hasPermi('manage:policy:add')")
    @Log(title = "Policy", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Policy policy)
    {
        return toAjax(policyService.insertPolicy(policy));
    }

    @PreAuthorize("@ss.hasPermi('manage:policy:edit')")
    @Log(title = "Policy", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Policy policy)
    {
        return toAjax(policyService.updatePolicy(policy));
    }

    @PreAuthorize("@ss.hasPermi('manage:policy:remove')")
    @Log(title = "Policy", businessType = BusinessType.DELETE)
    @DeleteMapping("/{policyIds}")
    public AjaxResult remove(@PathVariable Long[] policyIds)
    {
        return toAjax(policyService.deletePolicyByIds(policyIds));
    }
}

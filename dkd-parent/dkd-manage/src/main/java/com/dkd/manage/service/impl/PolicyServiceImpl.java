package com.dkd.manage.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dkd.common.utils.DateUtils;
import com.dkd.manage.domain.Policy;
import com.dkd.manage.mapper.PolicyMapper;
import com.dkd.manage.service.IPolicyService;

/**
 * Policy service impl
 */
@Service
public class PolicyServiceImpl implements IPolicyService
{
    @Autowired
    private PolicyMapper policyMapper;

    @Override
    public Policy selectPolicyById(Long policyId)
    {
        return policyMapper.selectPolicyById(policyId);
    }

    @Override
    public List<Policy> selectPolicyList(Policy policy)
    {
        return policyMapper.selectPolicyList(policy);
    }

    @Override
    public int insertPolicy(Policy policy)
    {
        policy.setCreateTime(DateUtils.getNowDate());
        policy.setUpdateTime(DateUtils.getNowDate());
        return policyMapper.insertPolicy(policy);
    }

    @Override
    public int updatePolicy(Policy policy)
    {
        policy.setUpdateTime(DateUtils.getNowDate());
        return policyMapper.updatePolicy(policy);
    }

    @Override
    public int deletePolicyByIds(Long[] policyIds)
    {
        return policyMapper.deletePolicyByIds(policyIds);
    }

    @Override
    public int deletePolicyById(Long policyId)
    {
        return policyMapper.deletePolicyById(policyId);
    }
}

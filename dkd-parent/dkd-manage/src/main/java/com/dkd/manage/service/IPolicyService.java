package com.dkd.manage.service;

import java.util.List;
import com.dkd.manage.domain.Policy;

/**
 * Policy service
 */
public interface IPolicyService
{
    Policy selectPolicyById(Long policyId);

    List<Policy> selectPolicyList(Policy policy);

    int insertPolicy(Policy policy);

    int updatePolicy(Policy policy);

    int deletePolicyByIds(Long[] policyIds);

    int deletePolicyById(Long policyId);
}

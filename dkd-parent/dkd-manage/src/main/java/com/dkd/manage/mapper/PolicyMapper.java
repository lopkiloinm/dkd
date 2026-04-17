package com.dkd.manage.mapper;

import java.util.List;
import com.dkd.manage.domain.Policy;

/**
 * Policy mapper
 */
public interface PolicyMapper
{
    Policy selectPolicyById(Long policyId);

    List<Policy> selectPolicyList(Policy policy);

    int insertPolicy(Policy policy);

    int updatePolicy(Policy policy);

    int deletePolicyById(Long policyId);

    int deletePolicyByIds(Long[] policyIds);
}

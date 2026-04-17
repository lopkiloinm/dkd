package com.dkd.manage.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.dkd.common.annotation.Excel;
import com.dkd.common.core.domain.BaseEntity;

/**
 * Pricing policy tb_policy
 */
public class Policy extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Policy id */
    private Long policyId;

    /** Policy display name */
    @Excel(name = "Policy Name")
    private String policyName;

    /** Discount (e.g. 80 means 80% of list price) */
    @Excel(name = "Discount")
    private Integer discount;

    public Long getPolicyId() { return policyId; }
    public void setPolicyId(Long policyId) { this.policyId = policyId; }
    public String getPolicyName() { return policyName; }
    public void setPolicyName(String policyName) { this.policyName = policyName; }
    public Integer getDiscount() { return discount; }
    public void setDiscount(Integer discount) { this.discount = discount; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("policyId", getPolicyId())
            .append("policyName", getPolicyName())
            .append("discount", getDiscount())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}

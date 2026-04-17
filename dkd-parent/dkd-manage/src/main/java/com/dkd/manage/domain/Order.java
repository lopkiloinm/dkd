package com.dkd.manage.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.dkd.common.annotation.Excel;
import com.dkd.common.core.domain.BaseEntity;

/**
 * Order object tb_order
 */
public class Order extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Primary key */
    private Long id;

    /** Order number */
    @Excel(name = "Order No")
    private String orderNo;

    /** Third-party transaction id */
    @Excel(name = "Third Party No")
    private String thirdNo;

    /** Vending machine inner code */
    @Excel(name = "Machine Code")
    private String innerCode;

    /** Channel code */
    @Excel(name = "Channel")
    private String channelCode;

    /** SKU id */
    private Long skuId;

    /** SKU name */
    @Excel(name = "SKU")
    private String skuName;

    /** SKU class id */
    private Integer classId;

    /** Order status: 0=pending-pay 1=paid 2=dispensed 3=dispense-failed 4=cancelled */
    @Excel(name = "Status")
    private Integer status;

    /** Paid amount (cents) */
    @Excel(name = "Amount")
    private Integer amount;

    /** List price (cents) */
    private Integer price;

    /** Pay type: wxpay / alipay */
    @Excel(name = "Pay Type")
    private String payType;

    /** Pay status: 0=unpaid 1=paid 2=refunding 3=refunded */
    @Excel(name = "Pay Status")
    private Integer payStatus;

    /** Partner revenue share (cents) */
    private Integer bill;

    /** Address */
    private String addr;

    /** Region id */
    private Long regionId;

    /** Region name */
    @Excel(name = "Region")
    private String regionName;

    /** Business type */
    private Integer businessType;

    /** Partner id */
    private Integer partnerId;

    /** Consumer openid */
    private String openId;

    /** Node id */
    private Long nodeId;

    /** Node name */
    @Excel(name = "Node")
    private String nodeName;

    /** Cancel reason */
    private String cancelDesc;

    /** Paid / created-before range helpers (non-persisted) */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date beginTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;

    public void setId(Long id) { this.id = id; }
    public Long getId() { return id; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public String getOrderNo() { return orderNo; }
    public void setThirdNo(String thirdNo) { this.thirdNo = thirdNo; }
    public String getThirdNo() { return thirdNo; }
    public void setInnerCode(String innerCode) { this.innerCode = innerCode; }
    public String getInnerCode() { return innerCode; }
    public void setChannelCode(String channelCode) { this.channelCode = channelCode; }
    public String getChannelCode() { return channelCode; }
    public void setSkuId(Long skuId) { this.skuId = skuId; }
    public Long getSkuId() { return skuId; }
    public void setSkuName(String skuName) { this.skuName = skuName; }
    public String getSkuName() { return skuName; }
    public void setClassId(Integer classId) { this.classId = classId; }
    public Integer getClassId() { return classId; }
    public void setStatus(Integer status) { this.status = status; }
    public Integer getStatus() { return status; }
    public void setAmount(Integer amount) { this.amount = amount; }
    public Integer getAmount() { return amount; }
    public void setPrice(Integer price) { this.price = price; }
    public Integer getPrice() { return price; }
    public void setPayType(String payType) { this.payType = payType; }
    public String getPayType() { return payType; }
    public void setPayStatus(Integer payStatus) { this.payStatus = payStatus; }
    public Integer getPayStatus() { return payStatus; }
    public void setBill(Integer bill) { this.bill = bill; }
    public Integer getBill() { return bill; }
    public void setAddr(String addr) { this.addr = addr; }
    public String getAddr() { return addr; }
    public void setRegionId(Long regionId) { this.regionId = regionId; }
    public Long getRegionId() { return regionId; }
    public void setRegionName(String regionName) { this.regionName = regionName; }
    public String getRegionName() { return regionName; }
    public void setBusinessType(Integer businessType) { this.businessType = businessType; }
    public Integer getBusinessType() { return businessType; }
    public void setPartnerId(Integer partnerId) { this.partnerId = partnerId; }
    public Integer getPartnerId() { return partnerId; }
    public void setOpenId(String openId) { this.openId = openId; }
    public String getOpenId() { return openId; }
    public void setNodeId(Long nodeId) { this.nodeId = nodeId; }
    public Long getNodeId() { return nodeId; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public String getNodeName() { return nodeName; }
    public void setCancelDesc(String cancelDesc) { this.cancelDesc = cancelDesc; }
    public String getCancelDesc() { return cancelDesc; }
    public Date getBeginTime() { return beginTime; }
    public void setBeginTime(Date beginTime) { this.beginTime = beginTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("orderNo", getOrderNo())
            .append("innerCode", getInnerCode())
            .append("channelCode", getChannelCode())
            .append("skuId", getSkuId())
            .append("skuName", getSkuName())
            .append("status", getStatus())
            .append("amount", getAmount())
            .append("payType", getPayType())
            .append("payStatus", getPayStatus())
            .append("partnerId", getPartnerId())
            .append("nodeId", getNodeId())
            .append("nodeName", getNodeName())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}

package com.dkd.manage.service;

import java.util.List;
import com.dkd.manage.domain.Sku;

/**
 * 商品Service接口
 */
public interface ISkuService
{
    /**
     * 查询商品
     */
    public Sku selectSkuById(Long skuId);

    /**
     * 查询商品列表
     */
    public List<Sku> selectSkuList(Sku sku);

    /**
     * 新增商品
     */
    public int insertSku(Sku sku);

    /**
     * 修改商品
     */
    public int updateSku(Sku sku);

    /**
     * 批量删除商品
     */
    public int deleteSkuByIds(Long[] skuIds);

    /**
     * 删除商品信息
     */
    public int deleteSkuById(Long skuId);
}

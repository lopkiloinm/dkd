package com.dkd.manage.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dkd.manage.mapper.SkuMapper;
import com.dkd.manage.domain.Sku;
import com.dkd.manage.service.ISkuService;

/**
 * 商品Service业务层处理
 */
@Service
public class SkuServiceImpl implements ISkuService
{
    @Autowired
    private SkuMapper skuMapper;

    /**
     * 查询商品
     */
    @Override
    public Sku selectSkuById(Long skuId)
    {
        return skuMapper.selectSkuById(skuId);
    }

    /**
     * 查询商品列表
     */
    @Override
    public List<Sku> selectSkuList(Sku sku)
    {
        return skuMapper.selectSkuList(sku);
    }

    /**
     * 新增商品
     */
    @Override
    public int insertSku(Sku sku)
    {
        return skuMapper.insertSku(sku);
    }

    /**
     * 修改商品
     */
    @Override
    public int updateSku(Sku sku)
    {
        return skuMapper.updateSku(sku);
    }

    /**
     * 批量删除商品
     */
    @Override
    public int deleteSkuByIds(Long[] skuIds)
    {
        return skuMapper.deleteSkuByIds(skuIds);
    }

    /**
     * 删除商品信息
     */
    @Override
    public int deleteSkuById(Long skuId)
    {
        return skuMapper.deleteSkuById(skuId);
    }
}

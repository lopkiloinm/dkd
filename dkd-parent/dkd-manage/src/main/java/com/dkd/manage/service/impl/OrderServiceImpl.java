package com.dkd.manage.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dkd.manage.mapper.OrderMapper;
import com.dkd.manage.domain.Order;
import com.dkd.manage.service.IOrderService;

/**
 * Order Service impl
 */
@Service
public class OrderServiceImpl implements IOrderService
{
    @Autowired
    private OrderMapper orderMapper;

    @Override
    public Order selectOrderById(Long id)
    {
        return orderMapper.selectOrderById(id);
    }

    @Override
    public Order selectOrderByOrderNo(String orderNo)
    {
        return orderMapper.selectOrderByOrderNo(orderNo);
    }

    @Override
    public List<Order> selectOrderList(Order order)
    {
        return orderMapper.selectOrderList(order);
    }

    @Override
    public int insertOrder(Order order)
    {
        return orderMapper.insertOrder(order);
    }

    @Override
    public int updateOrder(Order order)
    {
        return orderMapper.updateOrder(order);
    }
}

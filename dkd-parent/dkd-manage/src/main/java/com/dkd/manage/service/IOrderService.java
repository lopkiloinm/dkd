package com.dkd.manage.service;

import java.util.List;
import com.dkd.manage.domain.Order;

/**
 * Order Service
 */
public interface IOrderService
{
    Order selectOrderById(Long id);

    Order selectOrderByOrderNo(String orderNo);

    List<Order> selectOrderList(Order order);

    int insertOrder(Order order);

    int updateOrder(Order order);
}

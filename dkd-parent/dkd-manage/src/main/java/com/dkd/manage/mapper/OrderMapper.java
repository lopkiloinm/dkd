package com.dkd.manage.mapper;

import java.util.List;
import com.dkd.manage.domain.Order;

/**
 * Order Mapper
 */
public interface OrderMapper
{
    Order selectOrderById(Long id);

    Order selectOrderByOrderNo(String orderNo);

    List<Order> selectOrderList(Order order);

    int insertOrder(Order order);

    int updateOrder(Order order);

    int deleteOrderById(Long id);

    int deleteOrderByIds(Long[] ids);
}

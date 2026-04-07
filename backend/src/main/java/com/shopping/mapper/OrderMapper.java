package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Order;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单Mapper接口
 * 用于操作t_order表
 * 
 * @author 陈洪伟
 */
@Mapper
public interface OrderMapper extends BaseMapper<Order> {

}

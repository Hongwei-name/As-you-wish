package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Product;
import org.apache.ibatis.annotations.Mapper;

/**
 * 商品Mapper接口
 * 用于操作t_product表
 * 
 * @author 陈洪伟
 */
@Mapper
public interface ProductMapper extends BaseMapper<Product> {

}

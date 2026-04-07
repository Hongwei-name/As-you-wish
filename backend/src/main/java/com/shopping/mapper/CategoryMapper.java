package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Category;
import org.apache.ibatis.annotations.Mapper;

/**
 * 商品分类Mapper接口
 * 用于操作t_category表
 * 
 * @author 陈洪伟
 */
@Mapper
public interface CategoryMapper extends BaseMapper<Category> {

}

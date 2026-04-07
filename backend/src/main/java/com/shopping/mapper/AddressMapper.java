package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Address;
import org.apache.ibatis.annotations.Mapper;

/**
 * 地址 Mapper 接口
 * 继承 MyBatis-Plus BaseMapper，提供基础 CRUD 操作
 * 
 * @author 陈洪伟
 */
@Mapper
public interface AddressMapper extends BaseMapper<Address> {

}

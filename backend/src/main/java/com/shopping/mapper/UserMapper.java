package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户 Mapper 接口
 * 用于用户数据的数据库操作
 * 
 * @author 陈洪伟
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

}

package com.asyouwish.auth.mapper;

import com.asyouwish.auth.entity.AuthUser;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
//继承MyBatis-Plus 自带的 `BaseMapper`，并且指定泛型为 `AuthUser`
public interface AuthUserMapper extends BaseMapper<AuthUser> {
//     BaseMapper自带的CRUD方法直接就能用，不用在这里写

}

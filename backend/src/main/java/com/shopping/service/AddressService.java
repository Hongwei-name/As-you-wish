package com.shopping.service;

import com.shopping.entity.Address;

import java.util.List;

/**
 * 地址服务接口
 * 定义地址相关的业务方法
 * 
 * @author 陈洪伟
 */
public interface AddressService {

    /**
     * 查询用户所有地址
     * 
     * @param userId 用户ID
     * @return 地址列表
     */
    List<Address> getAddressListByUserId(Long userId);

    /**
     * 根据ID查询地址详情
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 地址详情
     */
    Address getAddressById(Long id, Long userId);

    /**
     * 添加地址
     * 如果是用户的第一个地址，自动设为默认地址
     * 
     * @param address 地址信息
     * @return 添加后的地址
     */
    Address addAddress(Address address);

    /**
     * 更新地址
     * 
     * @param address 地址信息
     * @param userId 用户ID（用于权限验证）
     * @return 更新后的地址
     */
    Address updateAddress(Address address, Long userId);

    /**
     * 删除地址
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 是否删除成功
     */
    boolean deleteAddress(Long id, Long userId);

    /**
     * 设置默认地址
     * 会自动取消其他地址的默认状态
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 是否设置成功
     */
    boolean setDefaultAddress(Long id, Long userId);

}

package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.shopping.entity.Address;
import com.shopping.mapper.AddressMapper;
import com.shopping.service.AddressService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 地址服务实现类
 * 实现地址相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Slf4j
@Service
public class AddressServiceImpl implements AddressService {

    @Autowired
    private AddressMapper addressMapper;

    /**
     * 查询用户所有地址
     * 
     * @param userId 用户ID
     * @return 地址列表
     */
    @Override
    public List<Address> getAddressListByUserId(Long userId) {
        log.info("查询用户所有地址，用户ID: {}", userId);
        LambdaQueryWrapper<Address> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Address::getUserId, userId)
                .orderByDesc(Address::getIsDefault)
                .orderByDesc(Address::getCreatedAt);
        return addressMapper.selectList(queryWrapper);
    }

    /**
     * 根据ID查询地址详情
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 地址详情
     */
    @Override
    public Address getAddressById(Long id, Long userId) {
        log.info("查询地址详情，地址ID: {}, 用户ID: {}", id, userId);
        LambdaQueryWrapper<Address> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Address::getId, id)
                .eq(Address::getUserId, userId);
        return addressMapper.selectOne(queryWrapper);
    }

    /**
     * 添加地址
     * 如果是用户的第一个地址，自动设为默认地址
     * 
     * @param address 地址信息
     * @return 添加后的地址
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Address addAddress(Address address) {
        log.info("添加地址，用户ID: {}", address.getUserId());
        
        LambdaQueryWrapper<Address> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Address::getUserId, address.getUserId());
        Long count = addressMapper.selectCount(queryWrapper);
        
        if (count == 0) {
            address.setIsDefault(1);
        } else {
            address.setIsDefault(0);
        }
        
        LocalDateTime now = LocalDateTime.now();
        address.setCreatedAt(now);
        address.setUpdatedAt(now);
        
        addressMapper.insert(address);
        log.info("地址添加成功，地址ID: {}", address.getId());
        return address;
    }

    /**
     * 更新地址
     * 
     * @param address 地址信息
     * @param userId 用户ID（用于权限验证）
     * @return 更新后的地址
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Address updateAddress(Address address, Long userId) {
        log.info("更新地址，地址ID: {}, 用户ID: {}", address.getId(), userId);
        
        Address existingAddress = getAddressById(address.getId(), userId);
        if (existingAddress == null) {
            log.warn("地址不存在或无权限，地址ID: {}, 用户ID: {}", address.getId(), userId);
            return null;
        }
        
        address.setUserId(userId);
        address.setUpdatedAt(LocalDateTime.now());
        address.setCreatedAt(existingAddress.getCreatedAt());
        address.setIsDefault(existingAddress.getIsDefault());
        
        addressMapper.updateById(address);
        log.info("地址更新成功，地址ID: {}", address.getId());
        return address;
    }

    /**
     * 删除地址
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 是否删除成功
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteAddress(Long id, Long userId) {
        log.info("删除地址，地址ID: {}, 用户ID: {}", id, userId);
        
        Address address = getAddressById(id, userId);
        if (address == null) {
            log.warn("地址不存在或无权限，地址ID: {}, 用户ID: {}", id, userId);
            return false;
        }
        
        int rows = addressMapper.deleteById(id);
        
        if (rows > 0 && address.getIsDefault() == 1) {
            LambdaQueryWrapper<Address> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(Address::getUserId, userId)
                    .orderByDesc(Address::getCreatedAt)
                    .last("LIMIT 1");
            Address latestAddress = addressMapper.selectOne(queryWrapper);
            
            if (latestAddress != null) {
                setDefaultAddress(latestAddress.getId(), userId);
            }
        }
        
        log.info("地址删除成功，地址ID: {}", id);
        return true;
    }

    /**
     * 设置默认地址
     * 会自动取消其他地址的默认状态
     * 
     * @param id 地址ID
     * @param userId 用户ID（用于权限验证）
     * @return 是否设置成功
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean setDefaultAddress(Long id, Long userId) {
        log.info("设置默认地址，地址ID: {}, 用户ID: {}", id, userId);
        
        Address address = getAddressById(id, userId);
        if (address == null) {
            log.warn("地址不存在或无权限，地址ID: {}, 用户ID: {}", id, userId);
            return false;
        }
        
        LambdaUpdateWrapper<Address> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Address::getUserId, userId)
                .set(Address::getIsDefault, 0);
        addressMapper.update(null, updateWrapper);
        
        LambdaUpdateWrapper<Address> defaultUpdateWrapper = new LambdaUpdateWrapper<>();
        defaultUpdateWrapper.eq(Address::getId, id)
                .eq(Address::getUserId, userId)
                .set(Address::getIsDefault, 1)
                .set(Address::getUpdatedAt, LocalDateTime.now());
        addressMapper.update(null, defaultUpdateWrapper);
        
        log.info("默认地址设置成功，地址ID: {}", id);
        return true;
    }

}

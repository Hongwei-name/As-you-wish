package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.entity.Address;
import com.shopping.service.AddressService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 地址控制器
 * 提供地址相关的 REST API 接口
 * 
 * @author 陈洪伟
 */
@Slf4j
@RestController
@RequestMapping("/api/address")
public class AddressController {

    @Autowired
    private AddressService addressService;

    /**
     * 获取用户地址列表
     * 需要JWT认证
     * 
     * @param request HTTP请求对象
     * @return 地址列表
     */
    @GetMapping("/list")
    public Result<List<Address>> getAddressList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("获取用户地址列表，用户ID: {}", userId);
        List<Address> addressList = addressService.getAddressListByUserId(userId);
        return Result.success(addressList);
    }

    /**
     * 获取地址详情
     * 需要JWT认证，只能查看自己的地址
     * 
     * @param id 地址ID
     * @param request HTTP请求对象
     * @return 地址详情
     */
    @GetMapping("/{id}")
    public Result<Address> getAddressById(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("获取地址详情，地址ID: {}, 用户ID: {}", id, userId);
        Address address = addressService.getAddressById(id, userId);
        if (address == null) {
            return Result.error("地址不存在或无权限访问");
        }
        return Result.success(address);
    }

    /**
     * 添加地址
     * 需要JWT认证，如果是第一个地址自动设为默认
     * 
     * @param address 地址信息
     * @param request HTTP请求对象
     * @return 添加后的地址
     */
    @PostMapping("/add")
    public Result<Address> addAddress(@RequestBody Address address, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("添加地址，用户ID: {}", userId);
        address.setUserId(userId);
        Address addedAddress = addressService.addAddress(address);
        return Result.success("添加成功", addedAddress);
    }

    /**
     * 更新地址
     * 需要JWT认证，只能更新自己的地址
     * 
     * @param address 地址信息
     * @param request HTTP请求对象
     * @return 更新后的地址
     */
    @PutMapping("/update")
    public Result<Address> updateAddress(@RequestBody Address address, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("更新地址，地址ID: {}, 用户ID: {}", address.getId(), userId);
        Address updatedAddress = addressService.updateAddress(address, userId);
        if (updatedAddress == null) {
            return Result.error("地址不存在或无权限修改");
        }
        return Result.success("更新成功", updatedAddress);
    }

    /**
     * 删除地址
     * 需要JWT认证，只能删除自己的地址
     * 
     * @param id 地址ID
     * @param request HTTP请求对象
     * @return 删除结果
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteAddress(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("删除地址，地址ID: {}, 用户ID: {}", id, userId);
        boolean success = addressService.deleteAddress(id, userId);
        if (!success) {
            return Result.error("地址不存在或无权限删除");
        }
        return Result.success();
    }

    /**
     * 设置默认地址
     * 需要JWT认证，只能设置自己的地址为默认
     * 
     * @param id 地址ID
     * @param request HTTP请求对象
     * @return 设置结果
     */
    @PutMapping("/default/{id}")
    public Result<Void> setDefaultAddress(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("设置默认地址，地址ID: {}, 用户ID: {}", id, userId);
        boolean success = addressService.setDefaultAddress(id, userId);
        if (!success) {
            return Result.error("地址不存在或无权限设置");
        }
        return Result.success();
    }

}

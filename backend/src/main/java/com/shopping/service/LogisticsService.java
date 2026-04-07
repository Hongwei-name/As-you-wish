package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.Logistics;
import com.shopping.entity.LogisticsTrack;
import java.util.List;

/**
 * 物流信息Service接口
 */
public interface LogisticsService extends IService<Logistics> {
    /**
     * 根据订单ID获取物流信息
     * @param orderId 订单ID
     * @return 物流信息
     */
    Logistics getByOrderId(Long orderId);
    
    /**
     * 创建物流信息
     * @param logistics 物流信息
     * @return 是否创建成功
     */
    boolean createLogistics(Logistics logistics);
    
    /**
     * 更新物流信息
     * @param logistics 物流信息
     * @return 是否更新成功
     */
    boolean updateLogistics(Logistics logistics);
    
    /**
     * 添加物流轨迹
     * @param track 物流轨迹
     * @return 是否添加成功
     */
    boolean addLogisticsTrack(LogisticsTrack track);
    
    /**
     * 根据物流ID获取轨迹列表
     * @param logisticsId 物流ID
     * @return 轨迹列表
     */
    List<LogisticsTrack> getLogisticsTracks(Long logisticsId);
    
    /**
     * 发货
     * @param orderId 订单ID
     * @param logisticsCompany 物流公司
     * @param logisticsNo 物流单号
     * @return 是否发货成功
     */
    boolean shipOrder(Long orderId, String logisticsCompany, String logisticsNo);
    
    /**
     * 更新物流状态
     * @param orderId 订单ID
     * @param status 物流状态
     * @param description 描述
     * @param location 地点
     * @return 是否更新成功
     */
    boolean updateLogisticsStatus(Long orderId, Integer status, String description, String location);
}
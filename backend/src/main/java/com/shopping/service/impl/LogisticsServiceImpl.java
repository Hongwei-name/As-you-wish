package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.LogisticsMapper;
import com.shopping.mapper.LogisticsTrackMapper;
import com.shopping.entity.Logistics;
import com.shopping.entity.LogisticsTrack;
import com.shopping.service.LogisticsService;
import com.shopping.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 物流信息Service实现类
 */
@Service
public class LogisticsServiceImpl extends ServiceImpl<LogisticsMapper, Logistics> implements LogisticsService {
    
    @Autowired
    private LogisticsMapper logisticsMapper;
    
    @Autowired
    private LogisticsTrackMapper logisticsTrackMapper;
    
    @Autowired
    private OrderService orderService;
    
    @Override
    public Logistics getByOrderId(Long orderId) {
        return logisticsMapper.selectByOrderId(orderId);
    }
    
    @Override
    public boolean createLogistics(Logistics logistics) {
        return save(logistics);
    }
    
    @Override
    public boolean updateLogistics(Logistics logistics) {
        return updateById(logistics);
    }
    
    @Override
    public boolean addLogisticsTrack(LogisticsTrack track) {
        return logisticsTrackMapper.insert(track) > 0;
    }
    
    @Override
    public List<LogisticsTrack> getLogisticsTracks(Long logisticsId) {
        return logisticsTrackMapper.selectByLogisticsId(logisticsId);
    }
    
    @Override
    @Transactional
    public boolean shipOrder(Long orderId, String logisticsCompany, String logisticsNo) {
        // 检查订单是否存在
        Logistics existingLogistics = logisticsMapper.selectByOrderId(orderId);
        Logistics logistics;
        
        if (existingLogistics == null) {
            // 创建物流信息
            logistics = new Logistics();
            logistics.setOrderId(orderId);
            logistics.setLogisticsCompany(logisticsCompany);
            logistics.setLogisticsNo(logisticsNo);
            logistics.setStatus(1); // 已发货
            logistics.setCreatedAt(LocalDateTime.now());
            logistics.setUpdatedAt(LocalDateTime.now());
            if (!save(logistics)) {
                return false;
            }
        } else {
            // 更新物流信息
            existingLogistics.setLogisticsCompany(logisticsCompany);
            existingLogistics.setLogisticsNo(logisticsNo);
            existingLogistics.setStatus(1); // 已发货
            existingLogistics.setUpdatedAt(LocalDateTime.now());
            if (!updateById(existingLogistics)) {
                return false;
            }
            logistics = existingLogistics;
        }
        
        // 添加物流轨迹
        LogisticsTrack track = new LogisticsTrack();
        track.setLogisticsId(logistics.getId());
        track.setStatus(1); // 已发货
        track.setDescription("商品已发货");
        track.setLocation("发货仓库");
        track.setCreatedAt(LocalDateTime.now());
        if (!addLogisticsTrack(track)) {
            return false;
        }
        
        // 更新订单状态为已发货
        orderService.updateOrderStatus(orderId, 1);
        
        return true;
    }
    
    @Override
    @Transactional
    public boolean updateLogisticsStatus(Long orderId, Integer status, String description, String location) {
        // 获取物流信息
        Logistics logistics = logisticsMapper.selectByOrderId(orderId);
        if (logistics == null) {
            return false;
        }
        
        // 更新物流状态
        logistics.setStatus(status);
        logistics.setUpdatedAt(LocalDateTime.now());
        if (!updateById(logistics)) {
            return false;
        }
        
        // 添加物流轨迹
        LogisticsTrack track = new LogisticsTrack();
        track.setLogisticsId(logistics.getId());
        track.setStatus(status);
        track.setDescription(description);
        track.setLocation(location);
        track.setCreatedAt(LocalDateTime.now());
        if (!addLogisticsTrack(track)) {
            return false;
        }
        
        // 如果物流状态为已送达，更新订单状态为待收货
        if (status == 3) {
            orderService.updateOrderStatus(orderId, 2);
        }
        
        return true;
    }
}
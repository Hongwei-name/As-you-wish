package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.shopping.entity.BrowseHistory;
import com.shopping.mapper.BrowseHistoryMapper;
import com.shopping.service.BrowseHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 浏览历史服务实现
 */
@Service
public class BrowseHistoryServiceImpl implements BrowseHistoryService {
    
    @Autowired
    private BrowseHistoryMapper browseHistoryMapper;
    
    @Override
    public void recordBrowseHistory(Long userId, Long productId) {
        // 检查是否已存在浏览记录
        BrowseHistory existingHistory = browseHistoryMapper.getLatestByUserIdAndProductId(userId, productId);
        if (existingHistory != null) {
            // 更新浏览时间
            existingHistory.setBrowseTime(LocalDateTime.now());
            browseHistoryMapper.updateById(existingHistory);
        } else {
            // 创建新的浏览记录
            BrowseHistory history = new BrowseHistory();
            history.setUserId(userId);
            history.setProductId(productId);
            history.setBrowseTime(LocalDateTime.now());
            browseHistoryMapper.insert(history);
        }
    }
    
    @Override
    public List<Long> getRecentProductIdsByUserId(Long userId, Integer limit) {
        return browseHistoryMapper.getRecentProductIdsByUserId(userId, limit);
    }
    
    @Override
    public void clearBrowseHistory(Long userId) {
        QueryWrapper<BrowseHistory> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        browseHistoryMapper.delete(wrapper);
    }
}
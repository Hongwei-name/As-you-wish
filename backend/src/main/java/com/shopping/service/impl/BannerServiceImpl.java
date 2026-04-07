package com.shopping.service.impl;

import com.shopping.entity.Banner;
import com.shopping.mapper.BannerMapper;
import com.shopping.service.BannerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 轮播图服务实现类
 *
 * @author 陈洪伟
 * @since 1.0.0
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BannerServiceImpl implements BannerService {

    private final BannerMapper bannerMapper;

    /**
     * 获取启用的轮播图列表
     *
     * @return 轮播图列表
     */
    @Override
    public List<Banner> getEnabledBanners() {
        log.info("获取启用的轮播图列表");
        return bannerMapper.selectEnabledBanners();
    }

    /**
     * 获取所有轮播图列表
     *
     * @return 轮播图列表
     */
    @Override
    public List<Banner> getAllBanners() {
        log.info("获取所有轮播图列表");
        return bannerMapper.selectList(null);
    }

    /**
     * 保存轮播图
     *
     * @param banner 轮播图信息
     * @return 保存后的轮播图
     */
    @Override
    public Banner saveBanner(Banner banner) {
        log.info("保存轮播图: {}", banner);
        bannerMapper.insert(banner);
        return banner;
    }

    /**
     * 更新轮播图
     *
     * @param banner 轮播图信息
     * @return 更新后的轮播图
     */
    @Override
    public Banner updateBanner(Banner banner) {
        log.info("更新轮播图: {}", banner);
        bannerMapper.updateById(banner);
        return banner;
    }

    /**
     * 删除轮播图
     *
     * @param id 轮播图ID
     */
    @Override
    public void deleteBanner(Long id) {
        log.info("删除轮播图: {}", id);
        bannerMapper.deleteById(id);
    }

    /**
     * 更新轮播图状态
     *
     * @param id 轮播图ID
     * @param status 状态
     */
    @Override
    public void updateBannerStatus(Long id, Integer status) {
        log.info("更新轮播图状态: {} -> {}", id, status);
        Banner banner = new Banner();
        banner.setId(id);
        banner.setStatus(status);
        bannerMapper.updateById(banner);
    }
}

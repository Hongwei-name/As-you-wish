package com.shopping.service;

import com.shopping.entity.Banner;

import java.util.List;

/**
 * 轮播图服务接口
 *
 * @author 陈洪伟
 * @since 1.0.0
 */
public interface BannerService {

    /**
     * 获取启用的轮播图列表
     *
     * @return 轮播图列表
     */
    List<Banner> getEnabledBanners();

    /**
     * 获取所有轮播图列表
     *
     * @return 轮播图列表
     */
    List<Banner> getAllBanners();

    /**
     * 保存轮播图
     *
     * @param banner 轮播图信息
     * @return 保存后的轮播图
     */
    Banner saveBanner(Banner banner);

    /**
     * 更新轮播图
     *
     * @param banner 轮播图信息
     * @return 更新后的轮播图
     */
    Banner updateBanner(Banner banner);

    /**
     * 删除轮播图
     *
     * @param id 轮播图ID
     */
    void deleteBanner(Long id);

    /**
     * 更新轮播图状态
     *
     * @param id 轮播图ID
     * @param status 状态
     */
    void updateBannerStatus(Long id, Integer status);
}

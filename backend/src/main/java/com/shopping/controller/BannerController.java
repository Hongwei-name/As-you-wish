package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.entity.Banner;
import com.shopping.service.BannerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 轮播图控制器
 *
 * @author 陈洪伟
 * @since 1.0.0
 */
@Slf4j
@RestController
@RequestMapping("/api/banner")
@RequiredArgsConstructor
public class BannerController {

    private final BannerService bannerService;

    /**
     * 获取轮播图列表
     *
     * @return 轮播图列表
     */
    @GetMapping("/list")
    public Result<List<Banner>> list() {
        log.info("获取轮播图列表");
        List<Banner> banners = bannerService.getEnabledBanners();
        return Result.success(banners);
    }
}

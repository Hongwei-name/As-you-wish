package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Banner;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 轮播图数据访问层
 *
 * @author 陈洪伟
 * @since 1.0.0
 */
@Mapper
public interface BannerMapper extends BaseMapper<Banner> {

    /**
     * 查询启用的轮播图列表，按排序字段升序排列
     *
     * @return 轮播图列表
     */
    @Select("SELECT * FROM t_banner WHERE status = 1 ORDER BY sort ASC")
    List<Banner> selectEnabledBanners();
}

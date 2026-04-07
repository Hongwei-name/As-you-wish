package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 轮播图实体类
 * 对应数据库表 t_banner
 *
 * @author 陈洪伟
 * @since 1.0.0
 */
@Data
@TableName("t_banner")
public class Banner {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 轮播图标题
     */
    private String title;

    /**
     * 轮播图描述
     */
    private String description;

    /**
     * 轮播图图片URL
     */
    private String image;

    /**
     * 跳转链接
     */
    private String link;

    /**
     * 排序
     */
    private Integer sort;

    /**
     * 状态：0-禁用，1-启用
     */
    private Integer status;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

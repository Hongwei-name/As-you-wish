package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品实体类
 * 对应数据库表 t_product
 * 
 * @author 陈洪伟
 */
@Data
@TableName("t_product")
public class Product implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 商品ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 商品名称
     */
    @TableField("name")
    private String name;

    /**
     * 分类ID
     */
    @TableField("category_id")
    private Long categoryId;

    /**
     * 商品价格
     */
    @TableField("price")
    private BigDecimal price;

    /**
     * 原价
     */
    @TableField("original_price")
    private BigDecimal originalPrice;

    /**
     * 库存
     */
    @TableField("stock")
    private Integer stock;

    /**
     * 商品主图
     */
    @TableField("image")
    private String image;

    /**
     * 商品图片列表（JSON格式）
     */
    @TableField("images")
    private String images;

    /**
     * 商品简介
     */
    @TableField("description")
    private String description;

    /**
     * 商品详情
     */
    @TableField("detail")
    private String detail;

    /**
     * 商品状态：0-下架，1-上架
     */
    @TableField("status")
    private Integer status;

    /**
     * 销量
     */
    @TableField("sales")
    private Integer sales;

    /**
     * 创建时间
     */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField("updated_at")
    private LocalDateTime updatedAt;

}

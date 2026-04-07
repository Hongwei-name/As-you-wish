package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Cart;
import com.shopping.vo.CartVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 购物车Mapper接口
 * 用于操作t_cart表
 * 
 * @author 陈洪伟
 */
@Mapper
public interface CartMapper extends BaseMapper<Cart> {

    /**
     * 根据用户ID查询购物车列表（关联商品信息）
     * 
     * @param userId 用户ID
     * @return 购物车列表
     */
    @Select("SELECT c.id, c.user_id, c.product_id, p.name AS product_name, p.price AS product_price, " +
            "p.original_price, p.image AS product_image, p.stock AS product_stock, " +
            "c.quantity, c.selected, c.created_at, c.updated_at " +
            "FROM t_cart c " +
            "LEFT JOIN t_product p ON c.product_id = p.id " +
            "WHERE c.user_id = #{userId} " +
            "ORDER BY c.created_at DESC")
    List<CartVO> selectCartListByUserId(@Param("userId") Long userId);

    /**
     * 根据用户ID和商品ID查询购物车记录
     * 
     * @param userId 用户ID
     * @param productId 商品ID
     * @return 购物车记录
     */
    @Select("SELECT * FROM t_cart WHERE user_id = #{userId} AND product_id = #{productId}")
    Cart selectByUserIdAndProductId(@Param("userId") Long userId, @Param("productId") Long productId);

    /**
     * 根据用户ID统计购物车商品数量
     * 
     * @param userId 用户ID
     * @return 商品数量
     */
    @Select("SELECT IFNULL(SUM(quantity), 0) FROM t_cart WHERE user_id = #{userId}")
    Integer countByUserId(@Param("userId") Long userId);

}

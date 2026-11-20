package com.zerok.productservice.mapper;

import com.asyouwish.contract.product.ProductSkuSnapshot;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 商品 SKU 查询映射，只读取商品服务拥有的商品表。
 */
@Mapper
public interface ProductSkuMapper {

    /**
     * 批量查询当前已上架且可售的 SKU 快照。
     */
    @Select({
            "<script>",
            "SELECT s.id AS skuId, s.spu_id AS spuId, s.sku_code AS skuCode,",
            "p.name AS productName, s.name AS skuName, CAST(s.spec_json AS CHAR) AS specJson,",
            "(SELECT image.image_url FROM gds_product_image image",
            " WHERE image.spu_id = s.spu_id AND (image.sku_id = s.id OR image.sku_id IS NULL)",
            " ORDER BY CASE WHEN image.sku_id = s.id THEN 0 ELSE 1 END, image.image_type, image.sort_order, image.id LIMIT 1)",
            " AS imageUrl, s.sale_price AS salePrice",
            "FROM gds_sku s",
            "JOIN gds_spu p ON p.id = s.spu_id",
            "JOIN gds_category c ON c.id = p.category_id",
            "WHERE s.status = 1 AND s.is_deleted = 0",
            "AND p.status = 1 AND p.is_deleted = 0",
            "AND c.status = 1 AND c.is_deleted = 0",
            "AND s.id IN",
            "<foreach collection='skuIds' item='skuId' open='(' separator=',' close=')'>",
            "#{skuId}",
            "</foreach>",
            "</script>"
    })
    List<ProductSkuSnapshot> findSellableSkus(@Param("skuIds") List<Long> skuIds);
}

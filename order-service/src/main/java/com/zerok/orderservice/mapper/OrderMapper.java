package com.zerok.orderservice.mapper;

import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrdOrder;
import com.zerok.orderservice.entity.OrderIdempotencyRecord;
import org.apache.ibatis.annotations.Arg;
import org.apache.ibatis.annotations.ConstructorArgs;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Order-owned persistence boundary for order headers, line snapshots, and idempotency state.
 */
@Mapper
public interface OrderMapper {

    @Insert("""
            INSERT INTO sys_idempotency_record
                (service_name, operation, idempotency_key, request_digest, status, expires_at)
            VALUES
                (#{serviceName}, #{operation}, #{idempotencyKey}, #{requestDigest}, 0, #{expiresAt})
            ON DUPLICATE KEY UPDATE
                id = LAST_INSERT_ID(id),
                request_digest = IF(expires_at < CURRENT_TIMESTAMP(3), VALUES(request_digest), request_digest),
                status = IF(expires_at < CURRENT_TIMESTAMP(3), 0, status),
                response_code = IF(expires_at < CURRENT_TIMESTAMP(3), NULL, response_code),
                response_body = IF(expires_at < CURRENT_TIMESTAMP(3), NULL, response_body),
                expires_at = IF(expires_at < CURRENT_TIMESTAMP(3), VALUES(expires_at), expires_at)
            """)
    int acquireIdempotency(@Param("serviceName") String serviceName,
                           @Param("operation") String operation,
                           @Param("idempotencyKey") String idempotencyKey,
                           @Param("requestDigest") String requestDigest,
                           @Param("expiresAt") LocalDateTime expiresAt);

    @Select("""
            SELECT id, request_digest, status, response_code, CAST(response_body AS CHAR) AS response_body
            FROM sys_idempotency_record
            WHERE service_name = #{serviceName}
              AND operation = #{operation}
              AND idempotency_key = #{idempotencyKey}
            FOR UPDATE
            """)
    @ConstructorArgs({
            @Arg(column = "id", javaType = long.class),
            @Arg(column = "request_digest", javaType = String.class),
            @Arg(column = "status", javaType = int.class),
            @Arg(column = "response_code", javaType = String.class),
            @Arg(column = "response_body", javaType = String.class)
    })
    OrderIdempotencyRecord findIdempotencyForUpdate(@Param("serviceName") String serviceName,
                                                     @Param("operation") String operation,
                                                     @Param("idempotencyKey") String idempotencyKey);

    @Select("""
            SELECT id, request_digest, status, response_code, CAST(response_body AS CHAR) AS response_body
            FROM sys_idempotency_record
            WHERE service_name = #{serviceName}
              AND operation = #{operation}
              AND idempotency_key = #{idempotencyKey}
            """)
    @ConstructorArgs({
            @Arg(column = "id", javaType = long.class),
            @Arg(column = "request_digest", javaType = String.class),
            @Arg(column = "status", javaType = int.class),
            @Arg(column = "response_code", javaType = String.class),
            @Arg(column = "response_body", javaType = String.class)
    })
    OrderIdempotencyRecord findIdempotency(@Param("serviceName") String serviceName,
                                           @Param("operation") String operation,
                                           @Param("idempotencyKey") String idempotencyKey);

    @Select("""
            SELECT COUNT(*) > 0
            FROM sys_idempotency_record
            WHERE service_name = 'order-service'
              AND operation = CONCAT('create-order:', #{userId})
              AND status = 1
              AND JSON_UNQUOTE(JSON_EXTRACT(response_body, '$.orderNo')) = #{orderNo}
            """)
    boolean isCreationComplete(@Param("orderNo") String orderNo, @Param("userId") long userId);

    @Update("""
            UPDATE sys_idempotency_record
            SET response_body = CAST(#{responseBody} AS JSON), response_code = 'ORDER_CREATED', status = 0
            WHERE id = #{id}
            """)
    int saveOrderPointer(@Param("id") long id, @Param("responseBody") String responseBody);

    @Update("""
            UPDATE sys_idempotency_record
            SET status = 1, response_code = '200'
            WHERE id = #{id} AND status = 0
            """)
    int completeIdempotency(@Param("id") long id);

    @Update("""
            UPDATE sys_idempotency_record
            SET status = 2, response_code = #{responseCode},
                response_body = CAST(#{responseBody} AS JSON)
            WHERE id = #{id} AND status = 0
            """)
    int failIdempotency(@Param("id") long id,
                        @Param("responseCode") String responseCode,
                        @Param("responseBody") String responseBody);

    @Insert("""
            INSERT INTO ord_order
                (order_no, auth_user_id, order_type, total_amount, pay_amount, discount_amount,
                 freight_amount, order_status, refund_status, receiver_name, receiver_phone,
                 receiver_address, note, expire_time, create_time, update_time, create_by, update_by)
            VALUES
                (#{orderNo}, #{authUserId}, #{orderType}, #{totalAmount}, #{payAmount}, #{discountAmount},
                 #{freightAmount}, #{orderStatus}, #{refundStatus}, #{receiverName}, #{receiverPhone},
                 #{receiverAddress}, #{note}, #{expireTime}, #{createTime}, #{updateTime}, #{createBy}, #{updateBy})
            """)
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertOrder(OrdOrder order);

    @Insert("""
            <script>
            INSERT INTO ord_item
                (order_id, order_no, sku_id, spu_id, sku_code, product_name, sku_name, spec_json,
                 image_url, unit_price, quantity, line_amount, discount_amount, pay_amount,
                 after_sale_quantity, created_at)
            VALUES
            <foreach collection="items" item="item" separator=",">
                (#{item.orderId}, #{item.orderNo}, #{item.skuId}, #{item.spuId}, #{item.skuCode},
                 #{item.productName}, #{item.skuName}, CAST(#{item.specJson} AS JSON), #{item.imageUrl},
                 #{item.unitPrice}, #{item.quantity}, #{item.lineAmount}, #{item.discountAmount},
                 #{item.payAmount}, #{item.afterSaleQuantity}, #{item.createdAt})
            </foreach>
            </script>
            """)
    int insertItems(@Param("items") List<OrdItem> items);

    @Select("""
            SELECT id, order_no, auth_user_id, total_amount, pay_amount, order_status,
                   receiver_name, receiver_phone, receiver_address, note, create_time
            FROM ord_order
            WHERE order_no = #{orderNo} AND auth_user_id = #{userId}
            """)
    @Results(id = "orderHeader", value = {
            @Result(property = "id", column = "id"),
            @Result(property = "orderNo", column = "order_no"),
            @Result(property = "authUserId", column = "auth_user_id"),
            @Result(property = "totalAmount", column = "total_amount"),
            @Result(property = "payAmount", column = "pay_amount"),
            @Result(property = "orderStatus", column = "order_status"),
            @Result(property = "receiverName", column = "receiver_name"),
            @Result(property = "receiverPhone", column = "receiver_phone"),
            @Result(property = "receiverAddress", column = "receiver_address"),
            @Result(property = "note", column = "note"),
            @Result(property = "createTime", column = "create_time")
    })
    OrdOrder findOrderByNoAndUser(@Param("orderNo") String orderNo, @Param("userId") long userId);

    @Select("""
            SELECT id, order_id, order_no, sku_id, spu_id, sku_code, product_name, sku_name,
                   CAST(spec_json AS CHAR) AS spec_json, image_url, unit_price, quantity,
                   line_amount, discount_amount, pay_amount, after_sale_quantity, created_at
            FROM ord_item
            WHERE order_id = #{orderId}
            ORDER BY id
            """)
    @Results(id = "orderItem", value = {
            @Result(property = "id", column = "id"),
            @Result(property = "orderId", column = "order_id"),
            @Result(property = "orderNo", column = "order_no"),
            @Result(property = "skuId", column = "sku_id"),
            @Result(property = "spuId", column = "spu_id"),
            @Result(property = "skuCode", column = "sku_code"),
            @Result(property = "productName", column = "product_name"),
            @Result(property = "skuName", column = "sku_name"),
            @Result(property = "specJson", column = "spec_json"),
            @Result(property = "imageUrl", column = "image_url"),
            @Result(property = "unitPrice", column = "unit_price"),
            @Result(property = "quantity", column = "quantity"),
            @Result(property = "lineAmount", column = "line_amount"),
            @Result(property = "discountAmount", column = "discount_amount"),
            @Result(property = "payAmount", column = "pay_amount"),
            @Result(property = "afterSaleQuantity", column = "after_sale_quantity"),
            @Result(property = "createdAt", column = "created_at")
    })
    List<OrdItem> findItemsByOrderId(@Param("orderId") long orderId);

    @Update("""
            UPDATE ord_order
            SET order_status = 4, cancel_reason = #{reason}, update_time = #{updatedAt}, update_by = #{userId}
            WHERE id = #{orderId} AND auth_user_id = #{userId} AND order_status = 0
            """)
    int closePendingOrder(@Param("orderId") long orderId,
                          @Param("userId") long userId,
                          @Param("reason") String reason,
                          @Param("updatedAt") LocalDateTime updatedAt);
}

package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 客服消息实体类
 */
@Data
@TableName("t_cs_message")
public class CsMessage {
    /**
     * 消息ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 会话ID
     */
    private Long sessionId;
    
    /**
     * 发送者类型：0-用户，1-客服
     */
    private Integer senderType;
    
    /**
     * 消息内容
     */
    private String content;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
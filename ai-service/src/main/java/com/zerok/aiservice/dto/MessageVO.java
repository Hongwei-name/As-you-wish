package com.zerok.aiservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 历史消息列表项。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageVO {

    private String id;

    private String conversationId;

    private String role;

    private String content;

    private String status;

    private LocalDateTime createdAt;
}
package com.zerok.aiservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 会话列表项。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConversationVO {

    private String id;

    private String title;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
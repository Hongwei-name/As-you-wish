package com.zerok.aiservice.entity;


import lombok.Data;

@Data
@TableName("chat_message")
public class ChatMessage {
    private Long id;
    private int conversationId;
    private String role;

}

package com.zerok.aiservice.controller;


import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class ChatController {
    private final ChatClient chatClient;
    @RequestMapping(
            value = "/chat",
            produces = "text/event-stream;charset=utf-8"
    )
    public Flux<String> chat(
            String prompt,
            @RequestParam(required = false) String conversationId
    ){
        if (conversationId == null || conversationId.isBlank()){
            conversationId = "default-session";
        }
        String sessionId = conversationId;
        return chatClient.prompt()
                .user(prompt)
                .advisors(a->a.param(ChatMemory.CONVERSATION_ID,sessionId))
                .stream()
                .content();
    }
}

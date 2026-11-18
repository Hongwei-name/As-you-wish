package com.zerok.aiservice.repository;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
public class InMemoryChatHistoryRepository implements ChatHistoryRepository{


    private final Map<String ,List<String>> 

    @Override
    public void save(String type, String chatId) {

    }

    @Override
    public List<String> getChatId(String type) {
        return List.of();
    }
}

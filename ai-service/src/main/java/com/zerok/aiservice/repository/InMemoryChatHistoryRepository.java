package com.zerok.aiservice.repository;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class InMemoryChatHistoryRepository implements ChatHistoryRepository {

    private final ConcurrentHashMap<String, CopyOnWriteArrayList<String>> chatIdsByType = new ConcurrentHashMap<>();

    @Override
    public void save(String type, String chatId) {
        chatIdsByType.computeIfAbsent(type, ignored -> new CopyOnWriteArrayList<>()).add(chatId);
    }

    @Override
    public List<String> getChatId(String type) {
        List<String> chatIds = chatIdsByType.get(type);
        return chatIds == null ? List.of() : List.copyOf(chatIds);
    }
}

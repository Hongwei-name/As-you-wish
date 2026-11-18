package com.zerok.aiservice.repository;

import java.util.List;

public interface ChatHistoryRepository {
    void save(String type, String chatId);

    List<String> getChatId(String type);
}

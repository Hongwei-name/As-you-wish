package com.zerok.aiservice.config;


import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.InMemoryChatMemoryRepository;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CommonConfiguration {

    @Bean
    public ChatMemory chatMemory(){
        return MessageWindowChatMemory.builder()
                .chatMemoryRepository(new InMemoryChatMemoryRepository())
                .maxMessages(20)
                .build();
    }

    @Bean
    public ChatClient chatClient(OpenAiChatModel model,ChatMemory chatMemory){
        return ChatClient
                .builder(model)
                .defaultSystem("你是'如你所愿'商城的智能助手。" +
                        "你的名字叫小愿.你会帮助客人推荐'如你所愿'商城上适合他的商品,请以小愿的身份和语气回答问题")
                .defaultAdvisors(
                        MessageChatMemoryAdvisor.builder(chatMemory).build()//记忆Advisor
                )//配置日志Advisor
                .build();

    }
}

package com.zerok.aiservice.config;


import com.zerok.aiservice.repository.MyBatisChatMemoryRepository;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CommonConfiguration {

    @Bean
    public ChatMemory chatMemory(MyBatisChatMemoryRepository chatMemoryRepository,
                                 @Value("${assistant.memory.max-messages:20}") int maxMessages) {
        // 上下文由 ai_message 读取；进程内不再保存对话记忆，服务重启后仍能记得历史。
        return MessageWindowChatMemory.builder()
                .chatMemoryRepository(chatMemoryRepository)
                .maxMessages(maxMessages)
                .build();
    }

    @Bean
    public ChatClient chatClient(OpenAiChatModel model,ChatMemory chatMemory){
        return ChatClient
                .builder(model)
                .defaultSystem("你是'如你所愿'商城的智能助手。" +
                        "你的名字叫小愿.你会帮助客人推荐'如你所愿'商城上适合他的商品,请以小愿的身份和语气回答问题。" +
                        "推荐前先了解用户的需求；如果没有拿到真实的商品或订单数据，不要编造商品名称、价格或购买记录，可以说明相关服务正在准备中。")
                .defaultAdvisors(
                        MessageChatMemoryAdvisor.builder(chatMemory).build()//记忆Advisor
                )//配置日志Advisor
                .build();

    }
}

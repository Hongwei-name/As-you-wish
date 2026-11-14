package com.zerok.aiservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

// 上下文测试不调用模型；真实 Nacos 注册由运行验证单独检查。
@SpringBootTest(properties = {
        "spring.ai.openai.api-key=test-only-key",
        "spring.cloud.nacos.discovery.enabled=false"


})
class AiServiceApplicationTests {

    @Test
    void contextLoads() {
    }

}

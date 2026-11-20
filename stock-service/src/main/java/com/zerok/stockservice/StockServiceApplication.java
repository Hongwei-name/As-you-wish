package com.zerok.stockservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Stock 服务入口，负责启动库存域 API 和 Nacos 服务注册。
 */
@SpringBootApplication
@EnableDiscoveryClient
public class StockServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(StockServiceApplication.class, args);
    }

}

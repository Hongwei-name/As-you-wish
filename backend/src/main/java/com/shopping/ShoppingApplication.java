package com.shopping;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 购物系统主应用类
 * Spring Boot 应用程序入口
 * 
 * @author 陈洪伟
 */
@SpringBootApplication
@MapperScan("com.shopping.mapper")
public class ShoppingApplication {

    /**
     * 应用程序主入口方法
     * 
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        SpringApplication.run(ShoppingApplication.class, args);
    }

}

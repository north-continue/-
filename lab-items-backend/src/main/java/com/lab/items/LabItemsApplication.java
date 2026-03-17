package com.lab.items;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

/**
 * 实验室物品管理平台 - 主启动类
 * @author Lab Team
 */
@SpringBootApplication
@MapperScan("com.lab.items.repository")
@EnableAspectJAutoProxy
public class LabItemsApplication {

    public static void main(String[] args) {
        SpringApplication.run(LabItemsApplication.class, args);
        System.out.println("====================================");
        System.out.println("实验室物品管理平台启动成功！");
        System.out.println("API 文档：http://localhost:8084/api/swagger-ui.html");
        System.out.println("====================================");
    }
}

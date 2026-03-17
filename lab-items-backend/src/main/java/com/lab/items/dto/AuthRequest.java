package com.lab.items.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 认证请求 DTO
 */
@Data
@Schema(description = "登录请求")
public class AuthRequest {

    @NotBlank(message = "用户名不能为空")
    @Schema(description = "用户名", required = true)
    private String username;

    @NotBlank(message = "密码不能为空")
    @Schema(description = "密码", required = true)
    private String password;
}

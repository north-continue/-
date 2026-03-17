package com.lab.items.controller;

import com.lab.items.dto.AuthRequest;
import com.lab.items.dto.AuthResponse;
import com.lab.items.dto.R;
import com.lab.items.entity.User;
import com.lab.items.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 */
@RestController
@RequestMapping("/auth")
@Tag(name = "认证管理", description = "用户登录认证相关接口")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public R<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        AuthResponse response = authService.login(request);
        return R.ok(response);
    }

    @GetMapping("/info")
    @Operation(summary = "获取当前用户信息")
    public R<User> getCurrentUserInfo() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = authService.getCurrentUser(username);
        return R.ok(user);
    }

    @PostMapping("/logout")
    @Operation(summary = "用户登出")
    public R<String> logout() {
        // JWT 无状态，前端删除 token 即可
        return R.ok("登出成功");
    }
}

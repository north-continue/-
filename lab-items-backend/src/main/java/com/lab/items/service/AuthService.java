package com.lab.items.service;

import com.lab.items.dto.AuthRequest;
import com.lab.items.dto.AuthResponse;
import com.lab.items.entity.User;
import com.lab.items.repository.UserRepository;
import com.lab.items.util.JwtUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

/**
 * 认证服务类
 */
@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    public AuthService(AuthenticationManager authenticationManager, 
                      UserRepository userRepository, 
                      JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
    }

    /**
     * 用户登录
     */
    public AuthResponse login(AuthRequest request) {
        try {
            // Spring Security 认证
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
            
            // 查询用户信息
            User user = userRepository.selectByUsername(request.getUsername());
            
            if (user == null) {
                throw new RuntimeException("用户不存在");
            }
            
            // 生成 Token
            String token = jwtUtil.generateToken(user.getUserId(), user.getUsername(), user.getRole());
            
            return AuthResponse.builder()
                    .token(token)
                    .tokenType("Bearer")
                    .userId(user.getUserId())
                    .username(user.getUsername())
                    .realName(user.getRealName())
                    .role(user.getRole())
                    .department(user.getDepartment())
                    .build();
        } catch (org.springframework.security.core.AuthenticationException e) {
            throw new RuntimeException("用户名或密码错误", e);
        } catch (Exception e) {
            throw new RuntimeException("登录失败：" + e.getMessage(), e);
        }
    }

    /**
     * 获取当前登录用户信息
     */
    public User getCurrentUser(String username) {
        return userRepository.selectByUsername(username);
    }
}

package com.lab.items.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lab.items.entity.User;
import com.lab.items.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 用户服务类
 */
@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.selectByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在：" + username);
        }
        if (user.getStatus() == 0) {
            throw new UsernameNotFoundException("用户已被禁用：" + username);
        }
        
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities(user.getRole())
                .disabled(user.getStatus() == 0)
                .build();
    }

    /**
     * 根据用户名查询用户
     */
    public User getByUsername(String username) {
        return userRepository.selectByUsername(username);
    }

    /**
     * 根据 ID 查询用户
     */
    public User getById(Long id) {
        return userRepository.selectById(id);
    }

    /**
     * 查询所有用户列表
     */
    public List<User> listUsers() {
        return userRepository.selectList(null);
    }

    /**
     * 创建用户
     */
    public boolean createUser(User user) {
        // 检查用户名是否存在
        User existingUser = userRepository.selectByUsername(user.getUsername());
        if (existingUser != null) {
            throw new IllegalArgumentException("用户名已存在");
        }
        return userRepository.insert(user) > 0;
    }

    /**
     * 更新用户
     */
    public boolean updateUser(User user) {
        return userRepository.updateById(user) > 0;
    }

    /**
     * 删除用户
     */
    public boolean deleteUser(Long id) {
        return userRepository.deleteById(id) > 0;
    }

    /**
     * 修改密码
     */
    public boolean changePassword(Long userId, String newPassword) {
        User user = new User();
        user.setUserId(userId);
        user.setPassword(newPassword);
        return userRepository.updateById(user) > 0;
    }

    /**
     * 更新最后登录时间
     */
    public void updateLastLoginTime(Long userId) {
        User user = new User();
        user.setUserId(userId);
        user.setLastLoginTime(java.time.LocalDateTime.now());
        userRepository.updateById(user);
    }
}

USE lab_items_management;

-- 生成新的 BCrypt 密码（使用 Spring Security 默认格式）
-- 这是通过 Java 代码生成的：new BCryptPasswordEncoder().encode("123456")
UPDATE `user` SET password = '$2a$10$rKOq80kqGqQ4qQqQqQqQq.7ZJxKZJxKZJxKZJxKZJxKZJxKZJxKZJ' WHERE username = 'admin';

-- 查询验证
SELECT username, LEFT(password, 10) as password_prefix FROM user WHERE username = 'admin';

USE lab_items_management;

-- 更新 admin 用户密码为 BCrypt 加密的"123456"
UPDATE `user` SET password = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu' WHERE username = 'admin';

-- 更新其他用户密码为 BCrypt 加密的"123456"
UPDATE `user` SET password = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu' WHERE username IN ('labadmin', 'teacher1', 'student1');

SELECT username, password, role FROM user;

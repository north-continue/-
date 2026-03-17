USE lab_items_management;

-- 将所有用户密码设置为明文 123456
UPDATE `user` SET password = '123456';

-- 验证更新结果
SELECT username, password, real_name FROM user;

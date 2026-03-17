-- =====================================================
-- 实验室物品管理平台 - 简化版数据库脚本（无外键约束）
-- 用于快速测试和演示
-- =====================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS lab_items_management 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

USE lab_items_management;

-- =====================================================
-- 1. 用户表
-- =====================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户 ID',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码 (加密)',
  `real_name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `role` ENUM('ADMIN', 'LAB_ADMIN', 'TEACHER', 'STUDENT') NOT NULL DEFAULT 'STUDENT' COMMENT '角色',
  `department` VARCHAR(100) DEFAULT NULL COMMENT '所属部门/学院',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`user_id`),
  INDEX `idx_username` (`username`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =====================================================
-- 2. 物品类别表
-- =====================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `category_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '类别 ID',
  `category_name` VARCHAR(100) NOT NULL COMMENT '类别名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父类别 ID',
  `level` TINYINT DEFAULT 1 COMMENT '层级',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `description` TEXT DEFAULT NULL COMMENT '描述',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`category_id`),
  INDEX `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品类别表';

-- =====================================================
-- 3. 物品表（移除外键约束）
-- =====================================================
DROP TABLE IF EXISTS `item`;
CREATE TABLE `item` (
  `item_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '物品 ID',
  `item_code` VARCHAR(50) NOT NULL UNIQUE COMMENT '物品编号',
  `qr_code` VARCHAR(255) DEFAULT NULL COMMENT '二维码内容',
  `item_name` VARCHAR(200) NOT NULL COMMENT '物品名称',
  `category_id` BIGINT NOT NULL COMMENT '类别 ID',
  `specification` VARCHAR(200) DEFAULT NULL COMMENT '规格型号',
  `brand` VARCHAR(100) DEFAULT NULL COMMENT '品牌',
  `unit` VARCHAR(20) DEFAULT NULL COMMENT '单位',
  `price` DECIMAL(10,2) DEFAULT NULL COMMENT '单价',
  `purchase_date` DATE DEFAULT NULL COMMENT '购买日期',
  `supplier` VARCHAR(200) DEFAULT NULL COMMENT '供应商',
  `location` VARCHAR(200) DEFAULT NULL COMMENT '存放位置',
  `lab_room` VARCHAR(50) DEFAULT NULL COMMENT '实验室房间号',
  `shelf` VARCHAR(50) DEFAULT NULL COMMENT '货架号',
  `image_url` VARCHAR(500) DEFAULT NULL COMMENT '图片 URL',
  `total_quantity` INT DEFAULT 0 COMMENT '总数量',
  `available_quantity` INT DEFAULT 0 COMMENT '可用数量',
  `borrowed_quantity` INT DEFAULT 0 COMMENT '借出数量',
  `min_stock` INT DEFAULT 0 COMMENT '最低库存预警值',
  `max_stock` INT DEFAULT 0 COMMENT '最高库存预警值',
  `status` ENUM('AVAILABLE', 'BORROWED', 'REPAIRING', 'SCRAPPED', 'LOST') DEFAULT 'AVAILABLE' COMMENT '物品状态',
  `warranty_period` INT DEFAULT NULL COMMENT '保修期 (月)',
  `warranty_expiry` DATE DEFAULT NULL COMMENT '保修到期日期',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_user_id` BIGINT NOT NULL COMMENT '创建人 ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`item_id`),
  INDEX `idx_item_code` (`item_code`),
  INDEX `idx_category_id` (`category_id`),
  INDEX `idx_location` (`location`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品表';

-- =====================================================
-- 4. 初始化数据
-- =====================================================

-- 1. 初始化用户数据
INSERT INTO `user` (`username`, `password`, `real_name`, `email`, `phone`, `role`, `department`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '系统管理员', 'admin@lab.com', '13800138000', 'ADMIN', '信息中心', 1),
('labadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '实验室管理员', 'labadmin@lab.com', '13800138001', 'LAB_ADMIN', '实验中心', 1),
('teacher1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '张老师', 'teacher@lab.com', '13800138002', 'TEACHER', '计算机学院', 1),
('student1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '李明', 'student@lab.com', '13800138003', 'STUDENT', '计算机学院', 1);

-- 2. 初始化物品类别
INSERT INTO `category` (`category_name`, `parent_id`, `level`, `sort_order`, `description`) VALUES
('实验设备', 0, 1, 1, '各类实验仪器设备'),
('办公设备', 0, 1, 2, '办公用设备物品'),
('耗材', 0, 1, 3, '实验消耗材料'),
('工具', 0, 1, 4, '实验工具'),
('计算机设备', 1, 2, 1, '计算机相关设备'),
('电子设备', 1, 2, 2, '电子类设备'),
('测量仪器', 1, 2, 3, '测量类仪器'),
('打印机', 2, 2, 1, '打印设备'),
('投影仪', 2, 2, 2, '投影设备');

-- 3. 初始化系统配置
INSERT INTO `system_config` (`config_key`, `config_value`, `config_type`, `config_desc`, `is_editable`) VALUES
('BORROW_MAX_DAYS', '30', 'NUMBER', '最大借用天数', 1),
('BORROW_APPROVAL_REQUIRED', '1', 'BOOLEAN', '借用是否需要审批', 1),
('ALERT_CHECK_INTERVAL', '7', 'NUMBER', '库存预警检查间隔 (天)', 1),
('OVERDUE_REMINDER_DAYS', '3', 'NUMBER', '逾期提前提醒天数', 1),
('QR_CODE_PREFIX', 'LAB', 'STRING', '二维码前缀', 1),
('SYSTEM_NAME', '实验室物品管理平台', 'STRING', '系统名称', 1),
('ALLOW_NEGATIVE_STOCK', '0', 'BOOLEAN', '是否允许负库存', 1);

SELECT '数据库初始化完成！' AS message;

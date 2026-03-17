-- =====================================================
-- 实验室物品管理平台 - 完整数据库初始化脚本
-- =====================================================

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
-- 3. 物品表
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
-- 4. 入库记录表
-- =====================================================
DROP TABLE IF EXISTS `in_record`;
CREATE TABLE `in_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `in_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '入库单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `quantity` INT NOT NULL COMMENT '入库数量',
  `in_type` ENUM('PURCHASE', 'RETURN', 'TRANSFER', 'OTHER') DEFAULT 'PURCHASE' COMMENT '入库类型',
  `supplier` VARCHAR(200) DEFAULT NULL COMMENT '供应商',
  `invoice_no` VARCHAR(100) DEFAULT NULL COMMENT '发票号',
  `operator_id` BIGINT NOT NULL COMMENT '操作人 ID',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_in_no` (`in_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库记录表';

-- =====================================================
-- 5. 出库记录表
-- =====================================================
DROP TABLE IF EXISTS `out_record`;
CREATE TABLE `out_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `out_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '出库单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `quantity` INT NOT NULL COMMENT '出库数量',
  `out_type` ENUM('BORROW', 'USE', 'TRANSFER', 'OTHER') DEFAULT 'USE' COMMENT '出库类型',
  `receiver_id` BIGINT DEFAULT NULL COMMENT '领用人 ID',
  `operator_id` BIGINT NOT NULL COMMENT '操作人 ID',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_out_no` (`out_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='出库记录表';

-- =====================================================
-- 6. 借用记录表
-- =====================================================
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `borrow_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '借用单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `borrower_id` BIGINT NOT NULL COMMENT '借用人 ID',
  `quantity` INT NOT NULL COMMENT '借用数量',
  `borrow_date` DATETIME NOT NULL COMMENT '借用日期',
  `expected_return_date` DATE DEFAULT NULL COMMENT '预计归还日期',
  `return_date` DATETIME DEFAULT NULL COMMENT '实际归还日期',
  `status` ENUM('BORROWED', 'RETURNED', 'OVERDUE') DEFAULT 'BORROWED' COMMENT '状态',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审批人 ID',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_borrow_no` (`borrow_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_borrower_id` (`borrower_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='借用记录表';

-- =====================================================
-- 7. 报废报修表
-- =====================================================
DROP TABLE IF EXISTS `repair_record`;
CREATE TABLE `repair_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `record_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '记录单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `type` ENUM('REPAIR', 'SCRAP') NOT NULL COMMENT '类型',
  `reason` TEXT NOT NULL COMMENT '原因',
  `reporter_id` BIGINT NOT NULL COMMENT '报告人 ID',
  `handler_id` BIGINT DEFAULT NULL COMMENT '处理人 ID',
  `status` ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'REJECTED') DEFAULT 'PENDING' COMMENT '状态',
  `handle_result` TEXT DEFAULT NULL COMMENT '处理结果',
  `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_record_no` (`record_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报废报修表';

-- =====================================================
-- 8. 操作日志表
-- =====================================================
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志 ID',
  `user_id` BIGINT NOT NULL COMMENT '用户 ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `operation` VARCHAR(100) NOT NULL COMMENT '操作',
  `method` VARCHAR(200) NOT NULL COMMENT '请求方法',
  `params` TEXT DEFAULT NULL COMMENT '请求参数',
  `ip` VARCHAR(50) DEFAULT NULL COMMENT 'IP 地址',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1-成功，0-失败',
  `error_msg` TEXT DEFAULT NULL COMMENT '错误信息',
  `execute_time` BIGINT DEFAULT NULL COMMENT '执行时间(ms)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- =====================================================
-- 初始化数据
-- =====================================================

-- 初始化用户数据
INSERT INTO `user` (`username`, `password`, `real_name`, `email`, `phone`, `role`, `department`, `status`) VALUES
('admin', '$2a$10$2NymWg4F4sMJQxot215a1.Jz4HV5M91Fw9is5iq0i6lLQqeYdPAtK', 'Admin', 'admin@lab.com', '13800138000', 'ADMIN', 'IT', 1),
('labadmin', '$2a$10$2NymWg4F4sMJQxot215a1.Jz4HV5M91Fw9is5iq0i6lLQqeYdPAtK', 'Lab Admin', 'labadmin@lab.com', '13800138001', 'LAB_ADMIN', 'Lab', 1),
('teacher1', '$2a$10$2NymWg4F4sMJQxot215a1.Jz4HV5M91Fw9is5iq0i6lLQqeYdPAtK', 'Teacher', 'teacher@lab.com', '13800138002', 'TEACHER', 'CS Dept', 1);

-- 初始化物品类别
INSERT INTO `category` (`category_name`, `parent_id`, `level`, `sort_order`, `description`) VALUES
('Equipment', 0, 1, 1, 'Lab Equipment'),
('Office', 0, 1, 2, 'Office Equipment'),
('Consumables', 0, 1, 3, 'Lab Consumables');

SELECT 'Database initialization completed!' AS message;
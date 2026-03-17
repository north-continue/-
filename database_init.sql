
CREATE DATABASE IF NOT EXISTS lab_items_management 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

USE lab_items_management;

-- =====================================================
-- 1. 用户表 (user) - 最先创建，因为其他表会引用
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
-- 2. 物品类别表 (category) - 第二个创建
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
-- 3. 物品表 (item) - 现在 user 和 category 已存在，可以添加外键
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
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_item_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_item_creator` FOREIGN KEY (`create_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品表';

-- =====================================================
-- 4. 入库记录表 (in_record)
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
  `warehouse_location` VARCHAR(200) DEFAULT NULL COMMENT '入库位置',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `operator_user_id` BIGINT NOT NULL COMMENT '操作人 ID',
  `operate_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_in_no` (`in_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_operate_time` (`operate_time`),
  CONSTRAINT `fk_in_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_in_operator` FOREIGN KEY (`operator_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库记录表';

-- =====================================================
-- 5. 出库记录表 (out_record)
-- =====================================================
DROP TABLE IF EXISTS `out_record`;
CREATE TABLE `out_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `out_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '出库单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `quantity` INT NOT NULL COMMENT '出库数量',
  `out_type` ENUM('BORROW', 'CONSUME', 'TRANSFER', 'SCRAP', 'OTHER') DEFAULT 'BORROW' COMMENT '出库类型',
  `recipient_user_id` BIGINT DEFAULT NULL COMMENT '领用人 ID',
  `recipient_department` VARCHAR(100) DEFAULT NULL COMMENT '领用部门',
  `purpose` VARCHAR(500) DEFAULT NULL COMMENT '用途说明',
  `warehouse_location` VARCHAR(200) DEFAULT NULL COMMENT '出库位置',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `operator_user_id` BIGINT NOT NULL COMMENT '操作人 ID',
  `operate_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_out_no` (`out_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_recipient` (`recipient_user_id`),
  INDEX `idx_operate_time` (`operate_time`),
  CONSTRAINT `fk_out_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_out_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `user`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_out_operator` FOREIGN KEY (`operator_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='出库记录表';

-- =====================================================
-- 6. 借用记录表 (borrow_record)
-- =====================================================
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `borrow_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '借用单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `quantity` INT NOT NULL COMMENT '借用数量',
  `borrower_user_id` BIGINT NOT NULL COMMENT '借用人 ID',
  `borrower_department` VARCHAR(100) DEFAULT NULL COMMENT '借用部门',
  `borrow_purpose` VARCHAR(500) DEFAULT NULL COMMENT '借用用途',
  `expected_return_date` DATE NOT NULL COMMENT '预计归还日期',
  `actual_return_date` DATE DEFAULT NULL COMMENT '实际归还日期',
  `borrow_status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'BORROWED', 'RETURNED', 'OVERDUE') DEFAULT 'PENDING' COMMENT '借用状态',
  `approver_user_id` BIGINT DEFAULT NULL COMMENT '审批人 ID',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
  `approve_remark` VARCHAR(500) DEFAULT NULL COMMENT '审批意见',
  `reminder_sent` TINYINT DEFAULT 0 COMMENT '是否已发送提醒：1-是，0-否',
  `last_reminder_time` DATETIME DEFAULT NULL COMMENT '最后提醒时间',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_borrow_no` (`borrow_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_borrower` (`borrower_user_id`),
  INDEX `idx_borrow_status` (`borrow_status`),
  INDEX `idx_expected_return` (`expected_return_date`),
  CONSTRAINT `fk_borrow_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_borrow_borrower` FOREIGN KEY (`borrower_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_borrow_approver` FOREIGN KEY (`approver_user_id`) REFERENCES `user`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='借用记录表';

-- =====================================================
-- 7. 报废报修表 (repair_record)
-- =====================================================
DROP TABLE IF EXISTS `repair_record`;
CREATE TABLE `repair_record` (
  `record_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `repair_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '报修单号',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `report_type` ENUM('REPAIR', 'SCRAP', 'MAINTENANCE') NOT NULL COMMENT '报修类型',
  `fault_description` TEXT NOT NULL COMMENT '故障描述',
  `reporter_user_id` BIGINT NOT NULL COMMENT '报修人 ID',
  `reporter_department` VARCHAR(100) DEFAULT NULL COMMENT '报修部门',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `report_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '报修时间',
  `handler_user_id` BIGINT DEFAULT NULL COMMENT '处理人 ID',
  `handle_status` ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'CLOSED') DEFAULT 'PENDING' COMMENT '处理状态',
  `handle_result` TEXT DEFAULT NULL COMMENT '处理结果',
  `handle_cost` DECIMAL(10,2) DEFAULT NULL COMMENT '处理费用',
  `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  INDEX `idx_repair_no` (`repair_no`),
  INDEX `idx_item_id` (`item_id`),
  INDEX `idx_reporter` (`reporter_user_id`),
  INDEX `idx_handler` (`handler_user_id`),
  INDEX `idx_handle_status` (`handle_status`),
  CONSTRAINT `fk_repair_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_repair_reporter` FOREIGN KEY (`reporter_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_repair_handler` FOREIGN KEY (`handler_user_id`) REFERENCES `user`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报废报修表';

-- =====================================================
-- 8. 库存预警表 (alert_config)
-- =====================================================
DROP TABLE IF EXISTS `alert_config`;
CREATE TABLE `alert_config` (
  `config_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置 ID',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `min_stock` INT NOT NULL COMMENT '最低库存阈值',
  `max_stock` INT NOT NULL COMMENT '最高库存阈值',
  `alert_enabled` TINYINT DEFAULT 1 COMMENT '是否启用预警：1-启用，0-禁用',
  `alert_method` VARCHAR(50) DEFAULT 'SYSTEM' COMMENT '预警方式：SYSTEM-系统通知，EMAIL-邮件，SMS-短信',
  `alert_recipients` VARCHAR(500) DEFAULT NULL COMMENT '预警接收人 (JSON 格式)',
  `last_alert_time` DATETIME DEFAULT NULL COMMENT '最后预警时间',
  `alert_count` INT DEFAULT 0 COMMENT '预警次数',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_item_id` (`item_id`),
  CONSTRAINT `fk_alert_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存预警配置表';

-- =====================================================
-- 9. 操作日志表 (operation_log)
-- =====================================================
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志 ID',
  `module` VARCHAR(50) DEFAULT NULL COMMENT '功能模块',
  `operation_type` VARCHAR(50) DEFAULT NULL COMMENT '操作类型',
  `operation_desc` VARCHAR(500) DEFAULT NULL COMMENT '操作描述',
  `request_method` VARCHAR(10) DEFAULT NULL COMMENT '请求方法',
  `request_url` VARCHAR(500) DEFAULT NULL COMMENT '请求 URL',
  `request_params` TEXT DEFAULT NULL COMMENT '请求参数',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP 地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '浏览器标识',
  `operator_user_id` BIGINT DEFAULT NULL COMMENT '操作人 ID',
  `operator_username` VARCHAR(50) DEFAULT NULL COMMENT '操作人用户名',
  `execute_time` BIGINT DEFAULT NULL COMMENT '执行时长 (ms)',
  `status` TINYINT DEFAULT 1 COMMENT '操作状态：1-成功，0-失败',
  `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
  `operate_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`),
  INDEX `idx_module` (`module`),
  INDEX `idx_operation_type` (`operation_type`),
  INDEX `idx_operator` (`operator_user_id`),
  INDEX `idx_operate_time` (`operate_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- =====================================================
-- 10. 盘点记录表 (inventory_check)
-- =====================================================
DROP TABLE IF EXISTS `inventory_check`;
CREATE TABLE `inventory_check` (
  `check_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '盘点 ID',
  `check_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '盘点单号',
  `check_type` ENUM('REGULAR', 'TEMPORARY', 'SPECIAL') DEFAULT 'REGULAR' COMMENT '盘点类型',
  `check_scope` ENUM('ALL', 'CATEGORY', 'LOCATION', 'SINGLE') DEFAULT 'ALL' COMMENT '盘点范围',
  `scope_value` VARCHAR(500) DEFAULT NULL COMMENT '范围值 (类别 ID/位置/物品 ID)',
  `plan_start_time` DATETIME DEFAULT NULL COMMENT '计划开始时间',
  `plan_end_time` DATETIME DEFAULT NULL COMMENT '计划结束时间',
  `actual_start_time` DATETIME DEFAULT NULL COMMENT '实际开始时间',
  `actual_end_time` DATETIME DEFAULT NULL COMMENT '实际结束时间',
  `check_status` ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING' COMMENT '盘点状态',
  `total_items` INT DEFAULT 0 COMMENT '应盘物品数',
  `checked_items` INT DEFAULT 0 COMMENT '已盘物品数',
  `normal_count` INT DEFAULT 0 COMMENT '正常数量',
  `abnormal_count` INT DEFAULT 0 COMMENT '异常数量',
  `checker_user_id` BIGINT DEFAULT NULL COMMENT '盘点人 ID',
  `reviewer_user_id` BIGINT DEFAULT NULL COMMENT '审核人 ID',
  `review_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `review_remark` VARCHAR(500) DEFAULT NULL COMMENT '审核意见',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_user_id` BIGINT NOT NULL COMMENT '创建人 ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`check_id`),
  INDEX `idx_check_no` (`check_no`),
  INDEX `idx_check_type` (`check_type`),
  INDEX `idx_check_status` (`check_status`),
  CONSTRAINT `fk_check_checker` FOREIGN KEY (`checker_user_id`) REFERENCES `user`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_check_creator` FOREIGN KEY (`create_user_id`) REFERENCES `user`(`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='盘点记录表';

-- =====================================================
-- 11. 盘点明细表 (inventory_check_detail)
-- =====================================================
DROP TABLE IF EXISTS `inventory_check_detail`;
CREATE TABLE `inventory_check_detail` (
  `detail_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '明细 ID',
  `check_id` BIGINT NOT NULL COMMENT '盘点 ID',
  `item_id` BIGINT NOT NULL COMMENT '物品 ID',
  `system_quantity` INT NOT NULL COMMENT '系统数量',
  `actual_quantity` INT NOT NULL COMMENT '实际数量',
  `difference` INT NOT NULL COMMENT '差异数量',
  `check_result` ENUM('NORMAL', 'SURPLUS', 'LOSS', 'DAMAGE') DEFAULT 'NORMAL' COMMENT '盘点结果',
  `check_location` VARCHAR(200) DEFAULT NULL COMMENT '盘点位置',
  `check_remark` VARCHAR(500) DEFAULT NULL COMMENT '盘点备注',
  `checker_user_id` BIGINT DEFAULT NULL COMMENT '盘点人 ID',
  `check_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '盘点时间',
  PRIMARY KEY (`detail_id`),
  INDEX `idx_check_id` (`check_id`),
  INDEX `idx_item_id` (`item_id`),
  CONSTRAINT `fk_detail_check` FOREIGN KEY (`check_id`) REFERENCES `inventory_check`(`check_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_item` FOREIGN KEY (`item_id`) REFERENCES `item`(`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='盘点明细表';

-- =====================================================
-- 12. 系统配置表 (system_config)
-- =====================================================
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
  `config_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置 ID',
  `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
  `config_value` TEXT DEFAULT NULL COMMENT '配置值',
  `config_type` VARCHAR(50) DEFAULT 'STRING' COMMENT '配置类型',
  `config_desc` VARCHAR(500) DEFAULT NULL COMMENT '配置描述',
  `is_editable` TINYINT DEFAULT 1 COMMENT '是否可编辑：1-是，0-否',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  INDEX `idx_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- =====================================================
-- 13. 消息通知表 (notification)
-- =====================================================
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `notification_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '通知 ID',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '内容',
  `notification_type` ENUM('SYSTEM', 'BORROW', 'ALERT', 'REPAIR', 'CHECK') DEFAULT 'SYSTEM' COMMENT '通知类型',
  `priority` ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM' COMMENT '优先级',
  `receiver_user_id` BIGINT NOT NULL COMMENT '接收人 ID',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读：1-是，0-否',
  `read_time` DATETIME DEFAULT NULL COMMENT '阅读时间',
  `related_type` VARCHAR(50) DEFAULT NULL COMMENT '关联类型',
  `related_id` BIGINT DEFAULT NULL COMMENT '关联 ID',
  `send_method` VARCHAR(50) DEFAULT 'SYSTEM' COMMENT '发送方式',
  `send_status` TINYINT DEFAULT 0 COMMENT '发送状态：1-成功，0-失败',
  `send_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`notification_id`),
  INDEX `idx_receiver` (`receiver_user_id`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_notification_type` (`notification_type`),
  CONSTRAINT `fk_notification_receiver` FOREIGN KEY (`receiver_user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息通知表';

-- =====================================================
-- 初始化数据
-- =====================================================

-- 1. 初始化用户数据
INSERT INTO `user` (`username`, `password`, `real_name`, `email`, `phone`, `role`, `department`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '系统管理员', 'admin@lab.com', '13800138000', 'ADMIN', '信息中心', 1),
('labadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '实验室管理员', 'labadmin@lab.com', '13800138001', 'LAB_ADMIN', '实验中心', 1),
('teacher1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '张老师', 'teacher@lab.com', '13800138002', 'TEACHER', '计算机学院', 1),
('student1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '李明', 'student@lab.com', '13800138003', 'STUDENT', '计算机学院', 1);
-- 注：密码均为加密后的"123456"

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

-- =====================================================
-- 视图定义
-- =====================================================

-- 1. 物品库存视图
CREATE OR REPLACE VIEW `v_item_stock` AS
SELECT 
  i.item_id,
  i.item_code,
  i.item_name,
  c.category_name,
  i.specification,
  i.location,
  i.total_quantity,
  i.available_quantity,
  i.borrowed_quantity,
  i.min_stock,
  i.max_stock,
  CASE 
    WHEN i.available_quantity <= i.min_stock THEN 'LOW'
    WHEN i.available_quantity >= i.max_stock AND i.max_stock > 0 THEN 'HIGH'
    ELSE 'NORMAL'
  END AS stock_status,
  i.status,
  u.real_name AS creator_name
FROM item i
LEFT JOIN category c ON i.category_id = c.category_id
LEFT JOIN user u ON i.create_user_id = u.user_id;

-- 2. 借用记录视图
CREATE OR REPLACE VIEW `v_borrow_detail` AS
SELECT 
  br.record_id,
  br.borrow_no,
  i.item_code,
  i.item_name,
  br.quantity,
  br.borrower_user_id,
  bu.real_name AS borrower_name,
  br.borrower_department,
  br.expected_return_date,
  br.actual_return_date,
  br.borrow_status,
  CASE 
    WHEN br.borrow_status = 'RETURNED' THEN '已完成'
    WHEN br.actual_return_date IS NULL AND br.expected_return_date < CURDATE() THEN '已逾期'
    WHEN br.actual_return_date IS NULL AND br.expected_return_date = CURDATE() THEN '今日到期'
    WHEN br.actual_return_date IS NULL AND br.expected_return_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN '即将到期'
    ELSE '借用中'
  END AS status_desc,
  br.approver_user_id,
  au.real_name AS approver_name,
  br.approve_time,
  br.create_time
FROM borrow_record br
LEFT JOIN item i ON br.item_id = i.item_id
LEFT JOIN user bu ON br.borrower_user_id = bu.user_id
LEFT JOIN user au ON br.approver_user_id = au.user_id;

-- 3. 库存预警视图
CREATE OR REPLACE VIEW `v_stock_alert` AS
SELECT 
  i.item_id,
  i.item_code,
  i.item_name,
  c.category_name,
  i.available_quantity,
  i.min_stock,
  i.max_stock,
  CASE 
    WHEN i.available_quantity <= i.min_stock THEN CONCAT('库存不足，当前:', i.available_quantity, ', 预警值:', i.min_stock)
    WHEN i.available_quantity >= i.max_stock AND i.max_stock > 0 THEN CONCAT('库存过高，当前:', i.available_quantity, ', 上限:', i.max_stock)
    ELSE '正常'
  END AS alert_message,
  DATEDIFF(CURDATE(), i.warranty_expiry) AS warranty_days_left
FROM item i
LEFT JOIN category c ON i.category_id = c.category_id
WHERE i.available_quantity <= i.min_stock 
   OR (i.available_quantity >= i.max_stock AND i.max_stock > 0)
   OR (i.warranty_expiry IS NOT NULL AND DATEDIFF(CURDATE(), i.warranty_expiry) BETWEEN 0 AND 30);

-- =====================================================
-- 存储过程
-- =====================================================

-- 1. 物品入库存储过程
DELIMITER $$
CREATE PROCEDURE `sp_item_instock`(
  IN p_item_id BIGINT,
  IN p_quantity INT,
  IN p_in_type VARCHAR(20),
  IN p_supplier VARCHAR(200),
  IN p_warehouse_location VARCHAR(200),
  IN p_remark TEXT,
  IN p_operator_user_id BIGINT,
  OUT p_in_no VARCHAR(50),
  OUT p_result INT
)
BEGIN
  DECLARE v_current_time DATETIME;
  
  SET v_current_time = NOW();
  SET p_in_no = CONCAT('IN', DATE_FORMAT(v_current_time, '%Y%m%d%H%i%s'));
  
  START TRANSACTION;
  
  INSERT INTO in_record (in_no, item_id, quantity, in_type, supplier, warehouse_location, remark, operator_user_id, operate_time)
  VALUES (p_in_no, p_item_id, p_quantity, p_in_type, p_supplier, p_warehouse_location, p_remark, p_operator_user_id, v_current_time);
  
  UPDATE item 
  SET total_quantity = total_quantity + p_quantity,
      available_quantity = available_quantity + p_quantity
  WHERE item_id = p_item_id;
  
  SET p_result = 1;
  
  COMMIT;
END$$
DELIMITER ;

-- 2. 物品出库存储过程
DELIMITER $$
CREATE PROCEDURE `sp_item_outstock`(
  IN p_item_id BIGINT,
  IN p_quantity INT,
  IN p_out_type VARCHAR(20),
  IN p_recipient_user_id BIGINT,
  IN p_purpose VARCHAR(500),
  IN p_warehouse_location VARCHAR(200),
  IN p_remark TEXT,
  IN p_operator_user_id BIGINT,
  OUT p_out_no VARCHAR(50),
  OUT p_result INT
)
BEGIN
  DECLARE v_available_qty INT;
  DECLARE v_current_time DATETIME;
  
  SET v_current_time = NOW();
  
  SELECT available_quantity INTO v_available_qty
  FROM item
  WHERE item_id = p_item_id;
  
  IF v_available_qty < p_quantity THEN
    SET p_result = -1;
    LEAVE;
  END IF;
  
  SET p_out_no = CONCAT('OUT', DATE_FORMAT(v_current_time, '%Y%m%d%H%i%s'));
  
  START TRANSACTION;
  
  INSERT INTO out_record (out_no, item_id, quantity, out_type, recipient_user_id, purpose, warehouse_location, remark, operator_user_id, operate_time)
  VALUES (p_out_no, p_item_id, p_quantity, p_out_type, p_recipient_user_id, p_purpose, p_warehouse_location, p_remark, p_operator_user_id, v_current_time);
  
  UPDATE item 
  SET available_quantity = available_quantity - p_quantity
  WHERE item_id = p_item_id;
  
  SET p_result = 1;
  
  COMMIT;
END$$
DELIMITER ;

-- =====================================================
-- 触发器
-- =====================================================

DELIMITER $$
CREATE TRIGGER `trg_borrow_approved`
AFTER UPDATE ON borrow_record
FOR EACH ROW
BEGIN
  IF OLD.borrow_status = 'PENDING' AND NEW.borrow_status = 'APPROVED' THEN
    UPDATE item 
    SET borrowed_quantity = borrowed_quantity + NEW.quantity,
        available_quantity = available_quantity - NEW.quantity
    WHERE item_id = NEW.item_id;
  END IF;
  
  IF OLD.borrow_status = 'BORROWED' AND NEW.borrow_status = 'RETURNED' THEN
    UPDATE item 
    SET borrowed_quantity = borrowed_quantity - NEW.quantity,
        available_quantity = available_quantity + NEW.quantity
    WHERE item_id = NEW.item_id;
  END IF;
END$$
DELIMITER ;

-- =====================================================
-- 完成提示
-- =====================================================
SELECT '数据库初始化完成！' AS message;

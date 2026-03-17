/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : lab_items_management

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 15/03/2026 14:21:59
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for alert_config
-- ----------------------------
DROP TABLE IF EXISTS `alert_config`;
CREATE TABLE `alert_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置 ID',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `min_stock` int NOT NULL COMMENT '最低库存阈值',
  `max_stock` int NOT NULL COMMENT '最高库存阈值',
  `alert_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用预警：1-启用，0-禁用',
  `alert_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'SYSTEM' COMMENT '预警方式：SYSTEM-系统通知，EMAIL-邮件，SMS-短信',
  `alert_recipients` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预警接收人 (JSON 格式)',
  `last_alert_time` datetime NULL DEFAULT NULL COMMENT '最后预警时间',
  `alert_count` int NULL DEFAULT 0 COMMENT '预警次数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_item_id`(`item_id` ASC) USING BTREE,
  CONSTRAINT `fk_alert_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '库存预警配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of alert_config
-- ----------------------------

-- ----------------------------
-- Table structure for borrow_record
-- ----------------------------
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `borrow_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '借用单号',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `quantity` int NOT NULL COMMENT '借用数量',
  `borrower_user_id` bigint NOT NULL COMMENT '借用人 ID',
  `borrower_department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '借用部门',
  `borrow_purpose` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '借用用途',
  `expected_return_date` date NOT NULL COMMENT '预计归还日期',
  `actual_return_date` date NULL DEFAULT NULL COMMENT '实际归还日期',
  `borrow_status` enum('PENDING','APPROVED','REJECTED','BORROWED','RETURNED','OVERDUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PENDING' COMMENT '借用状态',
  `approver_user_id` bigint NULL DEFAULT NULL COMMENT '审批人 ID',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `approve_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批意见',
  `reminder_sent` tinyint NULL DEFAULT 0 COMMENT '是否已发送提醒：1-是，0-否',
  `last_reminder_time` datetime NULL DEFAULT NULL COMMENT '最后提醒时间',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  UNIQUE INDEX `borrow_no`(`borrow_no` ASC) USING BTREE,
  INDEX `idx_borrow_no`(`borrow_no` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_borrower`(`borrower_user_id` ASC) USING BTREE,
  INDEX `idx_borrow_status`(`borrow_status` ASC) USING BTREE,
  INDEX `idx_expected_return`(`expected_return_date` ASC) USING BTREE,
  INDEX `fk_borrow_approver`(`approver_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_borrow_approver` FOREIGN KEY (`approver_user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_borrow_borrower` FOREIGN KEY (`borrower_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_borrow_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '借用记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of borrow_record
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '类别 ID',
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类别名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父类别 ID',
  `level` tinyint NULL DEFAULT 1 COMMENT '层级',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '物品类别表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '实验设备', 0, 1, 1, '各类实验仪器设备', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (2, '办公设备', 0, 1, 2, '办公用设备物品', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (3, '耗材', 0, 1, 3, '实验消耗材料', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (4, '工具', 0, 1, 4, '实验工具', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (5, '计算机设备', 1, 2, 1, '计算机相关设备', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (6, '电子设备', 1, 2, 2, '电子类设备', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (7, '测量仪器', 1, 2, 3, '测量类仪器', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (8, '打印机', 2, 2, 1, '打印设备', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `category` VALUES (9, '投影仪', 2, 2, 2, '投影设备', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');

-- ----------------------------
-- Table structure for in_record
-- ----------------------------
DROP TABLE IF EXISTS `in_record`;
CREATE TABLE `in_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `in_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '入库单号',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `quantity` int NOT NULL COMMENT '入库数量',
  `in_type` enum('PURCHASE','RETURN','TRANSFER','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PURCHASE' COMMENT '入库类型',
  `supplier` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商',
  `invoice_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发票号',
  `warehouse_location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入库位置',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `operator_user_id` bigint NOT NULL COMMENT '操作人 ID',
  `operate_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  UNIQUE INDEX `in_no`(`in_no` ASC) USING BTREE,
  INDEX `idx_in_no`(`in_no` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_operate_time`(`operate_time` ASC) USING BTREE,
  INDEX `fk_in_operator`(`operator_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_in_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_in_operator` FOREIGN KEY (`operator_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '入库记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of in_record
-- ----------------------------

-- ----------------------------
-- Table structure for inventory_check
-- ----------------------------
DROP TABLE IF EXISTS `inventory_check`;
CREATE TABLE `inventory_check`  (
  `check_id` bigint NOT NULL AUTO_INCREMENT COMMENT '盘点 ID',
  `check_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '盘点单号',
  `check_type` enum('REGULAR','TEMPORARY','SPECIAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'REGULAR' COMMENT '盘点类型',
  `check_scope` enum('ALL','CATEGORY','LOCATION','SINGLE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ALL' COMMENT '盘点范围',
  `scope_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '范围值 (类别 ID/位置/物品 ID)',
  `plan_start_time` datetime NULL DEFAULT NULL COMMENT '计划开始时间',
  `plan_end_time` datetime NULL DEFAULT NULL COMMENT '计划结束时间',
  `actual_start_time` datetime NULL DEFAULT NULL COMMENT '实际开始时间',
  `actual_end_time` datetime NULL DEFAULT NULL COMMENT '实际结束时间',
  `check_status` enum('PENDING','PROCESSING','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PENDING' COMMENT '盘点状态',
  `total_items` int NULL DEFAULT 0 COMMENT '应盘物品数',
  `checked_items` int NULL DEFAULT 0 COMMENT '已盘物品数',
  `normal_count` int NULL DEFAULT 0 COMMENT '正常数量',
  `abnormal_count` int NULL DEFAULT 0 COMMENT '异常数量',
  `checker_user_id` bigint NULL DEFAULT NULL COMMENT '盘点人 ID',
  `reviewer_user_id` bigint NULL DEFAULT NULL COMMENT '审核人 ID',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核意见',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `create_user_id` bigint NOT NULL COMMENT '创建人 ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`check_id`) USING BTREE,
  UNIQUE INDEX `check_no`(`check_no` ASC) USING BTREE,
  INDEX `idx_check_no`(`check_no` ASC) USING BTREE,
  INDEX `idx_check_type`(`check_type` ASC) USING BTREE,
  INDEX `idx_check_status`(`check_status` ASC) USING BTREE,
  INDEX `fk_check_checker`(`checker_user_id` ASC) USING BTREE,
  INDEX `fk_check_creator`(`create_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_check_checker` FOREIGN KEY (`checker_user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_check_creator` FOREIGN KEY (`create_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '盘点记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_check
-- ----------------------------

-- ----------------------------
-- Table structure for inventory_check_detail
-- ----------------------------
DROP TABLE IF EXISTS `inventory_check_detail`;
CREATE TABLE `inventory_check_detail`  (
  `detail_id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细 ID',
  `check_id` bigint NOT NULL COMMENT '盘点 ID',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `system_quantity` int NOT NULL COMMENT '系统数量',
  `actual_quantity` int NOT NULL COMMENT '实际数量',
  `difference` int NOT NULL COMMENT '差异数量',
  `check_result` enum('NORMAL','SURPLUS','LOSS','DAMAGE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NORMAL' COMMENT '盘点结果',
  `check_location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '盘点位置',
  `check_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '盘点备注',
  `checker_user_id` bigint NULL DEFAULT NULL COMMENT '盘点人 ID',
  `check_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '盘点时间',
  PRIMARY KEY (`detail_id`) USING BTREE,
  INDEX `idx_check_id`(`check_id` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  CONSTRAINT `fk_detail_check` FOREIGN KEY (`check_id`) REFERENCES `inventory_check` (`check_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '盘点明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_check_detail
-- ----------------------------

-- ----------------------------
-- Table structure for item
-- ----------------------------
DROP TABLE IF EXISTS `item`;
CREATE TABLE `item`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物品 ID',
  `item_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品编号',
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '二维码内容',
  `item_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品名称',
  `category_id` bigint NOT NULL COMMENT '类别 ID',
  `specification` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格型号',
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '单价',
  `purchase_date` date NULL DEFAULT NULL COMMENT '购买日期',
  `supplier` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '存放位置',
  `lab_room` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '实验室房间号',
  `shelf` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '货架号',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片 URL',
  `total_quantity` int NULL DEFAULT 0 COMMENT '总数量',
  `available_quantity` int NULL DEFAULT 0 COMMENT '可用数量',
  `borrowed_quantity` int NULL DEFAULT 0 COMMENT '借出数量',
  `min_stock` int NULL DEFAULT 0 COMMENT '最低库存预警值',
  `max_stock` int NULL DEFAULT 0 COMMENT '最高库存预警值',
  `status` enum('AVAILABLE','BORROWED','REPAIRING','SCRAPPED','LOST') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'AVAILABLE' COMMENT '物品状态',
  `warranty_period` int NULL DEFAULT NULL COMMENT '保修期 (月)',
  `warranty_expiry` date NULL DEFAULT NULL COMMENT '保修到期日期',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `create_user_id` bigint NOT NULL COMMENT '创建人 ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`item_id`) USING BTREE,
  UNIQUE INDEX `item_code`(`item_code` ASC) USING BTREE,
  INDEX `idx_item_code`(`item_code` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_location`(`location` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `fk_item_creator`(`create_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_item_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_item_creator` FOREIGN KEY (`create_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '物品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of item
-- ----------------------------

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `notification_id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知 ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `notification_type` enum('SYSTEM','BORROW','ALERT','REPAIR','CHECK') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'SYSTEM' COMMENT '通知类型',
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MEDIUM' COMMENT '优先级',
  `receiver_user_id` bigint NOT NULL COMMENT '接收人 ID',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读：1-是，0-否',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联 ID',
  `send_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'SYSTEM' COMMENT '发送方式',
  `send_status` tinyint NULL DEFAULT 0 COMMENT '发送状态：1-成功，0-失败',
  `send_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`notification_id`) USING BTREE,
  INDEX `idx_receiver`(`receiver_user_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_notification_type`(`notification_type` ASC) USING BTREE,
  CONSTRAINT `fk_notification_receiver` FOREIGN KEY (`receiver_user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志 ID',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '功能模块',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作类型',
  `operation_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作描述',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求方法',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求 URL',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求参数',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP 地址',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浏览器标识',
  `operator_user_id` bigint NULL DEFAULT NULL COMMENT '操作人 ID',
  `operator_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人用户名',
  `execute_time` bigint NULL DEFAULT NULL COMMENT '执行时长 (ms)',
  `status` tinyint NULL DEFAULT 1 COMMENT '操作状态：1-成功，0-失败',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '错误信息',
  `operate_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_operator`(`operator_user_id` ASC) USING BTREE,
  INDEX `idx_operate_time`(`operate_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for out_record
-- ----------------------------
DROP TABLE IF EXISTS `out_record`;
CREATE TABLE `out_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `out_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '出库单号',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `quantity` int NOT NULL COMMENT '出库数量',
  `out_type` enum('BORROW','CONSUME','TRANSFER','SCRAP','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'BORROW' COMMENT '出库类型',
  `recipient_user_id` bigint NULL DEFAULT NULL COMMENT '领用人 ID',
  `recipient_department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领用部门',
  `purpose` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用途说明',
  `warehouse_location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出库位置',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `operator_user_id` bigint NOT NULL COMMENT '操作人 ID',
  `operate_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  UNIQUE INDEX `out_no`(`out_no` ASC) USING BTREE,
  INDEX `idx_out_no`(`out_no` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_recipient`(`recipient_user_id` ASC) USING BTREE,
  INDEX `idx_operate_time`(`operate_time` ASC) USING BTREE,
  INDEX `fk_out_operator`(`operator_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_out_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_out_operator` FOREIGN KEY (`operator_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_out_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出库记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of out_record
-- ----------------------------

-- ----------------------------
-- Table structure for repair_record
-- ----------------------------
DROP TABLE IF EXISTS `repair_record`;
CREATE TABLE `repair_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `repair_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '报修单号',
  `item_id` bigint NOT NULL COMMENT '物品 ID',
  `report_type` enum('REPAIR','SCRAP','MAINTENANCE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '报修类型',
  `fault_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '故障描述',
  `reporter_user_id` bigint NOT NULL COMMENT '报修人 ID',
  `reporter_department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报修部门',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `report_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报修时间',
  `handler_user_id` bigint NULL DEFAULT NULL COMMENT '处理人 ID',
  `handle_status` enum('PENDING','PROCESSING','COMPLETED','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PENDING' COMMENT '处理状态',
  `handle_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '处理结果',
  `handle_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '处理费用',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  UNIQUE INDEX `repair_no`(`repair_no` ASC) USING BTREE,
  INDEX `idx_repair_no`(`repair_no` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_reporter`(`reporter_user_id` ASC) USING BTREE,
  INDEX `idx_handler`(`handler_user_id` ASC) USING BTREE,
  INDEX `idx_handle_status`(`handle_status` ASC) USING BTREE,
  CONSTRAINT `fk_repair_handler` FOREIGN KEY (`handler_user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_repair_item` FOREIGN KEY (`item_id`) REFERENCES `item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_repair_reporter` FOREIGN KEY (`reporter_user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '报废报修表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of repair_record
-- ----------------------------

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置 ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置值',
  `config_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'STRING' COMMENT '配置类型',
  `config_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配置描述',
  `is_editable` tinyint NULL DEFAULT 1 COMMENT '是否可编辑：1-是，0-否',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE,
  INDEX `idx_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'BORROW_MAX_DAYS', '30', 'NUMBER', '最大借用天数', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (2, 'BORROW_APPROVAL_REQUIRED', '1', 'BOOLEAN', '借用是否需要审批', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (3, 'ALERT_CHECK_INTERVAL', '7', 'NUMBER', '库存预警检查间隔 (天)', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (4, 'OVERDUE_REMINDER_DAYS', '3', 'NUMBER', '逾期提前提醒天数', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (5, 'QR_CODE_PREFIX', 'LAB', 'STRING', '二维码前缀', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (6, 'SYSTEM_NAME', '实验室物品管理平台', 'STRING', '系统名称', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');
INSERT INTO `system_config` VALUES (7, 'ALLOW_NEGATIVE_STOCK', '0', 'BOOLEAN', '是否允许负库存', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户 ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码 (加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `role` enum('ADMIN','LAB_ADMIN','TEACHER','STUDENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STUDENT' COMMENT '角色',
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '所属部门/学院',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '系统管理员', 'admin@lab.com', '13800138000', 'ADMIN', '信息中心', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10', NULL);
INSERT INTO `user` VALUES (2, 'labadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '实验室管理员', 'labadmin@lab.com', '13800138001', 'LAB_ADMIN', '实验中心', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10', NULL);
INSERT INTO `user` VALUES (3, 'teacher1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '张老师', 'teacher@lab.com', '13800138002', 'TEACHER', '计算机学院', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10', NULL);
INSERT INTO `user` VALUES (4, 'student1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu', '李明', 'student@lab.com', '13800138003', 'STUDENT', '计算机学院', 1, '2026-03-15 13:53:10', '2026-03-15 13:53:10', NULL);

-- ----------------------------
-- View structure for v_borrow_detail
-- ----------------------------
DROP VIEW IF EXISTS `v_borrow_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_borrow_detail` AS select `br`.`record_id` AS `record_id`,`br`.`borrow_no` AS `borrow_no`,`i`.`item_code` AS `item_code`,`i`.`item_name` AS `item_name`,`br`.`quantity` AS `quantity`,`br`.`borrower_user_id` AS `borrower_user_id`,`bu`.`real_name` AS `borrower_name`,`br`.`borrower_department` AS `borrower_department`,`br`.`expected_return_date` AS `expected_return_date`,`br`.`actual_return_date` AS `actual_return_date`,`br`.`borrow_status` AS `borrow_status`,(case when (`br`.`borrow_status` = 'RETURNED') then '已完成' when ((`br`.`actual_return_date` is null) and (`br`.`expected_return_date` < curdate())) then '已逾期' when ((`br`.`actual_return_date` is null) and (`br`.`expected_return_date` = curdate())) then '今日到期' when ((`br`.`actual_return_date` is null) and (`br`.`expected_return_date` = (curdate() + interval 3 day))) then '即将到期' else '借用中' end) AS `status_desc`,`br`.`approver_user_id` AS `approver_user_id`,`au`.`real_name` AS `approver_name`,`br`.`approve_time` AS `approve_time`,`br`.`create_time` AS `create_time` from (((`borrow_record` `br` left join `item` `i` on((`br`.`item_id` = `i`.`item_id`))) left join `user` `bu` on((`br`.`borrower_user_id` = `bu`.`user_id`))) left join `user` `au` on((`br`.`approver_user_id` = `au`.`user_id`)));

-- ----------------------------
-- View structure for v_item_stock
-- ----------------------------
DROP VIEW IF EXISTS `v_item_stock`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_item_stock` AS select `i`.`item_id` AS `item_id`,`i`.`item_code` AS `item_code`,`i`.`item_name` AS `item_name`,`c`.`category_name` AS `category_name`,`i`.`specification` AS `specification`,`i`.`location` AS `location`,`i`.`total_quantity` AS `total_quantity`,`i`.`available_quantity` AS `available_quantity`,`i`.`borrowed_quantity` AS `borrowed_quantity`,`i`.`min_stock` AS `min_stock`,`i`.`max_stock` AS `max_stock`,(case when (`i`.`available_quantity` <= `i`.`min_stock`) then 'LOW' when ((`i`.`available_quantity` >= `i`.`max_stock`) and (`i`.`max_stock` > 0)) then 'HIGH' else 'NORMAL' end) AS `stock_status`,`i`.`status` AS `status`,`u`.`real_name` AS `creator_name` from ((`item` `i` left join `category` `c` on((`i`.`category_id` = `c`.`category_id`))) left join `user` `u` on((`i`.`create_user_id` = `u`.`user_id`)));

-- ----------------------------
-- View structure for v_stock_alert
-- ----------------------------
DROP VIEW IF EXISTS `v_stock_alert`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_stock_alert` AS select `i`.`item_id` AS `item_id`,`i`.`item_code` AS `item_code`,`i`.`item_name` AS `item_name`,`c`.`category_name` AS `category_name`,`i`.`available_quantity` AS `available_quantity`,`i`.`min_stock` AS `min_stock`,`i`.`max_stock` AS `max_stock`,(case when (`i`.`available_quantity` <= `i`.`min_stock`) then concat('库存不足，当前:',`i`.`available_quantity`,', 预警值:',`i`.`min_stock`) when ((`i`.`available_quantity` >= `i`.`max_stock`) and (`i`.`max_stock` > 0)) then concat('库存过高，当前:',`i`.`available_quantity`,', 上限:',`i`.`max_stock`) else '正常' end) AS `alert_message`,(to_days(curdate()) - to_days(`i`.`warranty_expiry`)) AS `warranty_days_left` from (`item` `i` left join `category` `c` on((`i`.`category_id` = `c`.`category_id`))) where ((`i`.`available_quantity` <= `i`.`min_stock`) or ((`i`.`available_quantity` >= `i`.`max_stock`) and (`i`.`max_stock` > 0)) or ((`i`.`warranty_expiry` is not null) and ((to_days(curdate()) - to_days(`i`.`warranty_expiry`)) between 0 and 30)));

-- ----------------------------
-- Procedure structure for sp_item_instock
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_item_instock`;
delimiter ;;
CREATE PROCEDURE `sp_item_instock`(IN p_item_id BIGINT,
  IN p_quantity INT,
  IN p_in_type VARCHAR(20),
  IN p_supplier VARCHAR(200),
  IN p_warehouse_location VARCHAR(200),
  IN p_remark TEXT,
  IN p_operator_user_id BIGINT,
  OUT p_in_no VARCHAR(50),
  OUT p_result INT)
BEGIN
  DECLARE v_item_code VARCHAR(50);
  DECLARE v_current_time DATETIME;
  
  SET v_current_time = NOW();
  SET p_in_no = CONCAT('IN', DATE_FORMAT(v_current_time, '%Y%m%d%H%i%s'));
  
  START TRANSACTION;
  
  -- 插入入库记录
  INSERT INTO in_record (in_no, item_id, quantity, in_type, supplier, warehouse_location, remark, operator_user_id, operate_time)
  VALUES (p_in_no, p_item_id, p_quantity, p_in_type, p_supplier, p_warehouse_location, p_remark, p_operator_user_id, v_current_time);
  
  -- 更新物品库存
  UPDATE item 
  SET total_quantity = total_quantity + p_quantity,
      available_quantity = available_quantity + p_quantity
  WHERE item_id = p_item_id;
  
  SET p_result = 1;
  
  COMMIT;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

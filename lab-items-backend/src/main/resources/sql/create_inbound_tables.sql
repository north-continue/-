-- 入库单表
CREATE TABLE IF NOT EXISTS `inbound_order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库单ID',
  `order_no` varchar(50) NOT NULL COMMENT '入库单号',
  `order_type` enum('PURCHASE','RETURN','TRANSFER','OTHER') DEFAULT 'PURCHASE' COMMENT '入库类型：采购、退货、调拨、其他',
  `supplier_id` bigint DEFAULT NULL COMMENT '供应商ID',
  `supplier_name` varchar(200) DEFAULT NULL COMMENT '供应商名称',
  `warehouse_id` bigint DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` varchar(100) DEFAULT NULL COMMENT '仓库名称',
  `total_amount` decimal(10,2) DEFAULT '0.00' COMMENT '总金额',
  `total_quantity` int DEFAULT '0' COMMENT '总数量',
  `status` enum('DRAFT','PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED') DEFAULT 'DRAFT' COMMENT '状态：草稿、待审核、已审核、已拒绝、已完成、已取消',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `approver_id` bigint DEFAULT NULL COMMENT '审核人ID',
  `approver_name` varchar(50) DEFAULT NULL COMMENT '审核人姓名',
  `approve_time` datetime DEFAULT NULL COMMENT '审核时间',
  `arrival_date` date DEFAULT NULL COMMENT '预计到货日期',
  `actual_arrival_date` date DEFAULT NULL COMMENT '实际到货日期',
  `invoice_no` varchar(100) DEFAULT NULL COMMENT '发票号',
  `contract_no` varchar(100) DEFAULT NULL COMMENT '合同号',
  `remark` text COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_supplier` (`supplier_id`),
  KEY `idx_warehouse` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库单表';

-- 入库单明细表
CREATE TABLE IF NOT EXISTS `inbound_order_detail` (
  `detail_id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint NOT NULL COMMENT '入库单ID',
  `item_id` bigint NOT NULL COMMENT '物品ID',
  `item_code` varchar(50) DEFAULT NULL COMMENT '物品编码',
  `item_name` varchar(200) NOT NULL COMMENT '物品名称',
  `specification` varchar(200) DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '入库数量',
  `unit_price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `total_price` decimal(10,2) DEFAULT '0.00' COMMENT '总价',
  `batch_no` varchar(50) DEFAULT NULL COMMENT '批次号',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date DEFAULT NULL COMMENT '有效期',
  `quality_status` enum('QUALIFIED','UNQUALIFIED','INSPECTING') DEFAULT 'QUALIFIED' COMMENT '质量状态：合格、不合格、检验中',
  `location` varchar(100) DEFAULT NULL COMMENT '存放位置',
  `remark` text COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`detail_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_item_id` (`item_id`),
  CONSTRAINT `fk_order_detail_order` FOREIGN KEY (`order_id`) REFERENCES `inbound_order` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库单明细表';

-- 供应商表
CREATE TABLE IF NOT EXISTS `supplier` (
  `supplier_id` bigint NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `supplier_code` varchar(50) NOT NULL COMMENT '供应商编码',
  `supplier_name` varchar(200) NOT NULL COMMENT '供应商名称',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(100) DEFAULT NULL COMMENT '联系邮箱',
  `address` varchar(500) DEFAULT NULL COMMENT '地址',
  `credit_level` enum('A','B','C','D') DEFAULT 'B' COMMENT '信用等级',
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态：正常、停用',
  `remark` text COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `uk_supplier_code` (`supplier_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商表';

-- 仓库表
CREATE TABLE IF NOT EXISTS `warehouse` (
  `warehouse_id` bigint NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `warehouse_code` varchar(50) NOT NULL COMMENT '仓库编码',
  `warehouse_name` varchar(100) NOT NULL COMMENT '仓库名称',
  `warehouse_type` enum('MAIN','SUB','VIRTUAL') DEFAULT 'MAIN' COMMENT '仓库类型：主仓库、子仓库、虚拟仓库',
  `location` varchar(200) DEFAULT NULL COMMENT '位置',
  `manager_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `manager_name` varchar(50) DEFAULT NULL COMMENT '负责人姓名',
  `capacity` int DEFAULT NULL COMMENT '容量',
  `current_stock` int DEFAULT '0' COMMENT '当前库存',
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态：正常、停用',
  `remark` text COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`warehouse_id`),
  UNIQUE KEY `uk_warehouse_code` (`warehouse_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仓库表';

-- 插入示例数据
INSERT INTO `supplier` (`supplier_code`, `supplier_name`, `contact_person`, `contact_phone`, `contact_email`, `address`, `credit_level`, `status`) VALUES
('SUP001', '科技有限公司', '张三', '13800138000', 'zhangsan@example.com', '北京市海淀区', 'A', 'ACTIVE'),
('SUP002', '实验器材供应商', '李四', '13900139000', 'lisi@example.com', '上海市浦东新区', 'B', 'ACTIVE'),
('SUP003', '化学试剂公司', '王五', '13700137000', 'wangwu@example.com', '广州市天河区', 'A', 'ACTIVE');

INSERT INTO `warehouse` (`warehouse_code`, `warehouse_name`, `warehouse_type`, `location`, `manager_id`, `manager_name`, `capacity`, `current_stock`, `status`) VALUES
('WH001', '主仓库', 'MAIN', '实验楼一楼', 1, '管理员', 10000, 500, 'ACTIVE'),
('WH002', '化学品仓库', 'SUB', '实验楼二楼', 2, '管理员', 5000, 200, 'ACTIVE'),
('WH003', '仪器设备仓库', 'SUB', '实验楼三楼', 3, '管理员', 3000, 150, 'ACTIVE');

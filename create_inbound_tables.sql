USE lab_items_management;

-- 创建供应商表
CREATE TABLE IF NOT EXISTS `supplier` (
  `supplier_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `supplier_code` VARCHAR(50) NOT NULL UNIQUE COMMENT '供应商编码',
  `supplier_name` VARCHAR(200) NOT NULL COMMENT '供应商名称',
  `contact_person` VARCHAR(100) DEFAULT NULL COMMENT '联系人',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `contact_email` VARCHAR(100) DEFAULT NULL COMMENT '联系邮箱',
  `address` VARCHAR(500) DEFAULT NULL COMMENT '地址',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`supplier_id`),
  INDEX `idx_supplier_code` (`supplier_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商表';

-- 创建仓库表
CREATE TABLE IF NOT EXISTS `warehouse` (
  `warehouse_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `warehouse_code` VARCHAR(50) NOT NULL UNIQUE COMMENT '仓库编码',
  `warehouse_name` VARCHAR(200) NOT NULL COMMENT '仓库名称',
  `warehouse_type` VARCHAR(50) DEFAULT 'LAB' COMMENT '仓库类型',
  `location` VARCHAR(500) DEFAULT NULL COMMENT '仓库位置',
  `manager_id` BIGINT DEFAULT NULL COMMENT '管理员ID',
  `manager_name` VARCHAR(100) DEFAULT NULL COMMENT '管理员姓名',
  `capacity` INT DEFAULT NULL COMMENT '仓库容量',
  `current_stock` INT DEFAULT 0 COMMENT '当前库存量',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`warehouse_id`),
  INDEX `idx_warehouse_code` (`warehouse_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仓库表';

-- 创建入库单表
CREATE TABLE IF NOT EXISTS `inbound_order` (
  `order_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '入库单ID',
  `order_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '入库单号',
  `order_type` VARCHAR(50) NOT NULL DEFAULT 'PURCHASE' COMMENT '入库类型',
  `supplier_id` BIGINT DEFAULT NULL COMMENT '供应商ID',
  `supplier_name` VARCHAR(200) DEFAULT NULL COMMENT '供应商名称',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` VARCHAR(200) DEFAULT NULL COMMENT '仓库名称',
  `total_amount` DECIMAL(12,2) DEFAULT 0.00 COMMENT '总金额',
  `total_quantity` INT DEFAULT 0 COMMENT '总数量',
  `status` VARCHAR(50) NOT NULL DEFAULT 'DRAFT' COMMENT '状态',
  `operator_id` BIGINT NOT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(100) NOT NULL COMMENT '操作人姓名',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(100) DEFAULT NULL COMMENT '审核人姓名',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `arrival_date` DATE DEFAULT NULL COMMENT '预计到货日期',
  `actual_arrival_date` DATE DEFAULT NULL COMMENT '实际到货日期',
  `invoice_no` VARCHAR(100) DEFAULT NULL COMMENT '发票号',
  `contract_no` VARCHAR(100) DEFAULT NULL COMMENT '合同号',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-否，1-是',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  INDEX `idx_order_type` (`order_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库单表';

-- 创建入库单明细表
CREATE TABLE IF NOT EXISTS `inbound_order_detail` (
  `detail_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` BIGINT NOT NULL COMMENT '入库单ID',
  `item_id` BIGINT DEFAULT NULL COMMENT '物品ID',
  `item_code` VARCHAR(50) DEFAULT NULL COMMENT '物品编码',
  `item_name` VARCHAR(200) NOT NULL COMMENT '物品名称',
  `specification` VARCHAR(200) DEFAULT NULL COMMENT '规格型号',
  `unit` VARCHAR(20) DEFAULT NULL COMMENT '单位',
  `quantity` INT NOT NULL COMMENT '入库数量',
  `unit_price` DECIMAL(10,2) DEFAULT 0.00 COMMENT '单价',
  `total_price` DECIMAL(12,2) DEFAULT 0.00 COMMENT '总价',
  `batch_no` VARCHAR(100) DEFAULT NULL COMMENT '批次号',
  `production_date` DATE DEFAULT NULL COMMENT '生产日期',
  `expiry_date` DATE DEFAULT NULL COMMENT '有效期',
  `quality_status` VARCHAR(50) DEFAULT 'QUALIFIED' COMMENT '质量状态',
  `location` VARCHAR(200) DEFAULT NULL COMMENT '存放位置',
  `remark` TEXT DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`detail_id`),
  INDEX `idx_order_id` (`order_id`),
  INDEX `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库单明细表';

-- 插入测试数据
INSERT INTO `supplier` (`supplier_code`, `supplier_name`, `contact_person`, `contact_phone`, `status`) VALUES
('SUP001', 'Scientific Instruments Co', 'Manager Zhang', '13800138001', 1),
('SUP002', 'Lab Equipment Factory', 'Manager Li', '13800138002', 1),
('SUP003', 'Chemical Reagent Company', 'Manager Wang', '13800138003', 1);

INSERT INTO `warehouse` (`warehouse_code`, `warehouse_name`, `warehouse_type`, `location`, `status`) VALUES
('WH001', 'Main Warehouse', 'MAIN', 'Lab Building 1F', 1),
('WH002', 'Chemistry Lab Warehouse', 'LAB', 'Lab Building 2F', 1),
('WH003', 'Biology Lab Warehouse', 'LAB', 'Lab Building 3F', 1);

INSERT INTO `inbound_order` (`order_no`, `order_type`, `supplier_id`, `supplier_name`, `warehouse_id`, `warehouse_name`, `total_amount`, `total_quantity`, `status`, `operator_id`, `operator_name`, `arrival_date`) VALUES
('IN20230320001', 'PURCHASE', 1, 'Scientific Instruments Co', 1, 'Main Warehouse', 15000.00, 10, 'DRAFT', 2, 'Admin', '2023-03-25'),
('IN20230320002', 'PURCHASE', 2, 'Lab Equipment Factory', 2, 'Chemistry Lab Warehouse', 25000.00, 5, 'APPROVED', 2, 'Admin', '2023-03-28');

INSERT INTO `inbound_order_detail` (`order_id`, `item_id`, `item_code`, `item_name`, `specification`, `unit`, `quantity`, `unit_price`, `total_price`, `batch_no`, `quality_status`, `location`) VALUES
(1, NULL, 'ITEM001', 'Microscope', 'BX53', 'unit', 10, 1500.00, 15000.00, 'BATCH001', 'QUALIFIED', 'Area A'),
(2, NULL, 'ITEM002', 'Centrifuge', 'TGL-16G', 'unit', 5, 5000.00, 25000.00, 'BATCH002', 'QUALIFIED', 'Area B');

package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 入库单实体类
 */
@Data
@TableName("inbound_order")
@Schema(description = "入库单")
public class InboundOrder implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "order_id", type = IdType.AUTO)
    @Schema(description = "入库单ID")
    private Long orderId;

    @Schema(description = "入库单号")
    private String orderNo;

    @Schema(description = "入库类型")
    private String orderType;

    @Schema(description = "供应商ID")
    private Long supplierId;

    @Schema(description = "供应商名称")
    private String supplierName;

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "总金额")
    private BigDecimal totalAmount;

    @Schema(description = "总数量")
    private Integer totalQuantity;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "操作人ID")
    private Long operatorId;

    @Schema(description = "操作人姓名")
    private String operatorName;

    @Schema(description = "审核人ID")
    private Long approverId;

    @Schema(description = "审核人姓名")
    private String approverName;

    @Schema(description = "审核时间")
    private LocalDateTime approveTime;

    @Schema(description = "预计到货日期")
    private LocalDate arrivalDate;

    @Schema(description = "实际到货日期")
    private LocalDate actualArrivalDate;

    @Schema(description = "发票号")
    private String invoiceNo;

    @Schema(description = "合同号")
    private String contractNo;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableLogic
    @Schema(description = "是否删除")
    private Boolean deleted;
}

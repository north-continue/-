package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 入库单明细实体类
 */
@Data
@TableName("inbound_order_detail")
@Schema(description = "入库单明细")
public class InboundOrderDetail implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "detail_id", type = IdType.AUTO)
    @Schema(description = "明细ID")
    private Long detailId;

    @Schema(description = "入库单ID")
    private Long orderId;

    @Schema(description = "物品ID")
    private Long itemId;

    @Schema(description = "物品编码")
    private String itemCode;

    @Schema(description = "物品名称")
    private String itemName;

    @Schema(description = "规格型号")
    private String specification;

    @Schema(description = "单位")
    private String unit;

    @Schema(description = "入库数量")
    private Integer quantity;

    @Schema(description = "单价")
    private BigDecimal unitPrice;

    @Schema(description = "总价")
    private BigDecimal totalPrice;

    @Schema(description = "批次号")
    private String batchNo;

    @Schema(description = "生产日期")
    private LocalDate productionDate;

    @Schema(description = "有效期")
    private LocalDate expiryDate;

    @Schema(description = "质量状态")
    private String qualityStatus;

    @Schema(description = "存放位置")
    private String location;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

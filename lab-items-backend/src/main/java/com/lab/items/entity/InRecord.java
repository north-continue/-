package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 入库记录实体类
 */
@Data
@TableName("in_record")
@Schema(description = "入库记录")
public class InRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "record_id", type = IdType.AUTO)
    @Schema(description = "记录 ID")
    private Long recordId;

    @Schema(description = "入库单号")
    private String inNo;

    @Schema(description = "物品 ID")
    private Long itemId;

    @Schema(description = "入库数量")
    private Integer quantity;

    @Schema(description = "入库类型：PURCHASE, RETURN, TRANSFER, OTHER")
    private String inType;

    @Schema(description = "供应商")
    private String supplier;

    @Schema(description = "发票号")
    private String invoiceNo;

    @Schema(description = "操作人 ID")
    private Long operatorId;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}

package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 出库记录实体类
 */
@Data
@TableName("out_record")
@Schema(description = "出库记录")
public class OutRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "record_id", type = IdType.AUTO)
    @Schema(description = "记录 ID")
    private Long recordId;

    @Schema(description = "出库单号")
    private String outNo;

    @Schema(description = "物品 ID")
    private Long itemId;

    @Schema(description = "出库数量")
    private Integer quantity;

    @Schema(description = "出库类型：BORROW, USE, TRANSFER, OTHER")
    private String outType;

    @Schema(description = "领用人 ID")
    private Long receiverId;

    @Schema(description = "操作人 ID")
    private Long operatorId;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
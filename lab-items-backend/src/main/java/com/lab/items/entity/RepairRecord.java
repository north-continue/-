package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 报废报修实体类
 */
@Data
@TableName("repair_record")
@Schema(description = "报废报修记录")
public class RepairRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "record_id", type = IdType.AUTO)
    @Schema(description = "记录 ID")
    private Long recordId;

    @Schema(description = "记录单号")
    private String recordNo;

    @Schema(description = "物品 ID")
    private Long itemId;

    @Schema(description = "类型：REPAIR, SCRAP")
    private String type;

    @Schema(description = "原因")
    private String reason;

    @Schema(description = "报告人 ID")
    private Long reporterId;

    @Schema(description = "处理人 ID")
    private Long handlerId;

    @Schema(description = "状态：PENDING, PROCESSING, COMPLETED, REJECTED")
    private String status;

    @Schema(description = "处理结果")
    private String handleResult;

    @Schema(description = "处理时间")
    private LocalDateTime handleTime;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
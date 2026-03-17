package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 借用记录实体类
 */
@Data
@TableName("borrow_record")
@Schema(description = "借用记录")
public class BorrowRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "record_id", type = IdType.AUTO)
    @Schema(description = "记录 ID")
    private Long recordId;

    @Schema(description = "借用单号")
    private String borrowNo;

    @Schema(description = "物品 ID")
    private Long itemId;

    @Schema(description = "借用数量")
    private Integer quantity;

    @Schema(description = "借用人 ID")
    private Long borrowerUserId;

    @Schema(description = "借用部门")
    private String borrowerDepartment;

    @Schema(description = "借用用途")
    private String borrowPurpose;

    @Schema(description = "预计归还日期")
    private LocalDate expectedReturnDate;

    @Schema(description = "实际归还日期")
    private LocalDate actualReturnDate;

    @Schema(description = "借用状态：PENDING, APPROVED, REJECTED, BORROWED, RETURNED, OVERDUE")
    private String borrowStatus;

    @Schema(description = "审批人 ID")
    private Long approverUserId;

    @Schema(description = "审批时间")
    private LocalDateTime approveTime;

    @Schema(description = "审批意见")
    private String approveRemark;

    @Schema(description = "是否已发送提醒：1-是，0-否")
    private Integer reminderSent;

    @Schema(description = "最后提醒时间")
    private LocalDateTime lastReminderTime;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

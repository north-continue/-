package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 仓库实体类
 */
@Data
@TableName("warehouse")
@Schema(description = "仓库")
public class Warehouse implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "warehouse_id", type = IdType.AUTO)
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "仓库编码")
    private String warehouseCode;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "仓库类型")
    private String warehouseType;

    @Schema(description = "仓库位置")
    private String location;

    @Schema(description = "管理员ID")
    private Long managerId;

    @Schema(description = "管理员姓名")
    private String managerName;

    @Schema(description = "仓库容量")
    private Integer capacity;

    @Schema(description = "当前库存量")
    private Integer currentStock;

    @Schema(description = "状态")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

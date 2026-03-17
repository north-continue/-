package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 物品实体类
 */
@Data
@TableName("item")
@Schema(description = "物品信息")
public class Item implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "item_id", type = IdType.AUTO)
    @Schema(description = "物品 ID")
    private Long itemId;

    @Schema(description = "物品编号")
    private String itemCode;

    @Schema(description = "二维码内容")
    private String qrCode;

    @Schema(description = "物品名称")
    private String itemName;

    @Schema(description = "类别 ID")
    private Long categoryId;

    @Schema(description = "规格型号")
    private String specification;

    @Schema(description = "品牌")
    private String brand;

    @Schema(description = "单位")
    private String unit;

    @Schema(description = "单价")
    private BigDecimal price;

    @Schema(description = "购买日期")
    private LocalDate purchaseDate;

    @Schema(description = "供应商")
    private String supplier;

    @Schema(description = "存放位置")
    private String location;

    @Schema(description = "实验室房间号")
    private String labRoom;

    @Schema(description = "货架号")
    private String shelf;

    @Schema(description = "图片 URL")
    private String imageUrl;

    @Schema(description = "总数量")
    private Integer totalQuantity;

    @Schema(description = "可用数量")
    private Integer availableQuantity;

    @Schema(description = "借出数量")
    private Integer borrowedQuantity;

    @Schema(description = "最低库存预警值")
    private Integer minStock;

    @Schema(description = "最高库存预警值")
    private Integer maxStock;

    @Schema(description = "物品状态：AVAILABLE, BORROWED, REPAIRING, SCRAPPED, LOST")
    private String status;

    @Schema(description = "保修期 (月)")
    private Integer warrantyPeriod;

    @Schema(description = "保修到期日期")
    private LocalDate warrantyExpiry;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人 ID")
    private Long createUserId;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

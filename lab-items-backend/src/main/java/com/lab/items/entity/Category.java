package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 物品类别实体类
 */
@Data
@TableName("category")
@Schema(description = "物品类别")
public class Category implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "category_id", type = IdType.AUTO)
    @Schema(description = "类别 ID")
    private Long categoryId;

    @Schema(description = "类别名称")
    private String categoryName;

    @Schema(description = "父类别 ID")
    private Long parentId;

    @Schema(description = "层级")
    private Integer level;

    @Schema(description = "排序")
    private Integer sortOrder;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "状态：1-启用，0-禁用")
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}

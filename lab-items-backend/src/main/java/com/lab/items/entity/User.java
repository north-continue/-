package com.lab.items.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
@TableName("user")
@Schema(description = "用户信息")
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "user_id", type = IdType.AUTO)
    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "密码 (加密)")
    private String password;

    @Schema(description = "真实姓名")
    private String realName;

    @Schema(description = "邮箱")
    private String email;

    @Schema(description = "手机号")
    private String phone;

    @Schema(description = "角色：ADMIN, LAB_ADMIN, TEACHER, STUDENT")
    private String role;

    @Schema(description = "所属部门/学院")
    private String department;

    @Schema(description = "状态：1-启用，0-禁用")
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "最后登录时间")
    private LocalDateTime lastLoginTime;
}

package com.lab.items.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.InRecord;
import com.lab.items.repository.InRecordRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

/**
 * 入库记录控制器
 */
@RestController
@RequestMapping("/in-records")
@Tag(name = "入库记录", description = "入库记录相关接口")
public class InRecordController {

    private final InRecordRepository inRecordRepository;

    public InRecordController(InRecordRepository inRecordRepository) {
        this.inRecordRepository = inRecordRepository;
    }

    @GetMapping
    @Operation(summary = "分页查询入库记录")
    public R<IPage<InRecord>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String inNo,
            @RequestParam(required = false) Long itemId) {
        
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<InRecord> page =
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        
        LambdaQueryWrapper<InRecord> queryWrapper = new LambdaQueryWrapper<>();
        
        if (inNo != null && !inNo.isEmpty()) {
            queryWrapper.like(InRecord::getInNo, inNo);
        }
        if (itemId != null) {
            queryWrapper.eq(InRecord::getItemId, itemId);
        }
        
        queryWrapper.orderByDesc(InRecord::getCreateTime);
        
        return R.ok(inRecordRepository.selectPage(page, queryWrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID查询入库记录")
    public R<InRecord> getById(@PathVariable Long id) {
        return R.ok(inRecordRepository.selectById(id));
    }
}

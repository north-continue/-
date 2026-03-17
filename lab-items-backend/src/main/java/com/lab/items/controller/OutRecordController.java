package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.OutRecord;
import com.lab.items.service.OutRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 出库记录控制器
 */
@RestController
@RequestMapping("/out-records")
@Tag(name = "出库管理", description = "出库记录相关接口")
public class OutRecordController {

    private final OutRecordService outRecordService;

    public OutRecordController(OutRecordService outRecordService) {
        this.outRecordService = outRecordService;
    }

    @GetMapping
    @Operation(summary = "分页查询出库记录")
    public R<IPage<OutRecord>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String outNo,
            @RequestParam(required = false) Long itemId) {
        IPage<OutRecord> page = outRecordService.getPageList(pageNum, pageSize, outNo, itemId);
        return R.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询出库记录")
    public R<OutRecord> getById(@PathVariable Long id) {
        OutRecord record = outRecordService.getById(id);
        return R.ok(record);
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "创建出库记录")
    public R<OutRecord> create(@RequestBody OutRecord outRecord) {
        OutRecord created = outRecordService.create(outRecord);
        return R.ok(created);
    }

    @GetMapping("/all")
    @Operation(summary = "查询所有出库记录")
    public R<List<OutRecord>> listAll() {
        List<OutRecord> list = outRecordService.listAll();
        return R.ok(list);
    }
}
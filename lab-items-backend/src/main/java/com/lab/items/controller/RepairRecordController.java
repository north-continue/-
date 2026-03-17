package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.RepairRecord;
import com.lab.items.service.RepairRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 报废报修控制器
 */
@RestController
@RequestMapping("/repair-records")
@Tag(name = "报废报修", description = "报废报修相关接口")
public class RepairRecordController {

    private final RepairRecordService repairRecordService;

    public RepairRecordController(RepairRecordService repairRecordService) {
        this.repairRecordService = repairRecordService;
    }

    @GetMapping
    @Operation(summary = "分页查询报废报修记录")
    public R<IPage<RepairRecord>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String recordNo,
            @RequestParam(required = false) Long itemId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String status) {
        IPage<RepairRecord> page = repairRecordService.getPageList(pageNum, pageSize, recordNo, itemId, type, status);
        return R.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询报废报修记录")
    public R<RepairRecord> getById(@PathVariable Long id) {
        RepairRecord record = repairRecordService.getById(id);
        return R.ok(record);
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN', 'TEACHER')")
    @Operation(summary = "创建报废报修记录")
    public R<RepairRecord> create(@RequestBody RepairRecord repairRecord) {
        RepairRecord created = repairRecordService.create(repairRecord);
        return R.ok(created);
    }

    @PutMapping("/{id}/handle")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "处理报废报修")
    public R<RepairRecord> handle(@PathVariable Long id, @RequestBody Map<String, Object> params) {
        Long handlerId = Long.valueOf(params.get("handlerId").toString());
        String handleResult = params.get("handleResult").toString();
        String status = params.get("status").toString();
        RepairRecord handled = repairRecordService.handle(id, handlerId, handleResult, status);
        return R.ok(handled);
    }

    @GetMapping("/all")
    @Operation(summary = "查询所有报废报修记录")
    public R<List<RepairRecord>> listAll() {
        List<RepairRecord> list = repairRecordService.listAll();
        return R.ok(list);
    }
}
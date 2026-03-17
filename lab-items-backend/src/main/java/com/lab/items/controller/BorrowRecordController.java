package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.BorrowRecord;
import com.lab.items.service.BorrowRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 借用记录控制器
 */
@RestController
@RequestMapping("/borrow-records")
@Tag(name = "借用管理", description = "借用记录相关接口")
public class BorrowRecordController {

    private final BorrowRecordService borrowRecordService;

    public BorrowRecordController(BorrowRecordService borrowRecordService) {
        this.borrowRecordService = borrowRecordService;
    }

    @GetMapping
    @Operation(summary = "分页查询借用记录")
    public R<IPage<BorrowRecord>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String borrowNo,
            @RequestParam(required = false) Long itemId,
            @RequestParam(required = false) Long borrowerId,
            @RequestParam(required = false) String status) {
        IPage<BorrowRecord> page = borrowRecordService.getPageList(pageNum, pageSize, borrowNo, itemId, borrowerId, status);
        return R.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询借用记录")
    public R<BorrowRecord> getById(@PathVariable Long id) {
        BorrowRecord record = borrowRecordService.getById(id);
        return R.ok(record);
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN', 'TEACHER')")
    @Operation(summary = "创建借用记录")
    public R<BorrowRecord> create(@RequestBody BorrowRecord borrowRecord) {
        BorrowRecord created = borrowRecordService.create(borrowRecord);
        return R.ok(created);
    }

    @PutMapping("/{id}/return")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "归还物品")
    public R<BorrowRecord> returnItem(@PathVariable Long id) {
        BorrowRecord returned = borrowRecordService.returnItem(id);
        return R.ok(returned);
    }

    @GetMapping("/all")
    @Operation(summary = "查询所有借用记录")
    public R<List<BorrowRecord>> listAll() {
        List<BorrowRecord> list = borrowRecordService.listAll();
        return R.ok(list);
    }
}
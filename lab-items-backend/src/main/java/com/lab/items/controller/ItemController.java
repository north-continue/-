package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.Item;
import com.lab.items.service.ItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 物品控制器
 */
@RestController
@RequestMapping("/items")
@Tag(name = "物品管理", description = "物品 CRUD 相关接口")
public class ItemController {

    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping
    @Operation(summary = "分页查询物品列表")
    public R<IPage<Item>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String itemName,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String status) {
        IPage<Item> page = itemService.getPageList(pageNum, pageSize, itemName, categoryId, status);
        return R.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询物品详情")
    public R<Item> getById(@PathVariable Long id) {
        Item item = itemService.getById(id);
        return R.ok(item);
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "创建物品")
    public R<Item> create(@RequestBody Item item) {
        Item created = itemService.create(item);
        return R.ok(created);
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "更新物品")
    public R<Item> update(@RequestBody Item item) {
        Item updated = itemService.update(item);
        return R.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "删除物品")
    public R<Void> delete(@PathVariable Long id) {
        itemService.delete(id);
        return R.ok();
    }

    @GetMapping("/qr/{qrCode}")
    @Operation(summary = "扫码获取物品信息")
    public R<Item> getByQrCode(@PathVariable String qrCode) {
        Item item = itemService.getByQrCode(qrCode);
        return R.ok(item);
    }

    @PostMapping("/batch")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "批量导入物品")
    public R<Boolean> batchInsert(@RequestBody List<Item> items) {
        boolean result = itemService.batchInsert(items);
        return R.ok(result);
    }
}

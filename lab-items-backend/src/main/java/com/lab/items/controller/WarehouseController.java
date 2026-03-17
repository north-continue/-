package com.lab.items.controller;

import com.lab.items.dto.R;
import com.lab.items.entity.Warehouse;
import com.lab.items.repository.WarehouseRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 仓库控制器
 */
@RestController
@RequestMapping("/warehouses")
@Tag(name = "仓库管理", description = "仓库相关接口")
public class WarehouseController {

    private final WarehouseRepository warehouseRepository;

    public WarehouseController(WarehouseRepository warehouseRepository) {
        this.warehouseRepository = warehouseRepository;
    }

    @GetMapping
    @Operation(summary = "查询所有仓库")
    public R<List<Warehouse>> listAll() {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Warehouse> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        queryWrapper.eq(Warehouse::getStatus, 1);
        queryWrapper.orderByAsc(Warehouse::getWarehouseName);
        return R.ok(warehouseRepository.selectList(queryWrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID查询仓库")
    public R<Warehouse> getById(@PathVariable Long id) {
        return R.ok(warehouseRepository.selectById(id));
    }

    @PostMapping
    @Operation(summary = "创建仓库")
    public R<Warehouse> create(@RequestBody Warehouse warehouse) {
        warehouseRepository.insert(warehouse);
        return R.ok(warehouse);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新仓库")
    public R<Void> update(@PathVariable Long id, @RequestBody Warehouse warehouse) {
        warehouse.setWarehouseId(id);
        warehouseRepository.updateById(warehouse);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除仓库")
    public R<Void> delete(@PathVariable Long id) {
        warehouseRepository.deleteById(id);
        return R.ok();
    }
}

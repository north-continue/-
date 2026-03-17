package com.lab.items.controller;

import com.lab.items.dto.R;
import com.lab.items.entity.Supplier;
import com.lab.items.repository.SupplierRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 供应商控制器
 */
@RestController
@RequestMapping("/suppliers")
@Tag(name = "供应商管理", description = "供应商相关接口")
public class SupplierController {

    private final SupplierRepository supplierRepository;

    public SupplierController(SupplierRepository supplierRepository) {
        this.supplierRepository = supplierRepository;
    }

    @GetMapping
    @Operation(summary = "查询所有供应商")
    public R<List<Supplier>> listAll() {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Supplier> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        queryWrapper.eq(Supplier::getStatus, 1);
        queryWrapper.orderByAsc(Supplier::getSupplierName);
        return R.ok(supplierRepository.selectList(queryWrapper));
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID查询供应商")
    public R<Supplier> getById(@PathVariable Long id) {
        return R.ok(supplierRepository.selectById(id));
    }

    @PostMapping
    @Operation(summary = "创建供应商")
    public R<Supplier> create(@RequestBody Supplier supplier) {
        supplierRepository.insert(supplier);
        return R.ok(supplier);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新供应商")
    public R<Void> update(@PathVariable Long id, @RequestBody Supplier supplier) {
        supplier.setSupplierId(id);
        supplierRepository.updateById(supplier);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除供应商")
    public R<Void> delete(@PathVariable Long id) {
        supplierRepository.deleteById(id);
        return R.ok();
    }
}

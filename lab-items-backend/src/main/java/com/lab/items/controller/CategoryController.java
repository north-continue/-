package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.Category;
import com.lab.items.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 类别控制器
 */
@RestController
@RequestMapping("/categories")
@Tag(name = "类别管理", description = "物品类别相关接口")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    @Operation(summary = "分页查询类别列表")
    public R<IPage<Category>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String categoryName) {
        IPage<Category> page = categoryService.getPageList(pageNum, pageSize, categoryName);
        return R.ok(page);
    }

    @GetMapping("/all")
    @Operation(summary = "查询所有类别")
    public R<List<Category>> listAll() {
        List<Category> list = categoryService.listAll();
        return R.ok(list);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询类别详情")
    public R<Category> getById(@PathVariable Long id) {
        Category category = categoryService.getById(id);
        return R.ok(category);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "创建类别")
    public R<Boolean> create(@RequestBody Category category) {
        boolean result = categoryService.create(category);
        return R.ok(result);
    }

    @PutMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "更新类别")
    public R<Boolean> update(@RequestBody Category category) {
        boolean result = categoryService.update(category);
        return R.ok(result);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'LAB_ADMIN')")
    @Operation(summary = "删除类别")
    public R<Boolean> delete(@PathVariable Long id) {
        boolean result = categoryService.delete(id);
        return R.ok(result);
    }

    @GetMapping("/tree")
    @Operation(summary = "获取树形结构类别")
    public R<List<Category>> getTreeList() {
        List<Category> treeList = categoryService.getTreeList();
        return R.ok(treeList);
    }
}

package com.lab.items.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lab.items.entity.Category;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 类别服务类
 */
@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    /**
     * 分页查询类别列表
     */
    public IPage<Category> getPageList(Integer pageNum, Integer pageSize, String categoryName) {
        Page<Category> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        if (categoryName != null && !categoryName.isEmpty()) {
            wrapper.like(Category::getCategoryName, categoryName);
        }
        wrapper.orderByAsc(Category::getSortOrder);
        return categoryRepository.selectPage(page, wrapper);
    }

    /**
     * 查询所有类别（树形结构）
     */
    public List<Category> listAll() {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Category::getSortOrder);
        return categoryRepository.selectList(wrapper);
    }

    /**
     * 根据 ID 查询类别
     */
    public Category getById(Long id) {
        return categoryRepository.selectById(id);
    }

    /**
     * 创建类别
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean create(Category category) {
        // 如果是子类别，检查父类别是否存在
        if (category.getParentId() != null && category.getParentId() > 0) {
            Category parent = categoryRepository.selectById(category.getParentId());
            if (parent == null) {
                throw new IllegalArgumentException("父类别不存在");
            }
            category.setLevel(parent.getLevel() + 1);
        } else {
            category.setParentId(0L);
            category.setLevel(1);
        }
        
        return categoryRepository.insert(category) > 0;
    }

    /**
     * 更新类别
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean update(Category category) {
        return categoryRepository.updateById(category) > 0;
    }

    /**
     * 删除类别
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean delete(Long id) {
        // 检查是否有子类别
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Category::getParentId, id);
        Long count = categoryRepository.selectCount(wrapper);
        if (count > 0) {
            throw new IllegalArgumentException("该类别下存在子类别，无法删除");
        }
        
        return categoryRepository.deleteById(id) > 0;
    }

    /**
     * 获取类别树形结构
     */
    public List<Category> getTreeList() {
        List<Category> allCategories = listAll();
        // TODO: 构建树形结构
        return allCategories;
    }
}

package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

/**
 * 类别数据访问接口
 */
@Mapper
@Repository
public interface CategoryRepository extends BaseMapper<Category> {
    
}

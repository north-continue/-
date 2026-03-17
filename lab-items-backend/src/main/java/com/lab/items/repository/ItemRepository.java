package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lab.items.entity.Item;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

/**
 * 物品数据访问接口
 */
@Mapper
@Repository
public interface ItemRepository extends BaseMapper<Item> {
    
    /**
     * 分页查询物品列表
     */
    IPage<Item> selectItemPage(Page<Item> page, @Param("itemName") String itemName, 
                               @Param("categoryId") Long categoryId, 
                               @Param("status") String status);
}

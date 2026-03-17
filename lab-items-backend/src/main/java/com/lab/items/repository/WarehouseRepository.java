package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.Warehouse;
import org.apache.ibatis.annotations.Mapper;

/**
 * 仓库仓储接口
 */
@Mapper
public interface WarehouseRepository extends BaseMapper<Warehouse> {
}

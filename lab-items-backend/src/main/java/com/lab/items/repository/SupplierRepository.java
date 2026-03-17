package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.Supplier;
import org.apache.ibatis.annotations.Mapper;

/**
 * 供应商仓储接口
 */
@Mapper
public interface SupplierRepository extends BaseMapper<Supplier> {
}

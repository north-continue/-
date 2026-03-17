package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.InboundOrder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 入库单仓储接口
 */
@Mapper
public interface InboundOrderRepository extends BaseMapper<InboundOrder> {
}

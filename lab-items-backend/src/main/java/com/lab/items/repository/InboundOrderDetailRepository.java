package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.InboundOrderDetail;
import org.apache.ibatis.annotations.Mapper;

/**
 * 入库单明细仓储接口
 */
@Mapper
public interface InboundOrderDetailRepository extends BaseMapper<InboundOrderDetail> {
}

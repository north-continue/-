package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.InRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 入库记录 Mapper
 */
@Mapper
public interface InRecordRepository extends BaseMapper<InRecord> {
}

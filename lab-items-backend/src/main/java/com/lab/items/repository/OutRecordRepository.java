package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.OutRecord;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

/**
 * 出库记录数据访问接口
 */
@Mapper
@Repository
public interface OutRecordRepository extends BaseMapper<OutRecord> {
}
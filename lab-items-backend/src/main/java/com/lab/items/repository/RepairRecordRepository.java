package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.RepairRecord;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

/**
 * 报废报修数据访问接口
 */
@Mapper
@Repository
public interface RepairRecordRepository extends BaseMapper<RepairRecord> {
}
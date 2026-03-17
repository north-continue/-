package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.BorrowRecord;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

/**
 * 借用记录数据访问接口
 */
@Mapper
@Repository
public interface BorrowRecordRepository extends BaseMapper<BorrowRecord> {
}
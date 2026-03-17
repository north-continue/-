package com.lab.items.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.entity.BorrowRecord;
import com.lab.items.repository.BorrowRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 借用记录服务类
 */
@Service
public class BorrowRecordService {

    private final BorrowRecordRepository borrowRecordRepository;

    public BorrowRecordService(BorrowRecordRepository borrowRecordRepository) {
        this.borrowRecordRepository = borrowRecordRepository;
    }

    /**
     * 创建借用记录
     */
    @Transactional
    public BorrowRecord create(BorrowRecord borrowRecord) {
        // 生成借用单号
        String borrowNo = "BORROW" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        borrowRecord.setBorrowNo(borrowNo);
        borrowRecord.setBorrowStatus("PENDING");
        
        // 保存借用记录
        borrowRecordRepository.insert(borrowRecord);
        
        return borrowRecord;
    }

    /**
     * 归还物品
     */
    @Transactional
    public BorrowRecord returnItem(Long recordId) {
        BorrowRecord record = borrowRecordRepository.selectById(recordId);
        if (record != null) {
            record.setBorrowStatus("RETURNED");
            record.setActualReturnDate(java.time.LocalDate.now());
            borrowRecordRepository.updateById(record);
        }
        return record;
    }

    /**
     * 分页查询借用记录
     */
    public IPage<BorrowRecord> getPageList(Integer pageNum, Integer pageSize, String borrowNo, Long itemId, Long borrowerId, String status) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<BorrowRecord> page = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BorrowRecord> queryWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        
        if (borrowNo != null && !borrowNo.isEmpty()) {
            queryWrapper.eq(BorrowRecord::getBorrowNo, borrowNo);
        }
        if (itemId != null) {
            queryWrapper.eq(BorrowRecord::getItemId, itemId);
        }
        if (borrowerId != null) {
            queryWrapper.eq(BorrowRecord::getBorrowerUserId, borrowerId);
        }
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq(BorrowRecord::getBorrowStatus, status);
        }
        
        queryWrapper.orderByDesc(BorrowRecord::getCreateTime);
        
        return borrowRecordRepository.selectPage(page, queryWrapper);
    }

    /**
     * 根据ID查询借用记录
     */
    public BorrowRecord getById(Long id) {
        return borrowRecordRepository.selectById(id);
    }

    /**
     * 查询所有借用记录
     */
    public List<BorrowRecord> listAll() {
        return borrowRecordRepository.selectList(null);
    }
}
package com.lab.items.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.entity.RepairRecord;
import com.lab.items.repository.RepairRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 报废报修服务类
 */
@Service
public class RepairRecordService {

    private final RepairRecordRepository repairRecordRepository;

    public RepairRecordService(RepairRecordRepository repairRecordRepository) {
        this.repairRecordRepository = repairRecordRepository;
    }

    /**
     * 创建报废报修记录
     */
    @Transactional
    public RepairRecord create(RepairRecord repairRecord) {
        // 生成记录单号
        String recordNo = "REPAIR" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        repairRecord.setRecordNo(recordNo);
        repairRecord.setStatus("PENDING");
        
        // 保存记录
        repairRecordRepository.insert(repairRecord);
        
        return repairRecord;
    }

    /**
     * 处理报废报修
     */
    @Transactional
    public RepairRecord handle(Long recordId, Long handlerId, String handleResult, String status) {
        RepairRecord record = repairRecordRepository.selectById(recordId);
        if (record != null) {
            record.setHandlerId(handlerId);
            record.setHandleResult(handleResult);
            record.setStatus(status);
            record.setHandleTime(LocalDateTime.now());
            repairRecordRepository.updateById(record);
        }
        return record;
    }

    /**
     * 分页查询报废报修记录
     */
    public IPage<RepairRecord> getPageList(Integer pageNum, Integer pageSize, String recordNo, Long itemId, String type, String status) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<RepairRecord> page = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<RepairRecord> queryWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        
        if (recordNo != null && !recordNo.isEmpty()) {
            queryWrapper.eq(RepairRecord::getRecordNo, recordNo);
        }
        if (itemId != null) {
            queryWrapper.eq(RepairRecord::getItemId, itemId);
        }
        if (type != null && !type.isEmpty()) {
            queryWrapper.eq(RepairRecord::getType, type);
        }
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq(RepairRecord::getStatus, status);
        }
        
        queryWrapper.orderByDesc(RepairRecord::getCreateTime);
        
        return repairRecordRepository.selectPage(page, queryWrapper);
    }

    /**
     * 根据ID查询报废报修记录
     */
    public RepairRecord getById(Long id) {
        return repairRecordRepository.selectById(id);
    }

    /**
     * 查询所有报废报修记录
     */
    public List<RepairRecord> listAll() {
        return repairRecordRepository.selectList(null);
    }
}
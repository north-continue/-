package com.lab.items.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.entity.OutRecord;
import com.lab.items.repository.OutRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 出库记录服务类
 */
@Service
public class OutRecordService {

    private final OutRecordRepository outRecordRepository;

    public OutRecordService(OutRecordRepository outRecordRepository) {
        this.outRecordRepository = outRecordRepository;
    }

    /**
     * 创建出库记录
     */
    @Transactional
    public OutRecord create(OutRecord outRecord) {
        // 生成出库单号
        String outNo = "OUT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        outRecord.setOutNo(outNo);
        
        // 保存出库记录
        outRecordRepository.insert(outRecord);
        
        return outRecord;
    }

    /**
     * 分页查询出库记录
     */
    public IPage<OutRecord> getPageList(Integer pageNum, Integer pageSize, String outNo, Long itemId) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<OutRecord> page = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OutRecord> queryWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        
        if (outNo != null && !outNo.isEmpty()) {
            queryWrapper.eq(OutRecord::getOutNo, outNo);
        }
        if (itemId != null) {
            queryWrapper.eq(OutRecord::getItemId, itemId);
        }
        
        queryWrapper.orderByDesc(OutRecord::getCreateTime);
        
        return outRecordRepository.selectPage(page, queryWrapper);
    }

    /**
     * 根据ID查询出库记录
     */
    public OutRecord getById(Long id) {
        return outRecordRepository.selectById(id);
    }

    /**
     * 查询所有出库记录
     */
    public List<OutRecord> listAll() {
        return outRecordRepository.selectList(null);
    }
}
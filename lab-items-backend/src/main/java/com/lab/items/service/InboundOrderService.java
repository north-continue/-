package com.lab.items.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.entity.InboundOrder;
import com.lab.items.entity.InboundOrderDetail;
import com.lab.items.repository.InboundOrderDetailRepository;
import com.lab.items.repository.InboundOrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 入库单服务类
 */
@Service
public class InboundOrderService {

    private final InboundOrderRepository inboundOrderRepository;
    private final InboundOrderDetailRepository inboundOrderDetailRepository;

    public InboundOrderService(InboundOrderRepository inboundOrderRepository,
                               InboundOrderDetailRepository inboundOrderDetailRepository) {
        this.inboundOrderRepository = inboundOrderRepository;
        this.inboundOrderDetailRepository = inboundOrderDetailRepository;
    }

    /**
     * 创建入库单
     */
    @Transactional
    public InboundOrder create(InboundOrder order, List<InboundOrderDetail> details) {
        // 生成入库单号
        String orderNo = "IN" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        order.setOrderNo(orderNo);

        // 设置默认状态
        if (order.getStatus() == null) {
            order.setStatus("DRAFT");
        }

        // 计算总数量和总金额
        int totalQuantity = 0;
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (InboundOrderDetail detail : details) {
            totalQuantity += detail.getQuantity();
            if (detail.getTotalPrice() != null) {
                totalAmount = totalAmount.add(detail.getTotalPrice());
            }
        }

        order.setTotalQuantity(totalQuantity);
        order.setTotalAmount(totalAmount);

        // 保存入库单
        inboundOrderRepository.insert(order);

        // 保存入库单明细
        for (InboundOrderDetail detail : details) {
            detail.setOrderId(order.getOrderId());
            inboundOrderDetailRepository.insert(detail);
        }

        return order;
    }

    /**
     * 分页查询入库单
     */
    public IPage<InboundOrder> getPageList(Integer pageNum, Integer pageSize, String orderNo,
                                           String status, Long supplierId, String orderType) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<InboundOrder> page =
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);

        LambdaQueryWrapper<InboundOrder> queryWrapper = new LambdaQueryWrapper<>();

        if (orderNo != null && !orderNo.isEmpty()) {
            queryWrapper.like(InboundOrder::getOrderNo, orderNo);
        }
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq(InboundOrder::getStatus, status);
        }
        if (supplierId != null) {
            queryWrapper.eq(InboundOrder::getSupplierId, supplierId);
        }
        if (orderType != null && !orderType.isEmpty()) {
            queryWrapper.eq(InboundOrder::getOrderType, orderType);
        }

        queryWrapper.orderByDesc(InboundOrder::getCreateTime);

        return inboundOrderRepository.selectPage(page, queryWrapper);
    }

    /**
     * 根据ID查询入库单
     */
    public InboundOrder getById(Long id) {
        return inboundOrderRepository.selectById(id);
    }

    /**
     * 查询入库单明细
     */
    public List<InboundOrderDetail> getDetailsByOrderId(Long orderId) {
        LambdaQueryWrapper<InboundOrderDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(InboundOrderDetail::getOrderId, orderId);
        return inboundOrderDetailRepository.selectList(queryWrapper);
    }

    /**
     * 更新入库单
     */
    @Transactional
    public void update(InboundOrder order, List<InboundOrderDetail> details) {
        // 更新入库单基本信息
        inboundOrderRepository.updateById(order);

        // 删除原有明细
        LambdaQueryWrapper<InboundOrderDetail> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(InboundOrderDetail::getOrderId, order.getOrderId());
        inboundOrderDetailRepository.delete(deleteWrapper);

        // 重新计算总数量和总金额
        int totalQuantity = 0;
        BigDecimal totalAmount = BigDecimal.ZERO;

        // 插入新的明细
        for (InboundOrderDetail detail : details) {
            detail.setOrderId(order.getOrderId());
            inboundOrderDetailRepository.insert(detail);
            totalQuantity += detail.getQuantity();
            if (detail.getTotalPrice() != null) {
                totalAmount = totalAmount.add(detail.getTotalPrice());
            }
        }

        // 更新入库单的汇总信息
        order.setTotalQuantity(totalQuantity);
        order.setTotalAmount(totalAmount);
        inboundOrderRepository.updateById(order);
    }

    /**
     * 删除入库单
     */
    @Transactional
    public void deleteById(Long id) {
        // 删除入库单明细
        LambdaQueryWrapper<InboundOrderDetail> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(InboundOrderDetail::getOrderId, id);
        inboundOrderDetailRepository.delete(deleteWrapper);

        // 删除入库单
        inboundOrderRepository.deleteById(id);
    }

    /**
     * 审核入库单
     */
    @Transactional
    public void approve(Long orderId, Long approverId, String approverName, boolean approved) {
        InboundOrder order = getById(orderId);
        if (order != null) {
            order.setApproverId(approverId);
            order.setApproverName(approverName);
            order.setApproveTime(LocalDateTime.now());
            order.setStatus(approved ? "APPROVED" : "REJECTED");
            inboundOrderRepository.updateById(order);
        }
    }

    /**
     * 完成入库单
     */
    @Transactional
    public void complete(Long orderId) {
        InboundOrder order = getById(orderId);
        if (order != null && "APPROVED".equals(order.getStatus())) {
            order.setStatus("COMPLETED");
            order.setActualArrivalDate(java.time.LocalDate.now());
            inboundOrderRepository.updateById(order);
        }
    }

    /**
     * 取消入库单
     */
    @Transactional
    public void cancel(Long orderId) {
        InboundOrder order = getById(orderId);
        if (order != null && ("DRAFT".equals(order.getStatus()) || "PENDING".equals(order.getStatus()))) {
            order.setStatus("CANCELLED");
            inboundOrderRepository.updateById(order);
        }
    }

    /**
     * 提交入库单审核
     */
    @Transactional
    public void submitForApproval(Long orderId) {
        InboundOrder order = getById(orderId);
        if (order != null && "DRAFT".equals(order.getStatus())) {
            order.setStatus("PENDING");
            inboundOrderRepository.updateById(order);
        }
    }
}

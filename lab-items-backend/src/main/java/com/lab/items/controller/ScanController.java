package com.lab.items.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.lab.items.dto.R;
import com.lab.items.entity.Item;
import com.lab.items.entity.InRecord;
import com.lab.items.entity.OutRecord;
import com.lab.items.repository.ItemRepository;
import com.lab.items.repository.InRecordRepository;
import com.lab.items.repository.OutRecordRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 扫码出入库控制器
 */
@RestController
@RequestMapping("/scan")
@Tag(name = "扫码管理", description = "扫码出入库相关接口")
public class ScanController {

    private final ItemRepository itemRepository;
    private final InRecordRepository inRecordRepository;
    private final OutRecordRepository outRecordRepository;

    public ScanController(ItemRepository itemRepository, 
                          InRecordRepository inRecordRepository,
                          OutRecordRepository outRecordRepository) {
        this.itemRepository = itemRepository;
        this.inRecordRepository = inRecordRepository;
        this.outRecordRepository = outRecordRepository;
    }

    /**
     * 扫码获取物品信息
     */
    @GetMapping("/item/{code}")
    @Operation(summary = "扫码获取物品信息")
    public R<Item> getItemByCode(@PathVariable String code) {
        LambdaQueryWrapper<Item> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Item::getItemCode, code)
                    .or()
                    .eq(Item::getQrCode, code);
        
        Item item = itemRepository.selectOne(queryWrapper);
        if (item == null) {
            return R.fail("未找到该物品，请检查编码是否正确");
        }
        return R.ok(item);
    }

    /**
     * 扫码入库
     */
    @PostMapping("/inbound")
    @Transactional
    @Operation(summary = "扫码入库")
    public R<InRecord> scanInbound(@RequestBody InRecordRequest request) {
        // 查找物品
        LambdaQueryWrapper<Item> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Item::getItemCode, request.getItemCode())
                    .or()
                    .eq(Item::getQrCode, request.getItemCode());
        
        Item item = itemRepository.selectOne(queryWrapper);
        if (item == null) {
            return R.fail("未找到该物品，请检查编码是否正确");
        }

        // 创建入库记录
        InRecord inRecord = new InRecord();
        inRecord.setItemId(item.getItemId());
        inRecord.setQuantity(request.getQuantity());
        inRecord.setInType(request.getInType() != null ? request.getInType() : "PURCHASE");
        inRecord.setSupplier(request.getSupplier());
        inRecord.setInvoiceNo(request.getInvoiceNo());
        inRecord.setOperatorId(request.getOperatorId());
        inRecord.setRemark(request.getRemark());
        
        // 生成入库单号
        String inNo = "IN" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) 
                     + String.format("%04d", (int)(Math.random() * 10000));
        inRecord.setInNo(inNo);
        
        // 保存入库记录
        inRecordRepository.insert(inRecord);

        // 更新物品库存
        LambdaUpdateWrapper<Item> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Item::getItemId, item.getItemId())
                     .set(Item::getTotalQuantity, item.getTotalQuantity() + request.getQuantity())
                     .set(Item::getAvailableQuantity, item.getAvailableQuantity() + request.getQuantity())
                     .set(Item::getStatus, "AVAILABLE");
        
        itemRepository.update(null, updateWrapper);

        return R.ok(inRecord);
    }

    /**
     * 扫码出库
     */
    @PostMapping("/outbound")
    @Transactional
    @Operation(summary = "扫码出库")
    public R<OutRecord> scanOutbound(@RequestBody OutRecordRequest request) {
        // 查找物品
        LambdaQueryWrapper<Item> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Item::getItemCode, request.getItemCode())
                    .or()
                    .eq(Item::getQrCode, request.getItemCode());
        
        Item item = itemRepository.selectOne(queryWrapper);
        if (item == null) {
            return R.fail("未找到该物品，请检查编码是否正确");
        }

        // 检查库存是否充足
        if (item.getAvailableQuantity() < request.getQuantity()) {
            return R.fail("库存不足，当前可用数量：" + item.getAvailableQuantity());
        }

        // 创建出库记录
        OutRecord outRecord = new OutRecord();
        outRecord.setItemId(item.getItemId());
        outRecord.setQuantity(request.getQuantity());
        outRecord.setOutType(request.getOutType() != null ? request.getOutType() : "USE");
        outRecord.setReceiverId(request.getReceiverId());
        outRecord.setOperatorId(request.getOperatorId());
        outRecord.setRemark(request.getRemark());
        
        // 生成出库单号
        String outNo = "OUT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) 
                      + String.format("%04d", (int)(Math.random() * 10000));
        outRecord.setOutNo(outNo);
        
        // 保存出库记录
        outRecordRepository.insert(outRecord);

        // 更新物品库存
        int newAvailableQty = item.getAvailableQuantity() - request.getQuantity();
        int newBorrowedQty = item.getBorrowedQuantity() + request.getQuantity();
        
        String newStatus = item.getStatus();
        if (newAvailableQty <= 0) {
            newStatus = "BORROWED";
        }

        LambdaUpdateWrapper<Item> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Item::getItemId, item.getItemId())
                     .set(Item::getAvailableQuantity, newAvailableQty)
                     .set(Item::getBorrowedQuantity, newBorrowedQty)
                     .set(Item::getStatus, newStatus);
        
        itemRepository.update(null, updateWrapper);

        return R.ok(outRecord);
    }

    /**
     * 快速扫码入库（简化版）
     */
    @PostMapping("/quick-inbound")
    @Transactional
    @Operation(summary = "快速扫码入库")
    public R<InRecord> quickScanInbound(
            @RequestParam String itemCode,
            @RequestParam Integer quantity,
            @RequestParam Long operatorId,
            @RequestParam(required = false) String supplier,
            @RequestParam(required = false) String remark) {
        
        // 查找物品
        LambdaQueryWrapper<Item> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Item::getItemCode, itemCode)
                    .or()
                    .eq(Item::getQrCode, itemCode);
        
        Item item = itemRepository.selectOne(queryWrapper);
        if (item == null) {
            return R.fail("未找到该物品");
        }

        // 创建入库记录
        InRecord inRecord = new InRecord();
        inRecord.setItemId(item.getItemId());
        inRecord.setQuantity(quantity);
        inRecord.setInType("PURCHASE");
        inRecord.setSupplier(supplier);
        inRecord.setOperatorId(operatorId);
        inRecord.setRemark(remark);
        
        String inNo = "IN" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) 
                     + String.format("%04d", (int)(Math.random() * 10000));
        inRecord.setInNo(inNo);
        
        inRecordRepository.insert(inRecord);

        // 更新库存
        LambdaUpdateWrapper<Item> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Item::getItemId, item.getItemId())
                     .set(Item::getTotalQuantity, item.getTotalQuantity() + quantity)
                     .set(Item::getAvailableQuantity, item.getAvailableQuantity() + quantity)
                     .set(Item::getStatus, "AVAILABLE");
        
        itemRepository.update(null, updateWrapper);

        return R.ok(inRecord);
    }

    /**
     * 快速扫码出库（简化版）
     */
    @PostMapping("/quick-outbound")
    @Transactional
    @Operation(summary = "快速扫码出库")
    public R<OutRecord> quickScanOutbound(
            @RequestParam String itemCode,
            @RequestParam Integer quantity,
            @RequestParam Long operatorId,
            @RequestParam(required = false) Long receiverId,
            @RequestParam(required = false) String remark) {
        
        // 查找物品
        LambdaQueryWrapper<Item> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Item::getItemCode, itemCode)
                    .or()
                    .eq(Item::getQrCode, itemCode);
        
        Item item = itemRepository.selectOne(queryWrapper);
        if (item == null) {
            return R.fail("未找到该物品");
        }

        if (item.getAvailableQuantity() < quantity) {
            return R.fail("库存不足，当前可用数量：" + item.getAvailableQuantity());
        }

        // 创建出库记录
        OutRecord outRecord = new OutRecord();
        outRecord.setItemId(item.getItemId());
        outRecord.setQuantity(quantity);
        outRecord.setOutType("USE");
        outRecord.setReceiverId(receiverId);
        outRecord.setOperatorId(operatorId);
        outRecord.setRemark(remark);
        
        String outNo = "OUT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) 
                      + String.format("%04d", (int)(Math.random() * 10000));
        outRecord.setOutNo(outNo);
        
        outRecordRepository.insert(outRecord);

        // 更新库存
        int newAvailableQty = item.getAvailableQuantity() - quantity;
        String newStatus = newAvailableQty <= 0 ? "BORROWED" : item.getStatus();

        LambdaUpdateWrapper<Item> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Item::getItemId, item.getItemId())
                     .set(Item::getAvailableQuantity, newAvailableQty)
                     .set(Item::getBorrowedQuantity, item.getBorrowedQuantity() + quantity)
                     .set(Item::getStatus, newStatus);
        
        itemRepository.update(null, updateWrapper);

        return R.ok(outRecord);
    }

    // 请求体类
    public static class InRecordRequest {
        private String itemCode;
        private Integer quantity;
        private String inType;
        private String supplier;
        private String invoiceNo;
        private Long operatorId;
        private String remark;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getInType() { return inType; }
        public void setInType(String inType) { this.inType = inType; }
        public String getSupplier() { return supplier; }
        public void setSupplier(String supplier) { this.supplier = supplier; }
        public String getInvoiceNo() { return invoiceNo; }
        public void setInvoiceNo(String invoiceNo) { this.invoiceNo = invoiceNo; }
        public Long getOperatorId() { return operatorId; }
        public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }

    public static class OutRecordRequest {
        private String itemCode;
        private Integer quantity;
        private String outType;
        private Long receiverId;
        private Long operatorId;
        private String remark;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getOutType() { return outType; }
        public void setOutType(String outType) { this.outType = outType; }
        public Long getReceiverId() { return receiverId; }
        public void setReceiverId(Long receiverId) { this.receiverId = receiverId; }
        public Long getOperatorId() { return operatorId; }
        public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }
}

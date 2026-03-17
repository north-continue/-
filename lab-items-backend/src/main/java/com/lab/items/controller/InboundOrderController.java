package com.lab.items.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lab.items.dto.R;
import com.lab.items.entity.InboundOrder;
import com.lab.items.entity.InboundOrderDetail;
import com.lab.items.service.InboundOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 入库单控制器
 */
@RestController
@RequestMapping("/inbound-orders")
@Tag(name = "入库管理", description = "入库单相关接口")
public class InboundOrderController {

    private final InboundOrderService inboundOrderService;

    public InboundOrderController(InboundOrderService inboundOrderService) {
        this.inboundOrderService = inboundOrderService;
    }

    @GetMapping
    @Operation(summary = "分页查询入库单")
    public R<IPage<InboundOrder>> getPageList(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long supplierId,
            @RequestParam(required = false) String orderType) {
        IPage<InboundOrder> page = inboundOrderService.getPageList(pageNum, pageSize, orderNo, status, supplierId, orderType);
        return R.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 查询入库单")
    public R<Map<String, Object>> getById(@PathVariable Long id) {
        InboundOrder order = inboundOrderService.getById(id);
        List<InboundOrderDetail> details = inboundOrderService.getDetailsByOrderId(id);
        return R.ok(Map.of("order", order, "details", details));
    }

    @PostMapping
    @Operation(summary = "创建入库单")
    public R<InboundOrder> create(@RequestBody Map<String, Object> request) {
        InboundOrder order = (InboundOrder) request.get("order");
        @SuppressWarnings("unchecked")
        List<InboundOrderDetail> details = (List<InboundOrderDetail>) request.get("details");

        InboundOrder created = inboundOrderService.create(order, details);
        return R.ok(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新入库单")
    public R<Void> update(@PathVariable Long id, @RequestBody Map<String, Object> request) {
        InboundOrder order = (InboundOrder) request.get("order");
        @SuppressWarnings("unchecked")
        List<InboundOrderDetail> details = (List<InboundOrderDetail>) request.get("details");

        order.setOrderId(id);
        inboundOrderService.update(order, details);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除入库单")
    public R<Void> delete(@PathVariable Long id) {
        inboundOrderService.deleteById(id);
        return R.ok();
    }

    @PostMapping("/{id}/approve")
    @Operation(summary = "审核入库单")
    public R<Void> approve(@PathVariable Long id, @RequestParam Long approverId,
                          @RequestParam String approverName, @RequestParam boolean approved) {
        inboundOrderService.approve(id, approverId, approverName, approved);
        return R.ok();
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "完成入库单")
    public R<Void> complete(@PathVariable Long id) {
        inboundOrderService.complete(id);
        return R.ok();
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "取消入库单")
    public R<Void> cancel(@PathVariable Long id) {
        inboundOrderService.cancel(id);
        return R.ok();
    }

    @PostMapping("/{id}/submit")
    @Operation(summary = "提交入库单审核")
    public R<Void> submitForApproval(@PathVariable Long id) {
        inboundOrderService.submitForApproval(id);
        return R.ok();
    }
}

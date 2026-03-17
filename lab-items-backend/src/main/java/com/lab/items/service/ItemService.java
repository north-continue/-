package com.lab.items.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lab.items.entity.Item;
import com.lab.items.repository.ItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 物品服务类
 */
@Service
public class ItemService {

    private final ItemRepository itemRepository;

    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    /**
     * 分页查询物品列表
     */
    public IPage<Item> getPageList(Integer pageNum, Integer pageSize, String itemName, 
                                   Long categoryId, String status) {
        Page<Item> page = new Page<>(pageNum, pageSize);
        return itemRepository.selectItemPage(page, itemName, categoryId, status);
    }

    /**
     * 根据 ID 查询物品详情
     */
    public Item getById(Long id) {
        return itemRepository.selectById(id);
    }

    /**
     * 创建物品
     */
    @Transactional(rollbackFor = Exception.class)
    public Item create(Item item) {
        // 生成物品编号
        String itemCode = generateItemCode();
        item.setItemCode(itemCode);
        
        // 初始化库存
        if (item.getAvailableQuantity() == null) {
            item.setAvailableQuantity(0);
        }
        if (item.getTotalQuantity() == null) {
            item.setTotalQuantity(0);
        }
        if (item.getBorrowedQuantity() == null) {
            item.setBorrowedQuantity(0);
        }
        
        // 默认状态
        if (!StringUtils.hasText(item.getStatus())) {
            item.setStatus("AVAILABLE");
        }
        
        itemRepository.insert(item);
        return item;
    }

    /**
     * 更新物品
     */
    @Transactional(rollbackFor = Exception.class)
    public Item update(Item item) {
        itemRepository.updateById(item);
        return item;
    }

    /**
     * 删除物品
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        itemRepository.deleteById(id);
    }

    /**
     * 生成物品编号
     */
    private String generateItemCode() {
        return "ITEM" + System.currentTimeMillis();
    }

    /**
     * 扫码获取物品信息
     */
    public Item getByQrCode(String qrCode) {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getQrCode, qrCode);
        return itemRepository.selectOne(wrapper);
    }

    /**
     * 批量导入物品
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean batchInsert(List<Item> items) {
        for (Item item : items) {
            item.setItemCode(generateItemCode());
            if (item.getCreateTime() == null) {
                item.setCreateTime(LocalDateTime.now());
            }
            if (item.getUpdateTime() == null) {
                item.setUpdateTime(LocalDateTime.now());
            }
        }
        
        for (Item item : items) {
            itemRepository.insert(item);
        }
        return true;
    }
}

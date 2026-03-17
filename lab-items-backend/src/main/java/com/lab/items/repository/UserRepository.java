package com.lab.items.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lab.items.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

/**
 * 用户数据访问接口
 */
@Mapper
@Repository
public interface UserRepository extends BaseMapper<User> {
    
    /**
     * 根据用户名查询用户
     */
    User selectByUsername(@Param("username") String username);
}

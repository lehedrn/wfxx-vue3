package com.ruoyi.demo.mapper;

import java.util.List;
import com.ruoyi.demo.domain.Customer;
import com.ruoyi.demo.domain.Goods;

/**
 * 客户管理Mapper接口
 * 
 * @author lihd
 * @date 2026-04-06
 */
public interface CustomerMapper 
{
    /**
     * 查询客户管理
     * 
     * @param customerId 客户管理主键
     * @return 客户管理
     */
    public Customer selectCustomerByCustomerId(Long customerId);

    /**
     * 查询客户管理列表
     * 
     * @param customer 客户管理
     * @return 客户管理集合
     */
    public List<Customer> selectCustomerList(Customer customer);

    /**
     * 新增客户管理
     * 
     * @param customer 客户管理
     * @return 结果
     */
    public int insertCustomer(Customer customer);

    /**
     * 修改客户管理
     * 
     * @param customer 客户管理
     * @return 结果
     */
    public int updateCustomer(Customer customer);

    /**
     * 删除客户管理
     * 
     * @param customerId 客户管理主键
     * @return 结果
     */
    public int deleteCustomerByCustomerId(Long customerId);

    /**
     * 批量删除客户管理
     * 
     * @param customerIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCustomerByCustomerIds(Long[] customerIds);

    /**
     * 批量删除商品管理
     * 
     * @param customerIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteGoodsByCustomerIds(Long[] customerIds);
    
    /**
     * 批量新增商品管理
     * 
     * @param goodsList 商品管理列表
     * @return 结果
     */
    public int batchGoods(List<Goods> goodsList);
    

    /**
     * 通过客户管理主键删除商品管理信息
     * 
     * @param customerId 客户管理ID
     * @return 结果
     */
    public int deleteGoodsByCustomerId(Long customerId);
}

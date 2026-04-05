package com.ruoyi.demo.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import com.ruoyi.common.utils.StringUtils;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.demo.domain.Goods;
import com.ruoyi.demo.mapper.CustomerMapper;
import com.ruoyi.demo.domain.Customer;
import com.ruoyi.demo.service.ICustomerService;

/**
 * 客户管理Service业务层处理
 * 
 * @author lihd
 * @date 2026-04-06
 */
@Service
public class CustomerServiceImpl implements ICustomerService 
{
    @Autowired
    private CustomerMapper customerMapper;

    /**
     * 查询客户管理
     * 
     * @param customerId 客户管理主键
     * @return 客户管理
     */
    @Override
    public Customer selectCustomerByCustomerId(Long customerId)
    {
        return customerMapper.selectCustomerByCustomerId(customerId);
    }

    /**
     * 查询客户管理列表
     * 
     * @param customer 客户管理
     * @return 客户管理
     */
    @Override
    public List<Customer> selectCustomerList(Customer customer)
    {
        return customerMapper.selectCustomerList(customer);
    }

    /**
     * 新增客户管理
     * 
     * @param customer 客户管理
     * @return 结果
     */
    @Transactional
    @Override
    public int insertCustomer(Customer customer)
    {
        int rows = customerMapper.insertCustomer(customer);
        insertGoods(customer);
        return rows;
    }

    /**
     * 修改客户管理
     * 
     * @param customer 客户管理
     * @return 结果
     */
    @Transactional
    @Override
    public int updateCustomer(Customer customer)
    {
        customerMapper.deleteGoodsByCustomerId(customer.getCustomerId());
        insertGoods(customer);
        return customerMapper.updateCustomer(customer);
    }

    /**
     * 批量删除客户管理
     * 
     * @param customerIds 需要删除的客户管理主键
     * @return 结果
     */
    @Transactional
    @Override
    public int deleteCustomerByCustomerIds(Long[] customerIds)
    {
        customerMapper.deleteGoodsByCustomerIds(customerIds);
        return customerMapper.deleteCustomerByCustomerIds(customerIds);
    }

    /**
     * 删除客户管理信息
     * 
     * @param customerId 客户管理主键
     * @return 结果
     */
    @Transactional
    @Override
    public int deleteCustomerByCustomerId(Long customerId)
    {
        customerMapper.deleteGoodsByCustomerId(customerId);
        return customerMapper.deleteCustomerByCustomerId(customerId);
    }

    /**
     * 新增商品管理信息
     * 
     * @param customer 客户管理对象
     */
    public void insertGoods(Customer customer)
    {
        List<Goods> goodsList = customer.getGoodsList();
        Long customerId = customer.getCustomerId();
        if (StringUtils.isNotNull(goodsList))
        {
            List<Goods> list = new ArrayList<Goods>();
            for (Goods goods : goodsList)
            {
                goods.setCustomerId(customerId);
                list.add(goods);
            }
            if (list.size() > 0)
            {
                customerMapper.batchGoods(list);
            }
        }
    }
}

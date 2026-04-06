# Mapper 数据访问层

## 概述

`ruoyi-system/mapper` 包提供了 MyBatis 数据访问接口，用于与数据库进行交互。所有 Mapper 接口都使用 XML 映射文件定义 SQL 语句。

**源码位置**: `ruoyi-system/src/main/java/com/ruoyi/system/mapper/`  
**XML 位置**: `ruoyi-system/src/main/resources/mapper/system/`

## 模块结构

```
mapper/
├── SysUserMapper.java           # 用户数据访问
├── SysRoleMapper.java           # 角色数据访问
├── SysMenuMapper.java           # 菜单数据访问
├── SysDeptMapper.java           # 部门数据访问
├── SysDictTypeMapper.java       # 字典类型数据访问
├── SysDictDataMapper.java       # 字典数据数据访问
├── SysPostMapper.java           # 岗位数据访问
├── SysConfigMapper.java         # 参数配置数据访问
├── SysNoticeMapper.java         # 通知公告数据访问
├── SysNoticeReadMapper.java     # 公告已读记录数据访问
├── SysOperLogMapper.java        # 操作日志数据访问
├── SysLogininforMapper.java     # 登录日志数据访问
├── SysUserRoleMapper.java       # 用户角色关联数据访问
├── SysRoleMenuMapper.java       # 角色菜单关联数据访问
├── SysRoleDeptMapper.java       # 角色部门关联数据访问
└── SysUserPostMapper.java       # 用户岗位关联数据访问
```

## 核心 Mapper 接口

### 用户、角色、菜单、部门

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| SysUserMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml) | 用户增删改查、角色分配、状态管理 |
| SysRoleMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysRoleMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysRoleMapper.xml) | 角色增删改查、权限分配、数据范围 |
| SysMenuMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysMenuMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysMenuMapper.xml) | 菜单树形管理、路由构建、权限标识 |
| SysDeptMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysDeptMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysDeptMapper.xml) | 部门树形管理、组织架构 |

### 字典、配置、公告

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| SysDictTypeMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysDictTypeMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysDictTypeMapper.xml) | 字典类型管理 |
| SysDictDataMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysDictDataMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysDictDataMapper.xml) | 字典数据管理 |
| SysConfigMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysConfigMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysConfigMapper.xml) | 参数配置管理 |
| SysNoticeMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNoticeMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysNoticeMapper.xml) | 通知公告管理 |
| SysNoticeReadMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNoticeReadMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysNoticeReadMapper.xml) | 公告已读状态追踪 |

### 日志、在线用户

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| SysOperLogMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysOperLogMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysOperLogMapper.xml) | 操作日志记录 |
| SysLogininforMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysLogininforMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysLogininforMapper.xml) | 登录日志记录 |

### 关联关系

| Mapper | 源码 | XML | 主要功能 |
|--------|------|-----|----------|
| SysUserRoleMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserRoleMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysUserRoleMapper.xml) | 用户角色关联 |
| SysRoleMenuMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysRoleMenuMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysRoleMenuMapper.xml) | 角色菜单关联 |
| SysRoleDeptMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysRoleDeptMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysRoleDeptMapper.xml) | 角色部门关联 |
| SysUserPostMapper | [`🔗`](../../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserPostMapper.java) | [`🔗`](../../ruoyi-system/src/main/resources/mapper/system/SysUserPostMapper.xml) | 用户岗位关联 |

---

## Mapper 方法命名规范

| 前缀 | 说明 | 返回类型 |
|------|------|----------|
| select | 查询操作 | 实体对象/List/TableDataInfo |
| insert | 新增操作 | int（影响行数） |
| update | 修改操作 | int（影响行数） |
| delete | 删除操作 | int（影响行数） |
| check | 唯一性校验 | 实体对象/int |
| count | 统计操作 | int |

---

## 使用示例

### 1. 注入 Mapper

```java
@Service
public class SysUserServiceImpl implements ISysUserService {
    
    @Autowired
    private SysUserMapper userMapper;
    
    // 使用 mapper...
}
```

### 2. 基本 CRUD

```java
// 查询
SysUser user = userMapper.selectUserById(1L);

// 列表（带分页）
List<SysUser> list = userMapper.selectUserList(condition);

// 新增
int rows = userMapper.insertUser(user);

// 修改
rows = userMapper.updateUser(user);

// 删除
rows = userMapper.deleteUserById(1L);
```

### 3. 条件查询

```java
// 构建查询条件
SysUser condition = new SysUser();
condition.setUserName("admin");
condition.setStatus("0");

// 执行查询
List<SysUser> list = userMapper.selectUserList(condition);
```

### 4. 唯一性校验

```java
// 校验用户名是否唯一
SysUser exists = userMapper.checkUserNameUnique(userName);
if (StringUtils.isNotNull(exists)) {
    throw new ServiceException("用户名已存在");
}
```

### 5. 关联查询

```java
// 根据用户 ID 查询岗位列表
List<Long> postIds = userMapper.selectUserPostListByUserId(userId);

// 根据角色 ID 查询菜单列表
List<Long> menuIds = roleMapper.selectMenuIdsByRoleId(roleId);
```

---

## XML 映射文件示例

### SysPostMapper.xml 片段

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" 
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.ruoyi.system.mapper.SysPostMapper">
    
    <resultMap type="SysPost" id="SysPostResult">
        <id     property="postId"    column="post_id"    />
        <result property="postCode"  column="post_code"  />
        <result property="postName"  column="post_name"  />
        <result property="postSort"  column="post_sort"  />
        <result property="status"    column="status"     />
    </resultMap>
    
    <select id="selectPostList" parameterType="SysPost" resultMap="SysPostResult">
        select post_id, post_code, post_name, post_sort, status
        from sys_post
        <where>
            <if test="postCode != null and postCode != ''">
                and post_code like concat('%', #{postCode}, '%')
            </if>
            <if test="status != null and status != ''">
                and status = #{status}
            </if>
        </where>
    </select>
    
</mapper>
```

---

**文档版本**: 1.1  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

# Mapper 数据访问层

## 概述

`ruoyi-system/mapper` 包提供了 MyBatis 数据访问接口，用于与数据库进行交互。所有 Mapper 接口都使用 MyBatis 注解或 XML 映射文件来定义 SQL 语句。

## 模块结构

```
mapper/
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

## 配置说明

### MyBatis 配置

```java
@MapperScan(basePackages = "com.ruoyi.system.mapper")
@Configuration
public class MybatisConfig {
    // MyBatis 配置
}
```

### XML 映射文件位置

```
resources/mapper/system/
├── SysPostMapper.xml
├── SysConfigMapper.xml
├── SysNoticeMapper.xml
├── SysNoticeReadMapper.xml
├── SysOperLogMapper.xml
├── SysLogininforMapper.xml
├── SysUserRoleMapper.xml
├── SysRoleMenuMapper.xml
├── SysRoleDeptMapper.xml
└── SysUserPostMapper.xml
```

---

## Mapper 接口详解

### 1. SysPostMapper - 岗位数据访问

**接口路径**: `com.ruoyi.system.mapper.SysPostMapper`

```java
public interface SysPostMapper {
    
    // ========== 查询操作 ==========
    
    /**
     * 查询岗位数据集合
     * @param post 岗位信息（查询条件）
     * @return 岗位数据集合
     */
    List<SysPost> selectPostList(SysPost post);
    
    /**
     * 查询所有岗位
     * @return 岗位列表
     */
    List<SysPost> selectPostAll();
    
    /**
     * 通过岗位 ID 查询岗位信息
     * @param postId 岗位 ID
     * @return 岗位信息
     */
    SysPost selectPostById(Long postId);
    
    /**
     * 根据用户 ID 获取岗位选择框列表
     * @param userId 用户 ID
     * @return 选中岗位 ID 列表
     */
    List<Long> selectPostListByUserId(Long userId);
    
    /**
     * 查询用户所属岗位组
     * @param userName 用户名
     * @return 岗位列表
     */
    List<SysPost> selectPostsByUserName(String userName);
    
    // ========== 唯一性校验 ==========
    
    /**
     * 校验岗位名称
     * @param postName 岗位名称
     * @return 岗位信息（存在则返回，不存在则 null）
     */
    SysPost checkPostNameUnique(String postName);
    
    /**
     * 校验岗位编码
     * @param postCode 岗位编码
     * @return 岗位信息（存在则返回，不存在则 null）
     */
    SysPost checkPostCodeUnique(String postCode);
    
    // ========== 新增操作 ==========
    
    /**
     * 新增岗位信息
     * @param post 岗位信息
     * @return 影响行数
     */
    int insertPost(SysPost post);
    
    // ========== 修改操作 ==========
    
    /**
     * 修改岗位信息
     * @param post 岗位信息
     * @return 影响行数
     */
    int updatePost(SysPost post);
    
    // ========== 删除操作 ==========
    
    /**
     * 删除岗位信息
     * @param postId 岗位 ID
     * @return 影响行数
     */
    int deletePostById(Long postId);
    
    /**
     * 批量删除岗位信息
     * @param postIds 需要删除的岗位 ID 数组
     * @return 影响行数
     */
    int deletePostByIds(Long[] postIds);
}
```

**XML 映射示例**:

```xml
<mapper namespace="com.ruoyi.system.mapper.SysPostMapper">
    
    <resultMap type="SysPost" id="SysPostResult">
        <id property="postId" column="post_id"/>
        <result property="postCode" column="post_code"/>
        <result property="postName" column="post_name"/>
        <result property="postSort" column="post_sort"/>
        <result property="status" column="status"/>
        <result property="createTime" column="create_time"/>
    </resultMap>
    
    <!-- 查询岗位列表 -->
    <select id="selectPostList" parameterType="SysPost" resultMap="SysPostResult">
        SELECT post_id, post_code, post_name, post_sort, status, create_time
        FROM sys_post
        <where>
            <if test="postCode != null and postCode != ''">
                AND post_code like concat('%', #{postCode}, '%')
            </if>
            <if test="status != null and status != ''">
                AND status = #{status}
            </if>
            <if test="postName != null and postName != ''">
                AND post_name like concat('%', #{postName}, '%')
            </if>
        </where>
        ORDER BY post_sort ASC
    </select>
    
    <!-- 通过 ID 查询 -->
    <select id="selectPostById" parameterType="Long" resultMap="SysPostResult">
        SELECT * FROM sys_post WHERE post_id = #{postId}
    </select>
    
    <!-- 新增岗位 -->
    <insert id="insertPost" parameterType="SysPost" useGeneratedKeys="true" keyProperty="postId">
        INSERT INTO sys_post (
            <if test="postId != null and postId != 0">post_id,</if>
            <if test="postCode != null and postCode != ''">post_code,</if>
            <if test="postName != null and postName != ''">post_name,</if>
            <if test="postSort != null">post_sort,</if>
            <if test="status != null and status != ''">status,</if>
            <if test="remark != null and remark != ''">remark,</if>
            <if test="createBy != null and createBy != ''">create_by,</if>
            create_time
        ) VALUES (
            <if test="postId != null and postId != 0">#{postId},</if>
            <if test="postCode != null and postCode != ''">#{postCode},</if>
            <if test="postName != null and postName != ''">#{postName},</if>
            <if test="postSort != null">#{postSort},</if>
            <if test="status != null and status != ''">#{status},</if>
            <if test="remark != null and remark != ''">#{remark},</if>
            <if test="createBy != null and createBy != ''">#{createBy},</if>
            sysdate()
        )
    </insert>
</mapper>
```

**使用示例**:

```java
@Autowired
private SysPostMapper postMapper;

// 查询列表
SysPost condition = new SysPost();
condition.setStatus("0");
List<SysPost> list = postMapper.selectPostList(condition);

// 查询详情
SysPost post = postMapper.selectPostById(1L);

// 新增
SysPost newPost = new SysPost();
newPost.setPostCode("DEV");
newPost.setPostName("开发岗位");
postMapper.insertPost(newPost);

// 修改
post.setPostName("高级开发岗位");
postMapper.updatePost(post);

// 删除
postMapper.deletePostById(1L);

// 批量删除
postMapper.deletePostByIds(new Long[]{1L, 2L, 3L});
```

---

### 2. SysConfigMapper - 参数配置数据访问

**接口路径**: `com.ruoyi.system.mapper.SysConfigMapper`

```java
public interface SysConfigMapper {
    
    /**
     * 查询参数配置信息
     * @param config 参数配置信息（查询条件）
     * @return 参数配置信息
     */
    SysConfig selectConfig(SysConfig config);
    
    /**
     * 通过 ID 查询配置
     * @param configId 参数 ID
     * @return 参数配置信息
     */
    SysConfig selectConfigById(Long configId);
    
    /**
     * 查询参数配置列表
     * @param config 参数配置信息（查询条件）
     * @return 参数配置集合
     */
    List<SysConfig> selectConfigList(SysConfig config);
    
    /**
     * 根据键名查询参数配置信息（唯一性校验）
     * @param configKey 参数键名
     * @return 参数配置信息
     */
    SysConfig checkConfigKeyUnique(String configKey);
    
    /**
     * 新增参数配置
     * @param config 参数配置信息
     * @return 结果
     */
    int insertConfig(SysConfig config);
    
    /**
     * 修改参数配置
     * @param config 参数配置信息
     * @return 结果
     */
    int updateConfig(SysConfig config);
    
    /**
     * 删除参数配置
     * @param configId 参数 ID
     * @return 结果
     */
    int deleteConfigById(Long configId);
    
    /**
     * 批量删除参数信息
     * @param configIds 需要删除的参数 ID 数组
     * @return 结果
     */
    int deleteConfigByIds(Long[] configIds);
}
```

**使用示例**:

```java
@Autowired
private SysConfigMapper configMapper;

// 根据键名查询配置
SysConfig config = configMapper.checkConfigKeyUnique("sys.user.initPassword");
String initPassword = config.getConfigValue();

// 查询配置列表
SysConfig condition = new SysConfig();
condition.setConfigType("Y");
List<SysConfig> list = configMapper.selectConfigList(condition);

// 新增配置
SysConfig newConfig = new SysConfig();
newConfig.setConfigName("用户初始密码");
newConfig.setConfigKey("sys.user.initPassword");
newConfig.setConfigValue("123456");
newConfig.setConfigType("Y");
configMapper.insertConfig(newConfig);

// 更新配置
config.setConfigValue("admin123");
configMapper.updateConfig(config);
```

---

### 3. SysNoticeMapper - 通知公告数据访问

**接口路径**: `com.ruoyi.system.mapper.SysNoticeMapper`

```java
public interface SysNoticeMapper {
    
    /**
     * 查询公告信息
     * @param noticeId 公告 ID
     * @return 公告信息
     */
    SysNotice selectNoticeById(Long noticeId);
    
    /**
     * 查询公告列表
     * @param notice 公告信息（查询条件）
     * @return 公告集合
     */
    List<SysNotice> selectNoticeList(SysNotice notice);
    
    /**
     * 新增公告
     * @param notice 公告信息
     * @return 结果
     */
    int insertNotice(SysNotice notice);
    
    /**
     * 修改公告
     * @param notice 公告信息
     * @return 结果
     */
    int updateNotice(SysNotice notice);
    
    /**
     * 删除公告
     * @param noticeId 公告 ID
     * @return 结果
     */
    int deleteNoticeById(Long noticeId);
    
    /**
     * 批量删除公告信息
     * @param noticeIds 需要删除的公告 ID 数组
     * @return 结果
     */
    int deleteNoticeByIds(Long[] noticeIds);
}
```

**使用示例**:

```java
@Autowired
private SysNoticeMapper noticeMapper;

// 查询公告详情
SysNotice notice = noticeMapper.selectNoticeById(1L);

// 查询公告列表
SysNotice condition = new SysNotice();
condition.setNoticeType("1"); // 通知
condition.setStatus("0"); // 正常
List<SysNotice> list = noticeMapper.selectNoticeList(condition);

// 新增公告
SysNotice newNotice = new SysNotice();
newNotice.setNoticeTitle("系统维护通知");
newNotice.setNoticeType("1");
newNotice.setNoticeContent("<p>系统将于今晚进行维护...</p>");
newNotice.setStatus("0");
noticeMapper.insertNotice(newNotice);

// 修改公告
notice.setNoticeTitle("系统维护通知（更新）");
noticeMapper.updateNotice(notice);
```

---

### 4. SysNoticeReadMapper - 公告已读记录数据访问

**接口路径**: `com.ruoyi.system.mapper.SysNoticeReadMapper`

```java
public interface SysNoticeReadMapper {
    
    /**
     * 查询公告已读记录
     * @param noticeReadId 已读记录 ID
     * @return 已读记录信息
     */
    SysNoticeRead selectNoticeReadById(Long noticeReadId);
    
    /**
     * 查询公告已读记录列表
     * @param noticeRead 已读记录信息（查询条件）
     * @return 已读记录集合
     */
    List<SysNoticeRead> selectNoticeReadList(SysNoticeRead noticeRead);
    
    /**
     * 新增公告已读记录
     * @param noticeRead 已读记录信息
     * @return 结果
     */
    int insertNoticeRead(SysNoticeRead noticeRead);
    
    /**
     * 检查公告是否已读
     * @param noticeId 公告 ID
     * @param userId 用户 ID
     * @return 是否已读
     */
    Boolean checkNoticeRead(Long noticeId, Long userId);
}
```

**使用示例**:

```java
@Autowired
private SysNoticeReadMapper noticeReadMapper;

// 检查是否已读
Boolean isRead = noticeReadMapper.checkNoticeRead(1L, 100L);

// 新增已读记录
SysNoticeRead noticeRead = new SysNoticeRead();
noticeRead.setNoticeId(1L);
noticeRead.setUserId(100L);
noticeRead.setReadStatus("1");
noticeReadMapper.insertNoticeRead(noticeRead);
```

---

### 5. SysOperLogMapper - 操作日志数据访问

**接口路径**: `com.ruoyi.system.mapper.SysOperLogMapper`

```java
public interface SysOperLogMapper {
    
    /**
     * 新增操作日志
     * @param operLog 操作日志对象
     */
    void insertOperlog(SysOperLog operLog);
    
    /**
     * 查询系统操作日志集合
     * @param operLog 操作日志对象（查询条件）
     * @return 操作日志集合
     */
    List<SysOperLog> selectOperLogList(SysOperLog operLog);
    
    /**
     * 查询操作日志详细
     * @param operId 操作 ID
     * @return 操作日志对象
     */
    SysOperLog selectOperLogById(Long operId);
    
    /**
     * 批量删除系统操作日志
     * @param operIds 需要删除的操作日志 ID 数组
     * @return 结果
     */
    int deleteOperLogByIds(Long[] operIds);
    
    /**
     * 清空操作日志
     */
    void cleanOperLog();
}
```

**使用示例**:

```java
@Autowired
private SysOperLogMapper operLogMapper;

// 新增操作日志
SysOperLog operLog = new SysOperLog();
operLog.setTitle("用户管理");
operLog.setBusinessType(BusinessType.INSERT.ordinal());
operLog.setOperName("admin");
operLog.setOperUrl("/system/user");
operLog.setOperIp("127.0.0.1");
operLog.setStatus(0);
operLogMapper.insertOperlog(operLog);

// 查询操作日志列表
SysOperLog condition = new SysOperLog();
condition.setTitle("用户管理");
List<SysOperLog> list = operLogMapper.selectOperLogList(condition);

// 删除操作日志
operLogMapper.deleteOperLogByIds(new Long[]{1L, 2L, 3L});

// 清空操作日志
operLogMapper.cleanOperLog();
```

---

## 通用 Mapper 方法说明

### 查询方法命名规范

| 方法名前缀 | 说明 | 返回值 |
|-----------|------|--------|
| `select` | 查询操作 | 对象或 List |
| `selectList` | 查询列表 | List |
| `selectById` | 根据 ID 查询 | 对象 |
| `selectBy` | 根据条件查询 | 对象或 List |

### 新增方法命名规范

| 方法名前缀 | 说明 | 返回值 |
|-----------|------|--------|
| `insert` | 新增操作 | int |
| `insertSelective` | 新增非空字段 | int |

### 修改方法命名规范

| 方法名前缀 | 说明 | 返回值 |
|-----------|------|--------|
| `update` | 修改操作 | int |
| `updateById` | 根据 ID 修改 | int |

### 删除方法命名规范

| 方法名前缀 | 说明 | 返回值 |
|-----------|------|--------|
| `delete` | 删除操作 | int |
| `deleteById` | 根据 ID 删除 | int |
| `deleteByIds` | 批量删除 | int |

---

## MyBatis 注解使用

### @Select 注解

```java
@Select("SELECT * FROM sys_post WHERE post_id = #{postId}")
SysPost selectPostById(Long postId);
```

### @Insert 注解

```java
@Insert("INSERT INTO sys_post (post_code, post_name) VALUES (#{postCode}, #{postName})")
@Options(useGeneratedKeys = true, keyProperty = "postId")
int insertPost(SysPost post);
```

### @Update 注解

```java
@Update("UPDATE sys_post SET post_name = #{postName} WHERE post_id = #{postId}")
int updatePost(SysPost post);
```

### @Delete 注解

```java
@Delete("DELETE FROM sys_post WHERE post_id = #{postId}")
int deletePostById(Long postId);
```

### @Results 和 @Result 注解

```java
@Results(id = "postResult", value = {
    @Result(property = "postId", column = "post_id", id = true),
    @Result(property = "postCode", column = "post_code"),
    @Result(property = "postName", column = "post_name"),
    @Result(property = "postSort", column = "post_sort"),
    @Result(property = "status", column = "status")
})
@Select("SELECT * FROM sys_post")
List<SysPost> selectPostAll();
```

---

## 最佳实践

### 1. 使用参数对象传递参数

```java
// 推荐
SysPost post = new SysPost();
post.setStatus("0");
List<SysPost> list = postMapper.selectPostList(post);

// 不推荐
List<SysPost> list = postMapper.selectPostList("0");
```

### 2. 批量操作使用数组参数

```java
// 批量删除
int deletePostByIds(Long[] postIds);
```

XML 配置:

```xml
<delete id="deletePostByIds" parameterType="Long">
    DELETE FROM sys_post WHERE post_id IN
    <foreach collection="array" item="postId" open="(" separator="," close=")">
        #{postId}
    </foreach>
</delete>
```

### 3. 动态 SQL 使用

```xml
<select id="selectPostList" resultMap="SysPostResult">
    SELECT * FROM sys_post
    <where>
        <if test="postCode != null and postCode != ''">
            AND post_code like concat('%', #{postCode}, '%')
        </if>
        <if test="postName != null and postName != ''">
            AND post_name like concat('%', #{postName}, '%')
        </if>
        <if test="status != null and status != ''">
            AND status = #{status}
        </if>
    </where>
</select>
```

### 4. 使用缓存提高查询性能

```xml
<mapper namespace="com.ruoyi.system.mapper.SysPostMapper">
    
    <cache eviction="LRU" flushInterval="60000" size="512" readOnly="true"/>
    
    <select id="selectPostAll" resultMap="SysPostResult" useCache="true">
        SELECT * FROM sys_post
    </select>
</mapper>
```

### 5. 事务处理

```java
@Service
public class SysPostServiceImpl implements ISysPostService {
    
    @Autowired
    private SysPostMapper postMapper;
    
    @Transactional
    @Override
    public void deletePostByIds(Long[] postIds) {
        for (Long postId : postIds) {
            postMapper.deletePostById(postId);
        }
    }
}
```

---

**文档版本**: 1.0  
**最后更新**: 2026-04-07  
**基于版本**: RuoYi v3.9.2

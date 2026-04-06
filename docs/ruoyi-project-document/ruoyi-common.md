# RuoYi-Common 模块文档

## 概述

`ruoyi-common` 是 RuoYi 框架的通用工具模块，提供了项目中共用的工具类、注解、常量、异常处理、过滤器等核心组件。该模块是整个框架的基础依赖，其他业务模块都需要引用此模块。

## 模块结构

```
ruoyi-common/
├── annotation/        # 自定义注解
├── config/            # 配置类
├── constant/          # 常量定义
├── core/              # 核心域模型
│   ├── controller/    # 基础控制器
│   ├── domain/        # 域对象
│   ├── page/          # 分页相关
│   ├── redis/         # Redis 缓存
│   └── text/          # 文本处理
├── enums/             # 枚举类型
├── exception/         # 异常体系
├── filter/            # 过滤器链
├── utils/             # 工具类集合
└── xss/               # XSS 防护
```

## 依赖说明

### 主要依赖
- Spring Framework (context-support, web)
- Spring Security
- PageHelper (分页)
- Jackson & FastJSON2 (JSON 处理)
- Apache POI (Excel 处理)
- JJWT (Token 生成与解析)
- Redis (缓存)
- Commons 系列工具包

## 子模块文档

详细子模块文档请参考：
- [annotation](./ruoyi-common/annotation.md) - 自定义注解（@Log、@DataScope、@Excel 等）
- [config](./ruoyi-common/config.md) - 配置类（RuoYiConfig、序列化器等）
- [constant](./ruoyi-common/constant.md) - 常量定义（Constants、HttpStatus 等）
- [core](./ruoyi-common/core.md) - 核心域模型（实体、响应、分页等）
- [enums](./ruoyi-common/enums.md) - 枚举类型（BusinessType、UserStatus 等）
- [exception](./ruoyi-common/exception.md) - 异常体系（ServiceException、UserException 等）
- [filter](./ruoyi-common/filter.md) - 过滤器链（XSS 防护、防盗链等）
- [utils](./ruoyi-common/utils.md) - 工具类集合（上）- 核心工具类
- [utils-part2](./ruoyi-common/utils-part2.md) - 工具类集合（下）- 功能工具类

## 版本信息

- 框架版本：RuoYi v3.9.2
- Spring Boot 版本：4.x (JDK 17+)
- 模块版本：3.9.2

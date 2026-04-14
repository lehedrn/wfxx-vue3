CREATE TABLE sys_area (
  id              BIGINT          NOT NULL      AUTO_INCREMENT  COMMENT '编号',
  name            VARCHAR(100)    NOT NULL      COMMENT '区划名称',
  code            VARCHAR(12)     NOT NULL      COMMENT '区划编码（2/4/6/9/12位）',
  parent_code     VARCHAR(12)     DEFAULT '0'   COMMENT '父区域编码（0 为根节点）',
  ancestors       VARCHAR(128)    DEFAULT ''    COMMENT '祖级列表（逗号分隔，如 0,11,1101）',
  area_level      CHAR(1)         DEFAULT NULL  COMMENT '层级（字典 sys_area_level）',
  sort            INT             DEFAULT 1     COMMENT '排序号',
  create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP         COMMENT '创建时间',
  update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  create_by       VARCHAR(64)     DEFAULT ''    COMMENT '创建人',
  update_by       VARCHAR(64)     DEFAULT ''    COMMENT '更新人',
  remark          VARCHAR(500)    DEFAULT ''    COMMENT '备注',
  del_flag        CHAR(1)         DEFAULT '0'   COMMENT '删除标志（0 正常 1 删除）',
  PRIMARY KEY (id),
  KEY idx_code (code) COMMENT '区划编码索引',
  KEY idx_parent_code (parent_code) COMMENT '父区域编码索引'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='区划管理表';

create table demo_student (
  id           int(11)         auto_increment    comment '编号',
  name         varchar(30)     default ''        comment '学生名称',
  age          int(3)          default null      comment '年龄',
  student_hobby        varchar(30)     default ''        comment '爱好（1钓鱼 2写作 3运动 4冥想 5音乐 6电影）',
  sex          char(1)         default '0'       comment '性别（0男 1女 2未知）',
  status       char(1)         default '0'       comment '状态（0正常 1停用）',
  birthday     datetime                          comment '生日',
  primary key (id)
) engine=innodb auto_increment=1 comment = '学生信息表';
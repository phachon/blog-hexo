-- mysql innodb index --

-- create database test default charset utf8;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `first_name` char(10) NOT NULL DEFAULT '' COMMENT '姓',
  `last_name` varchar(10) NOT NULL DEFAULT '' COMMENT '名',
  `age` int(3) NOT NULL DEFAULT '0' COMMENT '年龄',
  PRIMARY KEY (`id`),
  KEY (`age`),
  KEY `firstName_lastName_age_index` (`first_name`, `last_name`, `age`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

DROP TABLE IF EXISTS `video`;
CREATE TABLE `video` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'role id',
  `user_id` int(10) NOT NULL COMMENT 'user id',
  `title` char(100) NOT NULL DEFAULT '' COMMENT '视频标题',
  PRIMARY KEY (`id`),
  KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='视频表';

insert into `user` (first_name, last_name, age) values ('zhang','san', 1);
insert into `user` (first_name, last_name, age) values ('li','si', 18);
insert into `user` (first_name, last_name, age) values ('wang','wu', 21);
insert into `user` (first_name, last_name, age) values ('pan','liu', 41);
insert into `user` (first_name, last_name, age) values ('jin','qi', 16);
insert into `user` (first_name, last_name, age) values ('yang','ba', 8);
insert into `user` (first_name, last_name, age) values ('yu','jiu', 9);
insert into `user` (first_name, last_name, age) values ('ding','q', 10);
insert into `user` (first_name, last_name, age) values ('wu','w', 13);
insert into `user` (first_name, last_name, age) values ('zhao','u', 51);
insert into `user` (first_name, last_name, age) values ('qian','k', 61);
insert into `user` (first_name, last_name, age) values ('zheng','o', 31);
insert into `user` (first_name, last_name, age) values ('zhou','z', 10);

insert into `video` (user_id, title) values (1, 'v1');
insert into `video` (user_id, title) values (1, 'v2');
insert into `video` (user_id, title) values (2, 'v3');
insert into `video` (user_id, title) values (2, 'v3');
insert into `video` (user_id, title) values (7, 'v9');
insert into `video` (user_id, title) values (1, 'v0');
insert into `video` (user_id, title) values (3, 'v1');
insert into `video` (user_id, title) values (4, 'v8');
insert into `video` (user_id, title) values (6, 'v9');
insert into `video` (user_id, title) values (8, 'v14');
insert into `video` (user_id, title) values (5, 'v3');
insert into `video` (user_id, title) values (4, 'v11');
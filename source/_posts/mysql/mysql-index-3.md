---
title: Mysql 索引系列（三）：索引的策略
date: 2018-09-28 18:25:15
banner: /images/mysql_logo.png
thumbnail: /images/mysql_logo.png
categories: Mysql
tags:
  - mysql
---
------------------------------------------

Mysql 的索引使用的是 B Tree 索引，B Tree 索引适用于全健值、键值范围、键前缀查询。索引在创建索引的时候，我们必须了解存储引擎的索引的策略。这样才能是得查询尽量达到最优。

<!-- more -->

## 索引的类型
先来介绍一下 Mysql 包含哪些索引类型，以及这些索引的使用场景

### 普通索引
是最基本的索引，没有任何限制。例如：
```$xslt
KEY index_name (`title`)
```

### 唯一索引
唯一索引的索引列的值必须是唯一的，但允许有空值。如果是联合索引，则列值的组合必须唯一。
```$xslt
UNIQUE index_name (`title`)
```

### 主键索引
主键索引一种特殊的唯一索引，一个表必须有一个主键，不允许有空值。也就是说主键索引是一种非空的唯一索引。
```$xslt
PRIMARY KEY (`id`)
```

### 联合索引
除了在单列的字段上设置索引，还可以将多个列上创建索引。使用联合索引必须遵循`最左前缀集合`，例如：
```$xslt
KEY index_name (`id`, `title`, `age`)
```

### 前缀索引
有时候需要索引很长的字符列，这会让索引变的大且慢。可以使用前缀索引来来节约索引空间，从而提高索引效率。前缀索引只索引指定的索引开始的部分长度字符。例如：
```$xslt
KEY index_name (title(7))
```
只会索引 `title` 从开始长度为 7 的字符。

### 覆盖索引
覆盖索引就是就是可以直接通过索引来获取数据，而不需要读取数据行。如果一个索引包含（或者说覆盖）所有需要查询的字段的值，我们就称之为 `覆盖索引`。
```$xslt
KEY index_name (`id`, `name`, `age`)
```
如果我们的 sql 查询语句：
```$xslt
select age from user where id=10 and name="p";
```
那么使用的就是覆盖索引，因为要查找数据 age 列本身就包含在索引数据中。

### 全文索引
主要用来查找文本中的关键字，而不是直接与索引中的值相比较，跟其他的索引不太一样，更像是搜索引擎。fulltext 索引配合 match against 操作使用。
```$xslt
FULLTEXT (content)
```
MyISAM 引擎支持全文索引，InnoDB 引擎不支持全文索引。

## 联合索引的索引策略
创建好了各种类型的索引之后，如何合理的使用索引才是关键。如果不能按照索引的策略去写查询语句，查询性能会非常低下。这里我们先创建一个表用来测试：

`Mysql 版本 5.7.23`

```$xslt
CREATE TABLE `user_info` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `first_name` char(10) NOT NULL DEFAULT '' COMMENT '姓',
  `last_name` varchar(10) NOT NULL DEFAULT '' COMMENT '名',
  `age` int(3) NOT NULL DEFAULT '0' COMMENT '年龄',
  PRIMARY KEY (`id`),
  KEY `firstName_lastName_age_index` (`first_name`, `last_name`, `age`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

insert into `user_info` (first_name, last_name, age) values ('zhang','san', 1);
insert into `user_info` (first_name, last_name, age) values ('li','si', 18);
insert into `user_info` (first_name, last_name, age) values ('wang','wu', 21);
insert into `user_info` (first_name, last_name, age) values ('pan','liu', 41);
insert into `user_info` (first_name, last_name, age) values ('jin','qi', 16);
insert into `user_info` (first_name, last_name, age) values ('yang','ba', 8);
insert into `user_info` (first_name, last_name, age) values ('yu','jiu', 9);
insert into `user_info` (first_name, last_name, age) values ('ding','q', 10);
insert into `user_info` (first_name, last_name, age) values ('wu','w', 13);
insert into `user_info` (first_name, last_name, age) values ('zhao','u', 51);
insert into `user_info` (first_name, last_name, age) values ('qian','k', 61);
insert into `user_info` (first_name, last_name, age) values ('zheng','o', 31);
insert into `user_info` (first_name, last_name, age) values ('zhou','z', 10);
```

根据最左前缀策略，对以下的查找有效。

### 全值匹配
全值匹配指的是和索引中的所有列都进行匹配。例如：
```$xslt
mysql> select * from user_info where first_name="yu" and last_name="jiu" and age=9;
+----+------------+-----------+-----+
| id | first_name | last_name | age |
+----+------------+-----------+-----+
|  7 | yu         | jiu       |   9 |
+----+------------+-----------+-----+
1 row in set (0.00 sec)

# 查看索引的使用情况
mysql> explain select * from user_info where first_name="yu" and last_name="jiu" and age=9\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: ref
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 66
          ref: const,const,const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```
从索引的使用来看，`firstName_lastName_age_index` 索引被使用，并且 key_len 的长度是 66 字节等于 fist_name(3*10) + last_name(3*10+2) + 4，能看出来索引三列都匹配。  

### 匹配最左前缀
即只使用索引的第一列，例如：
```$xslt
mysql> select * from user_info where first_name="yu";
+----+------------+-----------+-----+
| id | first_name | last_name | age |
+----+------------+-----------+-----+
|  7 | yu         | jiu       |   9 |
+----+------------+-----------+-----+
1 row in set (0.00 sec)

mysql> explain select * from user_info where first_name="yu"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: ref
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 30
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```
真正使用的索引 key 还是 firstName_lastName_age_index，key_len 是 30 说明只使用了第一列 first_name(3*10) 来匹配。
查询优化器会自动调整where子句的条件顺序以使用适合的索引，所以 where 子中的条件顺序颠倒也可以全值匹配。

### 匹配列前缀
也可以只匹配某一列的前缀，例如匹配姓为 y 开头的用户：
```$xslt
mysql> select * from user_info where first_name like "y%";
+----+------------+-----------+-----+
| id | first_name | last_name | age |
+----+------------+-----------+-----+
|  6 | yang       | ba        |   8 |
|  7 | yu         | jiu       |   9 |
+----+------------+-----------+-----+
2 rows in set (0.00 sec)
mysql> explain select * from user_info where first_name like "y%"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: range
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 30
          ref: NULL
         rows: 2
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
这里看到 key_len 也是 30，说明使用的也是第一列索引来匹配。

### 匹配范围值
用于匹配范围查找，例如匹配姓在 'a' 和 'y' 之间的人。
```$xslt
mysql> select * from user_info where first_name between 'a' and 'y';
+----+------------+-----------+-----+
| id | first_name | last_name | age |
+----+------------+-----------+-----+
|  8 | ding       | q         |  10 |
+----+------------+-----------+-----+
1 row in set (0.00 sec)
mysql> explain select * from user_info where first_name between 'a' and 'y'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: range
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 30
          ref: NULL
         rows: 3
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
可以看到 key_len 也是 30，说明只使用了索引的第一列来匹配。

### 精确匹配某一列且范围匹配另一列
直接上案例，查找 fist_name = 'yang' 且 last_name 范围查找的用户：
```$xslt
mysql> select * from user_info where first_name='yang' and last_name between 'a' and 'j';
+----+------------+-----------+-----+
| id | first_name | last_name | age |
+----+------------+-----------+-----+
|  6 | yang       | ba        |   8 |
+----+------------+-----------+-----+
1 row in set (0.00 sec)
mysql> explain select * from user_info where first_name='yang' and last_name between 'a' and 'j'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: range
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 62
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
key_len 为 62，说明使用了前两列索引来匹配，first_name(3*10) + last_name(3*10+2)。
如果第一列是范围查找第二列是精确查找会一样吗？

```$xslt
mysql> explain select * from user_info where first_name like '%a' and last_name='qiu'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user_info
   partitions: NULL
         type: index
possible_keys: NULL
          key: firstName_lastName_age_index
      key_len: 66
          ref: NULL
         rows: 13
     filtered: 20.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
可以看到，type 类型变成了 index ,也就是全索引扫描，效率是比较差的。

### 只访问索引的查询
这里用到覆盖索引，后面专门的章节来讲。

## 什么时候索引会失效?
- 如果条件中有or，即使其中有条件带索引也不会使用(这也是为什么尽量少用or的原因)。注意：要想使用or，又想让索引生效，只能将or条件中的每个列都加上索引
- 对于多列索引，不是使用的第一部分，则不会使用索引（即不符合最左前缀原则）
- like查询是以%开头
- 如果列类型是字符串，那一定要在条件中将数据使用引号引用起来, 否则不使用索引
- 查询条件中含有函数或表达式
- 如果 mysql 估计使用全表扫描要比使用索引快，则不使用索引

## 参考
《高性能 Mysql 第三版》
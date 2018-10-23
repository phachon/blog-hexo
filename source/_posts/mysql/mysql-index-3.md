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

Mysql 的索引使用的是 B Tree 索引，B Tree 索引适用于全健值、键值范围、键前缀查询。所以在创建索引的时候，我们必须了解存储引擎的索引的策略。这样才能使得查询效率尽量达到最优。

本示例中使用的 Mysql 版本是： `5.7.23`

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

## 单列索引的索引策略
对于单列索引，并不是任何时候查询都会生效，我们通过实例来看一下哪些查询会导致索引失效，这对于我们日常开发是至关重要的。
创建表结构如下：
```$xslt
DROP TABLE IF EXISTS `index_single_test`;
CREATE TABLE `index_single_test` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` char(10) NOT NULL DEFAULT '' COMMENT '索引名称',
  `type` char(50) NOT NULL DEFAULT '' COMMENT '类型',
  `size` int(10) NOT NULL DEFAULT 0 COMMENT '索引长度',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `type` (`type`),
  KEY `size` (`size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='单列索引测试表';

insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_1','key', 10);
insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_2','join', 8);
insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_3','primary', 8);
insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_4','key', 9);
insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_5','fulltext', 4);
insert into `index_single_test` (index_single_test.name, index_single_test.type, index_single_test.size) values ('index_6','unique', 6);
```

使用索引 name 来查询：
```
mysql> explain select * from index_single_test where name="index_1"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: const
possible_keys: name
          key: name
      key_len: 30
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)
```

我们看到 `type = "const", key = "name"` 确实使用索引来查询。

- 使用 Like 
```
mysql> explain select * from index_single_test where name like "%index_1"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 6
     filtered: 16.67
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
```
很明显，type 变成了 `ALL`, 全表扫描，没有使用索引

- 范围查询（between，<>）
```
mysql> explain select * from index_single_test where size between 0 and 5\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: range
possible_keys: size
          key: size
      key_len: 4
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using index condition
1 row in set, 1 warning (0.00 sec)
mysql> explain select * from index_single_test where size > 0 and size <5\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: range
possible_keys: size
          key: size
      key_len: 4
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using index condition
1 row in set, 1 warning (0.00 sec)
```
可以看到 `type=range key=size` 是使用索引来查询的。

- 使用 In
```
mysql> explain select * from index_single_test where size in (9,4,6)\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: ALL
possible_keys: size
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 6
     filtered: 50.00
        Extra: Using where
1 row in set, 1 warning (0.01 sec)
```
可以看到，`type = ALL, key = NULL` 并没有使用索引。

- 使用 or
```
mysql> explain select * from index_single_test where name='index_1' or id=2\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_single_test
   partitions: NULL
         type: ALL
possible_keys: PRIMARY,name
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 6
     filtered: 58.33
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
```
可以看到，`type = ALL, key = NULL` 并没有使用索引。即使 id 和 name 字段上都有索引。

`单列索引失效的情况总结`：
- `使用 Like 索引失效`
- `使用 In 索引失效`
- `使用 Or 索引失效`

## 联合（多列）索引的索引策略
接下来我们来看看联合（多列）索引的索引策略，这里我们创建表结构如下：

```$xslt
DROP TABLE IF EXISTS `index_double_test`;
CREATE TABLE `index_double_test` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` char(10) NOT NULL DEFAULT '' COMMENT '索引名称',
  `type` char(50) NOT NULL DEFAULT '' COMMENT '类型',
  `size` int(10) NOT NULL DEFAULT 0 COMMENT '索引长度',
  PRIMARY KEY (`id`),
  KEY `name_type_size` (`name`, `type`, `size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='多列索引测试表';
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_1','key', 10);
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_2','join', 8);
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_3','primary', 8);
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_4','key', 9);
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_5','fulltext', 4);
insert into `index_double_test` (index_double_test.name, index_double_test.type, index_double_test.size) values ('index_6','unique', 6);
```

根据`最左前缀策略`，联合索引对以下的查找有效。

### 1.全值匹配
全值匹配指的是和索引中的所有列都进行匹配。例如：
```$xslt
mysql> explain select * from index_double_test where name='index_1' and type='type' and size=9\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: ref
possible_keys: name_type_size
          key: name_type_size
      key_len: 184
          ref: const,const,const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```
从索引的使用来看，`type = ref key = name_type_size` , 并且 key_len 的长度是 184 字节等于 name(3 * 10) + type(3 * 50) + 4，能看出来索引三列都匹配。 

注意：查询优化器会自动调整 where 子句的条件顺序以使用适合的索引，所以 where 条件顺序颠倒也可以全值匹配。

### 2.匹配最左前缀
即只使用索引的第一列，例如：
```$xslt
mysql> explain select * from index_double_test where name='index_1'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: ref
possible_keys: name_type_size
          key: name_type_size
      key_len: 30
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.01 sec)
```
从索引的使用来看，`type = ref key = name_type_size` , key_len 是 30 说明只使用了第一列 name(3*10) 来匹配。

### 3.匹配列前缀
也可以只匹配某一列的前缀
```$xslt
mysql> explain select * from index_double_test where name like "ix%"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: range
possible_keys: name_type_size
          key: name_type_size
      key_len: 30
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
这里看到 key_len 也是 30，说明使用的也是第一列索引来匹配。

### 4.匹配范围值
用于匹配范围查找，示例如下：
```$xslt
mysql> explain select * from index_double_test where name between 'a' and 'm'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: range
possible_keys: name_type_size
          key: name_type_size
      key_len: 30
          ref: NULL
         rows: 2
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
可以看到 key_len 也是 30，说明只使用了索引的第一列来匹配。

### 5.精确匹配某一列且范围匹配另一列
直接上案例
```$xslt
mysql> explain select * from index_double_test where name='yu' and type like 'a%'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: range
possible_keys: name_type_size
          key: name_type_size
      key_len: 180
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)

mysql> explain select * from index_double_test where name='yu' and type like '%a'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: ref
possible_keys: name_type_size
          key: name_type_size
      key_len: 30
          ref: const
         rows: 1
     filtered: 16.67
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
这里第二列我们有两种情况：
1. 第二列使用前缀匹配(like type "a%")，key_len = 180 则说明使用的是第一列和第二列的索引
2. 第二列使用后缀匹配(like type "%a")，key_len = 30 则说明只使用了第一列索引，第二列索引无法使用

如果第一列是范围查找第二列是精确查找会一样吗？

```$xslt
mysql> explain select * from index_double_test where name like 'y%' and type='key'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: range
possible_keys: name_type_size
          key: name_type_size
      key_len: 180
          ref: NULL
         rows: 1
     filtered: 16.67
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)

mysql> explain select * from index_double_test where name like '%y' and type='key'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: index
possible_keys: NULL
          key: name_type_size
      key_len: 184
          ref: NULL
         rows: 6
     filtered: 16.67
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
第一列也有两种情况：
1. 第一列使用前缀匹配(like type "a%")，key_len = 180 则说明使用的是第一列和第二列的索引
2. 第一列使用后缀匹配(like type "%a")，type = index 则说明使用的是全索引扫描，效率是比较低的

### 6.只访问索引的查询
这里用到覆盖索引，后面专门的章节来讲。

### 联合索引使索引失效的情况
- 不是使用的第一部分，则索引使用全索引扫描
```
mysql> explain select * from index_double_test where type='key' and size=9\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: index
possible_keys: NULL
          key: name_type_size
      key_len: 184
          ref: NULL
         rows: 6
     filtered: 16.67
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```

- 查询条件中有 or
```
mysql> explain select * from index_double_test where name ='yu' or type='key' or size = 8\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: index_double_test
   partitions: NULL
         type: index
possible_keys: name_type_size
          key: name_type_size
      key_len: 184
          ref: NULL
         rows: 6
     filtered: 42.13
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
- like 查询是以 % 开头
上面有演示，这里不再演示

- 查询条件中有函数或表达式

`注意：这里索引失效，并不是不使用索引，可以看到  key = name_type_size, 只是 type = index，即全索引扫描，效率比较差而已` 

## 参考
《高性能 Mysql 第三版》
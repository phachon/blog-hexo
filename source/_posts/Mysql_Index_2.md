---
title: Mysql 索引系列（二）：了解并使用 EXPLAIN 命令
date: 2018-09-28 10:25:15
banner: /images/redis_logo.png
thumbnail: /images/redis_logo.png
categories: Mysql
tags:
  - mysql
---
---------------------------------------------------

上一篇文章讲解了 Mysql 在不同的存储引擎下索引的实现，在开始讲解索引的策略以及如何优化索引之
前，我觉得有必要先来了解以下如何去使用 `EXPLAIN` 命令来查看sql 语句的查询方式，因为在后续的
文章中，我们会经常使用该命令来调试和分析。除此之外，我们在工作中，也应该习惯去使用 `EXPLAIN`
命令来分析和优化索引。

<!-- more -->

## EXPLAIN 命令简介
EXPLAIN 命令用来查看 SQL 语句的执行计划。简单来说，就是通过和这个命令就可以查看该查询执行的
详细信息，通过查看并分析这些信息，我们可以优化我们的 SQL 语句和索引，最终来提高我们的查询效率。

### 使用方法
```$xslt
mysql> explain select * from user id=1\G
```
使用比较简单，直接在要查询的 select 语句前加上 explain 

## 准备数据
为了演示，这里新建数据库和表并插入一些数据。

```$xslt
CREATE TABLE `user` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `first_name` char(10) NOT NULL DEFAULT '' COMMENT '姓',
  `last_name` varchar(10) NOT NULL DEFAULT '' COMMENT '名',
  `age` int(3) NOT NULL DEFAULT '0' COMMENT '年龄',
  PRIMARY KEY (`id`),
  KEY `firstName_lastName_age_index` (`first_name`, `last_name`, `age`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

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
```

```$xslt
mysql> explain select * from user where id=1\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)
```
## 列字段解释

### id
select 查询的标识符，每个 select 都会自动分配一个唯一的标示符

### select_type
select_type 表示查询的类型，通常有如下值：
- SIMPLE 表示此查询是简单查询，即不包含 UNION 或子查询
- PRIMARY 表示此查询是最外层的查询
- UNION 表示此查询是 UNION 的第二个或者随后的查询
- DEPENDENT UNION 表示 UNION 的第二个或后面的查询，取决于外面的查询
- UNION RESULT 表示 UNION 的结果
- SUBQUERY 子查询中的第一个 SELECT 
- DEPENDENT SUBQUERY 子查询中的第一个 SELECT ,取决于外面的查询，即子查询依赖于外层的查询结果

最常见的就是 SIMPLE 查询，查询没有子查询，也没有 UNION 查询时，通常就是 SIMPLE
```$xslt
mysql> explain select * from user where id=1\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)
```

使用了 UNION 查询，输出结果如下：
```$xslt
mysql> explain (select * from user where id=1) union (select * from user where id=2);
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
| id | select_type  | table      | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra           |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
|  1 | PRIMARY      | user       | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
|  2 | UNION        | user       | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL            |
| NULL | UNION RESULT | <union1,2> | NULL       | ALL   | NULL          | NULL    | NULL    | NULL  | NULL |     NULL | Using temporary |
+----+--------------+------------+------------+-------+---------------+---------+---------+-------+------+----------+-----------------+
3 rows in set, 1 warning (0.00 sec)
```

### table
查询涉及的表或者衍生表

### partitions
匹配的分区

### type
type 字段比较重要，表示数据的查询类型，根据 type 字段判断是全表扫描还是索引扫描
- system：表中只有一条数据，是特殊的 const
- const：针对`主键`或`唯一索引`的`等值查询`扫描，最多只返回一条数据。const 查询速度非常快，因为仅仅读取一次即可。例如：
```$xslt
mysql> explain select * from user where id=1\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.04 sec)
```

- eq_ref：此类型通常出现在多表的 join 查询，表示前表的每一个结果，都只能匹配到后表的一行结果，查询的操作符通常是 `=`，查询效率比较高：
```$xslt
mysql> explain select * from user,video where user.id=video.user_id\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: video
   partitions: NULL
         type: index
possible_keys: user_id,user_id_2
          key: user_id_2
      key_len: 304
          ref: NULL
         rows: 12
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: test.video.user_id
         rows: 1
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
``` 

- ref：此类型通常出现在多表的 join 查询，针对于非唯一索引或主键索引，或者是使用了 `最左前缀` 规则索引的查询。
- range：表示使用的是范围查询，通过索引字段范围获取表中部分数据记录，这个类型通常出现在 =，<>,>,<=,>=, IS NULL, <=>, between, in() 操作中。
type 是 range，explain 输出的 ref 字段为 NULL，并且 key_len 字段是此次查询中使用到的最长的那个索引。
```$xslt
mysql> explain select * from user where user.id > 0 and user.id <40\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: range
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: NULL
         rows: 13
     filtered: 100.00
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
mysql> explain select age from user where age between 0 and 40\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: range
possible_keys: age
          key: age
      key_len: 4
          ref: NULL
         rows: 10
     filtered: 100.00
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
- index：表示全索引扫描，和 all 类型类似，只不过 all 类型是全表扫描，而 index 类型只扫描所有的索引，而不是扫描数据。通常情况下，index 出现在所要查询的
数据直接出现在索引树中就可以直接获取到，而不需要扫描数据。一般 Extra 字段会显示 Using index。
```$xslt
mysql> explain select * from user where age between 0 and 40\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: index
possible_keys: age
          key: first_name_2
      key_len: 64
          ref: NULL
         rows: 13
     filtered: 76.92
        Extra: Using where; Using index
1 row in set, 1 warning (0.00 sec)
```
从 range 里面的示例和上面的示例我们可以看到两条相似的语句使用的查询类型不一样，原因是：
因为 age 是索引，当使用 select age，直接可以通过二级索引树查到范围数据，所以是 range
当使用 select * , 因为二级索引只能查到 age 和主键，想要查到所有数据集，需要再次回到主索引树查找，因此退化成了 index, 也就是需要全索引扫描

- all：表示全表扫描，这个是最差的扫描。如果出现了 all，那么我们应该优化掉。对于大数据量的情况下，这将是灾难。
```$xslt
mysql> explain select * from video where video.title="v1"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: video
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12
     filtered: 10.00
        Extra: Using where
1 row in set, 1 warning (0.00 sec)
```
title 不是索引，所以只能全表扫描。

type 的性能比较：

`all < index < range < ref < eq_ref < const < system`

### possible_keys
表示在 Mysql 查询时可能使用到的索引，注意，即使有些索引在 possible_key 出现，但是并不表示此索引会被真正的被 Mysql 用到。具体使用的是哪些索引，由字段 key 表示

### key
表示 Mysql 在查询中真正使用到的索引。

### key_len
表示查询优化器在使用了索引的字节数，这个字段可以评估组合索引是否完全被使用，或者是只使用了最左部分，key_len 的计算规则如下：

- 字符串类型
  - char(n): 如果是 uft8 编码，则是 3n 字节; utf8mb4 编码，则是 4n 字节
  - varchar(n): 如果是 uft8 编码，则是 3n+2 字节; utf8mb4 编码，则是 4n+2 字节
注意：如果属性不是 NOT NULL, 则需要多加 1 个字节。

- 数值类型
  - TINYINT: 1 字节
  - SMALLINT: 2 字节
  - MEDIUMINT: 3 字节
  - INT: 4 字节
  - BIGINT: 8 字节

- 时间类型
 - DATE: 3 字节
 - TIMESTAMP: 4 字节
 - DATETIME: 8 字节

在 user 表中我们有联合索引 `KEY (first_name, last_name, age)` 举例说明:
```$xslt
mysql> explain select * from user where first_name='yu'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
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
我们的查询语句使用的是 `first_name='yu'`，根据`最左匹配原则`，只匹配了第一列 first_name, first_name 的字段类型是 char, 且是 NOT NULL, 所以 key_len 是 30, 表示只使用了 30 字节的索引长度。
再来看一个例子：

```$xslt
mysql> explain select * from user where first_name='yu' and last_name="jiu"\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: ref
possible_keys: firstName_lastName_age_index
          key: firstName_lastName_age_index
      key_len: 62
          ref: const,const
         rows: 1
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```

这个例子中匹配了前两列，所以是 key_len(first_name) + key_len(last_name) 等于 3*10 + 3*10+2 = 62 字节

### ref
哪个字段或常数与 key 一起被使用

### rows
rows 也是一个重要的字段. MySQL 查询优化器根据统计信息, 估算 SQL 要查找到结果集需要扫描读取的数据行数。

### filtered
表示此查询条件所过滤的数据的百分比

### Extra
Extra 的信息表示额外的信息。常见的有以下几种内容：

- Using filesort
当出现 Using filesort 时，表示需要额外的排序操作，不能通过索引顺序达到排序的效果，这种情况下一般都建议优化掉。例如：

```$xslt
mysql> explain select * from user order by age desc\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: index
possible_keys: NULL
          key: firstName_lastName_age_index
      key_len: 66
          ref: NULL
         rows: 13
     filtered: 100.00
        Extra: Using index; Using filesort
1 row in set, 1 warning (0.00 sec)
```

- Using index
"覆盖索引扫描", 表示查询在索引树中就可查找所需数据, 不用扫描表数据文件, 一般性能不错

- Using temporary
查询有使用临时表, 一般出现于排序, 分组和多表 join 的情况, 查询效率不高, 建议优化.

## 总结
简单的介绍了以下 explain 的使用方法以及各种参数的意义。通常，我们应该经常来使用 explain 语句来分析我们的查询语句是否可以优化。尤其是判断索引的创建是否合理。

## 参考
[MySQL 性能优化神器 Explain 使用分析](https://segmentfault.com/a/1190000008131735)

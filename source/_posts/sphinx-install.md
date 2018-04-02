---
title: Sphinx 在 Linux 下的安装与基本配置
date: 2016-09-06
categories: Coding
tags:
  - Sphinx
  - Linux
  - Mysql
---
----------------------------------

## 下载

Sphinx 官网：http://sphinxsearch.com/
wget http://sphinxsearch.com/files/sphinx-2.2.10-release.tar.gz

## 安装

### 解压压缩包

```
tar zxvf sphinx-2.2.10-release.tar.gz
cd sphinx-2.2.10-release
```

找到 mysql 的安装目录，我的是在 /usr/bin/mysql 执行 /usr/lcoal/sphinx 为 sphinx 的安装目录。

```
sudo ./configure --prefix=/usr/local/sphinx --with-mysql=/usr/local/mysql
make 
make install
```

不出问题的话应该已经安装成功了

<!-- more -->

其他参数的配置

```
--with-mysql-includes=/usr/local/mysql/include/mysql/
--with-mysql-libs=/usr/local/mysql/lib/mysql/
--with-mmseg=/usr/local/mmseg/
--with-mmseg-includes=/usr/local/mmseg/include/mmseg/
--with-mmseg-libs=/usr/local/mmseg/lib/
```

## 配置

找到 sphinx 的安装目录 /usr/local/sphinx/etc .复制一份 sphinx.conf.dist 为 test.conf
打开文件对照注释编写配置文件。由于都是英文，这里将经常用到的一些配置做解释如下：

数据源配置解析：

```
source 
{
 # 数据源类型 mysql，pgsql，mssql，xmlpipe，xmlpipe2，odbc
 type			= mysql
 # -------------------------连接sql数据源的一些配置---------------------------
 sql_host        = localhost
 sql_user        = root
 sql_pass       = 123456
 sql_db           = test
 sql_port         = 3306
 #  使用 unix sock连接可以使用这个
 #sql_sock      = /tmp/mysql.sock

 # --------------------------mysql 相关配置----------------------------------------

 # mysql 与 sphinx 之间的交互，0/32/2048/32768  无/使用压缩协议/握手后切换到ssl/Mysql 4.1版本身份认证。
 mysql_connect_flags   = 32
 ## 当mysql_connect_flags设置为2048（ssl）的时候，下面几个就代表ssl连接所需要使用的几个参数。
 # mysql_ssl_cert        = /etc/ssl/client-cert.pem
 # mysql_ssl_key     = /etc/ssl/client-key.pem
 # mysql_ssl_ca      = /etc/ssl/cacert.pem

 #---------------------------mssql 相关配置----------------------------------------
 # 是否使用 windows 登陆
 # mssql_winauth     = 1
 # 使用unicode还是单字节数据
 # mssql_unicode     = 1
 
 #----------------------------odbc 相关配置-------------------------------------------
 odbc_dsn      = DBQ=C:\data;DefaultDir=C:\data;Driver={Microsoft Text Driver (*.txt; *.csv)};

 #-----------------------------sql 相关配置--------------------------------------------
 # sql某一列的缓冲大小，一般是针对字符串来说的
 # sql_column_buffers    = content=12M, comments=1M
 # 索引的 sql 执行前需要执行的操作，比如设置字符串为 utf8
 sql_query_pre     = SET NAMES utf8
 # 索引的 sql 执行语句
 sql_query       =  SELECT id, name, age FROM test
 # 联合查询
 # sql_joined_field是增加一个字段，这个字段是从其他表查询中查询出来的。
 # 如果是query，则返回id和查询字段，如果是payload-query，则返回id，查询字段和权重
 # 查询需要按照id进行升序排列
 # sql_joined_field  = tags from query; SELECT docid, CONCAT('tag',tagid) FROM tags ORDER BY docid ASC
 # sql_joined_field  = wtags from payload-query; SELECT docid, tag, tagweight FROM tags ORDER BY docid ASC

 #----------------------------字段属性的配置（用于过滤和排序）----------------------------------------
 # uint无符号整型属性
 sql_attr_uint       = id
 # 布尔值属性
 # sql_attr_bool     = is_deleted
 # 长整型属性(有负数用 bigint)
 # sql_attr_bigint       = my_bigint_id
 # 时间戳属性，经常被用于做排序
 sql_attr_timestamp  = date_added
 # 字符串排序属性。一般我们按照字符串排序的话，我们会将这个字符串存下来进入到索引中，然后在查询的时候比较索引中得字符大小进行排序。
 # 但是这个时候索引就会很大，于是我们就想到了一个方法，我们在建立索引的时候，先将字符串值从数据库中取出，暂存，排序。
 # 然后给排序后的数组分配一个序号，然后在建立索引的时候，就将这个序号存入到索引中去。这样在查询的时候也就能完成字符串排序的操作。
 # 这，就是这个字段的意义。
 # sql_attr_str2ordinal  = author_name
 # 浮点数属性
 # sql_attr_float        = lat_radians
 # sql_attr_float        = long_radians
 # 字符串属性
 # sql_attr_string       = stitle
 # 文档词汇数记录属性。比如下面就是在索引建立的时候增加一个词汇数的字段
 # sql_attr_str2wordcount    = stitle
}

 # sphinx 的 source 有继承属性，也就是说共有的部分可以写在父级数据源中，比如数据库连接配置信息
 source main_0: main
{
   sql_ranged_throttle = 100
}

```

索引配置解析：

```
index test1
{
   # 索引类型，包括有plain，distributed和rt。分别是普通索引/分布式索引/增量索引。默认是plain。
   # type          = plain
   # 索引数据源
   source          = src1
   # 索引文件存放路径
   path            =/usr/local/sphinx/var/data/src1
   # 字符集编码类型，可以为sbcs,utf-8
   charset_type        =  utf-8
   # 字符表和大小写转换规则
   # 'sbcs' default value is
   # charset_table     = 0..9, A..Z->a..z, _, a..z, U+A8->U+B8, U+B8, U+C0..U+DF->U+E0..U+FF, U+E0..U+FF
   # 'utf-8' default value is
   # charset_table     = 0..9, A..Z->a..z, _, a..z, U+410..U+42F->U+430..U+44F, U+430..U+44F
}
```
  
搜索服务searchd 配置

```
searchd
{
   # 监听端口
   listen          = 9312
   listen          = 9307:mysql4
   # 监听日志路径
   log             = /usr/local/sphinx/var/log/searchd.log
   # 查询日志路径
   query_log       = /usr/local/sphinx/var/log/query.log
   # 客户端读超时时间
   read_timeout    = 5
   # 客户端持久时间
   client_timeout  = 300
   #并行执行搜索数量
   max_children    = 0
   #进程 pid 文件
   pid_file        = /usr/local/sphinx/var/log/searchd.pid
   #当进行索引轮换的时候，可能需要消耗大量的时间在轮换索引上。
   # 启动了无缝轮转，就以消耗内存为代价减少轮转的时间
   seamless_rotate = 1
   # 索引预开启，强制重新打开所有索引文件
   preopen_indexes = 1
   # 索引轮换成功之后，是否删除以.old为扩展名的索引拷贝
   unlink_old      = 1
   # 多值属性MVA更新的存储空间的内存共享池大小
   mva_updates_pool = 1M
   #网络通讯时允许的最大的包的大小
   max_packet_size = 8M
   # 每次查询允许设置的过滤器的最大个数
   max_filters     = 256
   # 单个过滤器允许的值的最大个数
   max_filter_values = 4096
   # 每次批量查询的查询数限制
   max_batch_queries = 32
   # 多处理模式（MPM）。 可选项；可用值为none、fork、prefork，以及threads。 默认在Unix类系统为form，Windows系统为threads。
   workers         = form
}
```

## 开启sphinx

### 生成索引

```
/usr/local/sphinx/bin/indexer --config /usr/local/sphinx/etc/test.conf --all
```

### 打开 sphinx 进程

```
/usr/local/sphinx/bin/searchd --config /usr/local/sphinx/etc/sphinx.conf
```

## 参考

1. http://www.cnblogs.com/yjf512/p/3598332.html


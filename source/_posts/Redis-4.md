---
title: Redis系列（四）：Redis 持久化机制
date: 2018-09-25 17:41:47
categories: Redis
banner: /images/redis_logo.png
thumbnail: /images/redis_logo.png
tags: 
  - redis
---
----------------------------------

Redis 作为最流行的非关系型数据库之一，既然是数据库就应该具备数据持久化的机制，本篇文章将针对 Redis 的数据持久化与数据恢复来进行讨论。

<!-- more -->

## 什么是持久化？
简单来说，持久化就是将数据放到即使断电后数据也不会丢失的设备中，一般是物理设备，通常理解为硬盘

## Redis 持久化机制
Redis 提供了两种持久化机制，分别是 Snapshotting（快照&RDB）和 AOF（Append Only File）持久化机制。

## 快照持久化
快照是 Redis 默认的持久化方式，这种方式就是将内存中的数据以快照的方式写入到二进制文件中，默认
的文件名为 dump.rdb，默认文件在 Redis 启动的当前目录下，rdb 文件的路径可通过配置文件更改。
我们也可以配置 `Redis 在 n 秒内如果超过 m 个 key 被修改`就自动做快照，默认的快照持久化的配置如下：

```$xslt
# 快照持久化的配置
save 900 1 // 900 秒内超过 1 个 key 被修改就执行快照
save 300 10 // 300 秒内超过 10 个 key 被修改就执行快照
save 60 10000 // 60 秒内超过 10000 个 key 被修改就执行快照

# 快照 rdb 文件的位置
dbfilename dump.rdb
```

快照的执行过程：
1. 客户端手动执行 `save` 或 `bgsave` 命令发起执行快照的请求或者 redis 触发了执行快照的条件发起快照请求
2. redis 调用 fork 函数，创建新的子进程
3. 为了不影响 redis 的本身的工作，父进程继续处理 Client 的请求，子进程负责将内存中的内容写到临时文件中。 
`这里需要注意的是，由于操作系统的写时复制机制，也就是说发生 fork 的时候，父进程和子进程是共享相同的内存空间，
当父进程接受到写处理请求时，操作系统会为主进程创建要修改的数据的副本，而不影响子进程的数据。所以子进程快照的数据
是 fork 那一刻整个数据库的数据`
4. 当子进程写完临时文件之后，用临时文件替换掉原来的快照文件，然后子进程退出。

注意点：
1. 快照持久化方式是每次都将内存中的数据持久化数据完整的写入到磁盘，并不是只同步增量的数
据，如果数据量很大的话，写操作比较多，会引起大量的磁盘 I/O, 可能会严重影响性能。
2. 关于 `save` 和 `bgsave` 命令，都是用来快照镜像的操作.
`save` 命令是在 redis 主线程中操作的，会阻塞所有的 Client 的请求。不推荐使用
`bgsave` 命令是非阻塞的方式来对数据快照。是推荐的使用快照的方式。

## AOF 持久化
既然已经有了快照的持久化方式，还需要 AOF 持久化吗？我们来分析一种情况：
由于 Redis 快照的方式并不是实时的，是在一定的时间间隔内才执行快照操作，事实上也不能实时快照，数据量比较大的情况下，磁盘 I/O 会严重影响性能。
如果在 Redis 上一次持久化之后到下一次持久化之间，Redis 突然 down 掉了。那岂不是有部分数据没有持久化到磁盘，操作数据丢失。如此一来，就需要依靠 AOF 的持久化机制来保证数据的不丢失。

Append Only File，读取字面意思，就是将数据追加到文件中。其工作原理是 `Redis 将每一个收到的写命令
都通过系统调用 write 函数追加到 aof 文件中`，默认是 appendonly.aof。当然操作系统会在内核中缓存 
write 所作的修改，所以可能并不是立即写入到磁盘上。这样其实 AOF 的持久化机制也会丢失一部分的数据，
但是我们可以通过修改配置文件使 redis 使用 `fsync` 来强制将数据同步到磁盘上，具体的配置如下：

```$xslt
# 启用 aof 的持久化机制
appendonly yes
# aof 文件的位置
appendfilename "appendonly.aof"
# 持久化的时机：always、everysec、no
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
# redis在恢复时，会忽略最后一条可能存在问题的指令。默认值yes。
# aof 写入时，可能存在指令写错的问题(突然断电，写了一半)，
# 这种情况下，yes会log并继续，而no会直接恢复失败.
aof-load-truncated yes
```

`注意：` del 命令如果删除一个不存在的 key 并不会被记录在 aof 日志中因为 redis 判断出该操作并没有对数据集做出修改。

### AOF 持久化时机
- always 总是写入 aof 文件，并完成磁盘的同步，速度最慢，但是最安全，不会丢失数据
- everysec 每秒一次写入 aof 文件，并完成磁盘同步。默认的配置，最多会有 1 秒的数据丢失
- no 完全依赖操作系统写入磁盘，速度最快，但可能会丢失计较多的数据

### AOF 持久化的问题
持久化的 aof 文件越来越大，所有的写操作都会追加到 aof 日志文件里，但其实恢复数据只往往需要最后的几条写命令。
所以为了解决这个问题，redis 提供了 `BGREWRITEAOF` 命令压缩持久化文件。

### AOF 文件重写压缩原理
收到此命令之后，redis 会使用和快照类似的方式将内存中的数据以命令的方式保存到临时文件中，最后替换原来的 aof 文件。具体的过程如下：

- redis 收到 `BGREWRITEAOF`命令
- redis 调用 fork 函数，创建新的子进程
- 父进程继续处理 client 请求，除了把命令继续写入到 aof 文件中，同时把写命令写入到缓存中，保证子进程重写失败的话不会出问题。
- 子进程把快照的内容以命令的方式写到临时文件后，子进程发信号通知父进程，父进程把缓存的写命令也写入到临时文件中
- 父进程用临时文件替换掉旧的 aof 文件，并重新命名，后面收到的命令也重新往新的 aof 文件中追加

aof 文件压缩相关配置：
```$xslt
# 是否不使用 fsync 的方式重写
no-appendfsync-on-rewrite no
# aof 文件增长的比例
auto-aof-rewrite-percentage 100
# aof 文件重写的最小大小
auto-aof-rewrite-min-size 64mb
```

### 深挖 BGREWRITEAOF 配置

- no-appendfsync-on-rewrite 参数
当进行 `bgrewriteof` 命令操作的时候，主进程也会继续写 aof 文件，子进程会写临时的 aof 文件，只要是写文件就会进行磁盘的 I/O 操作，如此一来，就会两个进程就会竞争磁盘。为了解决不竞争磁盘，
`bgrewriteof` 同时也可以配置是否是采用 `fsync` 方式来强制写入磁盘，具体的配置字段是 `no-appendfsync-on-rewrite`:
`no-appendfsync-on-rewrite no` ：意思是 `appendfsync` 是 `yes`, 也就是说会采用 `fsync` 每次都强制写磁盘，该种方式比较安全，不会造成数据丢失，但是磁盘的写入操作会和主进程的磁盘写入造成竞争，会阻塞主进程的磁盘写入
`no-appendfsync-on-rewrite yes`: 意思是  `appendfsync` 是 `no`, 也就是说不会采用 `fsync` 不是每次强制写入磁盘，而是先写入到缓冲区，这样就不会和主进程的写入造成竞争，但是，如果这个时候 Redis 挂掉来，那就会造成数据丢失，
默认在 Linux 操作系统写会丢失 `30s` 的数据。
所以，如果无法忍受延迟，而可以容忍少量的数据丢失，则设置为 `yes`；如果无法忍受数据丢失，则设置为 `no`

- auto-aof-rewrite-percentage 参数
aof 文件增长的比例，即当前的 aof 文件的大小相比上一次重写时候的 aof 文件的比例大小。默认是 100%，也就是 1 倍。当增长到 1 倍的时候。Redis 就会启动 aof 重写来压缩文件大小

- auto-aof-rewrite-min-size 参数
aof 文件重写的最小的文件大小。即最开始的 aof 重写当文件必须要到达配置的大小时才会触发。后面每次的重写就不会根据这个变量来，会根据上面的重写文件增长比例 `auto-aof-rewrite-percentage`来触发

## 数据恢复机制
我们首先要明白为什么要持久化，持久化的核心就是当`服务崩溃之后数据不至于不丢失`。那么如何来对数据进行恢复呢？

![Redis 数据恢复流程](/images/redis_hf.png)

从流程图可以看出，Redis 在启动服务的时候是自动的进程数据恢复。不需要手动操作。

两种数据文件的恢复过程，相对来说RDB的启动恢复可能会更短一些，原因有两个:
- RDB 的文件中每一条数据只有一条记录，不会像 AOF 日志那样可能存在一条数据有多此操作记录的情况。
- RDB 的文件存储格式与 Redis 数据在内存中的编码格式一致，不需要再进行数据编码工作，CPU 消耗较小。

下面是 AOF 文件的载入与还原过程：

![AOF 文件恢复流程](/images/redis_hf.png)

## 两种持久化方式的对比

### Snapshotting 快照
优点：
- 性能最大化，采用 fork 子进程的方式快照，主进程继续处理命令
- 文件的数据格式和内存的编码一直，恢复数据快速方便

缺点：
- 由于是不定时的进行快照，会造成数据丢失，数据安全性低

### Aof 
优点：
- 数据安全性高，aof 持久化可以配置 appendfsync ，每次强制写入磁盘。
- 采用 append 模式写文件，即使中途宕机，可以通过 redis-check-aof 工具解决一致性问题
- aof 机制提供 rewrite 重写模式来压缩 aof 文件。

缺点：
- 可能文件会比 rdb 文件要大
- 数据集大的时候，服务启动数据恢复时间比rdb时间长

### 如何选择？
那么到底该如何选择使用那种持久化机制？
通常来说，如果想要提供很高的数据保障性，那么同时使用两种方式持久化机制。
如果可以接受带来的几分钟的数据丢失，那么可以直接使用默认的持久化机制 `快照`。

个人建议，生产环境使用持久化机制，最好两种方式都开启。

## 总结
可以看到，Redis 的持久化机制是可以保证数据可靠性。在使用 Redis 的时候可以根据实际的业务场景来合理的选择不同的持久化方案。

## 参考
[redis的持久化和缓存机制](https://blog.csdn.net/tr1912/article/details/70197085?)
[Redis的2种持久化方式对比](https://blog.csdn.net/gangchengzhong/article/details/52859225)
[redis的no-appendfsync-on-rewrite参数](http://blog.sina.com.cn/s/blog_14e63d3fe0102we43.html)
[Redis提供的持久化机制（RDB和AOF）](https://www.cnblogs.com/xingzc/p/5988080.html)
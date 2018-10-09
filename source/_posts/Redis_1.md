---
title: Redis系列（一）：Redis 主从同步集群模式
date: 2018-09-23
categories: Coding
tags:
  - redis
---
----------------------------------

在生产环境中，为了保证 Redis 服务的高可用，我们往往要使用 Redis 的集群模式，Redis 的集群模式有三种：主从同步集群模式、哨兵集群模式、Cluster 集群模式，本篇文章先介绍 Redis 主从同步集群模式的原理及实现。

## 什么是主从同步

简单来说，`主从同步` 就是指以一个主节点作为基准节点，将数据同步给从节点，使得主从节点的数据保持一致。这里的主节点一般也称为 Master 节点，从节点一般也叫做 Slave 节点。一个 Master 节点可以
拥有多个 Slave 节点。这种架构就叫做 `一主多从` 的主从架构。如果每一个 Slave 节点也作为基准节点，同时也拥有多个 Slave 节点，那么这中架构就叫做 `级联结构`的主从架构。本篇文章仅研究 `一主多从`主从架构。

![一主多从&级联结构](/images/redis_1.png)

## Redis 主从同步集群模式的应用场景

```
那么什么时候需要使用主从同步的集群模式？
```
个人认为 Redis 主从同步有一下几种应用场景

### 场景一：Slave 作为 Master 节点的数据备份
主从服务器架构的设计，可以大大加强 Redis 服务的健壮性。当主服务器出现故障时，可以人工或自动切换到从服务器继续提供服务，同时当主服务器的数据因为某种原因不能恢复时，可以使用从服务器备份的数据。
除了这些之外，还经常使用从服务器来处理一些操作比较耗时的命令，以防止阻塞主服务器的工作，导致主服务的请求不能及时处理。
例如: Redis里面有1亿个key，其中有10w个key是以某个固定的已知的前缀开头的，如果将它们全部找出来？我们知道使用 `keys` 命令可以扫出指定模式的 key 列表。

```
如果 Redis 正在线上提供服务，会有什么问题吗？
```

因为 Redis 是单线程的，keys 指令会导致线程阻塞一段时间，线上服务会停顿，直到指令执行完毕，服务才能恢复。这个时候如果我们可以将 Redis 配置一个从服务器，将比较耗时或者阻塞的操作都在从
服务器来操作，以防止主服务器停顿。当然除了这种解决办法，还可以使用 scan 命令（scan 命令是无阻塞的）来扫描出需要的 key , 但是有一定的重复率。可以在客户端进行去重。

### 场景二：数据读写分离
读写分离的场景往往是我们最多使用的场景，类似于 Mysql 读写分离，一般是主服务器来提供写操作，从服务器提供读操作。主服务器的写操作会同步给从服务器。
数据读写分离将读操作和写操作隔离开，使得读写相互不影响效率，提高了服务的读写速度。

### 场景三：多个从服务器根据业务拆分
此种场景其实是基于场景二的基础上增加的，当读多写少的情况下，我们还可以根据读的不同业务将多个从服务器拆分，例如，从服务器 A 专门用来提供视频业务的数据访问，从服务 B 专门用来新闻业务的数据访问，从服务器 C 专门用来提供用户的数据访问。
此种场景不仅减轻了主服务器的压力，同时也使得不同的业务数据访问互不影响。

## Redis 主从同步的配置
Redis 的安装这里不再介绍，我们以两台机器为例来搭建主从同步的 Redis 集群，一台在 windows 下，一个 Redis 实例为 192.168.238.1:6379; 一台在虚拟机里， 两个 Redis 实例为 192.168.238.129:6379, 192.168.238.129:6380
假如我们配置让 windows 机器的 Redis 实例为主节点，另外两个节点为从节点。

### 配置
- 运行主节点的 Redis 实例
```$xslt
> redis-server.exe
[8616] 09 Oct 17:31:00.826 # Server started, Redis version 3.0.502
[8616] 09 Oct 17:31:00.826 * DB loaded from disk: 0.000 seconds
[8616] 09 Oct 17:31:00.826 * The server is now ready to accept connections on port 6379
```

- 运行节点的 Redis 实例
从节点有两种方式来指定自己所需要连接的主节点，一种是直接在启动的命令行参数指定，一种是修改 /etc/redis.conf 文件，两个从节点为分别用两种不同的方式来演示：

从节点 192.168.238.129:6379 采用命令行参数的方式指定 Master
```$xslt
> /usr/local/redis/bin/redis-server --slaveof 192.168.238.1 6379
13316:S 21 Sep 21:46:05.087 * The server is now ready to accept connections on port 6379
13316:S 21 Sep 21:46:05.087 * Connecting to MASTER 192.168.238.1:6379
13316:S 21 Sep 21:46:05.087 * MASTER <-> SLAVE sync started
13316:S 21 Sep 21:46:05.088 * Non blocking connect for SYNC fired the event.
13316:S 21 Sep 21:46:05.093 * Master replied to PING, replication can continue...
13316:S 21 Sep 21:46:05.100 * Partial resynchronization not possible (no cached master)
13316:S 21 Sep 21:46:05.118 * Full resync from master: 3c4a283f5c5f503d833bf3cad3ae1adde7af283d:1
13316:S 21 Sep 21:46:05.337 * MASTER <-> SLAVE sync: receiving 44 bytes from master
13316:S 21 Sep 21:46:05.338 * MASTER <-> SLAVE sync: Flushing old data
13316:S 21 Sep 21:46:05.339 * MASTER <-> SLAVE sync: Loading DB in memory
13316:S 21 Sep 21:46:05.339 * MASTER <-> SLAVE sync: Finished with success
```

从节点 192.168.238.129:6380 采用修改配置文件的方式指定 Master
打开 redis 的配置文件，修改 salveof 配置
```$xslt
265 # slaveof <masterip> <masterport>
266 slaveof 192.168.238.1 6379
```

运行从节点 Redis 实例
```$xslt
> /usr/local/redis/bin/redis-server /usr/local/redis/etc/redis_6380.conf
13521:S 21 Sep 21:52:34.853 * The server is now ready to accept connections on port 6380
13521:S 21 Sep 21:52:34.854 * Connecting to MASTER 192.168.238.1:6379
13521:S 21 Sep 21:52:34.854 * MASTER <-> SLAVE sync started
13521:S 21 Sep 21:52:34.860 * Non blocking connect for SYNC fired the event.
13521:S 21 Sep 21:52:34.863 * Master replied to PING, replication can continue...
13521:S 21 Sep 21:52:34.866 * Partial resynchronization not possible (no cached master)
13521:S 21 Sep 21:52:34.885 * Full resync from master: 3c4a283f5c5f503d833bf3cad3ae1adde7af283d:547
13521:S 21 Sep 21:52:35.063 * MASTER <-> SLAVE sync: receiving 44 bytes from master
13521:S 21 Sep 21:52:35.063 * MASTER <-> SLAVE sync: Flushing old data
13521:S 21 Sep 21:52:35.063 * MASTER <-> SLAVE sync: Loading DB in memory
13521:S 21 Sep 21:52:35.063 * MASTER <-> SLAVE sync: Finished with success
```

这时，我们注意观察一下主节点的输出，我们能看出，主节点已经和两个从节点同步成功
```$xslt
[8616] 09 Oct 17:37:39.515 * Slave 192.168.238.129:6379 asks for synchronization
[8616] 09 Oct 17:37:39.517 * Full resync requested by slave 192.168.238.129:6379
[8616] 09 Oct 17:37:39.517 * Starting BGSAVE for SYNC with target: disk
[8616] 09 Oct 17:37:39.523 * Background saving started by pid 5384
[8616] 09 Oct 17:37:39.657 # fork operation complete
[8616] 09 Oct 17:37:39.657 * Background saving terminated with success
[8616] 09 Oct 17:37:39.658 * Synchronization with slave 192.168.238.129:6379 succeeded
[8616] 09 Oct 17:43:09.583 * Slave 192.168.238.129:6380 asks for synchronization
[8616] 09 Oct 17:43:09.592 * Full resync requested by slave 192.168.238.129:6380
[8616] 09 Oct 17:43:09.599 * Starting BGSAVE for SYNC with target: disk
[8616] 09 Oct 17:43:09.601 * Background saving started by pid 8996
[8616] 09 Oct 17:43:09.778 # fork operation complete
[8616] 09 Oct 17:43:09.778 * Background saving terminated with success
[8616] 09 Oct 17:43:09.779 * Synchronization with slave 192.168.238.129:6380 succeeded
```

> 注意：如果主节点启用了密码认证，需要将从节点的配置文件的配置 masterauth xxxxxx 修改

### 验证
不要轻易相信别人说的，要始终相信眼睛看到；接下来我们来验证一下主服务器是否能将数据同步到两个从服务器

- 主节点
```$xslt
> redis-cli.exe
127.0.0.1:6379> set "foo" bar
OK
127.0.0.1:6379> get "foo"
"bar"
127.0.0.1:6379>
```

- 从节点1
```$xslt
> ./redis-cli -p 6379
127.0.0.1:6379> get foo
"bar"
127.0.0.1:6379> 
```

- 从节点2
```$xslt
> ./redis-cli -p 6380
127.0.0.1:6380> get foo
"bar"
127.0.0.1:6380> 
```

至此，`一主两从` 的 Redis 主从同步集群已经搭建成功。

## Redis 主从同步的原理
虽然我们已经能够配置并使用主从同步的 Redis 集群，但是我们还是有必要了解一下主从同步的实现原理，这样才能在遇到问题的时候迅速判断问题的发生的原因。
Redis 主从同步分为两个过程：全量同步和增量同步

### 全量同步
全量同步一般发生在 Slave 的初始化阶段，也就是 Slave 节点的启动阶段。具体的步骤如下（最好对照着刚刚启动的日志来看）：
- 从服务器连接主服务器（Log: Connecting to MASTER 192.168.238.1:6379）
- 从服务器发送 `SYNC` 命令到主服务器（Log: MASTER <-> SLAVE sync started）
- 主服务器接收到 `SYNC` 命名后，开始执行 `BGSAVE` 命令生成 `RDB` 文件并使用缓冲区记录此后执行的所有写命令（Log: Starting BGSAVE for SYNC with target: disk）
- 主服务器 `BGSAVE` 执行完后，向所有从服务器发送快照文件，并在发送期间继续记录被执行的写命令（Log: Synchronization with slave 192.168.238.129:6379 succeeded）
- 从服务器收到快照文件后丢弃所有旧数据，载入收到的快照（Log: MASTER <-> SLAVE sync: Flushing old data）
- 从服务器将快照载入内存（Log: MASTER <-> SLAVE sync: Loading DB in memory）
- 主服务器快照发送完毕后开始向从服务器发送缓冲区的写命令
- 从服务器完成对快照的载入，开始接收主服务器发送的写命令请求，并执行写命令。
- 至此，一次全量同步完成
 
### 增量同步
增量同步是指 Redis 在主从模式已经正常工作的情况下，主服务器将写操作同步到从服务器的过程
增量复制的原理当主服务器每执行一个写命令，就会将该命令发送给所有的从服务器，从服务器接收到命令之后立即执行。

### 深挖细节
1. 主节点执行 `BGSAVE` 生成全量镜像的 RDB 文件，是如何来工作的？
首先 `BGSAVE` 指令是用来在后台异步保存当前数据库的数据到磁盘，所以同步是异步的，不会阻塞主节点的进程，当执行 `BGSAVE` 后，会立即返回 OK, 然后 Redis `fork 出一个新子进程` 来专门生成全量镜像文件的工作，将数据保存到磁盘后，子进程退出。

2. 当主节点在 `BGSAVE` 的过程中，又有新的写请求到来，主节点怎么工作？这些写数据怎么保存？
根据 1 的细节，我们知道主节点会有一个新的子进程来单独处理全量镜像的生成工作，那么主节点父进程可以继续来接收新的请求。这里需要注意的是，当发生 fork 的时候，Redis 采用`写时复制（copy-on-write）策略`
即 fork 函数发生的那一刻，父子进程共享同一块内存数据，当父进程接收到写操作时，操作系统会复制一份数据以保证子进程的数据不受影响。所以新生产的 RDB 文件存储的是执行 fork 那一刻的数据。

3. 主服务执行 `BGSAVE` 命令如果内存不够生成 `rdb` 文件数据的大小怎么办？不能同步了吗？
可以采用 `无磁盘复制` 技术; 通常来讲，一个完全重同步需要在磁盘上创建一个 RDB 文件，然后加载这个文件以便为从服务器发送数据。如果使用比较低速或者容量较小的磁盘，这种操作会给主服务器带来较大的压力。
Redis从2.8.18版本开始尝试支持无磁盘的复制。使用这种设置时，子进程直接将RDB通过网络发送给从服务器，不使用磁盘作为中间存储。

配置键如下：
```

```

4. 主从同步的过程中，从服务器是阻塞的吗？
主从同步的过程中，也不会阻塞从服务器。当从服务器进程初始同步时，会使用旧的数据继续提供查询服务。当然这个也可以在配置文件修改。但是，需要注意的是，并不是整个过程都是不阻塞的，当从服务器接受到快照文件，需要删除旧的快照并加装新的数据集到内存，在这个短暂的
时间内，从服务器会阻塞连接进来的请求。



## Slave 节点宕掉的处理

## Master 节点宕掉的处理

## Redis 主从同步的优缺点

## 总结

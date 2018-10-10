---
title: Redis系列（二）：Redis 哨兵集群模式
date: 2018-09-24 12:09:10
categories: Coding
tags:
  - redis
---
----------------------------------

上一篇文章介绍了 Redis 集群的主从同步模式，虽然配置简单，但是缺点也十分突出：Master 内存受限，Master 宕机之后不能自动切换，不能水平扩容等等。本篇文章来介绍 Redis 的第二种集群模式 `哨兵模式`

## 什么是哨兵模式(Redis Sentinel)
哨兵（Sentinel）模式下会启动多个哨兵进程，哨兵进程的作用如下：
- 监控：能持续的监控 Redis 集群中主从节点的工作状态
- 通知：当被监控的节点出现问题之后，能通过 API 来通知系统管理员或其他程序
- 自动故障处理：如果发现主节点无法正常工作，哨兵进程将启动故障恢复机制把一个从节点提升为主节点，其他的从节点将会重新配置到新的主节点，并且应用程序会得到一个更换新地址的通知

## 哨兵模式的应用场景
当采用 Master-Slave 的高可用方案时候，如果 Master 宕机之后，想自动切换，可以考虑使用哨兵模式。哨兵模式其实是在主从模式的基础上工作的。

## 哨兵模式搭建

### 版本
Redis-3.2

### 环境
- windows: Master 192.168.238.1:6379
- linux: Slave1 192.168.238.129:6379
- linux: Slave2 192.168.238.129:6380

### 配置

#### 主从配置
这里不再多说，参考上一篇文章 [Redis系列（一）：Redis 主从同步集群模式](https://phachon.github.io.com/2018/09/23/Redis_1/)

#### 哨兵配置
三个节点配置一样的哨兵文件 sentinel.conf
```$xslt
# sentinel 监控 master1 ip 端口 数字1，表示主机挂掉后salve投票看让谁接替成为主机，得票数多少后成为主机
sentinel monitor mymaster 192.168.238.1 6379 1

# sentinel 认为 Redis 实例已经失效所需的毫秒数。
# 当实例超过该时间没有返回PING，或者直接返回错误，那么 Sentinel 将这个实例标记为主观下线。
# 只有一个 Sentinel 进程将实例标记为主观下线并不一定会引起实例的自动故障迁移,
# 只有在足够数量的 Sentinel 都将一个实例标记为主观下线之后，实例才会被标记为客观下线，这时自动故障迁移才会执行
sentinel down-after-milliseconds mymaster 30000

# 指定了在执行故障转移时，最多可以有多少个从Redis实例在同步新的主实例，
# 在从Redis实例较多的情况下这个数字越小，同步的时间越长，完成故障转移所需的时间就越长
sentinel parallel-syncs mymaster 1
```

Slave1 和 Slave2 由于在同一台机器上，所以需要修改一下 sentinel.conf 哨兵进程的端口
- Slave1
```$xslt
port 26379
```

- Slave2
```$xslt
port 26380
```

### 启动哨兵

- Master: 192.168.238.1:6379
```$xslt
> redis-server.exe sentinel.conf --sentinel
[10072] 10 Oct 15:50:15.690 # Sentinel runid is 120e26e25ddcea66377350d516e881fe7a0ec87a
[10072] 10 Oct 15:50:15.690 # +monitor master mymaster 192.168.238.1 6379 quorum 1
```

- Slave1: 192.168.238.129:6379
```$xslt
> /usr/local/redis/bin/redis-sentinel /usr/local/redis/etc/sentinel_6379.conf
722:X 10 Oct 16:19:03.972 # Sentinel ID is 0cc1559a5f8de817e942771a0fdcdaf863fbe8ba
722:X 10 Oct 16:19:03.972 # +monitor master mymaster 192.168.238.1 6379 quorum 1
```

- Slave2: 192.168.238.129:6380
```$xslt
> /usr/local/redis/bin/redis-sentinel /usr/local/redis/etc/sentinel_6380.conf
728:X 10 Oct 16:19:16.833 # Sentinel ID is 336d2855a506398d18a95b05cd472bec191b9656
728:X 10 Oct 16:19:16.833 # +monitor master mymaster 192.168.238.1 6379 quorum 1
```

- 查看一下主节点的主从配置
```$xslt
127.0.0.1:6379> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=192.168.238.129,port=6379,state=online,offset=70740,lag=1
slave1:ip=192.168.238.129,port=6380,state=online,offset=70881,lag=0
```

至此 `一主两从三哨兵` 的集群模式已搭建成功

### 测试

#### 主从同步测试
- Master
```$xslt
> redis-cli.exe
127.0.0.1:6379> set "foo" bar1
OK
```
- Slave1
```$xslt
> ./redis-cli -p 6379
127.0.0.1:6379> get foo
"bar1"
```

- Slave2
```$xslt
> ./redis-cli -p 6380
127.0.0.1:6380> get foo
"bar1"
```

- 主从自动切换测试

首选先使 Master 节点宕掉
观察两个 Slave 节点的 sentinel 进程的输出日志：
```$xslt
728:X 10 Oct 16:33:55.970 # +sdown master mymaster 192.168.238.1 6379
728:X 10 Oct 16:33:55.970 # +odown master mymaster 192.168.238.1 6379 #quorum 1/1
728:X 10 Oct 16:33:55.970 # +new-epoch 8
728:X 10 Oct 16:33:55.970 # +try-failover master mymaster 192.168.238.1 6379
728:X 10 Oct 16:33:55.972 # +vote-for-leader 336d2855a506398d18a95b05cd472bec191b9656 8
728:X 10 Oct 16:33:55.983 # 120e26e25ddcea66377350d516e881fe7a0ec87a voted for 0cc1559a5f8de817e942771a0fdcdaf863fbe8ba 8
728:X 10 Oct 16:34:06.193 # -failover-abort-not-elected master mymaster 192.168.238.1 6379
```
Slave 的哨兵进程发现 Master 出现问题，然后选举 ID 336d2855a506398d18a95b05cd472bec191b9656 的节点（Slave2）为 Master 节点
我们查看一下 Slave2 的主从配置

> 未配置成功！！！！

## 工作原理


## 主从切换


## 哨兵模式优缺点

## 总结

## 参考
[Redis哨兵集群模式](https://www.cnblogs.com/PatrickLiu/p/8444546.html)
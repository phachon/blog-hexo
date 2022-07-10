---
title: Redis系列（八）：Redis 数据结构之 SkipList
date: 2018-12-30 12:22:10
categories: Redis
banner: /images/redis_logo.png
thumbnail: /images/redis_logo.png
tags: 
  - redis
---
----------------------------------

SkipList 跳跃表是一种有序的数据结构，通过每个节点中维持多个指向其他节点的指针，从而达到快速访问的目的。跳跃表是有序集合数据类型的底层实现之一。

<!-- more -->

## 跳跃表的演变
跳跃表本质上也是来解决查找问题，提高查找效率，通常情况下，我们使用两种数据结构：

- 树结构（二叉树，平衡树，红黑树）
- 哈希结构

但是，跳跃表并不属于这两类，从 skipList 名字来看，跳跃表其实是从有序链表演变而来。

### 链表
我们先来看看有序链表的查找方式

![普通链表](/images/link)

很明显，只能从表头查到表尾，时间复杂度为 O(n)

### 跳跃表
我们试图将链表增加层级来提高查找效率，如下图所示：

![跳跃表](/images/skiplist)

如果查找所需要的数据，，

## 跳跃表与平衡树对比

## redis 跳跃表的实现

## 有序集合中跳跃表的使用
有序集合 zset 的常用命令如下：
```
// 添加一个成员和分数
zadd key score member
// 获取成员分数
zscore key member
// 获取成员排名
zrevrank key member
// 获取排名范围的成员
zrevrange key 1 3
// 获取分数范围的成员
zrevrangebyscore key 60 80
```

- zscore 并没有用到 skiplist 而是通过 dict 实现，有序集合通过 dict 来保存成员到分数的对应关系
- zrevrank 先通过


## 总结


参考资料：
- [Redis为什么用跳表而不用平衡树？](https://blog.csdn.net/u010412301/article/details/64923131)

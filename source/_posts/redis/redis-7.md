---
title: Redis系列（七）：Redis 数据结构之 dict
date: 2018-12-30 12:22:10
categories: Redis
banner: /images/redis_logo.png
thumbnail: /images/redis_logo.png
tags: 
  - redis
---
----------------------------------

redis 作为 key value 的数据库，字典是 redis 使用非常多的数据结构之一，本篇文章简单来了解一下 redis 的内部字典的实现

<!-- more -->
## 字典的数据结构
redis 的字典的数据结构如下：
```c
typedef struct dict {
    
    // 类型特定函数
    dictType *type;

    // 私有函数
    void *privatdata;

    // 哈希表
    dictht ht[2];

    // rehash 索引
    // 当 rehash 不在进行时，为 -1
    int trehashidx;
}
```
ht属性，一个包含两个项的数组，数组的每一个元素都是 dicth 哈希表，一般情况下，字典只会使用 dict[0] 的哈希表，当进行 rehash 时候，才会需要用到 dicth[1] 的哈希表。

trehashidex 属性，跟 rehash 相关，记录当前 rehash 的索引值。

dictht 的数据结构如下：
```c
typedef struct dictht {
    
    // 哈希表数组
    dictEntry *table[];
    
    // table 大小
    int size;

    // 计算索引的掩码
    int sizemask;

    // 已使用的大小
    int used
}
```

每一个的 dictEntry 结构里都存着两个属性，key 和 val，也就是字典的 key 和 value

## 哈希算法
redis 的 hash 算法相对比较简单。分为两步：

1. 根据哈希函数计算出 key 的哈希值，得到哈希值
```
hash = hashFunc(key);
```

2. 根据哈希值和哈希表的掩码进行运算，得到哈希表的索引值
```
idx = hash & sizemask;
```

计算出的索引值即为该 key 和 value 在 table 中的存储位置。

## 哈希碰撞
使用 hashTable, 那么就必须要解决哈希碰撞。
```
哈希碰撞就是当 key 计算出来的哈希索引的位置上已经存在了一个 key，那么就是发生了哈希碰撞。就是两个 key 都哈希到了同一个哈希索引的位置上
```

redis 解决哈希碰撞的方法是：链地址法

当发生哈希碰撞时，哈希节点通过 next 指针连接起来构成单向链表。

为了速度考虑，程序总是将新节点添加到表头的位置（时间复杂度为 1），排在其他节点的前面。

## ReHash 的原理
随着操作的不断进行，哈希表中保存的 key 会增多获或减少，为了让 hash 表的负载因子维持在一个合理的范围之内，redis 会进行 rehash 的操作。
```
负载因子 = 哈希表已保存节点数量 / 哈希表的大小
```
当负载因子大于等于 1 会触发哈希表的扩展操作
当负载因子小于等于 0.1 会触发哈希表的收缩操作

rehash 的过程：  
1. 为字典的 ht[1] 分配空间，空间的大小取决于要执行的操作以及哈希表 ht[0] 包含的键值对的大小
2. 将保存在 ht[0] 上的所有的键 rehash 到 ht[1] 上，rehash 需要重新计算得到索引值。
3. rehash 完成后，ht[0] 为空，释放 ht[0]，将 ht[1] 设置为 ht[0], 并为 ht[1] 创建一个空白的哈希表，为下次 rehash 准备。


### 渐进式的 rehash
redis 如果只保存了少量的键值对，那么一次 rehash 可以很快完成，但是当健值对很多的时候，一次性全部 rehash 肯定会影响 redis 的性能。所以，trehashidx 的属性派上用场。

当不需要 rehash 的时候，rehashidx = -1，当需要 rehash 的时候，rehashidx = 0;

这时候，当该 hashTable 中需要操作时，除了操作指定的键以外，同时还会将 ht[0] rehashidx 的索引位置的所有的键值对 rehash 到 ht[1] 的 hastTable 中，完成后对 rehashidx + 1。随着操作的不断进行，最终会完成 ht[0] 到 ht[1] 全部  rehash 工作。

渐进式的 rehash 过程中，发生增删改查的操作时的处理：
1. 增加新的键值对，只会对 ht[1] 的表新增
2. 查找键值对，先查找 ht[0]，没有的话查找 ht[1]
3. 修改键值对，对 ht[0] 和 ht[1] 都进行修改
4. 删除键值对，对 ht[0] 和 ht[1] 同时删除

## 字典的使用场景
字典在 redis 的使用场景比较多。
1. redis 的 key value 的存储结构
1. redis 的 hash 存储结构
2. redis zaset 中根据 feild 查找 score
。。。

## 总结
hashtable 是最常使用的一种数据结构，因为有 1 的时间复杂度，在设计 hashtable 时，可以借鉴 redis 的哈希碰撞和 rehash 的设计。
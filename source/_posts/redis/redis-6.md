---
title: Redis系列（六）：Redis 数据结构之 SDS
date: 2018-12-17 12:22:10
categories: Redis
banner: /images/redis_logo.png
thumbnail: /images/redis_logo.png
tags: 
  - redis
---
----------------------------------

Redis 没有直接使用 C 语言的字符串数组，而是自己构建了一个简单动态字符串用于 Redis 底层的字符串表示，即 SDS (Simple Dynamic String)

<!-- more -->

## SDS 的数据结构
C 语言使用以空格结尾的字符串数组来表示字符串。

```c
+---+---+---+---+---+----+
| R | e | d | i | s | \0 |
+---+---+---+---+---+----+
```

sds 的数据结构

```c
struct sdshdr {
	
	// 记录了 buf 中已使用的数量
	int len
	
	// 记录了 buf 中未使用的数量
	int free
	
	// 用于存储字符串的数组
	char buf[]
}
```

可以看出，在 c 的基础上加了两个属性，len 和 free。

## SDS 的优化
sds 字符串主要从三方面进行了优化

### 1.提高获取字符串长度效率
传统的 c 语言获取字符串长度的方式是没次都遍历字符串数组，是件复杂度为 n
sds 增加了 len 属性，所以获取字符串的事件复杂度将为 1

### 2.防止缓冲区溢出
当拼接字符串的时候，字符串长度需要增加时候，如果是 c 语言，那么首先我们必须在拼接字符串之前要判断字符串数组是否能够容纳增加后的字符串，否则的话要先对字符串数组进行内存充分配。如果忘记判断，就就造成缓冲区的溢出。

sds 字符串在操作字符串的 API 内部都进行了判断，所以不需要使用者再去关心内存溢出的问题，所以是从根本上杜绝了内存溢出的可能。

### 3.减少内存重分配 
在 c 语言中，每次在扩展字符串的时候，我们都需要每次先进行内存重新分配的操作，当字符串缩短时，同样要进行内存释放，否则会造成内存泄漏。操作内存属于系统操作，相对比较耗时。

sds 字符串使用 free 属性来减少内存重分配，当发生字符串扩展时，redis 不只是将 sds 的 buf 数组增加到新数组的长度，二是会额外增加一部分的空闲空间，空闲空间的长度就是 free 属性的值。当下一次再进行字符串扩展时，首先会判断空闲的字符串长度是否够，如果够，则直接进行扩展，而不需要再进行内存充分配的操作。同样，当字符串进行缩短的时候，sds 也并不会马上进行内存释放，而是将多出来的空闲 buf 数组的值保存到 free 属性中，等待下次字符串需要的时候再使用。

所以，正常情况下，redis 的 sds 可能有部分内存浪费的情况，sds 也提供了手动清理空闲的 buf。

## SDS 二进制安全
c 语言的字符串数组只能存储 ASCII 编码的字符，并且会以空格 \0 作为字符串的结尾，例如我们存入一个 ‘redis cluster’ 的字符串，当通过 c 语言获取的时候，只会读取到 'redis'。

redis 的 sds 字符串 api 不会对输入的数据进行任何的处理，所以可以是压缩的图像，视频，文件的二进制数据，也可以是以空格分割的文本数据。当在读取的时候， sds 不会以空格为结尾读取，而是通过 len 属性来读取字符窜。

## SDS 兼容性
除了做了上面的一些优化和功能扩展之外，sds 的设计还充分考虑到和 c 字符窜的兼容性，所以，sds 的 buf 数组也是必须以空格结尾。这样做的好处在于，可以复用一部分的 c 字符串的函数。例如，我们存入的是简单的文本数据，那么就可以直接使用 c 语言的一部分函数来直接操作 buf 数组。

## 总结
从 redis 的 sds 的设计中，可以看到作者考虑问题的细致，一个看似简单的扩展，其实大大提高了字符串的使用效率。所以，我们在设计系统或是编写代码的过程中，应该习惯取多去思考一些细节。
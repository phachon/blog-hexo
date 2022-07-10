---
title: Go runtime 系列之 - 内存分配
date: 2018-09-09
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

<!-- more -->

参考文档：

- [Go 语言内存管理（一）：系统内存管理](https://mp.weixin.qq.com/s?__biz=MzkyMzI0NjkzMw==&mid=2247491623&idx=1&sn=f6ac324f4fe9c72ae394f5425deee344&source=41#wechat_redirect)
- [在 Go 中恰到好处的内存对齐](https://mp.weixin.qq.com/s/OUY5T8_o7mS5jB386WWWfA)
- [图解Go语言内存分配](https://mp.weixin.qq.com/s?__biz=MzkyMzI0NjkzMw==&mid=2247491643&idx=1&sn=6f9d92f755679860c3767572267ca826&source=41#wechat_redirect)
- [Go 内存分配器可视化指南](https://github.com/coldnight/go-memory-allocator-visual-guide)
- [tcmalloc 介绍](http://legendtkl.com/2015/12/11/go-memory/)
- [图解 TCMalloc](https://zhuanlan.zhihu.com/p/29216091)
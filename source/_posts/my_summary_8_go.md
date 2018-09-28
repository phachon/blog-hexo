---
title: 知识点总结系列之：（八）GO
date: 2015-07-21
categories: Summary
tags:
  - go
---
----------------------------------

go 相关的知识点总结

- Go基本数据类型及占用的字节？
- Go 值类型有哪些？
- Go 引用类型有哪些？
- 常量的声明？
- 错误处理？（error, panic, recover）
- 基本命令（build,get,run,test）
- 除了 mutex 以外还有那些方式安全读写共享变量？
- JSON 标准库对 nil slice 和 空 slice 的处理是一致的吗？
- 1.9/1.10中，time.Now()返回的是什么时间？这样做的决定因素是什么?
- golang的sync.atomic和C++11的atomic最显著的在golang doc里提到的差别在哪里，如何解决或者说规避？
- 1.10为止，sync.RWMutex最主要的性能问题最容易在什么常见场景下暴露。有哪些解决或者规避方法？
- 如何做一个逻辑正确但golang调度器(1.10)无法正确应对，进而导致无法产生预期结果的程序。调度器如何改进可以解决此问题？
- 列出下面操作延迟数量级(1ms, 10us或100ns等)，cgo调用c代码，c调用go代码，channel在单线程单case的select中被选中，high contention下对未满的buffered channel的写延迟。
- 如何设计实现一个简单的goroutine leak检测库，可用于在测试运行结束后打印出所测试程序泄露的goroutine的stacktrace以及goroutine被创建的文件名和行号。
- 选择三个常见golang组件（channel, goroutine, [], map, sync.Map等），列举它们常见的严重伤害性能的anti-pattern。
- 一个C/C++程序需要调用一个go库，某一export了的go函数需高频率调用，且调用间隔需要调用根据go函数的返回调用其它C/C++函数处理，无法改变调用次序、相互依赖关系的前提下，如何最小化这样高频调用的性能损耗？
- 不考虑调度器修改本身，仅考虑runtime库的API扩展，如果要给调度器添加NUMA awareness且需要支持不同拓扑，runtime库需要添加哪些函数，哪些函数接口必须改动。
- stw的pause绝大多数情况下在100us量级，但有时跳增一个数量级。描述几种可能引起这一现象的触发因素和他们的解决方法。
- 已经对GC做了较充分优化的程序，在无法减小内存使用量的情况下，如何继续显著减低stw pause长度。
- 有一个常见说法是“我能用channel简单封装出一个类似sync.Pool功能的实现”。在多线程、high contention、管理不同资源的前提下，两者各方面性能上有哪些显著不同
- 无缓冲 chan 的发送和接收是否同步？
- Data Race问题怎么解决？能不能不加锁解决这个问题？
- 使用goroutine以及channel设计TCP链接的消息收发，以及消息处理？
- 使用go语言，编写并行计算的快速排序算法？
- [golang新手可能会踩的50大坑](https://segmentfault.com/a/1190000013739000)
- uint不能直接相减，结果是负数会变成一个很大的uint，这点对动态语言出身的会可能坑
- channel一定记得close
- goroutine记得return或者中断，不然容易造成goroutine占用大量CPU
- 从slice创建slice的时候，注意原slice的操作可能导致底层数组变化
- 如果你要创建一个很长的slice，尽量创建成一个slice里存引用，这样可以分批释放，避免gc在低配机器上stop the world
- 面试的时候尽量了解协程，线程，进程的区别。
- 什么是channel，为什么它可以做到线程安全？
- channel 的实现机制？（通过注册相关goroutine id实现消息通知的）
- 如何用channel实现一个令牌桶？
- 如何调试一个go程序？
- 如何写单元测试和基准测试？
- slice 底层数据结构的实现？
- 抢占式goroutine调用？
- 了解读写锁吗，原理是什么样的，为什么可以做到？
- golang的内存模型，知道多小才是小对象，为什么小对象多了会造成gc压力？
- Devops 用过吗？
- golang 采用什么并发模型？体现在哪里？
- goroutine 的调度是怎样的？
- golang 的内存回收是如何做到的？
- cap和len分别获取的是什么？
- netgo，cgo有什么区别？
- 什么是interface？
- 在 Vendor 特性之前包管理工具是怎么实现的？


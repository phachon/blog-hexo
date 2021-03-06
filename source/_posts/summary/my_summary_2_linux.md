---
title: 知识点总结系列之：（二）Linux 与操作系统
date: 2015-07-15 
categories: Summary
tags:
  - Linux
---
----------------------------------

Linux 与操作系统的知识点总结

## 操作系统内核

- [什么是孤儿进程僵尸进程?](https://www.cnblogs.com/Anker/p/3271773.html)
- 指针对应的地址是不是物理地址？
- 物理地址和虚拟地址通常叫做什么？缩写是什么？
- 操作系统的寻址方式？
- Linux 中如何计算可用内存？
- Linux 中如何用 top 命令中查看虚地址和实地址的信息？
- 如何用搜索引擎去了解 top 中的虚地址？不用搜索引擎怎么知道？
- top 的输出中哪些是表明了内存？
- 根据 top 计算可用内存有多少？
- 用 top 看耗性能的线程？
- 还有哪些命令可以找出性能瓶颈？
- epoll 与 select 比较？
- epoll 的缺点，如何克服缺点？
- epoll 机制中文件描述符就绪时如何从内核态通知到用户态的进程？
- epoll 实现？
- 说说同步异步的区别？
- 进程间通信的方式？
- 进程间的通信有哪些机制？在资源内存方面比较如何？
- 同一进程线程间的通信；不同进程线程间的通信；
- 如何判断系统在哪些地方耗费性能？
- cpu 调度的单位是什么？
- 如何让多核 cpu 更好的利用资源？
- 什么是缺页？缺页的算法？缺页中断时操作系统怎么做？
- 如何控制两个进程对一个数据的访问？怎么处理加锁问题？
- 说一说协程？
- 是否了解 netstat？
- 在 shell 中用 ./a.out | wc- l 结果是多少？管道的输入是哪个进程的？
- 谈谈 Linux 的文件权限。让只有拥有者才能读写？让拥有者只能读和执行？ 删除文件需要什么权限？
- 假如一个进程在对文件进行读写，管理员把文件删除了怎么办？
- 协程与进程线程比较有什么优势？
- 计算机从电源加载开始的启动过程？
- 什么是中断调用？中断程序的分类？
- 内核态和用户态的区别？
- 为什么需要内核态？
- 什么时候进入内核态？
- 多线程需要加锁的变量？
- 程序在内存中的布局？
- 什么是死锁，如何防止死锁？
- lsof作用和使用？
- strace作用和使用？
- ptrace作用和使用？
- 什么是内存管理？
- Linux 内存管理的方案有哪些？
- 内存池的理解？
- 什么是内存泄漏？如何发现内存泄漏？如何避免内存泄漏？
- 栈空间的大小？
- 操作系统自旋锁？
- 进程调度的算法？
- 文件被如何加载到内存中？
- linux中各种 I/O 模型原理 —— select 和 epoll
- 阻塞和非阻塞 I/O 区别
- linux系统文件机制
- 多进程同步方式
- 使用过哪些进程间通讯机制，并详细说明（重点）
- linux系统的各类异步机制
- 信号：列出常见的信号，信号怎么处理？
- i++ 是否原子操作？
- exit() _exit()的区别？
- linux的内存管理机制是什么？
- linux的任务调度机制是什么？
- 系统如何将一个信号通知到进程？
- 什么是死锁？如何避免死锁？
- 共享内存的使用实现原理？
- 多线程和多进程的区别（从cpu调度，上下文切换，数据共享，多核cup利用率，资源占用，等等各方面回答。哪些东西是一个线程私有的？答案中必须包含寄存器）；
- 标准库函数和系统调用的区别？
- 地址空间的栈和堆的大小限制？ 
- 静态库和动态库的区别？

## Linux 命令 
- ln 硬链接和软链接区别？
- kill 进程杀不掉的原因？
- linux 查看日志文件的方式？
- 常用的命令
    - ls
    - -l
    - -a
    - mkdir (-p)
    - cd
    - touch
    - echo 
    - cat
    - cp
    - mv
    - rm (-r,-f)
    - find
    - wc
    - grep
    - rmdir
    - tree
    - pwd
    - ln
    - more,less
    - head,tail
- 系统管道命令
    - stat
    - who
    - whoami
    - hostname
    - top
    - ps
    - du
    - df
    - ifconfig
    - ping
    - netstat
    - man
    - clear
    - alias
    - kill
    
- 解压缩
    - gzip
    - bzip
    - tar(c,x,z,j,v,f)
    
- 关机重启
    - shutdown(-r,-h now)
    - halt
    - reboot

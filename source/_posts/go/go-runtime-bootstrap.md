---
title: Go runtime 系列之 - 启动过程
date: 2018-09-09
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

通过查阅资料，了解 Go 语言的启动过程。

## 启动总体顺序

1. 命令行参数解析
2. 操作系统相关初始化
3. 调度器初始化
4. 创建 main.goroutine
5. 运行 main 函数

### 命令行参数初始化
主要是解析命令行参数并保存

### 操作系统相关初始化
主要是确定操作系统的 CPU 核数，CPU 核数决定默认的了 P 的数量

<!-- more -->

### 调度器初始化
调度器的初始化时启动程序的核心

1. 设置 M 的最大数量（10000）
2. 内存相关初始化
3. M 的初始化
4. 存储命令行参数和环境变量
5. 解析 Debug 调试参数
6. 初始化垃圾回收器
7. 初始化 poll 时间
8. 社会最大的 P 的数量，默认是 CPU 核数

### main.goroutine 初始化
1. 设置栈的最大值
2. 启动后台监控
3. 初始化 runtime.init 及 runtime 包
4. 启动垃圾回收器
5. 初始化 main.init 及用户或第三方引入的包

### 执行 main.main 函数
执行入口函数，开始运行


参考资料：
- [Go 程序是怎样跑起来的](https://www.cnblogs.com/qcrao-2018/p/11124360.html)
---
title: Go 数据结构之 - channel
date: 2022-07-09
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

channel 是 Goroutine 之间实现通信的数据核心数据结构，channel 是支撑 Go 语言高性能并发编程模型的重要结构，我们简单介绍下 channel 的设计原理、数据结构和常见操作。

## 设计原理
Go 语言的并发模型是通信顺序进程（Communicating sequential processes，CSP），Goroutine 和 Channel 分别对应 CSP 中的实体和传递信息的媒介，Goroutine 之间会通过 Channel 来传递数据。

## 数据结构

## Channel 操作

## 并发

参考资料：
- [Golang并发：再也不愁选channel还是选锁](https://segmentfault.com/a/1190000017890174?utm_source=sf-similar-article)
- [Channel](https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-channel/)
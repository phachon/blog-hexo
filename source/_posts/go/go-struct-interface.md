---
title: Go 数据结构之 - interface
date: 2022-07-09
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

interface 是 go 语言中非常重要的数据结构之一，利用 interface 我们可以实现类似面向对象的语言里的继承和封装的思想（go 语言里叫组合），同时对于复杂业务场景下，类型无法确定，经常需要定义一个能覆盖多种类型的变量，这个时候需要定义成 interface

<!-- more -->

## 数据类型
接口也是 Go 语言中的一种类型，它能够出现在变量的定义、函数的入参和返回值中并对它们进行约束，不过 Go 语言中有两种略微不同的接口，一种是带有一组方法的接口，另一种是不带任何方法的 interface{}
### 带方法的接口
interface 作为

### 任意类型的变量

## 数据结构
Go 语言根据接口类型是否包含一组方法将接口类型分成了两类：

- 使用 runtime.iface 结构体表示包含方法的接口
- 使用 runtime.eface 结构体表示不包含任何方法的 interface{} 类型；

### 类型结构体
用于表示接口的结构体是 runtime.iface，这个结构体中有指向原始数据的指针 data，不过更重要的是 runtime.itab 类型的 tab 字段。
```
type iface struct { // 16 字节
	tab  *itab
	data unsafe.Pointer
}
```
### 任意变量结构体
runtime.eface 结构体在 Go 语言中的定义是这样的：
```
type eface struct { // 16 字节
	_type *_type
	data  unsafe.Pointer
}
```
由于 interface{} 类型不包含任何方法，所以它的结构也相对来说比较简单，只包含指向底层数据和类型的两个指针。从上述结构我们也能推断出 — Go 语言的任意类型都可以转换成 interface{}

## 类型转换

## 类型断言

## 参考资料
- [golang-interface](https://draveness.me/golang/docs/part2-foundation/ch04-basic/golang-interface/#422-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)
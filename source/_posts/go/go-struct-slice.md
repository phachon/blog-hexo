---
title: Go 数据结构之 - 数组和 slice
date: 2022-07-09
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

golang 中的数组和 slice 也是比较常见的数据结构，但是 slice 和数组的区别初学者往往会搞不清楚；这里从底层数据结构来一探 slice 和数组的实现和差异。

<!-- More -->

## 数组
数组是由相同类型的数据组成的集合的数据结构，计算机会分配一段连续的内存来保存数组元素，我们可以利用数组的索引快速访问到特定的元素。 

```go
a := [4]int{1, 2, 3} // 初始化数组
```

关于数组的几点注意：
1. Go 语言中，数组属于值类型，因此当一个数组被赋值或者传递时，是会 copy 整个数组
2. 不同长度的数组代表不同的类型，例如 [4]int{} 和 [5]int{} 是不同的类型

### 函数参数
函数传递参数数组，由于 slice 是值类型，所以会 copy 一份数据

### 总结
数组类型比较简单，使用也相对比较局限，因为必须是固定大小空间的元素，且不能动态扩容，所以当已知数量的元素的时候适合用数组数据结构

## slice
slice 也叫切片，相比数组来说更加灵活和动态，是在数组的基础上做了补充，支持不定长度，动态扩容等特性，所以比数组的使用场景更广泛。切片本质是一个数组片段的描述，包括了数组的指针，这个片段的长度和容量(不改变内存分配情况下的最大长度)。

```go
struct {
    ptr *[]T // 数组的指针
    len int  // 当前切片的长度
    cap int  // 当前切片的容量，即数组的大小：
}
```

![go-slice-struct](/images/golang-slice-struct.png)

我们可以在运行区间改变长度和范围，当底层的数组长度不足时候，就会触发扩容，切片指向的数组就会发生变化

### 函数参数
函数传递参数数组，由于数组是值类型，所以会 copy 一份数据

### 追加和扩容
使用 append 关键字来追加元素，这里分两种情况会进入不同的流程，如果 append 返回的新切片不需要赋值回已有的变量：
```go
// append(slice, 1, 2, 3)
ptr, len, cap := slice
newlen := len + 3
if newlen > cap { // 新的长度大于数组的长度
    ptr, len, cap = growslice(slice, newlen) // 生成新的切片
    newlen = len + 3
}
*(ptr+len) = 1
*(ptr+len+1) = 2
*(ptr+len+2) = 3
return makeslice(ptr, newlen, cap) // 返回新切片
```

如果 append 返回的新切片需要赋值给已有的变量，即需要覆盖已有的变量：
```go
// slice = append(slice, 1, 2, 3)
a := &slice
ptr, len, cap := slice
newlen := len + 3
if uint(newlen) > uint(cap) {
   newptr, len, newcap = growslice(slice, newlen)
   vardef(a)
   // 区别在于这里，这里新生成的切片直接修改掉原来切片的指针
   *a.cap = newcap 
   *a.ptr = newptr
}
newlen = len + 3
*a.len = newlen
*(ptr+len) = 1
*(ptr+len+1) = 2
*(ptr+len+2) = 3
```
所以 append 赋值给原来的切片不会存在拷贝的问题，只是改变了数组的指针

扩容操作会调用 runtime.growslice 函数为切片扩容，扩容是为切片分配新的内存空间并拷贝原切片中元素的过程

在分配内存空间之前需要先确定新的切片容量，运行时根据切片的当前容量选择不同的策略进行扩容：
- 如果期望容量大于当前容量的两倍就会使用期望容量；
- 如果当前切片的长度小于 1024 就会将容量翻倍；
- 如果当前切片的长度大于 1024 就会每次增加 25% 的容量，直到新容量大于期望容量；

### 拷贝切片
copy(a, b) 的形式对切片进行拷贝，无论是编译期间拷贝还是运行时拷贝，两种拷贝方式都会通过 `runtime.memmove` 将整块内存的内容拷贝到目标的内存区域中，相比于依次拷贝元素，runtime.memmove 能够提供更好的性能。需要注意的是，整块拷贝内存仍然会占用非常多的资源，在大切片上执行拷贝操作时一定要注意对性能的影响。

### 切片截取
切片操作并不复制切片指向的元素，创建一个新的切片会复用原来切片的底层数组，因此切片操作是非常高效的。下面的例子展示了这个过程：
![slice-cap](/images/slice-cap.jpeg)

```go
nums := make([]int, 0, 8)
nums = append(nums, 1, 2, 3, 4, 5)
nums2 := nums[2:4]
printLenCap(nums)  // len: 5, cap: 8 [1 2 3 4 5]
printLenCap(nums2) // len: 2, cap: 6 [3 4]

nums2 = append(nums2, 50, 60)
printLenCap(nums)  // len: 5, cap: 8 [1 2 3 4 50]
printLenCap(nums2) // len: 4, cap: 6 [3 4 50 60]
```

- nums2 执行了一个切片操作 [2, 4]，此时 nums 和 nums2 指向的是同一个数组。
- nums2 增加 2 个元素 50 和 60 后，将底层数组下标 [4] 的值改为了 50，下标[5] 的值置为 60。
- 因为 nums 和 nums2 指向的是同一个数组，因此 nums 被修改为 [1, 2, 3, 4, 50]。

Go 语言在 Github 上的官方 wiki - SliceTricks 介绍了切片常见的操作技巧。另一个项目 [Go Slice Tricks Cheat Sheet](https://ueokande.github.io/go-slice-tricks/) 将这些操作以图片的形式呈现了出来，非常直观。

> 这部分摘自：[切片(slice)性能及陷阱](https://geektutu.com/post/hpg-slice.html)

## 常见陷阱
1. 大量内存得不到释放
在已有切片的基础上进行切片，不会创建新的底层数组。因为原来的底层数组没有发生变化，内存会一直占用，直到没有变量引用该数组。因此很可能出现这么一种情况，原切片由大量的元素构成，但是我们在原切片的基础上切片，虽然只使用了很小一段，但底层数组在内存中仍然占据了大量空间，得不到释放。比较推荐的做法，使用 copy 替代 re-slice。

2. slice 作为函数参数
slice 作为函数参数本身是值传递，slice 本身也是结构体，所以函数内部回重新 copy 一个结构体。值的注意的是，不管传的是 slice 还是 slice 指针，如果改变了 slice 底层数组的数据，会反应到实参 slice 的底层数据。为什么能改变底层数组的数据？很好理解：底层数据在 slice 结构体里是一个指针，仅管 slice 结构体自身不会被改变，也就是说底层数据地址不会被改变。 但是通过指向底层数据的指针，可以改变切片的底层数据，没有问题。
```go
package main
func main() {
    s := []int{1, 1, 1}
    f(s)
    fmt.Println(s)
}
func f(s []int) {
    // i只是一个副本，不能改变s中元素的值
    /*for _, i := range s {
        i++
    }
    */
    for i := range s {
        s[i] += 1
    }
}
```
运行一下，程序输出：
```
[2 2 2]
```
如果函数里 append 追加覆盖回如何呢？
```go
package main

import "fmt"

func Append(s []int) []int {
	// 这里 s 是 main 里面的 s 的拷贝
  // append 发生扩容返回的新的 slice 改变的是拷贝的 s，不是原来的 s
	s = append(s, 10)
	return s
}
func AppendPtr(s *[]int) {
	// 这里 *s 是 main 里面的 s 指针的拷贝
  // append 发生扩容返回的新的 slice 的指针就是原来 s 的指针
	*s = append(*s, 10)
	return
}

func main() {
	s := []int{1, 1, 1}
	newS := Append(s)
	fmt.Println(s)    // [1, 1, 1]
	fmt.Println(newS) // [1, 1, 1, 10]
	s = newS
	AppendPtr(&s)
	fmt.Println(s) // [1, 1, 1, 10, 10]
}
```

## 参考资料
- [切片(slice)性能及陷阱](https://geektutu.com/post/hpg-slice.html)
- [切片](https://draveness.me/golang/docs/part2-foundation/ch03-datastructure/golang-array-and-slice/)
- [切片作为函数参数](https://www.bookstack.cn/read/qcrao-Go-Questions/%E6%95%B0%E7%BB%84%E5%92%8C%E5%88%87%E7%89%87-%E5%88%87%E7%89%87%E4%BD%9C%E4%B8%BA%E5%87%BD%E6%95%B0%E5%8F%82%E6%95%B0.md)
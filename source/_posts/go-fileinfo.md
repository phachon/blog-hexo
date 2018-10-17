---
title: Go 获取文件信息方法
date: 2017-10-10
categories: Go基础
tags:
  - Go
---
----------------------------------

最近一直在写 go 语言，总结下go获取文件信息的方法

## 获取文件修改时间

```
fileInfo, _ := os.Stat("test.log")
//修改时间
modTime := fileInfo.ModTime()
fmt.Println(modTime)
```

<!-- more -->

## 判断文件是否存在

```
_, err := os.Stat("test.log")
if(os.IsNotExist(err)) {
	fmt.Println("file not exist!")
}
```

## 文件是否是目录

```
fileInfo, _ := os.Stat("test.log")
//是否是目录
isDir := fileInfo.IsDir()
fmt.Println(isDir)
```

## 文件权限

```
fileInfo, _ := os.Stat("test.log")
//权限
mode := fileInfo.Mode()
fmt.Println(mode)
```

## 获取文件名

```
fileInfo, _ := os.Stat("test.log")
//文件名
filename:= fileInfo.Name()
fmt.Println(filename)
```

## 获取文件大小

```
fileInfo, _ := os.Stat("test.log")
//文件大小
filesize:= fileInfo.Size()
fmt.Println(filesize)//返回的是字节
```

## 获取文件创建时间
文件的创建时间并没有直接的方法返回，翻看源代码才知道如何获取

```
fileInfo, _ := os.Stat("test.log")
fileSys := fileInfo.Sys().(*syscall.Win32FileAttributeData)
nanoseconds := fileSys.CreationTime.Nanoseconds() // 返回的是纳秒
createTime := nanoseconds/1e9 //秒
fmt.Println(createTime)
```

## 文件最后写入时间

```
fileInfo, _ := os.Stat("test.log")
fileSys := fileInfo.Sys().(*syscall.Win32FileAttributeData)
nanoseconds := fileSys.LastWriteTime.Nanoseconds() // 返回的是纳秒
lastWriteTime := nanoseconds/1e9 //秒
fmt.Println(lastWriteTime)
```

## 文件最后访问时间

```
fileInfo, _ := os.Stat("test.log")
fileSys := fileInfo.Sys().(*syscall.Win32FileAttributeData)
nanoseconds := fileSys.LastAccessTime.Nanoseconds() // 返回的是纳秒
lastAccessTime:= nanoseconds/1e9 //秒
fmt.Println(lastAccessTime)
```

## 文件属性

```
fileInfo, _ := os.Stat("test.log")
fileSys := fileInfo.Sys().(*syscall.Win32FileAttributeData)
fileAttributes:= fileSys.FileAttributes
fmt.Println(fileAttributes)
```

介绍一个我用 go 写的日志管理包，地址： https://github.com/phachon/go-logger


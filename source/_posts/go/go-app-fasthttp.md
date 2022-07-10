---
title: Go 应用之 - Fasthttp 高性能分析
date: 2019-01-11
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

fasthttp 号称比 net/http 要快 10 倍左右，之前使用 fasthttp 写过也写过一些项目，这里试图刨析一下 fasthttp 高性能的原因

<!-- more -->

## fasthttp介绍
github: https://github.com/valyala/fasthttp
这里先翻译一下官网的介绍

### FastHTTP最佳实践
1. 不要分配 object 和 []byte 缓冲区, 要尽可能地重用它们。FastHTTP API设计鼓励这样做。
2. sync.Pool 使用对象池
3. 在项目中开启 go tool pprof --alloc_objects your-program mem.ppro 通常会比 go tool pprof your-program cpu.pprof 更好
4. 写 tests 和 benchmarks
5. 避免在 []byte 和 string 之间进行转换，因为这可能导致 内存分配+复制 。FastHTTP API同时为[]byte 和 string 提供函数，使用这些函数，而不是在[]byte 和 string 之间手动转换。wiki: https://github.com/golang/go/wiki/CompilerOptimizations#string-and-byte
6. 在并发的环境下测试代码

### 合理使用 []byte 字节缓冲区

### 为什么还要创建另一个 HTTP 包而不是优化 net/http？
因为 net/http api 限制了许多优化机会。例如：
- net/http 请求对象生存期不受请求处理程序执行时间的限制。因此，服务器必须为每个请求创建一个新的请求对象，而不是像 fasthttp 那样重用现有对象。
- net/http api 要求每个请求创建一个新的响应对象。
- net/http 头存储在 map[string][] 字符串中。因此，在调用用户提供的请求处理程序之前，服务器必须解析所有头，将它们从 []byte 转换为 string，并将它们放入映射中。这都需要 fasthttp 避免不必要的内存分配。

### 为什么 fasthttp api 与 net/http 不兼容？
因为 net/http API 限制了许多优化机会。请参阅上面的答案了解更多详细信息。此外，某些 net/http API部件的使用还不理想：
比较 net/http connection hijacking 与 fasthttp connection hijacking.
比较 net/http Request.Body reading t与 fasthttp request body reading.

### 与 fasthttp 相比，net/http有什么优势？
- net/http 支持从 GO1.6 开始支持 HTTP/2.0
- net/http API是稳定的，而 FastHTTP API 不断发展
- net/http 处理更多的 http 情况
- net/http 应该包含更少的bug，因为它被更广泛的受众使用和测试。
- net/http 支持 go1.5 的旧版本

### 为什么 fastHttp API 返回 []byte 而不是 string？
因为 []byte 到 string 的转换需要内存重分配和复制

### fasthttp 支持哪些 go 版本？
go1.5+

## 优势总结
根据作者的解释，fasthttp 对性能提高的优化点主要在于：
1. 协程池
2. 对象的复用
3. 减少 []byte 到 string 的转化

## 源码分析
接下来我们从源码来分析一下 fasthttp 究竟做了哪些优化

### 协程池
go 官方原生的 server.go
```go
l := listen()
func (srv *Server) Serve(l net.Listener) error {
    for {
        rw, err := l.accept()
        ....
        // 处理请求, 每次都开启一个 gorotine
        go c.serve(ctx)
    }
}
```

fasthttp 的 Serve
```go
func (s *Server) Serve(ln net.Listener) error {
    for {
      if c, err = acceptConn(s, ln, &lastPerIPErrorTime); err != nil {
          ......
      }
      // 对应 go c.serve(ctx)
      if !wp.Serve(c) {
          //......
      }
      //......
    }
}
```
很明显，go 原生的 net/http 中，当接受到新的请求后就启动一个新的斜程，而 fasthttp 使用斜程池处理
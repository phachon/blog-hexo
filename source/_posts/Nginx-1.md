---
title: Nginx 系列（一）：工作原理
date: 2018-10-07 18:25:15
banner: /images/nginx_logo.png
thumbnail: /images/nginx_logo.png
categories: Nginx
tags:
  - nginx
---

Nginx 作为高性能的 HTTP 和 反向代理服务器，被广泛使用在互联网的业务中。经典的比如 Nginx + PHP-FPM 的组合。本篇文章来简单了解一下 Nginx 的基本原理。

<!-- more -->

## Nginx 体系架构
总体来说，Nginx 是由 `模块` 和 `内核` 组成，内核的设计非常的简洁。完成的工作也非常的简单。其实内核也是由模块组成的。内核的主要任务是：

`通过查找配置，将客户端的请求映射到对应的 location 块`，在每个 `location` 块中所配置的一些指令就会去启动不同的模块去完成对应的工作。例如：

```shell
location ~ \.php$ {
    root           html;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    include        fastcgi_params;
}
```
内核查找将 .php 结尾的请求全部映射到该 `location` 块中，在该块中又有相关的指令来启动其他的第三方模块来工作。

Nginx 从结构上分为三部分：

- 核心模块：HTTP 模块，EVENT 模块，MAIL 模块
- 基础模块：HTTP Access 模块，HTTP FastCGI 模块，HTTP Proxy 模块和 HTTP Rewrite 模块。
- 第三方模块：HTTP Upstream Request Hash 模块，Notice 模块，Rtmp 模块等等。

当然，如果用能力的话你也可以开发符合自己需求的模块。总体来说，采用了多模块组合的体系架构，使得 Nginx 才能如此的强大。

总体上 Nginx 对一个请求处理的过程如下：
- Nginx 接受到请求，通过查找配置信息，将请求映射到一个 location 块
- location 块在接收到请求后开始执行指令。会涉及到多个 handle 模块和多个 filter 模块。
  - handle 模块处理请求，并生产响应的内容
  - filter 模块对生成的响应内容处理并返回

## Nginx 进程模型
Nginx 的进程模型总体来说是属于`多进程模型`。在多进程模型下，会有一个唯一的 `Master` 进程，至少有一个 `Worker` 进程。在 Worker 进程中的线程数量的不同又可分为两类：

- 多线程：多线程即 Worker 进程中有多个线程在工作
- 单线程：单线程即 Worker 进程中有单个线程工作

Nginx  默认是多进程单线程的模型。启用线程池支持，编译时 configure 时需要显式加入 --with-threads 选项。

### Master 进程
Master 的进程的工作比较简单，主要工作有一下几点：
- 接受来自外界的信号，向各个 worker 进程发送信号
- 监控 worker 进程的运行状态，当 worker 进程异常退出，会启用新的 worker

#### reload 平滑重启实现的原理？
首先 reload 或者 -HUP pid 会向 master 进程发送一个重载信号，master 接受到信号后，重新加载配置文件，然后重新启动新的 worker 进程，并向老的 worker 进程发送信号，告诉它们可以退出了。
老的  worker 进程在接受到信号好，会停止接受新的请求，并处理完当前的请求，然后退出。

### Worker 进程
Worker 进程才是真正处理我们的网络请求的地方，一个请求，只可能被一个 worker 进程来处理。每个 worker 进程的竞争机会都是相等的。这就出现了问题，当一个请求过来之后，到底是哪个 worker 来执行？

每一个 worker 进程采用的是 epoll 异步非阻塞的方式来处理请求，epoll 支持监听多个 socket 网络套接字，这些套接字被注册到 listen_fd 变量里。

#### 惊群问题
当 listen_fd 有新的 accept() 请求过来的时候，操作系统会唤醒所有的 epoll_wait 该 listen_fd 变量的进程（Nginx 的每一个 worker 进程)。因为操作系统并不知道谁到底可以执行 accept，所以全部都唤醒。
但是，最终只能给一个 worker 来执行 accept，其他的 worker 都执行失败。所以这样的子进程似乎都是被 “吓醒” 的，所以又称为 “惊群问题”。
惊群问题的解决：

1. 我们最容易想到的，就是全局锁机制。原理类似于分布式的全局锁。具体的实现办法是：nginx 的每一个 worker 进程在被 “惊醒” 之后，都回首先去抢占一个全局的互斥锁。抢到锁的进程，那么恭喜，该进程就获得执行本次请求的机会，
开始读写数据。没有抢占到锁的则继续等待下一次机会。这里还需要注意到一点的是，当某个进程处理的工作量达到总设置的一定的比例时（7/8）,则就会停止申请锁。这样可以来均衡各个进程的任务量
该方法也是 Nginx 内核解决惊群问题的实现方法。

2. Nginx 1.9.1 采用新的机制，socket 分片机制。具体实现的原理是依赖操作系统的 Socket RequestPort 功能。选项允许多个socket监听同一个IP地址和端口的组合。内核负载均衡这些进来的sockets连接,将这些socket有效的分片。
当SO_REUSEPORT选项没开启时,连接进来时监听socket默认会通知某个进程，每个进程都有自己独立的监听socket.内核决定哪个是有效的socket(进程)得到这个连接。


在 worker 在 accept 这个连接之后，就开始读取数据，解析请求，处理请求，产生数据后，返回给客户端，最后才断开连接。

总体来说，Nginx 的多任务多请求处理机制，其实是抢占式的机制。多个 worker 去抢占。而不是 master 分配。

Worker 进程的数量最好与 CPU 核数一致，并且可以帮到进程到指定的 CPU 内核

## Nginx 网络模型
Nginx 之所以能够高并发，主要是采用了`异步非阻塞`的网络并发模型方式。

异步：针对内核的 I/O 事件，当向内核发出 I/O 请求的命令，不用等待 I/O 事件真正发生就返回，可以做另外的事情。

非阻塞IO：针对网络 I/O 操作，例如 socket ，不同等待 socket 是否可以操作，而是将 socket 注册到监听的变量里，通过不断的循环来监听是否有准备好的读写socket再来操作。

Nginx 异步 I/O 的实现是调用的操作系统的异步 I/O，AIO。
Nginx 非阻塞 I/O 的实现是通过 select, epoll 机制实现。

所以，Nginx 的异步非阻塞是 AIO + epoll 的机制共同来实现的。

epoll/select/poll 的网络模型的比较这里不再详细介绍。参考阅读 [并发服务器的实现方式](https://phachon.github.io/2018/09/09/concurrrent_server/)

## Nginx + PHP-FPM

PHP-FPM 其实就是php 实现的 fastcgi 进程管理器。PHP-FPM 的优点就是把动态语言与 HTTP Server 分离开来，Nginx 专门来处理一些静态请求。PHP-FPM 来处理动态的请求。

整体的工作流程如下：
- fastcgi 进程管理器 php-fpm 自身初始化，启动主进程 php-fpm 并且启动多个 cgi 子进程。
  - 主进程的 php-fpm 主要是用来管理 fastcgi 的子进程，监听端口 9000。
  - fastcgi 子进程等待来自 web server 的连接。
- 当客户端的请求到达 nginx 时，nginx 通过 location 指令，将所有的 .php 文件都交给 :9000 来处理，即 Nginx 通过 location 指令，将所有的 php 文件交给 9000 的 php-fpm 处理
- php-fpm 进程管理器选择并连接到一个进程 cgi 解释器。Nginx 将 cgi 环境变量和标准输入发送到 fastcgi 子进程。
- fastcgi 子进程处理完请求后将标准输出和错误信息从同一连接返回给 nginx。当 fastcgi 子进程关闭时，请求便完成。
- fastcgi 子进程等待并处理来自 fastcgi 进程管理器的下一个连接。

php-fpm 进程数的配置：
```shell
# 对于专用服务器，pm可以设置为static。
pm = dynamic 
# 如何控制子进程，选项有static和dynamic。如果选择static，则由pm.max_children指定固定的子进程数。如果选择dynamic，则由下开参数决定：
pm.max_children #，子进程最大数
pm.start_servers #，启动时的进程数
pm.min_spare_servers #，保证空闲进程数最小值，如果空闲进程小于此值，则创建新的子进程
pm.max_spare_servers #，保证空闲进程数最大值，如果空闲进程大于此值，此进行清理
# 设置每个子进程重生之前服务的请求数. 对于可能存在内存泄漏的第三方模块来说是非常有用的. 如果设置为 ’0′ 则一直接受请求.
pm.max_requests = 1000 
```

一般情况下，一个 php-fpm 子进程开启时占用 3-4M,运行一段时间后，会占用 20-30M，所以 php-fpm 进程数需要合理控制，一般对于 8G 内存，可以设置为 100个，最多占用 3G 内存。


## 总结
本篇文章介绍了 Nginx 的工作体系结构和进程模型，以及 Nginx + PHP-FPM 的工作原理。

## 参考
[Nginx 工作原理和优化](https://www.cnblogs.com/linguoguo/p/5511293.html)
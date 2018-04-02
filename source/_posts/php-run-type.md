---
title: 浅析 php 的几种运行方式
date: 2016-07-29
categories: Coding
tags:
  - PHP
  - CGI
  - FAST-CGI
  - PHP-FPM
  - CLI
---
----------------------------------

## PHP 的几种运行方式

1. CGI
2. FAST-CGI
3. Web-module
4. CLI

<!-- more -->

## CGI
CGI (Common Gateway Interface) 是通用网关型接口,CGI是外部应用程序（CGI程序）与Web服务器之间的接口标准，是在CGI程序和Web服务器之间传递信息的过程。简单的说，就是当你的 php引擎和web服务器相互传递消息时，CGI 规定了一套标准来规范如何传递数据以及数据传递的格式。

当 web 服务器接收到一个请求时，就会启动一个 CGI 进程，这里就会通知到PHP 引擎，然后去解析 php.ini 文件，开始处理请求，并且将处理的请求的结果以标准的格式返回给 web 服务器，并退出进程。

```sequence
title:CGI工作原理
浏览器->web服务器:发送请求
web服务器->CGI应用程序(php引擎):启动一个 CGI 进程
CGI应用程序(php引擎)->web服务器:发送解析好的信息
web服务器->浏览器:发送 html 信息
```

显而易见的是，这样每一个请求过来的话都会重新去启动一个 CGI 进程,关键是每个进程又都会去启动引擎去解析 php.ini 文件，这样当请求多的时候，效率会非常的低。因而，已经逐渐被抛弃。

注意：需要明确的是 CGI 只是一套接口标准，具体的实现程序才是用来启动进程的。比如根据 CGI 实现的 php-cgi 程序。

## FAST-CGI

既然 CGI 是如此的效率低下，聪明的人类肯定能够想出更好的方法来使得 CGI 更加高效，对的，这就是 FAST-CGI。

FAST-CGI 也是一种通用网关型接口，是建立在 CGI 的基础上进化而来,FastCGI 像是一个常驻(long-live)型的 CGI，它可以一直执行着，只要激活后，不会每次都要花费时间去fork一次(这是CGI最为人诟病的fork-and-execute 模式)。它还支持分布式的运算, 即 FastCGI 程序可以在网站服务器以外的主机上执行并且接受来自其它网站服务器来的请求。
简单理解呢，大概是这样：当web服务器启动时，会载入Fast-CGI 进程管理器，FastCGI进程管理器会同时开启多个 CGI 子进程，相当于一个进程池，当 web 请求到来时，会选择一个 CGI 解释器并连接，处理完成后将信息返回给web服务器，这时候，该子进程又会回到进程管理器中继续等待下一个连接，所以这样不需要每次都去重新启动进程，加载配置文件。

```sequence
title:fast-cgi 工作原理
web服务器->fastcgi进程管理:启动载入
fastcgi进程管理->cgi子进程:启动多个
web服务器->fastcgi进程管理:请求
fastcgi进程管理->cgi子进程:连接一个
cgi子进程->web服务器:返回解析并重新等待新的请求
```

php-cgi 只是用来处理 cgi 进程的程序，那 php fast-cgi 进程管理器是怎么实现的呢，php-fpm ,对的，就是它，php-fmp 用来管理和调度这些 php fast-cgi 进程。

注意：还是需要明确一下，fast-cgi 也只是一套协议标准，php fast-cgi才是具体的实现程序，php-fpm是实现了对 fast-cgi 的进程管理。

## Web-module

这个简称为 web 模块加载模式，想必用 apache 搭建过 php 环境的应该都了解，apahce 需要加载 mod-php5 模块，这个模块就是用来将 Apache 传递过来的 php 文件的请求，并处理这些请求，最终将处理的结果返回给 apache。在 apache 的配置文件中配置好了 php 模块，php 模块就会通过注册 apache2 的 ap_hook_post_config 挂钩，实现请求与返回。

windows 下：

```
LoadModule php5_module d:/server/php/php5apache2_2.dll
```
linux 下：

```
LoadModule php5_module modules/mod_php5.so
```

该模块是 apache 在CGI的基础上进行的一种扩展，加快PHP的运行效率

## CLI

php-CLI：PHP Command Line Interface

即 php 在命令行运行的接口，当然是相对于以上三种方式（web 请求）来说的

优点：

- 多进程池，子进程完成后，内核会回收掉
- 主进程只进行任务分发

CLI 模式在 windows 和 linux 都可以运行。

以上就是 php 的几种主要的运行方式，除此之外，还有一种运行方式是 ISAPI（Internet Server Application Program Interface）是微软提供的一套面向Internet服务的API接口，在这里就不多介绍了。因为现在几乎都是在 Linux 下部署 php 应用了。

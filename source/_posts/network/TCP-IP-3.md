---
title: TCP/IP 协议栈系列（三）：HTTP 协议概述
date: 2018-09-13 
categories: Network
tags:
  - tcp
---
----------------------------------

## HTTP 简介
HTTP协议是 Hyper Text Transfer Protocol（超文本传输协议）的缩写, 是用于从万维网（WWW:World Wide Web ）服务器传输超文本到本地浏览器的传送协议。

HTTP 是一个基于 TCP/IP 协议来传递数据（网页、文件等）的应用层协议。

## HTTP 特点
1、简单：客户向服务器请求服务时，只需传送请求方法和路径。请求方法常用的有 GET、HEAD、POST。每种方法规定了客户与服务器联系的类型不同。由于HTTP 协议简单，使得 HTTP 服务器的程序规模小，因而通信速度很快。

2、灵活：HTTP 允许传输任意类型的数据对象。正在传输的类型由 Content-Type 加以标记。

3、无连接：无连接的含义是限制每次连接只处理一个请求。服务器处理完客户的请求，并收到客户的应答后，即断开连接。采用这种方式可以节省传输时间。

4、无状态：HTTP 协议是无状态协议。无状态是指协议对于事务处理没有记忆能力。缺少状态意味着如果后续处理需要前面的信息，则它必须重传，这样可能导致每次连接传送的数据量增大。另一方面，在服务器不需要先前信息时它的应答就较快。

5、支持B/S及C/S模式。

## 请求过程
在浏览器输入：https://www.qq.com/ 浏览器向网站所在的服务器发送了一个 Request 请求，服务器接收到这个 Request 之后进行处理和解析，然后返回一个 Response 响应，然后传回给浏览器，Response 里面就包含了页面的 html 源代码等内容，浏览器再对其进行解析便将网页呈现了出来。
![http-client](/images/http-client.jpeg)

## HTTP 头部
HTTP 头部是一个传递额外重要信息的 `键值对`。主要分为：通用头部，请求头部，响应头部和实体头部。

`通用头部`：
- Connection：客户端和服务端使用的 tcp 连接类型
- Date：报文的时间
- Cache-Control：缓存的控制
- Transfer-Encoding：报文的传输方式；chunked 分块传输

`请求头部`：
- Accept：告诉服务器允许的媒体类型 Accept: text/plain
- Accept-Encoding：客户端支持的接收的编码方法 Accept-Encoding: gzip, deflate
- User-Agent：浏览器的身份标识字符串 User-Agent: Mozilla/……
- Referer：浏览器所访问的前一个页面

`响应头部`：
- Server：告知客户端服务器信息 Server: Apache/1.3.27 (Unix) (Red-Hat/Linux)
- Location：表示重定向后的 URL

`实体头部`：
- Allow：对某网络资源的有效的请求行为，不允许则返回405
- Content-encoding：返回内容的编码方式
- Content-Length：返回内容的字节长度
- Content-Language：响应体的语言

## Keep-Alive 机制
这里的 keep-alive 是指 http 协议里 header 头里设置的 `Connection: keep-alive`，请求头设置了 keep-alive 之后就会告诉对方这个请求响应完成后不要关闭，下一次咱们还用这个请求继续交流，我们用一个示意图来更加生动的表示两者的区别：

![keep-alive](/images/keep-alive.png)

### 为啥需要 keep-alive？
在 HTTP/1.0 中，浏览器每次发起 HTTP 请求都要与服务器创建一个新的 TCP 连接，服务器完成请求处理后立即断开 TCP 连接，服务器不跟踪每个客户也不记录过去的请求。创建和关闭 TCP 连接的过程需要消耗资源和时间，为了减少对 TCP 资源消耗，缩短响应时间，就需要重用 TCP 连接。

> 特别注意：所以我们需要清楚概念，有些地方也叫 keep-alive 为 http 长连接，这个说法并不是准确；因为 http 压根连连接都没有，真正连接是传输层的 tcp 才回建立连接，所以 http 不存在长连接一说，只有底层的 tcp 才存在长连接。这里 keep-alive 说的是当前的 tcp 连接是可复用的也叫 tcp 长连接或者叫 tcp 保活。

### 什么时候应该使用 keep-alive？
应该说当前大部分的场景已经使用 http1.1 都默认使用的 keep-alive tcp 长连接的方式；对于 http1.0，如果 http 客户端比较多，请求比较频繁，是需要手动设置 keep-alive

### keep-alive 缺点
长时间的保持 TCP 连接时容易导致系统资源被无效占用，若对 Keep-Alive 模式配置不当，将有可能比非 Keep-Alive 模式带来的损失更大。因此，我们需要正确地设置 keep-alive timeout 参数，当 TCP 连接在传送完最后一个 HTTP 响应，该连接会保持 keepalive_timeout 秒，之后就开始关闭这个链接。

## HTTP 报文长度
如果服务器预先知道报文大小，会直接返回的 header 头中的 Content-Length 标示报文的长度
如果服务器采用分块传输机制，就会采用 Transfer-Encoding: chunked 的方式来代替 Content-Length

分块传输编码（Chunked transfer encoding）是 HTTP/1.1 中引入的一种数据传输机制，其允许 HTTP 由服务器发送给客户端的数据可以分成多个部分，当数据分解成一系列数据块发送时，服务器就可以发送数据而不需要预先知道发送内容的总大小，每一个分块包含十六进制的长度值和数据，最后一个分块长度值为0，表示实体结束，客户机可以以此为标志确认数据已经接收完毕。

## GET 长度限制
HTTP 中的 GET 方法是通过 URL 传递数据的，而 URL 本身并没有对数据的长度进行限制，真正限制 GET 长度的是浏览器，例如 IE 浏览器对 URL 的最大限制为 2000多个字符，大概 2KB左右，像 Chrome, FireFox 等浏览器能支持的 URL 字符数更多，其中 FireFox 中 URL 最大长度限制为 65536 个字符，Chrome 浏览器中 URL 最大长度限制为 8182 个字符

## 状态码
1XX	指示信息--表示请求正在处理
2XX	成功--表示请求已被成功处理完毕
3XX	重定向--要完成的请求需要进行附加操作
4XX	客户端错误--请求有语法错误或者请求无法实现，服务器无法处理请求
5XX	服务器端错误--服务器处理请求出现错误


## 参考资料
[http的长连接和短连接](https://blog.csdn.net/luzhensmart/article/details/87186401)
[关于HTTP协议，一篇就够了](https://www.cnblogs.com/ranyonsue/p/5984001.html)
[HTTP协议详解](https://www.cnblogs.com/li0803/archive/2008/11/03/1324746.html)
---
title: Web 网站的基本工作原理
date: 2016-07-26
categories: Network
tags:
  - PHP
  - Apache
---
----------------------------------

## 静态页访问

- 示例：http://www.test.com/index.html
- 请求步骤：
 
(1) 用户输入需要访问的地址或者具体的网页文件
(2) 开始域名解析,会先找到本地的 hosts 文件，然后再找网络上的 DNS 服务器,最终解析到 ip 地址
(3) ip 地址所在机器的 Web 服务器接收这个请求，获取请求文件 index.html
(4) web 服务器将这个文件的信息返回给用户所用的浏览器
(5) 浏览器解析 html 代码，显示出数据

```sequence
Title: 静态网页资源的访问流程图
用户->浏览器:输入资源地址
浏览器->域名解析(DNS):解析 ip
域名解析(DNS)->web 服务器:根据 ip 找到服务器资源
web 服务器->浏览器:返回资源给浏览器
浏览器->用户:解析html显示
```

<!-- more -->

## 动态页访问

示例：http://www.test.com/test.php

请求步骤：

(1) 用户浏览器输入网址以及请求的动态文件的脚本
(2) 域名解析，先找本地 hosts ,再找 DNS
(3) web 服务器接收请求,获取请求文件 test.php
(4) web 服务器将 test.php 交给 php 引擎处理
(5) php 引擎解析 php 代码,如果连接了数据库，就调用 mysql 扩展，去操作数据库，最终将解析成 html 文件
(6) 将解析的 html 文件返回给 web 服务器(Apache)
(7) web服务器返回 test.php 得到的最终 html 文件给浏览器
(8) 浏览器解析html代码，显示数据

```sequence
title:动态网页的访问流程图
用户->浏览器:输入动态脚本地址
浏览器->域名解析(DNS):解析域名
域名解析(DNS)->Web服务器(Apache):ip定位到机器
Web服务器(Apache)->php引擎:发送test.php
php引擎->Web服务器(Apache):将解析成html文件返回
Web服务器(Apache)->浏览器:将html返回
浏览器->用户:解析html显示
```

## apache 的工作原理

Apache的诸多功能都是通过模块进行加载的，自己本身并不具备那么多能力（功能）,下图以 php 为例

```sequence
title:Apache 的工作示意图
浏览器->Apache:http://test.com/test.php
Apache->php引擎:test.php
php引擎->php扩展:mysql扩展
php扩展->mysql数据库:连接mysql
mysql数据库->php引擎:返回数据给php引擎
php引擎->Apache:解析成html返回
Apache->浏览器:返回html给浏览器
```

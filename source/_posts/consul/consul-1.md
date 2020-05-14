---
title: Consul系列（一）：Consul 的介绍与使用
date: 2018-11-26 13:51:00
banner: /images/consul_logo.png
thumbnail: /images/consul_logo.png
categories: Consul
tags:
  - consul
---
----------------------------------

Consul 用于实现分布式的服务发现和配置，内置了服务注册与发现框架，分布一致性协议实现，健康检查，Key/Value 存储，多数据中心方案，不再依赖其他工具。使用相对比较简单。

<!-- more -->

## Consul 介绍
Consul是一个分布式高可用的系统。相比其他的服务发现方案，Consul 的服务发现方案更"一站式"，内置服务发现与注册、分布式一致性协议实现、健康检查、Key/Value 存储，多数据中心方案。使用 Go 语言编写，因此，可编译成多个平台（Linux，Windows，Mac OS）

## Consul 特性

![](/images/consul.png)

- 服务发现 
- 健康检查
- Key/Value存储 
- 多数据中心

1. 支持多个数据中心， 上图有两个数据中心
2. 每个数据中心一般有 N个服务器，服务器数目要在可用性和性能上进行平衡，客户端数量没有限制。分布在不同的物理机上。
3. 一个集群中的所有节点都添加到 gossip protocol（通过这个协议进行成员管理和信息广播）中
4. 数据中心的所有服务端节点组成一个raft集合， 他们会选举出一个leader，leader服务所有的请求和事务， 如果非leader收到请求，把所有的改变同步(复制)给非leader.
5. 所有数据中心的服务器组成了一个 WAN gossip pool，他存在目的就是使数据中心可以相互交流，增加一个数据中心就是加入一个 WAN gossip pool，
6. 当一个服务端节点收到其他数据中心的请求， 会转发给对应数据中心的服务端。

## Consul 安装
https://www.consul.io/downloads.html 

不需要安装，解压后直接运行。

我这里下载的版本是 consul-1.5.2

## Consul Agent

运行 consul agent
```
# 开发模式运行，-node 指定节点名
consul agent -node consul.node.1 -dev
```
观察日志输出

## Web 管理界面
浏览器打开：http://127.0.0.1:8500

## 查看集群成员
```
consul members
```

会输出我们自己的节点，运行的地址，健康状态，自己在集群中的角色，版本信息
```
Node        Address         Status  Type    Build  Protocol  DC   Segment
consul.node.1  127.0.0.1:8301  alive   server  1.5.2  2         dc1  <all>
```

### HTTP 查询节点
```
curl 127.0.0.1:8500/v1/catalog/nodes
```
输出
```
[{"ID":"d68bd1c6-65dd-0a7e-97b0-c7dc409f9c91","Node":"consul.node.1","Address":"127.0.0.1","Datacenter":"dc1","TaggedAddresses":{"lan":"127.0.0.1","wan":"127.0.0.1"},"Meta":{"consul-network-segment":""},"CreateIndex":9,"ModifyIndex":10}]
```
### DNS 查询节点
```
dig @127.0.0.1 -p 8600 consul.node.1
```

## 服务注册
假如现在有一个 8088 的服务需要注册到 consul 中，我们先来定义一下服务

### 服务定义
服务定义最好是根据服务的所属业务线，业务模块，项目，以及服务属性来划分，例如，我们定义如下服务：
```
{
  "service": {
    "name": "video.user.info",
    "tags": ["go"],
    "port": 8088
  }
}
```
新建配置文件  /etc/consul.d/news.user.info.json，将服务信息写入

重启 agent
```
consul agent -config-dir /etc/consul.d -node consul.node.1 -dev
```
通过读取配置文件的服务定义信息，将服务 video.user.info 注册到了 consul 中


## 服务发现

通过 http 方式来发现服务
```
# video.user.info 是服务名
curl http://127.0.0.1:8500/v1/catalog/service/video.user.info
```
返回服务信息

## 总结
本文简单介绍了 Consul 的安装和使用，总体看 Consul 的安装和使用都比较简单。
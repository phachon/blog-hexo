---
title: Consul系列（五）：Consul 的一致性算法
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
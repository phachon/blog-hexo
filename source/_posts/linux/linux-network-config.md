---
title: Linux网络配置
date: 2016-07-24
categories: Linux
tags:
  - CentOS
  - Linux
---
----------------------------------

## 配置网络信息

```
vim /etc/sysconfig/network-scripts/ifcfg-eth0
```

打开ifcfg-eth0这个文件

![这里写图片描述](http://img.blog.csdn.net/20160724180749720)

在这个文件中，保存了第一块网卡的配置信息

- DEVICE	：设备名
- ONBOOT	：当系统启动后是否自动启动网卡设备   
- BOOTPROTO	：获取IP方式   static：静态获取
- IPADDR	：ip地址
- NETMASK	：子网掩码
- GATEWAY	：网关

<!-- more -->

如果没有IPADDR	：ip地址
则添加IPADDR=自己设置的ip地址
修改ONBOOT=”yes” BOOTPROTO=”static” 
修改完后：  :wq 或者  :x 保存退出

![这里写图片描述](http://img.blog.csdn.net/20160724180846978)

## 启动网络设备
 
(1) service

```
service  network  start|restart|stop
```
 
![这里写图片描述](http://img.blog.csdn.net/20160724181211607)
 
(2) ifup、ifdown

ifup：启用
ifdown：关闭

```
ifup eth0  ifdown eth0
```

## 测试网络连接
 
(1) ifconfig 查看当前网络设备

![这里写图片描述](http://img.blog.csdn.net/20160724181414000)

(2) ping

![这里写图片描述](http://img.blog.csdn.net/20160724181556474)

说明网络连接成功。

---
title: CentOS 下安装 Memcache 和 php 扩展
date: 2016-07-26
categories: Install
tags:
  - CentOS
  - Memcache
  - PHP
---
-----------------------------------

> CentOS 下安装 Memcache 和 php memcache 扩展

## 下载安装

查看相关软件包

```
Yum search memcached 
```

有了，可以进行安装了

```
Yum -y install memcached
```

<!-- more -->

Memcache关联php

```
yum -y install php-pecl-memcache
```

验证安装结果

```
memcached -h
php -m | grep memcache
```

Memcache的基本设置
启动memcache的服务端：

```
memcached -d -m 100 -u root -l 222.186.xx.xxx -p 11211 -c 512 -P /tmp/memcached.pid
```

## 参数说明

-d    选项是启动一个守护进程；
-m    是分配给Memcache使用的内存数量，单位是MB，我这里是100MB；
-u    是运行Memcache的用户，我这里是root；
-l    是监听的服务器IP地址我这里指定了服务器的IP地址222.186.xx.xxx；
-p    是设置Memcache监听的端口，我这里设置了11211，最好是1024以上的端口；
-c    选项是最大运行的并发连接数，默认是1024，我这里设置了512，按照你服务器的负载量来设定；
-P    是设置保存Memcache的pid文件，我这里是保存在 /tmp/memcached.pid；

## 使用

检查memcached是否启动

```
Netstat -an | more
tcp  0  0 222.186.xx.xxx:11211       0.0.0.0:*                   LIST
```

设置开机启动

```
Chkconfig memcached on
```

启动和停止

```
Service memcached start | stop
Or /etc/init.d/memcached start | stop
```

重启centos 

```
Shutdown -r now
Or reboot
```

编写 php 文件来验证 memcache 是否可用吧。

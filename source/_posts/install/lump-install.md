---
title: CentOS6.3+Apache2.2+php5.3.8+Mysql5.5.4源码搭建Lump环境
date: 2016-07-29
categories: Install
tags:
  - CentOS
  - Apache
  - PHP
  - Mysql
---
----------------------------------

## 系统环境

- 虚拟机VMware 下CentOS 6.3最小化安装。
- PHP版本：php-5.3.8.tar.gz
- Apache版本：httpd-2.2.31.tar.gz
- MySql版本：MySql-5.5.45.tar.gz

<!-- more -->

## 安装前准备

### 安装所需要的库文件
在安装PHP之前，应先安装PHP5需要的最新版本库文件，例如libxml2、libmcrypt以及GD2库等文件。安装GD2库是为了让PHP5支 持GIF、PNG和JPEG图片格式，所以在安装GD2库之前还要先安装最新的zlib、libpng、freetype和jpegsrc等库文件。
 
- autoconf-2.61.tar.gz
- freetype-2.3.5.tar.gz
- gd-2.0.35.tar.gz
- jpegsrc.v6b.tar.gz
- libmcrypt-2.5.8.tar.gz
- libpng-1.2.31.tar.gz
- libxml2-2.6.30.tar.gz
- zlib-1.2.3.tar.gz

下载安装包有两种方式：

(1).利用wget 工具 

先 yum install –y wget 安装wget .然后用 wget 
http://www.......com./ksk 下载

(2).利用 rz sz 命令将windows 下载好的包上传到 linux下 

```
yum install –y lrzsz  输入rz 弹出windows框选好安装包上传。
cd  /usr/local/src 进入到src目录下，将所有的安装包都放在这个目录下（方便管理）。
```

### 必须先安装gcc、gc-c++用来编译 这里采用yum安装即可。

```
yum install –y gcc
yum install –y gcc-c++
```
会自动安装成功。

### 解压缩

命令：tar –zxvf autoconf-2.61.tar.gz 
其他安装包一样。依次解压。

### make 命令

```
Yum install -y make
```
## 安装库文件

### 安装libxml2

```
# cd /usr/local/src/libxml2-2.6.30​
# ./configure --prefix=/usr/local/libxml2
# make && make install
```

### 安装libmcrypt

```
# cd /usr/local/src/libmcrypt-2.5.8
# ./configure --prefix=/usr/local/libmcrypt
# make && make install
```

### 安装zlib

```
# cd /usr/local/src/zlib-1.2.3
# ./configure    注意：这里直接./configure 不用--prefix
# make && make install
```

### 安装libpng

```
# cd /usr/local/src/libpng-1.2.31
# ./configure --prefix=/usr/local/libpng 注意：安装失败。原因很有可能是zlib 没有安装上
# make && make install
```

### 安装jpeg6

这个软件包安装有些特殊，其它软件包安装时如果目录不存在，会自动创建，但这个软件包安装时需要手动创建。

```
# mkdir /usr/local/jpeg6
# mkdir /usr/local/jpeg6/bin
# mkdir /usr/local/jpeg6/lib
# mkdir /usr/local/jpeg6/include
# mkdir -p /usr/local/jpeg6/man/man1
# cd /usr/local/src/jpeg-6b
# ./configure --prefix=/usr/local/jpeg6/ --enable-shared --enable-static
# make && make install
```
### 安装freetype

```
# cd /usr/local/src/freetype-2.3.5
# ./configure --prefix=/usr/local/freetype
# make
# make install
```
### 安装autoconf

```
# cd /usr/local/src/autoconf-2.61
# ./configure
# make && make install
```

### 安装GD库

```
# cd /usr/local/src/gd-2.0.35
# ./configure \
​--prefix=/usr/local/gd2/ \
​--enable-m4_pattern_allow \
​--with-zlib=/usr/local/zlib/ \
 --with-jpeg=/usr/local/jpeg6/ \
 --with-png=/usr/local/libpng/ \
 --with-freetype=/usr/local/freetype/
# make
```

出现错误：

```
make[2]: *** [gd_png.lo] Error 1
make[2]: Leaving directory `/usr/local/src/gd-2.0.35'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/usr/local/src/gd-2.0.35'make: *** [all] Error 2
```

分析：这个问题是因为gd库中的gd_png.c这个源文件中包含png.h时，png.h没有找到导致的。

解决：在编译文件里

```
# vi gd_png.c
# 将include “png.h” 改成 include “/usr/local/libpng/include/png.h”
```

其中/usr/local/libpng/为libpng安装路径。

```
# make install
```

### 开启80、3306端口

```
vi /etc/sysconfig/iptables
```
添加

```
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
```
重启防火墙

```
service iptables restart
```
### 关闭selinux

修改/etc/selinux/config 文件 

```
vi /etc/selinux/config
# 将SELINUX=enforcing改为SELINUX=disabled
```
重启防火墙

```
service iptables restart
```
## 安装 Apache

### 安装Apache

```
# cd /usr/local/src/httpd-2.2.9
# ./configure \
  --prefix=/usr/local/apache2 \
  --sysconfdir=/etc/httpd \
  --with-z=/usr/local/zlib \
  --with-included-apr \
  --enable-so \
  --enable-deflate=shared \
  --enable-expires=shared \
  --enable-rewrite=shared \
  --enable-static-support
# make && make install
```

### 配置Apache

启动Apache

```
#/usr/local/apache2/bin/apachectl start
```

如果提示httpd: Could not reliably determine the server's fully qualified domain name, using ::1 for ServerName

```
vi /etc/http/httpd.conf 
```

将里面的#ServerName www.example.com:80注释去掉,改成ServerName localhost:80 即可。再启动httpd

关闭Apache

```
# /usr/local/apache2/bin/apachectl stop
```

查看80端口是否开启 ，之前我们已经开启

```
# netstat -tnl|grep 80
```

然后可以通过浏览器访问http://localhost:80，如果页面显示正常显示测试页面，即表示apache已安装并启动成功。

添加自启动

```
# echo "/usr/local/apache2/bin/apachectl start" >> /etc/rc.d/rc.local
```

## 安装 Mysql

### cmake的安装

```
[root@localhost]# tar -zxv -f cmake-2.8.10.2.tar.gz // 解压压缩包
[root@localhost local]# cd cmake-2.8.10.2
[root@localhost cmake-2.8.10.2]# ./configure
[root@localhost cmake-2.8.10.2]# make
[root@localhost cmake-2.8.10.2]# make install
```
### 将cmake永久加入系统环境变量

用vi在文件/etc/profile文件中增加变量，使其永久有效，

```
[root@localhost local]# vi /etc/profile
```

在文件末尾追加以下两行代码：

```
PATH=/usr/local/cmake-2.8.10.2/bin:$PATHexport PATH
```

执行以下代码使刚才的修改生效：

```
[root@localhost local]# source /etc/profile
```

用 export 命令查看PATH值

```
[root@localhost local]# echo $PATH
```

注意：也可以直接yum install –y cmake 安装

### yum install -y ncurses-devel 

必须安装，不然会出错

### 创建mysql的安装目录及数据库存放目录

```
[root@localhost]# mkdir -p /usr/local/mysql //安装mysql
[root@localhost]# mkdir -p /usr/local/mysql/data //存放数据库
```

### 创建mysql用户及用户组

```
[root@localhost] groupadd mysql[root@localhost] useradd -r -g mysql mysql
```

### 编译安装mysql

```
[root@localhost local]# tar -zxv -f mysql-5.5.45.tar.gz //解压
[root@localhost local]# cd mysql-5.5.45
 cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
 -DDEFAULT_CHARSET=utf8 \
 -DDEFAULT_COLLATION=utf8_general_ci \
 -DWITH_EXTRA_CHARSETS=all \
 -DWITH_MYISAM_STORAGE_ENGINE=1 \
 -DWITH_INNOBASE_STORAGE_ENGINE=1 \
 -DWITH_MEMORY_STORAGE_ENGINE=1 \
 -DWITH_READLINE=1 \
 -DENABLED_LOCAL_INFILE=1 \
 -DMYSQL_DATADIR=/usr/local/mysql/data \
 -DMYSQL_USER=mysql
[root@localhost mysql-5.5.45]# make
[root@localhost mysql-5.5.45]# make install
```

### 检验是否安装成功

```
[root@localhost mysql-5.5.45]
# cd /usr/local/mysql/
[root@localhost mysql]# ls
bin COPYING data docs include INSTALL-BINARY lib man mysql-test README scripts share sql-bench support-files
```

有bin等以上文件的话，恭喜你已经成功安装了mysql。

### 设置mysql目录权限

```
[root@localhost mysql]
# cd /usr/local/mysql //把当前目录中所有文件的所有者设为root，所属组为mysql
[root@localhost mysql]
# chown -R root:mysql .
[root@localhost mysql]# chown -R mysql:mysql data
```

### 将mysql的启动服务添加到系统服务中

```
[root@localhost mysql]# cp support-files/my-medium.cnf /etc/my.cnfcp：是否覆盖"/etc/my.cnf"？ y
```

### 创建系统数据库的表

```
[root@localhost mysql]# cd /usr/local/mysql
[root@localhost mysql]# scripts/mysql_install_db --user=mysql
```

### 设置环境变量

```
[root@localhost ~]# vi /root/.bash_profile
```
修改为：

```
PATH=$PATH:$HOME/bin:/usr/local/mysql/bin:/usr/local/mysql/lib
[root@localhost ~]# source /root/.bash_profile //使刚才的修改生效
```

### 手动启动mysql

```
[root@localhost ~]# cd /usr/local/mysql
[root@localhost mysql]# ./bin/mysqld_safe --user=mysql & //启动MySQL，但不能停止
```

```
mysqladmin -u root -p shutdown //此时root还没密码，所以为空值，提示输入密码时，直接回车即可。
```

### 将mysql的启动服务添加到系统服务中

```
[root@localhost mysql]# cp support-files/mysql.server /etc/init.d/mysql
```

### 启动mysql

```
[root@localhost mysql]# service mysql startStarting MySQL... ERROR! The server quit without updating PID file (/usr/local/mysql/data/localhost.localdomain.pid).
```

启动失败：我这里是权限问题，先改变权限

```
[root@localhost mysql]# chown -R mysql:mysql /usr/local/mysql
```

接着启动服务器

```
[root@localhost mysql]# /etc/init.d/mysql start
```

### 修改MySQL的root用户的密码以及打开远程连接

```
[root@localhost mysql]# mysql -u root mysql

mysql> use mysql;
mysql> desc user;
mysql> GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "root"; //为root添加远程连接的能力
mysql> update user set Password = password('123456') where User='root'; //设置root用户密码
mysql> select Host,User,Password from user where User='root';
mysql> flush privileges;
mysql> exit;
```
### 重新登录

```
[root@localhost mysql]# mysql -u root -pEnter password:123456
```

若还不能进行远程连接，关闭防火墙

```
[root@localhost]# /etc/rc.d/init.d/iptables stop
```

## 安装 php

### 安装PHP

```
# cd /usr/local/src/php-5.3.8
# ./configure \
 --prefix=/usr/local/php \
 --with-config-file-path=/usr/local/php/etc \
 --with-apxs2=/usr/local/apache2/bin/apxs \
 --with-mysql=/usr/local/mysql/ \
 --with-libxml-dir=/usr/local/libxml2/ \
 --with-png-dir=/usr/local/libpng/ \
 --with-jpeg-dir=/usr/local/jpeg6/ \
 --with-freetype-dir=/usr/local/freetype/ \
​--with-gd=/usr/local/gd2/ \
 --with-zlib-dir=/usr/local/zlib/ \
​--with-mcrypt=/usr/local/libmcrypt/ \
​--with-mysqli=/usr/local/mysql/bin/mysql_config \
​--enable-mbstring=all \
​--enable-sockets
```

```
# make && make install
```

### 配置PHP

创建配置文件

```
# cp php.ini-development /usr/local/php/etc/php.ini
```

使用vi编辑apache配置文件

```
# vi /etc/httpd/httpd.conf
```

最后一行添加这一条代码 

```
Addtype application/x-httpd-php .php .phtml
```

重启Apache

```
# /usr/local/apache2/bin/apachectl restart
```

## 测试

### 编写info.php文件，查看php配置详细

```
#vi /usr/local/apache2/htdocs/info.php
```
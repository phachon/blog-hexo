---
title: Wamp 环境的搭建
date: 2016-07-26
categories: Coding
tags:
  - Windows
  - Mysql
  - Apache
  - PHP
---
----------------------------------

## Apache

### 下载
 
Apache是一种b/s结构的软件，Apache属于s服务端

下载地址：http://httpd.apache.org/download.cgi 选择相应的版本下载

我这里下载的是 httpd-2.2.22-win32-x86-no_ssl.msi
解释一下下载的文件：
版本：2.2.22
操作系统：win32 x86
是否提供ssl: no_ssl 不提供

<!-- more -->

### 安装

(1) 双击点击下载好的文件：httpd-2.2.22-win32-x86-no_ssl.msi
 
(2) 点击 next,进入协议页面，勾选同意。
     
![这里写图片描述](http://img.blog.csdn.net/20160726105923921)

(3) 点击两次 next 进入到服务器配置页面
     
![这里写图片描述](http://img.blog.csdn.net/20160726110132719)

(4) 点击next，进入配置模式，选择自定义配置模式
    
![这里写图片描述](http://img.blog.csdn.net/20160726110226955)
    
(5) 点击next，进入路径配置界面
    
在 D 盘下创建一个server 目录（不要使用中文）
将安装路劲选择到创建是server目录，并在server目录下创建一个Apache目录

![这里写图片描述](http://img.blog.csdn.net/20160726110753503)

(6) 点击next，进入到准备安装界面，点击install进行安装，之后点击finish完成,在电脑的任务栏会出现 apache 的图标，绿色代表已开启

![这里写图片描述](http://img.blog.csdn.net/20160726111119301)

(7) 验证是否成功

在浏览器输入 http://localhost ，页面 输出 It, works! 证明安装成功。

(8) apache 安装后的目录结构说明

D:/server/apache 下
 - bin: Apache 的可执行文件
 - cgi-bin：CGI 可执行文件
 - conf：配置文件
 - error：错误日志
 - htdocs：网站默认根目录
 - icons：图标
 - logs：日志
 - modules：Apache 可加载的模块
 
D:server/apache/bin

- httpd.exe apache 的服务端

(9) 几个简单的 httpd 命令
- M：Apache可以加载的模块（功能）
- l：当前Apache已经加载的模块
- t：验证配置文件的语法错误

在cmd控制台下，进入到 Apache 的bin目录，使用 httpd.exe 或者httpd 命令+空格+参数

![这里写图片描述](http://img.blog.csdn.net/20160726112532329)

配置文件验证

![这里写图片描述](http://img.blog.csdn.net/20160726112622574)

修改Apache配置文件：Apache/conf/httpd.conf

```
Servername www.test.com:80 #将前面的'#'号去掉即可开启
```

修改完配置文件后记得要重启 apache ,否则配置不会生效。

## Mysql

### 下载

```
mysql是一种c/s结构的软件。
```

当前是在为web服务器增加可以访问数据库的能力。
下载地址：http://www.mysql.com/downloads/
我这里下载的是:mysql-5.5-win32

### 安装
 
(1) 双击文件，进入安装界面

![这里写图片描述](http://img.blog.csdn.net/20160726113926564)

(2) 点击next，进入协议界面，选中同意协议，点击next进入配置模式

![这里写图片描述](http://img.blog.csdn.net/20160726114012955)

(3) 点击自定义安装，进入路径配置界面

在 D 盘 server 下创建一个目录 mysql
修改mysql的安装目录

![这里写图片描述](http://img.blog.csdn.net/20160726114215284)

修改数据路径

![这里写图片描述](http://img.blog.csdn.net/20160726114318206)

(4) 点击 next 进入到准备安装界面，点击install进行安装，安装完成之后进入到安装完成页面,勾选 finish 完成

![这里写图片描述](http://img.blog.csdn.net/20160726114504747)

(5) 点击next进行配置，进入到配置选择界面

![这里写图片描述](http://img.blog.csdn.net/20160726114622061)	

(6) 选择详细配置，点击next，进入到服务器类型配置界面

![这里写图片描述](http://img.blog.csdn.net/20160726114718625)

(7) 选择开发者机器，点击next，进入数据库用途配置

![这里写图片描述](http://img.blog.csdn.net/20160726114758798)

(8) 选择多功能数据库，点击next，进入到InnoDB驱动选择界面，可以直接点击next跳过

![这里写图片描述](http://img.blog.csdn.net/20160726114852599)

(9) 配置并发选项
    
![这里写图片描述](http://img.blog.csdn.net/20160726114939037)

(10) 选择手动选择，设置为默认的并发量15个，点击next，进入网络设置界面

![这里写图片描述](http://img.blog.csdn.net/20160726115039880)

(11) 勾选防火墙放行，其他默认，点击next进入到字符集设置界面

![这里写图片描述](http://img.blog.csdn.net/20160726115144085)

(12) 选择手动选择，设置字符集为utf8，点击next进入windows设置
    
![这里写图片描述](http://img.blog.csdn.net/20160726115223320)
    
(13) 勾选设置环境变量，点击next进入安全选项配置

![这里写图片描述](http://img.blog.csdn.net/20160726115259524)

(14) 输入root用户的密码，点击next进入到准备配置的界面

![这里写图片描述](http://img.blog.csdn.net/20160726115344086)

(15) 点击excute执行配置项，需要上面的四项都成功打上勾才算配置成功,点击finish完成安装。

![这里写图片描述](http://img.blog.csdn.net/20160726115423167)

(16) 检测是否安装成功

cmd控制台输入mysql –uroot –proot

![这里写图片描述](http://img.blog.csdn.net/20160726115550278)

(17) mysql 安装目录结构解释

- bin：执行文件
- data：数据存放目录
- include：包含文件
- lib：核心文件
- share：共享文件
- my.ini：mysql 核心配置文件

mysql 的 bin 目录

- mysql.exe mysql 的客户端
- mysqld.exe mysql 服务器端
	
## 配置PHP

### 下载
 
php 下载地址：http://www.php.net/downloads.php

选择对应的版本下载

### 配置
 
在 D:server/ 下创建 php 目录,将下载的 php 文件压缩包解压到该文件夹下

(1) 配置 apache,让 apache 能够识别 php
在Apache中加载PHP模块（把PHP当做Apache的一个模块来运行）。/apache/conf/httpd.conf

```
LoadModule php5_module d:/server/php/php5apache2_2.dll #加载PHP，当做Apache的模块 加载模式：LoadModule 模块名（不能随意） 模块的动态链接库所在的
AddType application/x-httpd-php .php #增加PHP处理模块需要处理的文件,将以.php结尾的文件交给PHP模块去处理
```

(2) 配置 php ，让  php 去连接 mysql

PHP本身没有能力去操作mysql，需要借助外部扩展才可以。在PHP中，提供一套mysql的扩展，能够连接mysql服务器。

在 php 的安装目录下有两个配置文件 php.ini-development php.ini-production,复制一份，修改为 php.ini 文件。打开 php.ini

将php的配置文件，加载到Apache的配置文件中。 /apache/conf/httpd.conf

```
PHPIniDir d:/server/php/php.ini #增加php配置文件的路径
```

开启mysql扩展。/php/php.ini

```
;extesion=php_mysql.dll #将前面的 ; 号去掉即可开启
```

指定扩展文件所在的目录。/php/php.ini
    
```
;extension_dir = "ext"
extension_dir = d:server/php/ext
```

修改 php 时区
    
在php的配置文件中去修改。/php/php.ini

```
;date_timezone = 
date_timezone = PRC #中国时区
```

## 配置虚拟主机

Apache的虚拟主机分为两种：基于IP地址的虚拟主机，基于域名的虚拟主机

基于域名的虚拟主机：通过域名来是的Apache区分对应的网站（文件夹）

Apache提供了多个位置可以用来配置虚拟主机，httpd.conf和/extra/httpd_vhost.conf
httpd.conf配置之后，只需要直接重启Apache即可生效
/extra/httpd_vhost.conf配置之后，需要在httpd.conf下加载对应的配置文件

### 先加载虚拟主机配置文件

找到 Include conf/extra/http-vhosts.conf,并开启

### 创建虚拟主机
```
<VirtualHost *:80>
    ServerName www.test.com #域名
    DocumentRoot "d:code/php/test" #路径
</VirtualHost>
```

### 重启 apache

### 修改 hosts 文件

hosts文件路径：C:\Windows\System32\drivers\etc\hosts

```
127.0.0.1 localhost
127.0.0.1 test.com
```

### 设置访问权限

```
<Directory "d:code/php/test"> # 目录访问权限
    Order Deny,Allow #设置顺序
    Deny from all
    Allow from all 
    DirectoryIndex indexs #指定访问方式，如果没有请求文件，而默认的文件又不存在，则显示所有的文件列表（在开发环境中应该禁用）
</Directory>
```

注意：一旦开启虚拟主机，那么默认的localhost会被覆盖，被第一个虚拟主机覆盖，为了解决不被覆盖的问题，需要额外增加一个localhost的虚拟主机。

```
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "d:server/apache/htdocs" #网站根目录
    
    <Directory "d:code/php/test"> # 目录访问权限
        Order Deny,Allow #设置顺序
        Deny from all
        Allow from all
    
        DirectoryIndex indexs #指定访问方式，如果没有请求文件，而默认的文件又不存在，则显示所有的文件列表（在开发环境中应该禁用）
    </Directory>
</VirtualHost>
```

### 更加清晰的配置方法

上面的配置方法是通用的配置虚拟主机的方式，但是随着越来越多的开发应用，会发现 Include conf/extra/http-vhosts.conf 里面会有越来越多的配置写在一起,有些早已不用的和正在使用的配置都加载在一起，不利于管理和修改。因此还可以采取以下的方式配置。

重新回到第1步中，打开 http.conf 文件，这次不要打开 Include conf/extra/http-vhosts.conf 的配置。而是在 http.conf 的最后一行添加 Include conf/extra/test.com.conf。

在 conf/extra 下面创建一个 test.com.conf 文件，然后将配置信息写入到文件中。

```
NameVirtualHost *:80
<VirtualHost *:80>
    ServerAdmin phachon@163.com
    DocumentRoot "D:/server/apache/htdocs/test"
    DirectoryIndex index.php
    ServerName test.com
    <Directory "D:/server/apache/htdocs/test">
        Options Indexes FollowSymLinks
        AllowOverride None
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
```

以后每新增一个虚拟主机配置就在 http.conf 的最后一行加载一下，并在 conf/extra 下创建对应的 conf 文件。
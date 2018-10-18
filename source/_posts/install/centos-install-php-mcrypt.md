---
title: CentOS下php安装 mcrypt 扩展
date: 2016-07-25
categories: Install
tags:
  - CentOS
  - PHP
  - mcrypt
---
----------------------------------

## 源码编译安装

需要下载Libmcrypt,mhash,mcrypt安装包

下载地址：http://www.sourceforge.net

- libmcrypt(libmcrypt-2.5.8.tar.gz );
- mcrypt(mcrypt-2.6.8.tar.gz );
- mhash(mhash-0.9.9.9.tar.gz );

```
wget "http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz"
wget "http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz"
wget "http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz"
```

<!-- more -->

## 安装Lmcrypt
    
```
tar -zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make
make install #说明：libmcript默认安装在/usr/local
```

## 安装mhash
```
tar -zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make
make install
```

## 安装mcrypt

```
tar -zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
LD_LIBRARY_PATH=/usr/local/lib ./configure
make
make install
```

安装php的mcrypt扩展(动态加载编译)

下载php下的mcrypt扩展或者直接下载php的完整安装包
http://www.php.net/releases/ 网页下找到自己服务器的php版本，下载后tar解压（本人的是php5.3.3）

进入ext/mcrypt文件夹
上传 mcrypt文件夹到你服务器的某个目录下然后进入此目录

执行phpize命令（phpize是用来扩展php扩展模块的，通过phpize可以建立php的外挂模块，如果没有？yum install php53-devel里包含了，或者其他方法）

```
[root@phachon 14:48 mcrypt] whereis phpize #phpize是否存在
phpize: /usr/bin/phpize /usr/share/man/man1/phpize.1.gz
[root@phachon 14:48 mcrypt] phpize
Configuring for:
PHP Api Version:         20090626
Zend Module Api No:      20090626
Zend Extension Api No:   220090626
```

执行完后，会发现当前目录下多了一些configure文件，最后执行php-config命令就基本完成了
执行以下命令，确保你的/usr/bin/php-config是存在的

```
[root@phachon 15:02 mcrypt] whereis php-config
php-config: /usr/bin/php-config /usr/share/man/man1/php-config.1.gz
[root@phachon 15:02 mcrypt] ./configure --with-php-config=/usr/bin/php-config
```

如果遇到以下错误，请先安装gcc，命令yum install gcc

```
configure: error: no acceptable C compiler found in $PATH
```

直到不报错，出现：config.status: creating config.h，执行以下命令

```
[root@phachon 15:06 mcrypt] make && make install
```

提示如下，说明你安装成功

```
Installing shared extensions:     /usr/lib64/php/modules/
```

顺便检查下/usr/lib64/php/modules/里的mrcypt.so扩展是否已经创建成功

然后的事就简单了，给你的php.ini添加一条extension=mcrypt.so

```
[root@phachon 15:09 mcrypt] cd /etc/php.d
```

创建一个mrcypt.ini文件就行，里面写extension=mcrypt.so

```
[root@phachon 15:17 php.d] echo 'extension=mcrypt.so' > mcrypt.ini
```

重启apache，phpinfo()，查看 mcrypt 模块扩展是不是加载了



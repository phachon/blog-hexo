---
title: Linux 常用命令总结
date: 2016-07-28
categories: Coding
tags:
  - Linux
---
----------------------------------

## 系统相关

- who 显示在线登录用户
- whoami 显示当前操作的用户
- hostname 主机名
- top 显示当前耗费最多的进程以及内存消耗
- ps -aux 显示所有的进程信息
- df 查看磁盘所占大小
- -h 带单位
- ifconfig 网络信息
- ping 测试网络连接
- netstat 网络状态信息
- kill 杀死进程
- clear 清屏
- shutdown
    - -r 关机重启
    - -h 关机不重启
    - now  立刻关机
- reboot   重启

<!-- more -->

## 目录相关

- cd 切换目录
- ls 列出目录下的文件或文件夹
- -l 列出文件详细信息
- -s 列出所有的文件及目录（包括隐藏）
- -f 列出的文件显示文件类型
- mkdir 创建目录
- -p 递归创建(父级不存在创建)
- pwd 显示当前目录路径
- rmdir 删除目录
- du 查看目录所占大小
- -h 带有单位显示目录所占大小
- zip 打包成 zip 文件
- unzip 解压 zip 文件 
- tar 打包压缩
    - -c  归档文件
    - -x  解压
    - -z  gzip压缩文件
    - -j   bzip2压缩文件
    - -v  显示压缩或解压缩过程
    - -f  使用档名
压缩：tar -zcvf /home/test.tar.gz /home/test
解压：tar -zxvf test.tar.gz ./
 
## 用户权限相关

- useradd 添加用户
- -c 注释信息
- -d 目录指定用户主目录，如果此目录不存在，则同时使用-m选项，可以创建主目录
- -g 用户组 指定用户所属的用户组
- -G 用户组，用户组指定用户所属的附加组
- -s Shell文件 指定用户的登录Shell
- -u 用户号 指定用户的用户号，如果同时有-o选项，则可以重复使用其他用户的标识号
- useradd –d /usr/sam -m sam
-  usermod 修改用户
- 参数和 useradd 一样
-  userdel 删除用户
- -r 连同目录一起删除
-  普通用户增加 root 权限
- 修改 /etc/sudoers 文件，找到下面一行，把前面的注释（#）去掉
```
Allows people in group wheel to run all commands
%wheel    ALL=(ALL)    ALL
```

然后修改用户，使其属于root组（wheel），命令如下：

```
usermod -g root phachon
```

修改完毕，现在可以用 phachon 帐号登录，然后用命令 su - ，即可获取root 权限

- sudo 命令可以不需要 root 密码来以 root 的权限执行
- 修改 /etc/sudoers 文件，找到下面一行，在root下面添加一行，如下所示：

```
Allow root to run any commands anywhere
root    ALL=(ALL)     ALL
phachon   ALL=(ALL)     ALL  #sudo 需要密码 
phachon ALL=(ALL)   NOPASSWD:ALL  # sudo 不需要密码
```

ok , 你就可以用  root 权限了

- chown 更改文件的用户用户组
- sudo chown [-R] owner[:group] {File|Directory}
```
sudo chown redis:redis ./redis
```
- 更改文件权限

首先先来了解一下三种基本权限
r  ->  读         数值表示为 4
w  ->  写         数值表示为 2
x  ->  可执行  数值表示为 1

假如某一个文件的权限为 -rw-rw-r--

-rw-rw-r--一共十个字符，分成四段。
第 1 个字符“-”表示普通文件，“l”链接，“d”表示目录
第2、3、4个字符“rw-”表示当前所属用户的权限，所以用数值表示为4+2=6
第5、6、7个字符“rw-”表示当前所属组的权限，所以用数值表示为4+2=6
第8、9、10个字符“r--”表示其他用户权限，所以用数值表示为2
所以操作此文件的权限用数值表示为662

777 对应的权限是 -rwxrwxrwx

```
sudo chmod 0777 test.php  修改 test.php 权限为 777
```
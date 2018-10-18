---
title: CronTab 解决周期内未执行完重复执行
date: 2016-08-23
categories: Linux
tags:
  - CronTab
  - PHP
---
----------------------------------

## crontab 执行 php 脚本

linux 下的 crontab 定时任务服务，可以用来定时运行脚本。工作中经常会用到这样的服务，使用起来比较简单。

```
/sbin/service crond start  # 开启服务
/sbin/service crond stop  # 停止服务
/sbin/service crond restart #重启服务
/sbin/service crond reload #重新加载服务

sudo crontab -e #插入一条定时任务
sudo crontab -l #查看所有的 root 用户下的定时任务列表
tail -f /var/log/cron # 实时查看定时任务日志
```

<!-- more -->

```
# 例如，添加如下一条定时任务
# 分 时 日 月 周
*  *  *  *  *   php test.php
```

## 重复执行问题

最近在工作中经常会用到定时任务，发现当我们的脚步的执行时间（假设：130s）大于定时任务的设定时间（假设：1分钟）时，定时任务会重复开始执行，即上次的任务还没有执行完，下次的任务的又开始执行。往往执行的脚本里的资源是不允许同时两个脚本同时共享资源，即保证操作的原子性。这样会造成执行出错，下面我们来验证一下。

以下是一个测试的 php 脚本，该脚本执行一次需要 130s 

```
<?php
$time = time();
$id = uniqid(); //一次执行的唯一标示
file_put_contents('/home/phachon/cron/test.log', "id: ".$id." 时间：".date('Y-m-d H:i:s', $time)."-开始\n", FILE_APPEND);
while(time() - $time < 130) {
    
}

file_put_contents('/home/phachon/cron/test.log', "id: ".$id." 时间：".date('Y-m-d H:i:s', time())."-结束\n", FILE_APPEND);

```

然后添加定时任务，每分钟（60s）执行一次

```
*/1 * * * * php /home/phachon/cron/test.php
```
过一段时间后，查看日志：

```
id: 57bbcd4d10262 时间：2016-08-23 12:13:01-开始
id: 57bbcd890e7f7 时间：2016-08-23 12:14:01-开始
id: 57bbcdc510685 时间：2016-08-23 12:15:01-开始
id: 57bbcd4d10262 时间：2016-08-23 12:15:11-结束
id: 57bbce010a78d 时间：2016-08-23 12:16:01-开始
id: 57bbcd890e7f7 时间：2016-08-23 12:16:11-结束
id: 57bbce3d0f68e 时间：2016-08-23 12:17:01-开始
id: 57bbcdc510685 时间：2016-08-23 12:17:11-结束
id: 57bbce790d90f 时间：2016-08-23 12:18:01-开始
id: 57bbce010a78d 时间：2016-08-23 12:18:11-结束
id: 57bbceb50eef8 时间：2016-08-23 12:19:01-开始
id: 57bbce3d0f68e 时间：2016-08-23 12:19:11-结束
id: 57bbce790d90f 时间：2016-08-23 12:20:11-结束
id: 57bbceb50eef8 时间：2016-08-23 12:21:11-结束
```

分析日志我们会发现 id = 57bbcd4d10262 的任务在 12:13:01 开始，但是还没有结束的时候，id=57bbcd890e7f7 和 id=57bbcdc510685 的任务就已经开始了，这样明显存在问题。我们想要的是每次单独执行完后，下一个执行开始:

```
id: 57bbcd4d10262 时间：2016-08-23 12:13:01-开始
id: 57bbcd4d10262 时间：2016-08-23 12:15:11-结束
id: 57bbcd890e7f7 时间：2016-08-23 12:14:01-开始
id: 57bbcd890e7f7 时间：2016-08-23 12:16:11-结束
```

## 解决办法

1. 利用临时文件
    
思路很简单，在执行文件的开头先判断是否有一个 test.lock 的文件，如果有 test.lock 文件，则 exit()，如果没有的话，创建 test.lock 文件，然后执行脚本文件，执行完毕删除 test.lock;
实现后代码：

```php
<?php
   $time = time();
   $id = uniqid();
   $lock = '/home/phachon/cron/lock/test.lock';
   if(file_exists($lock)) {
       exit('no');
   }
   touch($lock);

   file_put_contents('/home/phachon/cron/test2.log', "id: ".$id." 时间：".date('Y-m-d H:i:s', $time)."-开始\n", FILE_APPEND);
   while(time() - $time < 130) {

   }

   file_put_contents('/home/phachon/cron/test2.log', "id: ".$id." 时间：".date('Y-m-d H:i:s', time())."-结束\n", FILE_APPEND);
   unlink($lock);
```

查看日志如下：

```
id: 57bbdd3d6b5e8 时间：2016-08-23 13:21:01-开始
id: 57bbdd3d6b5e8 时间：2016-08-23 13:23:11-结束
id: 57bbddf10ecb9 时间：2016-08-23 13:24:01-开始
id: 57bbddf10ecb9 时间：2016-08-23 13:26:11-结束
```

2. 利用脚本加锁

思路和第一种方式类似，只是不是用文件判断的方式，而是给文件加锁的方式

实现代码：

```php
<?php
$fp = fopen("/tmp/lock.txt", "w+");
// 进行排它型锁定
if (flock($fp, LOCK_EX | LOCK_NB)) {
   //执行任务
   run(); 
   // 释放锁定
   flock($fp, LOCK_UN); 
} else {
   echo "文件被锁定";
}
fclose($fp);
?>
```

第一种和第二种方法本质思路一样，确实也解决了问题，但是这样需要加代码在我们的脚本里，而且，这样其实 crontab 服务还是多了很多不必要的执行，浪费资源。
我们需要找到更加好的方法，在执行代码前就已经判断是否可以执行脚本。

3. 利用 linux flock 锁机制

利用 flock（FreeBSD lockf，CentOS下为 flock），在脚本执行前先检测能否获取某个文件锁，以防止脚本运行冲突。

格式：

```
flock [-sxun][-w #] fd#
flock [-sxon][-w #] file [-c] command
```
选项：

```
-s, --shared:    获得一个共享锁 
-x, --exclusive: 获得一个独占锁 
-u, --unlock:    移除一个锁，脚本执行完会自动丢弃锁 
-n, --nonblock:  如果没有立即获得锁，直接失败而不是等待 
-w, --timeout:   如果没有立即获得锁，等待指定时间 
-o, --close:     在运行命令前关闭文件的描述符号。用于如果命令产生子进程时会不受锁的管控 
-c, --command:   在shell中运行一个单独的命令 
-h, --help       显示帮助 
-V, --version:   显示版本
```

锁类型：

- 共享锁：多个进程可以使用同一把锁，常被用作读共享锁
- 独占锁：同时只允许一个进程使用，又称排他锁，写锁。

这里我们需要同时只允许一个进程使用，所以使用独占锁。

修改后的定时任务如下：

```
*/1 * * * *  flock -xn /tmp/test.lock -c 'php /home/phachon/cron/test.php' >> /home/phachon/cron/cron.log'
```

日志如下：

```
id: 57bbf255e4b2b 时间：2016-08-23 14:51:01-开始
id: 57bbf255e4b2b 时间：2016-08-23 14:53:11-结束
id: 57bbf3090eca0 时间：2016-08-23 14:54:01-开始
id: 57bbf3090eca0 时间：2016-08-23 14:56:11-结束
```

完美的解决了我们的问题

总体看来，还是用第三种方法比较好，而且也方便.
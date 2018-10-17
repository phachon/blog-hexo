---
title: You-get 的安装与使用
date: 2016-09-12
categories: Misc
tags:
  - You-get
  - Python3
  - Windows
---
----------------------------------

## You-get 介绍

You-Get 是一款命令行工具，用来下载网页中的视频、音频、图片，支持众多网站，包含 41 家国内主流视频、音乐网站，如 网易云音乐、AB 站、百度贴吧、斗鱼、熊猫、爱奇艺、凤凰视频、酷狗音乐、乐视、荔枝FM、秒拍、腾讯视频、优酷土豆、央视网、芒果TV 等等，只需一个命令就能直接下载视频、音频以及图片回来，并且可以自动合并视频。而对于有弹幕的网站，比如 B 站，还可以将弹幕下载回来。本篇文章介绍  you-get 的安装

<!-- more -->

## Ubuntu安装
官网地址：https://you-get.org/
github地址：https://github.com/soimort/you-get/
中文说明：
https://github.com/soimort/you-get/wiki/%E4%B8%AD%E6%96%87%E8%AF%B4%E6%98%8E
安装准备： python3
安装方法：

1. 安装 pip3

```
sudo apt-get install python3-pip #安装 you-get
sudo pip3 install you-get
```

2. 下载安装

```
sudo wget https://github.com/soimort/you-get/releases/download/v0.4.523/you-get-0.4.523.tar.gz
sudo tar -zxvf you-get-0.4.523.tar.gz
cd you-get
make install
```

更新方法:

1. pip3 

```
pip3 install --upgrade you-get
```

2. 普通更新

```
    you-get https://github.com/soimort/you-get/archive/master.zip
```

## Windows 安装

1. 安装 Python3 

安装比较简单，这里不再说明

2. 安装 pip

下载地址:https://pypi.python.org/pypi/pip#downloads
选择 pip-8.1.2.tar.gz (md5, pgp) 下载
解压到一个目录下，打开 CMD 命令行，进入该目录
执行: python3 setup.py install
自动安装

安装完成后，注意一下 pip 安装的路径

![这里写图片描述](http://img.blog.csdn.net/20160912160449553)

我这里的路径是 D:\Program Files(86)\python3\Scripts
将pip 的安装路径添加到环境变量中 path

3. 安装 you-get

```
pip3 install you-get
```

OK ,Windows 下的 you-get 安装成功.
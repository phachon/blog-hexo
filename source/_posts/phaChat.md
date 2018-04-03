---
title: 一个基于 node.js 搭建的web聊天系统
date: 2016-10-11
categories: Coding
tags:
  - Node
  - Express
  - WebSocket
  - Mysql
---
----------------------------------

## 简介
> 一个简单的 web 聊天室, 采用 node.js 编写，基于 express + mysql + socket 实现的在线多人web 聊天系统，包括用户的登陆注册，用户的个人信息修改,目的是为了更加深入学习了解 node.js 和 websocket 技术，给初学者一个练习的小项目。有兴趣的同学可以继续完善（用户的头像上传，创建聊天群，消息保存等）

<!-- more -->

## Install 安装

- 环境
 npm 3.*
 node v6.*
 express 4.3.*
 mysql 5.5.*
 redis 2.8.*
 
- 使用

进入根目录，phaChat
 
```
npm install
npm start //开启聊天室客户端
node server //开启聊天室服务端
```  

浏览器输入 http://127.0.0.1:3000/chat/index,

## 界面效果

注册

![这里写图片描述](http://img.blog.csdn.net/20161011181034598)

登录

![这里写图片描述](http://img.blog.csdn.net/20161011181057918)

聊天室

![这里写图片描述](http://img.blog.csdn.net/20161011181119231)

## 继续扩展

- 创建聊天室
- 用户修改头像
- 发送表情
- model层优化

## 项目地址

https://github.com/phachon/phaChat


---
title: 火狐浏览器下刷新不清除表单问题
date: 2016-12-30
categories: Misc
tags:
  - FireFox
  - Html
  - javascript
---
----------------------------------

## 问题

js 控制表单重新刷新

```
location.href = url;
location.reload();
```

测试时发现谷歌，360均正常，但是在火狐浏览器，刷新完之后，表单的数据还在，并没有清除，刚开始以为是浏览器的设置问题。查找资料后找到一些解决办法

<!-- more -->

## 解决

form 表单加参数

```
<form method="post" autocomplete="off" action="">
```

```
autocomplete="off" 加了之后火狐刷新不再携带原始数据,清空表单
```

ok，测试通过，完美解决

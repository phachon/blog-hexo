---
title: 点直播流媒体传输协议之 —— HLS（HTTP Live Streaming）
date: 2016-09-13
categories: Coding
tags:
  - HLS
  - TS
  - M3U8
---
----------------------------------

## 简介

在最近一年的工作中接触比较多的是视频点播和直播，也了解到了一些点直播的后端技术，这段时间希望将了解到的一些技术总结下来，这篇文章主要介绍流媒体协议 HLS

<!-- more -->

## 流媒体协议
常用的流媒体协议主要有 HTTP 渐进下载和基于 RTSP/RTP 的实时流媒体协议，这两种协议是完全不同的实现方式。主要区别如下：

1. 一种是分段渐近下载，一种是基于实时流来实现播放
2. 协议不同，HTTP 协议的渐近下载意味着你可以在一台普通的 HTTP 的应用服务器上就可以直接提供点播和直播服务
3. 延迟有差异，HTTP 渐近下载的方式的延迟理论上会略高于实时流媒体协议的播放
4. 渐近下载会生成索引文件，所以需要考虑存储，对 I/O 要求较高

## HLS简介

HLS （HTTP Live Streaming）是苹果公司实现的基于 HTTP 的流媒体协议，可以实现流媒体的点播和直播播放。当然，起初是只支持苹果的设备，目前大多数的移动设备也都实现了该功能。HTML5 直接支持该协议。

## 实现原理

HLS 点播是常见的分段 HTTP 点播，就是将视频流分成不同的片段，客户端不断的去下载该片段，由于片段之间的分段间隔时间非常短，所以看起来是一条完整的播放流，实现的重点是对于媒体文件的分割。同时，HLS 还支持多码率的切换，客户端可以选择从许多不同的备用源中以不同的速率下载同样的资源，允许流媒体会话适应不同的数据速率。多清晰度就是这样实现的。
为了播放媒体流，客户端首先需要获得播放列表文件，也就是根据 HLS 生成的片段列表，该列表中包含每个流媒体的文件，客户端以类似轮询的方式不断重复加载播放列表文件并将片段追加实现流媒体的播放。
播放列表文件就是通常我们所说的 m3u8 文件，是以后缀 .m3u8 Content-Type是"application/vnd.apple.mpegurl" 的文件。

## m3u8 介绍与分析

m3u8 文件本质说其实是采用了编码是 UTF-8 的 m3u 文件。
它只是一个纯索引文件，一个文件片段的列表，客户单打开它并不是播放它，而是根据它里面的文件片段找到视频文件的网路地址进行播放

这里抓包抓了一个 m3u8 文件打开看一下究竟是什么：

```
#EXTM3U
#EXT-X-VIDEO-INF:VIDEO=559ac1317682fa1fcdc67ed2774e4e1a980e0c264cefceb5c.....
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=245760
https://*******.com/video/cif/hNAQ0_jbip4j-0o_BhcdqMwyQxwtwbo1k3vVZhtjbcQ.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=491520
https://******.com/video/sd/hNAQ0_jbip4j-0o_BhcdqMwyQxwtwbo1k3vVZhtjbcQ.m3u8
```

分析该 m3u8 文件：
```
#EXTM3U：扩展标记 ，意思是我是 m3u 文件
#EXT-X-VIDEO-INF:VIDEO ：这个应该是自己定义的一个标签，指名是视频文件，后面可能跟的是视频标题之类的
#EXT-X-STREAM-INF
指定一个包含多媒体信息的 media URI 作为PlayList，一般做M3U8的嵌套使用，它只对紧跟后面的URI有效，#EXT-X-STREAM-INF:有以下属性：
BANDWIDTH：带宽，491520
PROGRAM-ID：该值是一个十进制整数，惟一地标识一个在PlayList文件范围内的特定的描述。一个PlayList 文件中可能包含多个有相同ID的此tag。
CODECS：不是必须的。
RESOLUTION：分辨率。
AUDIO：这个值必须和AUDIO类别的“EXT-X-MEDIA”标签中“GROUP-ID”属性值相匹配。
```

这里 PlayList 的地址我们发现还是个 m3u8 文件

```
https://*******.com/video/cif/hNAQ0_jbip4j-0o_BhcdqMwyQxwtwbo1k3vVZhtjbcQ.m3u8
https://******.com/video/sd/hNAQ0_jbip4j-0o_BhcdqMwyQxwtwbo1k3vVZhtjbcQ.m3u8
```

可以观察发现，这其实是 cif 和 sd 两种不同清晰度的 m3u8 文件，客户端根据网络或者选项去选择不同的清晰度的 m3u8 文件。
上面的 m3u8 文件为一级 m3u8 文件，这两个 m3u8 就称为二级 m3u8 文件，那么我们就顺着二级 m3u8 文件继续查看，将其中一个下载到本地打开分析：

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:11
#EXTINF:12.400,
http://*************/**/M00/00/BB/Cn1GQlfWRFaACQaQAAvsEEMIWI42131.ts
#EXTINF:10.000,
http://*************/**/M00/00/BB/Cn1GQlfWRFaAJO1mAAaTMDz8P4E9292.ts
#EXTINF:10.000,
http://*************/**/M00/00/BB/Cn1GQlfWRFaAZ2fyAAVQEM22iWA2544.ts
#EXTINF:11.120,
http://*************/**/M00/00/BB/Cn1GQlfWRFaAIfwHAAirSMgfpx03176.ts
#EXTINF:17.240,
http://*************/**/M00/00/BB/Cn1GQlfWRFaAaiz6AAn0SHY1csA7539.ts
#EXTINF:3.720,
http://*************/**/M00/00/BB/Cn1GQlfWRFaARLJ2AAGYUIIpGKA7707.ts
#EXT-X-ENDLIST
```

```
#EXT-X-VERSION:3 : 版本
#EXT-X-TARGETDURATION: 11
指定最大的媒体段时间长（秒）。所以#EXTINF中指定的时间长度必须小于或是等于这个最大值。这个tag在整个PlayList文件中只能出现一 次（在嵌套的情况下，一般有真正ts url     的m3u8才会出现该tag）
#EXTINF: duration 指定每个媒体段(ts)的持续时间（秒），仅对其后面的URI有效，title是下载资源的url
#EXT-X-ENDLIST 结束列表
```

这里我们看到了真正播放的流片段，ts 片，客户端拿到的就是这个 ts 片，然后不断下载请求到该片段并连续播放。

有些人可能要问了，那 ts 文件又到底是个什么东西呢，那就下载来看看，拿着其中的一个 ts 文件浏览器打开保存到本地：

![这里写图片描述](http://img.blog.csdn.net/20160913114717400)
 
发现保存到本地的文件就可以直接打开，其实就是真正的流媒体文件，但是这个文件只是片段，大概只有 10s 的时间。

## HLS播放实现时序图

```sequence
title:流媒体播放实现时序图
客户端->服务端play接口:请求
服务端play接口->客户端:返回一级 m3u8地址
客户端->m3u8文件服务器:获取一级m3u8文件
客户端->m3u8文件服务器:获取二级m3u8文件
客户端->ts文件服务器:不断获取 ts 流媒体文件
```

## HLS 直播

HLS 直播原理上还是按点播的方式实现的，通过 http 协议传输，生成 ts 索引文件以及 m3u8 索引文件。直播的复杂在于先要采集视频源和音频源的数据，然后再进行 H264 编码和音频 ACC 编码，并封装成 ts 包，其中还要考虑 ts 的分段生成策略。

下一篇我会介绍一篇关于 rtmp 协议的文章。

欢迎指正，Thanks...
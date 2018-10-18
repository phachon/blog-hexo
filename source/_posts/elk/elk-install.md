---
title: ELK 实时日志分析系统平台的学习与使用
date: 2016-09-22
categories: ELK
tags:
  - ELK
  - ElasticSearch
  - LogStash
  - Kibana
  - Marvel
  - Log
  - Linux
  - Redis
---
----------------------------------

## 简介
工作工程中，不论是开发还是运维，都会遇到各种各样的日志，主要包括系统日志、应用程序日志和安全日志，对于开发人员来说，查看日志，可以实时查看程序的运行错误，以及性能分析，通常，一个大中型的应用程序会被部署到多台服务器，那日志文件也会分散到不同的机器上，这样查看日志难道要一台一台去查看？显然是太麻烦了，开源的日志分析系统 ELK 完美的解决了这个问题。
ELK  并不是一个独立的系统，她是由 ElasticSearch、Logstash、Kibana 三个开源的工具组成。

- ElasticSearch
ElasticSearch是一个基于Lucene的搜索服务器。它提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口。Elasticsearch是用Java开发的，并作为Apache许可条款下的开放源码发布，是当前流行的企业级搜索引擎。设计用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。
- Logstash
Logstash 是一个开源的日志分析、收集工具，并将日志存储以供以后使用。
- Kibana
Kibana 是一个为 Logstash 和 ElasticSearch 提供的日志分析的 Web 接口。可使用它对日志进行高效的搜索、可视化、分析等各种操作。

<!-- more -->

## 搭建方法

基于一台主机的搭建，没有使用多台集群，logstah 收集日志后直接写入 elasticseach，可以用 redis 来作为日志队列
 
### jdk 安装
jdk 1.8 安装

### elasticseach 安装
 
下载地址：https://www.elastic.co/downloads，选择相应的版本 我这里的版本是 elasticsearch-2.4.0

解压目录:
```
[phachon@localhost elk]$ tar -zxf elasticsearch-2.4.0
[phachon@localhost elasticsearch-2.4.0]$
# 安装 head 插件
[phachon@localhost elasticsearch-2.4.0]$./bin/plugin install mobz/elasticsearch-head
[phachon@localhost elasticsearch-2.4.0]$ ls plugins/
head
编辑 elasticseach 的配置文件

[phachon@localhost elasticsearch-2.4.0]$ vim config/elasticseach.yml
13 # ---------------------------------- Cluster -----------------------------------
14 #
15 # Use a descriptive name for your cluster:
16 #
17  cluster.name: es_cluster #这里是你的el集群的名称
18 #
19 # ------------------------------------ Node ------------------------------------
20 #
21 # Use a descriptive name for the node:
22 #
23  node.name: node0 # elseach 集群中的节点
24 #
25 # Add custom attributes to the node:
26 #
27 # node.rack: r1
28 #
29 # ----------------------------------- Paths ------------------------------------
30 #
31 # Path to directory where to store the data (separate multiple locations by comma):
32 #
33  path.data: /tmp/elasticseach/data #设置 data 目录
34 #
35 # Path to log files:
36 #
37  path.logs: /tmp/elasticseach/logs # 设置 logs 目录
#
39 # ----------------------------------- Memory -----------------------------------
40 #
41 # Lock the memory on startup:
42 #
43 # bootstrap.memory_lock: true
44 #
45 # Make sure that the `ES_HEAP_SIZE` environment variable is set to about half the memory
46 # available on the system and that the owner of the process is allowed to use this limit.
47 #
48 # Elasticsearch performs poorly when the system is swapping the memory.
49 #
50 # ---------------------------------- Network -----------------------------------
51 #
52 # Set the bind address to a specific IP (IPv4 or IPv6):
53 #
54 # network.host: 192.168.0.1
55  network.host: 192.168.30.128  # 这里配置本机的 ip 地址,这个是我的虚拟机的 ip 
56 #
57 # Set a custom port for HTTP:
58 #
59  http.port: 9200 # 默认的端口
```

其他配置可先不设置
启动 elstaicseach

```
[root@localhost elasticsearch-2.4.0]$ ./bin/elasticsearch
```
注意，这里肯定会报错：

```
[root@localhost elasticsearch-2.4.0]# ./bin/elasticsearch
Exception in thread "main" java.lang.RuntimeException: don't run elasticsearch as root.
at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:94)
at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:160)
at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:286)
at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:35)
Refer to the log for complete error details.
```

之前在网上搜的教程这里都没有详细说明，导致花了很长时间卡在这里安装不成功。
提示的原因已经说的很清楚了，不能以 root 权限来安装 elasticseach
为 elsearch 添加专门的用户组和用户

```
[root@localhost elasticsearch-2.4.0]# groupadd elsearch
[root@localhost elasticsearch-2.4.0]# adduser -G elsearch elsearch
[root@localhost elasticsearch-2.4.0]# passwd elsearch 123456
```

将 elasticseach 的安装目录设置为 elsearch 用户组和用户所有

```
[root@localhost elk]# chown -R elsearch:elsearch elasticsearch-2.4.0/
```

别忘了将 /tmp/elasticseach/data 和 /tmp/elasticseach/logs 目录也设置为 elsearch 用户所有,要不然会没有权限读写

```
[root@localhost tmp]# chown -R elsearch:elsearch elasticseach/
```

好了。终于设置完毕。切换到 elsearch 重新启动

```
[elsearch@localhost elasticsearch-2.4.0]# ./bin/elasticsearch
[2016-09-22 01:51:42,102][WARN ][bootstrap] unable to install syscall filter: seccomp unavailable: requires kernel 3.5+ 
with CONFIG_SECCOMP andCONFIG_SECCOMP_FILTER compiled in
[2016-09-22 01:51:42,496][INFO ][node] [node0] version[2.4.0], pid[4205], build[ce9f0c7/2016-08-29T09:14:17Z]
[2016-09-22 01:51:42,496][INFO ][node] [node0] initializing ...
[2016-09-22 01:51:43,266][INFO ][plugins] [node0] modules [reindex, lang-expression, lang-groovy], plugins [head], 
sites [head]
[2016-09-22 01:51:43,290][INFO ][env] [node0] using [1] data paths, mounts [[/ (/dev/sda5)]], net usable_space [8.4gb], 
net total_space [14.6gb], spins?[possibly], types [ext4]
[2016-09-22 01:51:43,290][INFO ][env] [node0] heap size [998.4mb], compressed ordinary object pointers [unknown]
[2016-09-22 01:51:43,290][WARN ][env] [node0] max file descriptors [4096] for elasticsearch process likely too low, consider 
increasing to at least[65536]
[2016-09-22 01:51:45,697][INFO ][node] [node0] initialized
[2016-09-22 01:51:45,697][INFO ][node] [node0] starting ...
[2016-09-22 01:51:45,832][INFO ][transport] [node0] publish_address {192.168.30.128:9300}, bound_addresses {192.168.30.128:9300}
[2016-09-22 01:51:45,839][INFO ][discovery] [node0] es_cluster/kJMDfFMwQXGrigfknNs-_g
[2016-09-22 01:51:49,039][INFO ][cluster.service] [node0] new_master {node0}{kJMDfFMwQXGrigfknNs-_g}{192.168.30.128}
{192.168.30.128:9300}, reason:zen-disco-join(elected_as_master, [0] joins received)
[2016-09-22 01:51:49,109][INFO ][http] [node0] publish_address {192.168.30.128:9200}, bound_addresses {192.168.30.128:9200}
[2016-09-22 01:51:49,109][INFO ][node] [node0] started
[2016-09-22 01:51:49,232][INFO ][gateway] [node0] recovered [2] indices into cluster_state
```

启动成功
在本机浏览器访问 http://192.168.30.128:9200

![这里写图片描述](http://img.blog.csdn.net/20160922113309605)

说明搜索引擎 API 返回正常。注意要在服务器将 9200 端口打开，否则访问失败。

打开我们刚刚安装的 head 插件
http://192.168.30.128:9200/_plugin/head/

![这里写图片描述](http://img.blog.csdn.net/20160922113529720)

如果是第一次搭建好，里面是没有数据的，node0 节点也没有集群信息，这里我搭建完成后已经添加了数据。所以显示的有信息

### Logstash安装

下载地址：https://www.elastic.co/downloads，选择相应的版本 我这里的版本是 logstash-2.4.0.tar.gz
解压目录：

```
[root@localhost elk]# tar -zxvf logstash-2.4.0
[root@localhost elk]# cd logstash-2.4.0
```
编辑 logstash 配置文件：

```
[root@localhost logstash-2.4.0]# mkdir config
[root@localhost logstash-2.4.0]# vim config/logstash.conf
```

这里因为为了简单来显示一下数据，我这里将 apache 的日志作为数据源，也就是 logstash 的 input，直接输出到 elstaticseach 里，即 ouput

```
input {
     # For detail config for log4j as input,
     # See: https://www.elastic.co/guide/en/logstash/
     file {
           type => "apache-log" # log 名
           path => "/etc/httpd/logs/access_log" # log 路径
     }
}
filter {
    #Only matched data are send to output. 这里主要是用来过滤数据
}
output {
   # For detail config for elasticsearch as output,
   # See: https://www.elastic.co/guide/en/logstash/current
   elasticsearch {
     action => "index"          #The operation on ES
     hosts  => "192.168.30.128:9200"   #ElasticSearch host, can be array. # elasticseach 的 host 
     index  => "apachelog"         #The index to write data to. 
   }
}
```

使用命令来检测配置文件是否正确

```
[root@localhost logstash-2.4.0]# ./bin/logstash -f config/logstash.conf --configtest
Configuration OK
```

启动 logstash 来收集日志

```
[root@localhost logstash-2.4.0]# ./bin/logstash -f config/logstash.conf
Settings: Default pipeline workers: 4
Pipeline main started
```

好了，logstash 可以开始收集日志了，当日志文件有变化时，会动态的写入到 elastaticseach 中，先让我们来产生一些日志吧。
刷新 http://192.168.30.128/ 一直刷新，apache 产生访问日志。ok，打开我们的 elasticseach 的 web 页面 http://192.168.30.128:9200/_plugin/head/

![这里写图片描述](http://img.blog.csdn.net/20160922113659904)
     
这里就出现了我们刚刚配置的 apachelog 的日志，点开数据浏览

![这里写图片描述](http://img.blog.csdn.net/20160922113728826)

这里很详细的列出了我们的日志文件，还有字段，左边可进行相应的搜索，右边点击可查看具体的日志信息。
至此我们已经能够收集日志，并进行搜索，接下来我们来将搜索数据可视化成图表

### Kibana 的安装

下载：https://www.elastic.co/downloads 对应自己的版本, 这里我的版本是：kibana-4.6.1-linux-x86

解压目录：

```
[root@localhost elk]# tar -zxvf kibana-4.6.1-linux-x86
[root@localhost elk]# cd kibana-4.6.1-linux-x86
```

编辑配置文件：

```
 [root@localhost kibana-4.6.1-linux-x86]# vim config/kibana.yml
 # Kibana is served by a back end server. This controls which port to use.
 server.port: 5601  # kibaba 服务 port 
 # The host to bind the server to.
 server.host: "192.168.30.128"  # 你的kibaba 的服务host
 # If you are running kibana behind a proxy, and want to mount it at a path,
 # specify that path here. The basePath can't end in a slash.
 # server.basePath: ""
 # The maximum payload size in bytes on incoming server requests.
 # server.maxPayloadBytes: 1048576
 # The Elasticsearch instance to use for all your queries.
 elasticsearch.url: "http://192.168.30.128:9200"  # elastaticseach 的host
 # preserve_elasticsearch_host true will send the hostname specified in `elasticsearch`. If you set it to false,
 # then the host you use to connect to *this* Kibana instance will be sent.
 # elasticsearch.preserveHost: true

# Kibana uses an index in Elasticsearch to store saved searches, visualizations
# and dashboards. It will create a new index if it doesn't already exist.
kibana.index: ".kibana" # kibana

# The default application to load.
# kibana.defaultAppId: "discover"

# If your Elasticsearch is protected with basic auth, these are the user credentials
# used by the Kibana server to perform maintenance on the kibana_index at startup. Your Kibana
```

配置比较简单
配置完成后开始运行

```
[root@localhost kibana-4.6.1-linux-x86]# ./bin/kibana
log   [02:48:34.732] [info][status][plugin:kibana@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.771] [info][status][plugin:elasticsearch@1.0.0] Status changed from uninitialized to yellow - Waiting for Elasticsearch
log   [02:48:34.803] [info][status][plugin:kbn_vislib_vis_types@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.823] [info][status][plugin:markdown_vis@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.827] [info][status][plugin:metric_vis@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.835] [info][status][plugin:elasticsearch@1.0.0] Status changed from yellow to green - Kibana index ready
log   [02:48:34.840] [info][status][plugin:spyModes@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.847] [info][status][plugin:statusPage@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.857] [info][status][plugin:table_vis@1.0.0] Status changed from uninitialized to green - Ready
log   [02:48:34.867] [info][listening] Server running at http://192.168.30.128:5601
```

在浏览器运行  http://192.168.30.128:5601

![这里写图片描述](http://img.blog.csdn.net/20160922113810546)

这里要先添加 index，在 输入框输入我们刚刚收集的 apachelog 作为 index 名称

![这里写图片描述](http://img.blog.csdn.net/20160922113836334)

点击 create 创建

![这里写图片描述](http://img.blog.csdn.net/20160922113919343)

右上角选择时间来显示我们的数据访问，下面是数据的访问量

中间的搜索框可输入搜索条件搜索，搜索完成后点击右上角的 save seach 保存搜索数据 

![这里写图片描述](http://img.blog.csdn.net/20160922113936492)

点击 visualize 可以画出其他的数据分析图，比如饼状图

![这里写图片描述](http://img.blog.csdn.net/20160922114217980)

选择我们刚刚保存的 chrome 的文件来生成饼状图

因为数据没什么变化，所以只能全部是一样的。还是点击右上角的保存按钮，将饼状图保存为 test

![这里写图片描述](http://img.blog.csdn.net/20160922114030368)

添加到 面板中，点击 dashboard
点击 + 号添加

![这里写图片描述](http://img.blog.csdn.net/20160922114055328)

选择 test 来显示到面板，效果如下

![这里写图片描述](http://img.blog.csdn.net/20160922114123360)

这样简单的 ELK 系统就搭建起来了，当然，正真的使用环境中，我们会使用集群搭建。利用 redis 来处理日志队列。

## marvel 插件

Marvel是Elasticsearch的管理和监控工具，在开发环境下免费使用。拥有更好的数据图表界面。

首先在 elastaticsearch 下安装 marvel-agent 插件

```
[elsearch@localhost elasticsearch-2.4.0]$ ./bin/plugin install license
[elsearch@localhost elasticsearch-2.4.0]$ ./plugin install marvel-agent
```

这里注意，必须先执行 license 安装，再执行 marvel-agent 安装，安装完成后重启  elastaticseach
接下来 kibana 来安装 marvel 插件

```
[root@localhost kibana-4.6.1-linux-x86]# cd bin
[root@localhost bin]# ./kibana plugin --install elasticsearch/marvel/latest
```

安装完成后重启 kibana，选择 marvel 插件

![这里写图片描述](http://img.blog.csdn.net/20160922114438389)

![这里写图片描述](http://img.blog.csdn.net/20160922114331767)
 
是不是感觉有点高大上。。。

好了 ELK 的基本搭建就算是完成了，接下来我们考虑如何集群来使用这个系统。

欢迎指正， Thanks....
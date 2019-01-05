---
title: TCP/IP 协议栈系列（二）：协议概述
date: 2018-09-11 
categories: Network
tags:
  - tcp
---
----------------------------------

本章将**自底向上**来说明 TCP/IP协议栈各层的具体工作流程

## 传输介质
首先，我们应该都知道计算机之间必须通过一定的传输媒介才能将数据相互传递，例如，光缆，光纤，或者无线电波，不同的传输媒介决定了电信号（0 1）的传输方式，同时也影响了电信号的传输速率、传输带宽。

## 链路层
我们自然的会去思考：
> 如何才能将 0 1 的电信号通过传输媒介传输到对方的主机？

很好解决：我们将每个计算机都安装一个能接受数据和发送数据的设备，然后将 0 1 的电信号分组，也就是组成字节的形式发送出去。

> 为什么要组成字节发送，因为单纯的 0 1 是没有意义的，计算机用 8 个 0 或 1 的二进制位来表示一个字节，字节才是我们发送数据的最小单位

那么这里我们提到的接受数据和发送数据的设备，就是网卡。我们规定，数据包必须是从一块网卡到另一块网卡，而网卡的地址（即我们常说的MAC 地址）就是数据包要发送的地址和接受地址。
MAC 地址就像网卡的身份证一样，必须具有全球唯一性。MAC 地址采用 16 进制表示，共 6 个字节，前 3 个字节是厂商的编号，后三个字节是网卡流水号。例如：5C-0F-6E-13-D1-18  

解决了发送设备，接下来解决如何发送，所以就有人设计出来了一种发送数据的规范，也就是以太网协议。  

以太网协议规定，一组电信号就是一个数据包，一个数据包也被称为一帧。一个以太网数据包的格式如下：

```$xslt
+--------------+----------------------+--------------+
| head(14 byte)| data(46 ~ 1500 byte) | end (4 byte) |
+--------------+----------------------+--------------+
```

整个数据包由三部分组成，头部，数据，和尾部，头部占14个字节，包含原MAC地址，目标MAC地址和类型；数据区最短 46个字节，最大 1500 个字节，如果发送的数据大于 1500 个字节，则必须拆开多个数据包来发送。
尾部为 4 个字节，用来存数据帧的校验序列，用来验证整个数据包是否完整。  

以太网数据包发送过程：  
以太网协议会通过**广播**的形式将以太网数据包发送给**在同一个子网**的所有主机，这些主机接受到数据包之后，会取出数据包的头部里的 MAC 地址和自己的 MAC 地址进行比较，如果相等，就会接着处理数据，如果不相等，则会丢弃这个数据包。  

总结：链路层的工作就是将 0，1的电信号分组并组装成以太网数据包，然后网卡通过传输媒介以广播的形式将数据包发送给在同一个子网的接收方

> 注意：以太网协议始终是以广播的形式将数据包发给在同一个子网的主机

## 网络层
首先再回过头来看一下链路层，为了能让链路层工作，我们必须知道对方主机的 MAC 地址，而且还要知道对方的 MAC 地址是否和自己处于同一网络。

>1. 如果我们使用 MAC 地址来传输数据，那就必须记住每个 MAC 地址，但是去记一串这样长（ 5C-0F-6E-13-D1-18 ）的地址显然是不友好的
>2. 即使我们能记住 MAC 地址，MAC 地址也只于厂商有关，和网络无关，怎么能知道是不是在一个子网？
>3. 如果不是一个子网，那怎么办，以太网的协议难道不能发生以太网数据包了？

别急，能提出问题，那自然有解决方案，当没有解决办法的时候，那就设计一套新的协议来弥补这些问题。  

为了解决以上的问题，我们的前辈们设计了三个协议：IP 协议，ARP 协议，路由协议。同时呢将这三个协议放在了网路层。

### IP 协议
为了解决 1 和 2，必须指定了一套新的地址。使得我们能够区分两个主机是否在同一个网络。IP 地址分为 IPV4 和 IPV6 两种，现在普遍还在使用的是 IPV4 地址，IPV4 地址由 4 个字节 32 位组成，每个字节可以用一个十进制的数表示，通常，我们使用 . 隔开每个十进制数来表示 ip 地址，例如：192.168.12.11 。
同时，IPV4 对 IP 地址进行了分类，主要是 A B C D 四类，以 C 类地址 192.168.12.11 为例，其中前 24 位就是网络地址，后 8 位就是主机地址。那么网络地址相同的就是在一个局域网子网内
为了判断 IP 地址中的网络地址，IP 协议还引入了子网掩码，通过子网掩码和 IP 地址按位与运算，就能得到网络地址。  

因为在上层的传输层中，开发者会将 IP 地址传入，所以我们只用通过子网掩码进行运算后就能判断两个 IP 是否在一个子网内。

> 这里简单介绍一下 IP 数据包：

```
+-----------------+--------------------+
| head(20 byte)   | data (65515 byte)  |
+----------------=+--------------------+
```

### ARP 协议
我们解决了问题1和问题2，但是随之问题又来
> 现在设计的 IP 协议解决了在不在一个子网内的问题，但是如果用 IP 协议，以太网协议必须知道目标主机的 MAC 地址才能传输，怎么获取到目前主机的 MAC 地址？

为了解决这个问题，ARP 协议被设计出来，即 IP 地址解析协议，主要作用就是通过 IP 来获取到对应的 MAC 地址。  

ARP 协议的具体工作过程：  
ARP 会首先发起一个数据包，数据包里面包含了目标主机的 IP 地址，然后发送到链路层再次包装成以太网数据包，最终由以太网广播给自己当前子网的所有主机，主机接受到这个数据包之后，取出数据包的 IP 地址，和自己的 IP 地址进行对比如果相同就返回自己的 MAC 地址，如果不同就丢弃这个数据包。ARP 接受消息来确定目标主机的 MAC 地址。如果查询到了 MAC 地址，ARP 还会将该 IP 的 MAC 地址缓存到本机保留一段时间
等下次再有请求查询，直接先从缓存里取出。这样可以节约资源，提高查询效率。

> 相反的 RARP 协议是用来解析 MAC 地址为 IP 地址的协议 

### 路由协议
我们发现 ARP 协议通过 IP 获取 MAC 地址依然是局限在子网内，那不在子网的 IP 地址，ARP 不就拿不到 MAC 地址了？这也就是我们开始提出的第三个问题还没有解决。  

为了解决这个问题，前辈们又设计出了另一种协议-路由协议，路由协议必须借助路由设备来完成，即路由器或交换机，路由器扮演着交通枢纽的角色，会根据信道的情况，选择合适的路径来转发数据包
因此，刚刚我们的那个问题得到解决，首先是通过 IP 协议来判断两个 IP 是否在同一个子网内，如果在一个子网，那就通过 ARP 协议去获取 MAC 地址，然后再通过以太网协议将数据包广播到子网内；
如果不在一个子网内，以太网会将数据包先转发到本子网的网关进行路由，网关会进行多次转发，并最终将数据包转发到目标 IP 的子网内，然后再通过 ARP 协议获取目标主机的 MAC 地址，最终再通过以太网
协议将数据包发送到目标 MAC 地址。

> 总结一下：网络层的工作主要是**定义网络地址**、**划分网段**、**查询 MAC 地址**、对不是同一网段的**数据包进行路由转发**

## 传输层
依靠传输层和链路层的工作，数据已经能够正常的从一台主机发送到另一台主机，但是，我们在一台主机中往往不可能只有一个网络程序，所以当又多个网络程序同时工作的时候，我们依然会发现有如下问题
>  如何在多个网络程序运行的主机间进行数据传输，更简单的来说，就是如何一个主机的某个应用程序发出，然后由对方主机的应用程序接收？

为了解决这个问题，聪明的前辈们又想到了解决办法，为每一个网络程序分配一个不同的数字来表示，发送数据的时候指定发送到某台主机的某个数字的网络程序不就可以了。这个数字就是端口。
端口用 2 个字节来表示，范围是 0 ～ 65535，也就是最大 65535 个端口。一般情况下是足够用了。有了端口，我们来简单介绍下传输层的两种协议。

### TCP
我们知道网络层的数据包 IP 数据包都是不保证可靠性的，也就是说将数据发送出去，并不保证数据可达，并且数据发送也不保证有序。所以，为了满足一些对数据可靠性和有序性的应用。前辈们设计了新的协议
TCP 协议。TCP 协议是保证了数据的可靠性，有序性，面向连接的传输协议。如果发现有一个数据包收不到确认，就重新发送数据包。  

有了 TCP 协议，我们的应该程序可以将数据有序的，可靠的发送到对方指定端口的网络程序中。TCP 数据包格式

```
+-----------------+--------------------+
| head(20 byte)   | data               |
+----------------=+--------------------+
```

> TCP 建立连接需要经过 3 次握手，断开连接需要经过 4 次挥手。后面章节会详细来讲解整个过程，再次不详细讨论

### UDP
> 不一定是所有的场景都必须要求数据的可靠性和有序性，有些应用程序只要求数据能快速高效的发送出去，至于可靠性并不十分关系，那这个时候 TCP 协议似乎不能满足这种需求。

其实 IP 协议的数据包就可以满足我们的新的需求，但是 IP 协议是网络层，不存在端口。而我们在传输层规定了端口，所以干脆就在传输层新设计一个协议 UDP 协议，UDP 协议其实就是在 IP 协议的基础上指定了端口（简单理解）。

UDP 是面向用户的（非连接的）传输层协议，这是因为 UDP 不像 TCP 需要 3 次握手建立连接的机制。UDP 协议相较于 TCP 来说实现比较简单，没有确认机制，数据包一旦发出，不保证数据可达和有序。不过一般情况下 UDP
的数据包也不会有那么差的可靠性，还是能保证一定的可靠性。但是相较于 TCP ，UDP 的发送效率是比较快的。UDP 数据包的格式如下

```
+-----------------+--------------------+
| head(8 byte)    | data (65527 byte)  |
+----------------=+--------------------+
```

## 应用层
有了上面介绍的三层协议的支持，我们可以满足各种情况下，将我们的数据包发送到指定的端口的网络程序中，但是，传输的数据都是字节流，程序并不能很好的识别，操作性相对比较差。因此，在应用层
规范了各种各样的协议来规范我们的数据格式，同时也使得我们程序开发更为便利。常见的应用层协议有：HTTP、FTP、SMTP 等。针对不同类型的应用程序开发，可以使用不同的协议来开发。  

每天在浏览器浏览网页，我们最熟悉的莫过于 HTTP 协议了。后面我会有专门的章节来详细讲解 HTTP 协议，这里不做过多介绍。

## 总结
有了分层的模型，每一层基于协议又有非常明确的分工，使得计算机之间的数据传输有条不紊的进行。我们来自顶向下回顾一下每一层的数据传输过程：

- 应用层：应用层将用户输入的数据规范化，并根据应用层协议（如 HTTP 协议）封装成数据消息，传输给传输层
- 传输层：传输层拿到应用层消息，根据传输层协议，将数据再次包装，并加上传输层协议头，发给网络层
- 网络层：拿到传输层数据包，根据 IP 协议，将数据再次包装，加上 IP 协议头，发送给链路层
- 链路层：链路层拿到网络层数据包，再次包装层以太网数据包，加上以太网协议头。通过网卡发送给对方主机


再来自顶向下回顾一下每一层的职责：

- 应用层：按照应用层协议解析和规范用户数据
- 传输层：定义端口，确定要发送的目标主机上的应用程序，根据协议的不同，控制数据的传输
- 网络层：定义 IP 地址；分配网络地址和主机地址；解析 MAC 地址；将不在同一子网的数据包路由转发
- 链路层：对 0 1进行分组，定义数据帧，确认对方主机 MAC 地址。通过物理媒介传输到对方主机的网卡

>本文只是对 TCP/IP 协议栈各个层工作的一个概述，具体每一层的协议，后面会有专门的章节来介绍。

##### 参考文献
- [深入浅出 TCP/IP 协议栈](https://www.cnblogs.com/onepixel/p/7092302.html)
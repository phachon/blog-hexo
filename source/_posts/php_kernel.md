---
title: PHP 内核知识点总结
date: 2017-07-23
categories: Coding
tags:
  - php
---
----------------------------------

## PHP 的基本架构

- Zend引擎：Zend 整体用纯C实现，是 PHP 的内核部分，它将 PHP 代码翻译（词法、语法解析等一系列编译过程）为可执行 opcode 的处理并实现相应的处理方法、实现了基本的数据结构（如hashtable、oo）、内存分配及管理、提供了相应的 api 方法供外部调用，是一切的核心，所有的外围功能均围绕 Zend 实现。
- Extensions：围绕着 Zend 引擎，extensions 通过组件式的方式提供各种基础服务，我们常见的各种内置函数（如 array 系列）、标准库等都是通过 extension 来实现，用户也可以根据需要实现自己的 extension 以达到功能扩展、性能优化等目的（如贴吧正在使用的 PHP 中间层、富文本解析就是 extension 的典型应用）。
- Sapi：Sapi 全称是 Server Application Programming Interface，也就是服务端应用编程接口，Sapi 通过一系列钩子函数，使得 PHP 可以和外围交互数据，这是 PHP 非常优雅和成功的一个设计，通过 sapi 成功的将PHP本身和上层应用解耦隔离，PHP 可以不再考虑如何针对不同应用进行兼容，而应用本身也可以针对自己的特点实现不同的处理方式。
    - apache2handler：这是以apache作为webserver，采用mod_PHP模式运行时候的处理方式，也是现在应用最广泛的一种。
    - cgi：这是webserver和PHP直接的另一种交互方式，也就是大名鼎鼎的fastcgi协议，在最近今年fastcgi+PHP得到越来越多的应用，也是异步webserver所唯一支持的方式。
    - cli：命令行调用的应用模式
- 上层应用：这就是我们平时编写的 PHP 程序，通过不同的 sapi 方式得到各种各样的应用模式，如通过 webserver 实现 web 应用、在命令行下以脚本方式运行等等。

## PHP 执行过程
- 第一步：启动 web 服务器，如果是 apache, apache 通过 mod_php5.so 调用 sapi 接口启动 php 解释器，如果是 nginx, nginx 调用 php-fpm(php fast-cgi进程管理器)启动 php-fpm，php 内核调用各个扩展的初始化方法，使之处于激活状态
- 第二部：当发生请求时候, SAPI 将控制权交给 php 核心层, php 设置了本次请求的变量
- 第三部：php 核心层调用 zend 引擎将 php 源代码编译成 opcode 码，并在 zend 虚拟机运行得出结果，将结果返回给 php 核心层
    - 词法分析
    - 语法分析
    - 生成 opcode 码
    - 执行 opcode 码
- 第四部：php 核心层将返回结果通过 sapi 返回给 web 服务器，web 服务器将结果渲染在浏览器

## PHP SAPI 生命周期
PHP开始执行以后会经过两个主要的阶段：

- 处理请求之前的开始阶段
  - 第一个过程是模块初始化阶段（MINIT），在整个SAPI生命周期内 (例如 Apache 启动以后的整个生命周期内或者命令行程序整个执行过程中)， 该过程只进行一次。
  - 第二个过程是模块激活阶段（RINIT），该过程发生在请求阶段，例如通过 url 请求某个页面，则在每次请求之前都会进行模块激活（RINIT请求开始）。

请求处理完后就进入了结束阶段，一般脚本执行到末尾或者通过调用 exit() 或 die() 函数， PHP 都将进入结束阶段。和开始阶段对应，结束阶段也分为两个环节。

- 请求之后的结束阶段
  - 一个在请求结束后停用模块(RSHUTDOWN，对应RINIT)
  - 一个在 SAPI 生命周期结束（Web服务器退出或者命令行脚本执行完毕退出）时关闭模块(MSHUTDOWN，对应MINIT)

例如执行 test.php

```
php -f test.php
```

![单进程 SAPI 生命周期](/images/php_life.png)

调用每个模块的初始化前，初始化过程：
- 初始化若干全局变量
- 初始化若干常量
- 初始化Zend引擎和核心组件
- 解析 php.ini
- 全局操作函数的初始化
- 初始化静态构建的模块和共享模块(MINIT)

## 多进程SAPI生命周期

通常PHP是编译为apache的一个模块来处理PHP请求。Apache一般会采用多进程模式， Apache启动后会fork出多个子进程，每个进程的内存空间独立，每个子进程都会经过开始和结束环节， 不过每个进程
的开始阶段只在进程fork出来以来后进行，在整个进程的生命周期内可能会处理多个请求。 只有在Apache关闭或者进程被结束之后才会进行关闭阶段，在这两个阶段之间会随着每个请求重复请求开始-请求关闭的
环节。

## 多线程的SAPI生命周期
多线程模式和多进程中的某个进程类似，不同的是在整个进程的生命周期内会并行的重复着 请求开始-
请求关闭的环节


## Apache 加载 PHP 模块
当PHP需要在Apache服务器下运行时，一般来说，它可以mod_php5模块的形式集成， 此时mod_php5模块的作用是接收Apache传递过来的PHP⽂件请求，并处理这些请求， 然后将处理后的结果返
回给Apache。如果我们在Apache启动前在其配置⽂件中配置好了PHP模块（mod_php5）， PHP模块通过注册apache2的ap_hook_post_config挂钩，在Apache启动的时候启动此模块以接受PHP文件的请求。

- 静态加载
```
LoadModule php5_module modules/mod_php5.so
```

- 动态加载
如果需要在服务器运行时加载模块， 可以通过发送信号HUP或者AP_SIG_GRACEFUL给服务器，一旦接受到该信号，Apache将重新装载模块， ⽽不需要重新启动服务
器。

## Apache 运行过程
Apache的运行分为启动阶段和运行阶段。

### 启动阶段
Apache为了获得系统资源最⼤的使用权限，将以特权用户root（*nix系统）或超级管理员Administrator(Windows系统)完成启动， 并且整个过程处于一
个单进程单线程的环境中。 这个阶段包括配置⽂件解析(如http.conf⽂件)、模块加载(如mod_php，mod_perl)和系统资源初始化（例如⽇志⽂件、共享内存段、数据库连接等）等⼯作。
Apache的启动阶段执行了⼤量的初始化操作，并且将许多⽐较慢或者花费⽐较⾼的操作都集中在这个阶段完成，以减少了后⾯处理请求服务的压⼒。

### 运行阶段
Apache主要⼯作是处理用户的服务请求。 在这个阶段，Apache放弃特权用户级别，使用普通权限，这主要是基于安全性的考虑，防⽌由于代码的缺陷引起的安全漏洞。 Apache对HTTP的请求
可以分为连接、处理和断开连接三个⼤的阶段。

## PHP 的几种运行方式
https://phachon.com/2016/07/29/php-run-type/

## PHP 程序的执行过程
1. 如上例中， 传递给php程序需要执行的⽂件， php程序完成基本的准备⼯作后启动PHP及Zend引
擎，加载注册的扩展模块。
2. 初始化完成后读取脚本⽂件，Zend引擎对脚本⽂件进行词法分析，语法分析。然后编译成opcode执
行。 如过安装了apc之类的opcode缓存， 编译环节可能会被跳过⽽直接从缓存中读取opcode执
行。

### 词法分析
PHP的词法分析器是通过 lex 生成的， 词法规则⽂件在$PHP_SRC/Zend/zend_language_scanner.l， 这一阶段lex会会将源代码按照词法规则切分一个一个
的标记(token)。PHP中提供了一个函数 token_get_all()， 该函数接收一个字符串参数， 返回一个按照词法
规则切分好的数组。


## PHP 变量类型及存储结构
变量的值存储到以下所⽰ zval 结构体中。变量的 key 和指向 zval 的指针存储在符号表里。 zval 结构体定义在Zend/zend.h⽂件，其结构如下：

```
typedef struct _zval_struct zval;

struct _zval_struct {
    /* Variable information */
    zvalue_value value; /* value */
    zend_uint refcount__gc;
    zend_uchar type; /* active type */
    zend_uchar is_ref__gc;
};
```


变量的值存储在 zvalue_value 联合体中
```
typedef union _zvalue_value {
    long lval; /* long value */
    double dval; /* double value */
    struct {
        char *val;
        int len;
    } str;
    HashTable *ht; /* hash table value */
    zend_object_value obj;
} zvalue_value;
```

使用联合体⽽不是用结构体是出于空间利用率的考虑，因为一个变量同时只能属于一种类型。 如果使用结构体的话将会不必要的浪费空间，⽽PHP中的所有逻辑都围绕变量来进行的，这样的话， 内存浪费将是⼗分⼤的。这种做法成本⼩但收益⾮常⼤。

## PHP 哈希表实现

PHP内核中的哈希表是⼗分重要的数据结构，PHP的⼤部分的语⾔特性都是基于哈希表实现的，例如：变量的作用域、函数表、类的属性、⽅法等，Zend引擎内部的很多数据都是保存在哈希表中的。

PHP中的哈希表是使用拉链法来解决冲突的，具体点讲就是使用链表来存储哈希到同一个槽位的数据， Zend为了保存数据之间的关系使用了双向列表来链接元素。

PHP 哈希表实现中的数据结构，PHP使用两个数据结构来实现哈希表，HashTable结构体用于保存整个哈希表需要的基本信息，⽽ Bucket 结构体用于保存具体的数据内容

- HashTable 结构

```
typedef struct _hashtable {
     uint nTableSize; //表长度，并非元素个数
     uint nTableMask;//表的掩码，始终等于nTableSize-1
     uint nNumOfElements;//存储的元素个数
     ulong nNextFreeElement;//指向下一个空的元素位置
     Bucket *pInternalPointer;//foreach循环时，用来记录当前遍历到的元素位置
     Bucket *pListHead;
     Bucket *pListTail;
     Bucket **arBuckets;//存储的元素数组
     dtor_func_t pDestructor;//析构函数
     zend_bool persistent;//是否持久保存。从这可以发现，PHP数组是可以实现持久保存在内存中的，而无需每次请求都重新加载。
     unsigned char nApplyCount;
     zend_bool bApplyProtection;
} HashTable;
```

- Bucket 结构

```
typedef struct bucket {
     ulong h; //数组索引
     uint nKeyLength; //字符串索引的长度
     void *pData; //实际数据的存储地址
     void *pDataPtr; //引入的数据存储地址
     struct bucket *pListNext;
     struct bucket *pListLast;
     struct bucket *pNext; //双向链表的下一个元素的地址
     struct bucket *pLast;//双向链表的下一个元素地址
     char arKey[1]; /* Must be last element */
} Bucket;
```
PHP中初始化一个空数组或不足8个元素的数组，都会被创建8个长度的 HashTable。同样创建100个元素的数组，也会被分配128长度的HashTable。依次类推。

### PHP 哈希算法
PHP内核哈希表的散列函数很简单，直接使用 （HashTable->nTableSize & HashTable->nTableMask）的结果作为散列函数的实现。这样做的目的可能也是为了降低Hash算法的复杂度和提高性能。

### PHP 对字符串索引处理方式
与数字索引相比，只是多了一步将字符串转换为整型。用到的算法是time33，就是对字符串的每个字符转换为ASCII码乘上33并且相加得到的结果。


## PHP7 中 HashTable 优化

[blog](https://blog.csdn.net/xiaolei1982/article/details/52292866#t0)

## PHP7 变量存储的优化

## 内存管理机制
PHP的内存管理可以被看作是分层（hierarchical）的。 它分为三层：存储层（storage）、堆层（heap）和接⼝层（emalloc/efree）。 存储层通过 malloc()、mmap() 等函数向系统真正的申请内存，并通过 free() 函数释放所申请的内存。 存储层通常申请的内存块都⽐较⼤，这⾥申请的内存⼤并不是指
storage层结构所需要的内存⼤， 只是堆层通过调用存储层的分配⽅法时，其以⼤块⼤块的⽅式申请的内存，存储层的作用是将内存分配的⽅式对堆层透明化。

初始化内存管理顺序：

- 初始化 storage 层的分配方案
- 初始化 heap 堆层

PHP中的内存管理主要⼯作就是维护三个列表：⼩块内存列表（free_buckets）、 ⼤块内存列表（large_free_buckets）和剩余内存列表（rest_buckets）
从内存分配的过程中可以看出，内存块查找判断顺序依次是⼩块内存列表，⼤块内存列表，剩余内存列表。
ZendMM向系统进行的内存申请，并不是有需要时向系统即时申请， ⽽是由ZendMM的最底层（heap层）先向系统申请一⼤块的内存，通过对上⾯三种列表的填充， 建立一个类似于内存池的管理机制。 在程序运行需要使用
内存的时候，ZendMM会在内存池中分配相应的内存供使用。 这样做的好处是避免了PHP向系统频繁的内存申请操作


## 垃圾回收
引用计数、引用计数的问题。如何解决。







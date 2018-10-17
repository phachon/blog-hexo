---
title: PHPUnit windows 下的安装
date: 2017-10-20
categories: PHPUnit
tags:
  - PHPUnit
  - Windows
  - PHP
---
----------------------------------

> 本篇文章介绍一下 PHPUnit 在 windows 下的安装和配置

# 准备
- php 版本 php5.4.45
- phpunit 版本 phpunit4.8.24
- 操作系统：windows 7 (32)
- php 安装（这里不再详细讲解）
- phpunit 下载地址：https://phpunit.de/ 下载到文件 phpunit-4.8.24.phar

<!-- more -->

# 安装

1. 将下载的 phpunit-4.8.24.phar 文件保存保存为phar到你自己设定的目录，如我的目录是D：\server\phpunit 下。
2. 配置 path 环境变量；计算机右击属性—>高级系统设置—>环境变量–> 在系统变量下找到 path 一栏，选中，编辑。添加 phpunit 路径;D:\server\phpunit  到最后。注意 ; 不要忘记。
3. 按快捷键Win + R ，输入cmd并回车。打开 cmd 命令窗口，进入phpunit 的文件目录。D：\server\phpunit 
4. 输入 echo @php “%~dp0phpunit.phar” %* > phpunit.cmd

接着输入phpunit –version 并回车显示如下

```
PHPUnit 4.8.24 by Sebastian Bergmann and contributors
```

表示安装成功。（如果有误，输入exit 并回车，重新来一遍）

注意：如果失败，请检查你的 php  path 变量是否配置

# 基本命令

- –log-tap   生成TAP格式的日志文件
- –log-dbus  使用DBUS记录测试的执行情况
- –log-json  生成JSON格式的日志文件
- –coverage-html 生成html格式的代码覆盖报告
请注意这个功能只能在tokenizer和Xdebug安装后才能使用
- –coverage-clover 生成xml格式的代码覆盖报告
请注意这个功能只能在tokenizer和Xdebug安装后才能使用
- –testdox-html and –testdox-text  生成记录已运行测试的html或者纯文本格式的文件文档
- –filter 只运行名字符合参数规定的格式的测试，参数可以是一个测试的名字或者一个匹配多个测试名字的正则表达式
- –group  只运行规定的测试组，一个测试可以使用@group注释来分组    @author注视是一个和@group关联的注释标签，用来根据作者来过滤测试
- –exclude-group 只包含规定的多个测试组，一个测试可以使用@group注释来分组
- –list-groups    列出可用的测试组
- –loader 定义使用PHPUnit_Runner_TestSuiteLoader的接口
- –repeat    根据定义的数字重复运行测试
- –tap 使用Test Anything Protocol格式报告测试进程
- –testdox    使用agile documentation格式报告测试进程
- –colors     在输出结果中使用颜色
- –stderr    使用STDERR替代STDOUT输出结果
- –stop-on-error    在遇到第一个错误时停止执行
- –stop-on-failure    在遇到第一个失败时停止执行
- –stop-on-skipped       在遇到第一个跳过的测试时停止执行
- –stop-on-incomplete       在遇到第一个未完成的测试时停止执行
- –strict    当一个测试没有定义任何断言时将其标记为未完成的测试
- –verbose    输出例如未完成的测试的名字，跳过的测试的名字
- –wait    在每个测试开始之前等待用户按键，这个在你一个保持打开的窗口中运行很长的测试时很有帮助
- –skeleton-class    从一个测试类中生成一个概要测试类
- –skeleton-test    在Unit.php内为类Unit生成一个概要测试类UnitTest
- –process-isolation      在多个php进程中运行所有测试
- –no-globals-backup   不备份和还原$GLOBALS变量
- –static-backup    备份和还原用户定义的类中的静态变量
- –syntax-check    对测试的代码文件开启语法检查
- –bootstrap    定义测试前运行的bootstrap的php文件的路径
- –configuration, -c    从xml文件中读取配置，增加-c参数看更多的内容
如果phpunit.xml或phpunit.xml.dist(根据这个模式)在当前的目录中存在且–configuration参数没有使用的时候，配置信息会被自动读取
- –no-configuration    自动跳过当前目录的phpunit.xml和phpunit.xml.dist配置文件
- –include-path    在php的include_path增加路径
- -d    定义php的配置属性
- –debug    输出调试信息如测试的名称及该测试什么时候开始执行

提示当测试代码中含有php语法错误的时候，测试器会退出且不会打印任何错误信息，standard test suite loader可选择性检查测试文件源代码的PHP语法错误，但是不会检查测试文件中引入的其他的代码文件的语法错误
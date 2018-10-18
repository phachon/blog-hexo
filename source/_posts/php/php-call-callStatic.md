---
title: PHP 魔术方法
date: 2016-07-28
categories: PHP
tags:
  - PHP
---
----------------------------------

## __call 方法的使用

定义：在对象中调用一个不可访问方法时，__call() 会被调用。

<!-- more -->

示例：

```
<?php
/**
 * __call 测试 
 * @author phachon@163.com
 */
class Test {

	public function __construct() {
	}

	public function show() {
		echo "show 一下\n";
	}
	
	public function __call($method, $arguments) {
		echo "不可访问的方法都来我这里了\n";
	}
}

$test = new Test(); 
$test->show();//输出: show 一下
$test->close(); //输出: 不可访问的方法都来我这里来了
```

上面例子中调用 close 方法时不存在，所以被 __call 接收了。

但是如果调用类里面的方法是 protected 或者是 private 的时候，是否可以被 __call 接收呢？

```
<?php
/**
 * __call 测试 
 * @author phachon@163.com
 */
class Test {

	public function __construct() {
		echo "我是构造方法\n";
	}

	public function show() {
		echo "show 一下\n";
	}

	public function __call($method, $arguments) {
		echo "不可访问的方法都来我这里了\n";
	}

	protected function _sing() {
		echo "我是唱歌的";
	}

	private function _run() {
		echo "我是跑步的";
	}
}

$test = new Test();
$test->show(); //输出：show 一下
$test->_sing(); //输出：不可访问的方法都来我这里了
$test->_run();  //输出：不可访问的方法都来我这里了
$test->close(); //输出：不可访问的方法都来我这里了
```

事实证明除了没有定义的方法以及 private 和 protected 方法都会被魔术方法 __call 接收，所以定义为调用一个不可访问的方法时才被调用是十分准确的。（之前听有些人说是当访问一个未被定义的方法时被调用这是不准确的）

注意：__call 在使用时必须声明为 public 并且，方法必须有带两个参数，一个是 被调用的方法名，一个是方法携带的参数。

## __callStatic 方法的使用

定义：用静态方式中调用一个不可访问方法时，__callStatic() 会被调用。
示例：

```
<?php
/**
 * __callStatic 测试 
 * @author phachon@163.com
 */
class Test {

	public function __construct() {
		
	}

	public static function show() {
		echo "show 一下\n";
	}

	public static function __callStatic($className, $arguments) {
		echo "不可访问的静态方法来这里吧";
	}
}

Test::show(); //输出：show 一下
Test::close(); //输出：不可访问的静态方法来这里吧
```

同样对于没有定义的方法以及 private 和 protected 的静态方法，都会被__callStatic 接收。
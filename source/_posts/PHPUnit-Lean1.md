---
title: PHPUnit 学习实例代码
date: 2017-10-20
categories: Coding
tags:
  - PHP
  - PHPUnit
---
----------------------------------

> PHPUnit 基本用法+实例详解
上一篇文章介绍了 PHPUnit 在 windows  的安装和配置。今天我们来介绍一下 PHPUnit 如何编写一些基本的测试用例。我也是在最近才开始慢慢使用的 PHPUnit , 用不足之处，欢迎指正。

# 编写规范

1. 测试类一般以***Test 命名；
2. 该类必须继承 PHPUnit_Framework_TestCase 类；
3. 类里的测试用例方法一般以test开头，当然也可以通过@test注释来定义一个名字不为test开头的方法为测试方法；
4. 测试方法中需要使用断言方法来断言实际传入的参数与期望的参数是否一致来达到测试的目的；

<!-- more -->

# 测试用例

1. 基本的demo

定义一个类 DemoTest 并保存到 DemoTest.php 文件中

```php
<?php
/**
 * phpunit test demo
 * @author phachon@163.com
 */
class DemoTest extends PHPUnit_Framework_TestCase {

    /**
     * test
     */
    public function testPushAndPop() {
        $stack = array ();
        //断言 $stack 的长度为0
        $this->assertEquals(0, count($stack));
        array_push($stack, 'foo');

        //断言 $stack 的长度为 1
        $this->assertEquals(1, count($stack));
        //断言 $stack 的最后一个值为foo
        $this->assertEquals('foo', $stack[count($stack)-1]);
        //断言 $stack 出栈的值为 foo
        $this->assertEquals('foo', array_pop($stack));
        //断言 $stack 的长度为 0
        $this->assertEquals(0, count($stack));
    }

    /**
     * 定义test标签来声明是测试方法
     * @test
     */
    public function indexEquals() {
        $stack = array (0,1,2,3,4);
        //断言 $stack 索引 0 的值为2
        $this->assertEquals(2, $stack[0]);
    }
}
```

上面的代码中定义了两种测试用例的方法，一种是开头为test, 一种是定义@test标签；两种都可以。
然后运行测试这个类；打开命令窗口，进入该代码保存的文件目录输入:phpunit DemoTest.php
运行结果为：

```
Time:825 ms, Memory: 8.25Mb
There was 1 failure:
1) DemoTest::indexEquals
Failed asserting that 0 matches expected 2.
D:\server\apache\htdocs\my_php_code\phpunit\stack\DemoTest.php:32
FAILURES!
Tests: 2, Assertions: 6, Failures: 1.
```

解释一下：最上面的是一些耗时，内存消耗的多少。往下看测试结果说有一个错误，也就是测试未通过，在文件的32行。32行的意思是断言这个数组中索引为0的值为2，显然不是，这里我故意写错，所以测试失败。如果改为0则会显示OK;最后是显示2个测试用例，6个断言，其中一个失败。
 
2. 方法依赖关系

在测试类中，测试用例方法可以有依赖关系。通过依赖关系可以传一些参数到方法中；因为默认的测试用例方法是不能有参数的。
定义一个FunTest 类保存到文件中

```php
<?php
/**
 * 测试方法依赖关系
 * @author phachon@163.com
 */
class FuncTest extends PHPUnit_Framework_TestCase {

	public function testEmpty() {
		$stack = array ();
		$this->assertEmpty($stack);
		return $stack;
	}

	/**
	 * depends 方法用来表示依赖的方法名
	 * @depends testEmpty
	 * @param array $stack
	 * @return array
	 */
	public function testPush(array $stack) {
		array_push($stack, 'foo');
		$this->assertEquals('foo', $stack[count($stack)-1]);

		return $stack;
	}

	/**
	 * @depends testPush
	 * @param array $stack
	 */
	public function testPop(array $stack) {
		$this->assertEquals('foo', array_pop($stack));
		$this->assertEmpty($stack);
	}
}
```

标签@depends是表示依赖关系，上面的代码中testPop()依赖testPush(),testPush()依赖testEmpty(), 所以当testEmpty()测试通过后返回的变量可以作为testPush(array $stack)的参数。同理，testPop()也是一样。
运行结果如下：

```
Time: 726 ms, Memory: 8.25Mb
OK (3 tests, 4 assertions)
```
测试通过

3. 测试非依赖关系的方法传入参数

如果非依赖关系的方法，默认是不能有参数的，这个时候怎么样才能传参，PHPUnit 提供给了一个标签，@dataProvider
定义一个DataTest类保存到文件中

```php
<?php
/**
 * 测试非依赖关系的方法传入参数
 * 方法提供者
 * @author phachon@163.com
 */
class DataTest extends PHPUnit_Framework_TestCase {

	/**
	 * dataProvider 标签用来提供数据的方法名
	 * @dataProvider add_provider
	 */
	public function testAdd($a, $b, $c) {
		//断言 a + b = c
		$this->assertEquals($c, $a + $b);
	}

	/**
	 * 数据提供者的方法
	 * 格式：
	 * return array(
	 *      array(参数1,参数2,参数3,参数4,参数N),
	 *      array(参数1,参数2,参数3,参数4,参数N),
	 * );
	 */
	public function add_provider() {
		return array (
			array (0, 0, 0),
			array (0, 1, 1),
			array (1, 0, 1),
			array (1, 1, 2),
		);
	}
}
```

看上面代码应该就能明白。直接运行phpunit DataTest.php
运行结果如下：

```
Time: 379 ms, Memory: 8.25Mb
OK (3 tests, 4 assertions)
```

4. 数据提供者方法和依赖关系的限制

这个听起来有点绕口，意思是如果方法依赖和方法提供者同时使用的话，是有限制的。说半天我估计还是一塌糊涂，不解释，直接看代码
定义一个 Data2Test 类保存到文件

```php
<?php
/**
 * 数据提供者方法和依赖关系的限制
 *
 * 当一个测试方法依赖于另外一个使用data providers测试方法时,
 * 这个测试方法将会在它依赖的方法至少测试成功一次后运行,
 * 同时使用data providers的测试方法的执行的结果不能传入一个依赖它的测试方法中
 * @author phachon@163.com
 */
class Data2Test extends PHPUnit_Framework_TestCase {

	public function testA() {
		return 78;
	}

	/**
	 * @dataProvider add_provider
	 * @depends testB
	 */
	public function testB($a, $b, $c) {
		$this->assertEquals($c, $a + $b);
		return $a;
	}

	/**
	 * @depneds testB
	 */
	public function testC($a) {
		var_dump($a);
	}

	public function add_provider() {

		return array (
			array (0, 0, 0),
			array (0, 1, 1),
			array (1, 0, 1),
			array (1, 1, 2),
		);
	}
}
```

解释一下：
testB 依赖于 testA (testA 使用了dataProvider 提供数据)
如果 add_provider 提供的数据至少有一次是成功的，则在成功一次后运行 testC
如果 add_provider 提供的数据没有一次是成功的，则 testC 一次也不会执行
但是 testC 执行的结果永远是 null, 因为 $a 是通过 dataProvider 提供的。不能传入依赖它的测试方法中
好像还是不太明白，反正我是尽力了。慢慢理解吧。

5. 通过构造迭代器来为方法提供数据

通过标签 @dataProvider 来直接返回数据作为数据提供者，PHPUnit 也可以通过返回构造器对象来提供数据。上代码
新建 IteratorTest.php 文件 

```php
<?php
/**
 * 通过构造迭代器来为方法提供数据
 * @author phachon@163.com
 */
class myIterator implements Iterator {

	private $_position = 0;
	
	private $_array = array (
		array (0, 0, 0),
		array (0, 1, 1),
		array (1, 0, 1),
		array (1, 1, 2)
	);

	public function current() {
		echo 0;
		return $this->_array[$this->_position];
	}

	public function key() {
		echo 1;
		return $this->_position;
	}

	public function next() {
		echo 2;
		++$this->_position;
	}

	public function valid() {
		echo 3;
		return isset($this->_array[$this->_position]);
	}

	public function rewind() {
		echo 4;
		return $this->_position = 0;
	}
}
```

```php
/**
 * 测试类
 */
class IteratorTest extends PHPUnit_Framework_TestCase {

	/**
	 * @dataProvider add_provider
	 */
	public function testAdd($a, $b, $c) {

		$this->assertEquals($c, $a + $b);
	}

	public function add_provider() {

		return new myIterator();
	}
}
```

先定义了一个构造器，然后返回这个构造器对象，同样也能提供数据。运行 phpunit IteratorTest.php
运行结果如下：

```
Time: 408 ms, Memory: 8.25Mb
OK (4 tests, 4 assertions)
```

6. 异常测试

有时候我们希望能够抛出我们所期待的异常。这里有三种方法来测试异常，上代码
定义 ThrowTest 类保存到文件

```php
<?php
/**
 * 测试异常
 * 三种方法
 * @author phachon@163.com
 */
class ThrowTest extends PHPUnit_Framework_TestCase {

	/**
	 * 1.注释法: expectedException 期待的异常
	 * @expectedExeption My_Exception
	 */
	public function testException1() {

	}

	/**
	 * 2.设定法：$this->setExpectedException 期待的异常
	 */
	public function testException2() {
		$this->setExpectedException('My_Exception');
	}

	/**
	 * 3.捕获法：try catch
	 */
	public function testException3() {
		try {
			//代码
		} catch (My_Exception $e) {
			//捕获到异常测试通过，否则失败
			return ;
		}
		$this->fail('一个期望的异常没有被捕获');
	}
}
```

代码应该很明白了，不用解释了。

7. 错误测试

有时候代码会发生错误，比如某个php文件找不到，文件不可读，php 文件加载失败等。这个时候我们也能进行测试，是否发生错误；PHPUnit 会把错误直接转化为异常PHPUnit_Framework_Error并抛出；我们要做到的是捕获这个异常。上代码。
定义 ErrorTest 类保存到文件中

```php
<?php
/**
 * 错误测试
 * phpunit 会把错误直接转化为异常PHPUnit_Framework_Error并抛出
 */
class ErrorTest extends PHPUnit_Framework_TestCase {

	/**
	 * 期待捕获 PHPUnit_Framework_Error 的异常
	 * @expectedException PHPUnit_Framework_Error
	 */
	public function testError() {
		//如果文件不存在就会抛出异常，我们需要捕获异常
		include '../test.php';
	}
}
```

测试显示OK,则证明已经捕获。

8. 对输出进行测试

有时候我们需要对程序的指定输出进行测试。比如echo 还是 print() 指定的值是否正确。
定义类 OutputTest 类保存到文件

```php
<?php
/**
 * 输出测试
 * @author phachon@163.com
 */
class OutputTest extends PHPUnit_Framework_TestCase {

	public function testExpectFooActualFoo() {
		$this->expectOutputString('foo');
		print 'foo';
	}

	public function testExpectBarActualBaz() {
		$this->expectOutputString('bar');
		print 'baz';
	}
}
```

注意: 在严格模式下，本身产生输出的测试将会失败。

9. 基镜（fixture）

PHPUnit 支持共享建立基境的代码。在运行某个测试方法前，会调用一个名叫 setUp() 的模板方法。setUp() 是创建测试所用对象的地方。当测试方法运行结束后，不管是成功还是失败，都会调用另外一个名叫 tearDown() 的模板方法。tearDown() 是清理测试所用对象的地方。

```php
<?php
class FixTureTest extends PHPUnit_Framework_TestCase {

	protected $stack;

	protected function setUp() {
		$this->stack = array();
	}

	public function testEmpty() {
		$this->assertTrue(empty($this->stack));
	}

	public function testPush() {
		array_push($this->stack, 'foo');
		$this->assertEquals('foo', $this->stack[count($this->stack)-1]);
		$this->assertFalse(empty($this->stack));
	}

	public function testPop() {
		array_push($this->stack, 'foo');
		$this->assertEquals('foo', array_pop($this->stack));
		$this->assertTrue(empty($this->stack));
	}
}
```

以上是PHPUnit 官方的一个代码示例。
测试类的每个测试方法都会运行一次 setUp() 和 tearDown() 模板方法（同时，每个测试方法都是在一个全新的测试类实例上运行的）。
另外，setUpBeforeClass() 与 tearDownAfterClass() 模板方法将分别在测试用例类的第一个测试运行之前和测试用例类的最后一个测试运行之后调用。

setUp() 多 tearDown() 少
理论上说，setUp() 和 tearDown() 是精确对称的，但是实践中并非如此。实际上，只有在 setUp() 中分配了诸如文件或套接字之类的外部资源时才需要实现 tearDown() 。如果 setUp() 中只创建纯 PHP 对象，通常可以略过 tearDown()。不过，如果在 setUp() 中创建了大量对象，你可能想要在 tearDown() 中 unset() 指向这些对象的变量，这样它们就可以被垃圾回收机制回收掉。对测试用例对象的垃圾回收动作则是不可预知的。 —PHPUnit 官方网站

# 总结

好了，今天大概就先介绍这些，已经可以大概写一些测试用例了。当然还有更高级的测试使用方法。现在为什么不讲呢，因为我也不会。。
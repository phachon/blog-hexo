---
title: Go 语言操作 mysql 建表问题的解决办法
date: 2018-02-05
categories: Go
tags:
  - Go
  - Mysql
---
----------------------------------

## 问题
开发中需要利用 go 读取 sql 文件自动创建表。

table.sql 文件内容如下
```
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(30) NOT NULL COMMENT '姓名',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';
```

<!-- more -->
go 代码如下：
```
func createTable() (err error) {
	host := "127.0.0.1"
	port := "3306"
	user := "root"
	pass := "admin"
	name := "test"
	sqlBytes, err = ioutil.ReadFile("docs/databases/table.sql");
	if err != nil {
		return
	}
	sqlTable := string(sqlBytes);
	fmt.Println(sqlTable)
	db, err := sql.Open("mysql", user+":"+pass+"@tcp("+host+":"+port+")/"+name+"?charset=utf8")
	if err != nil {
		return
	}
	defer db.Close()
	_, err = db.Exec(sqlTable)
	if err != nil {
		return
	}
	return nil
}
```
执行，出错：
```
Error 1064: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right 
syntax to use near 'CREATE TABLE `user` (`user_id` int(11) NOT NULL AUTO_INCREMENT COMMEN' at line 1
```
刚开始是以为 sql 语句本身有问题，所以将 sql 语句直接粘贴到 mysql 命令行执行，成功。所以不是 sql 语句的问题。

查找资料才知道原因是 mysql 默认是不能在一个语句中同时执行两条 sql 语句，把 drop table 和 create table 拆开。

## 解决办法

1. 将 多条 sql 语句拆开，每个语句单独执行 db.Exec()
2. 查看 go-sql-driver 的文档，发现可以支持一条语句多条 sql 执行。修改代码如下
```
db, err := sql.Open("mysql", user+":"+pass+"@tcp("+host+":"+port+")/"+name+"?charset=utf8&multiStatements=true")
```
增加了 &multiStatements=true 参数


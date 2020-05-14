---
title: Go switch 踩坑记录 
date: 2019-06-28
banner: /images/go_logo.jpg
thumbnail: /images/go_logo.jpg
categories: Go
tags:
  - go
---
----------------------------------

在一次工作中使用 switch 才发现和其他的语言的 switch 有些不一样，避免再次踩坑，在这里总结一下。

<!-- more -->

示例代码

```
// 获取考试成绩
func GetGrade(score string) (grade string) {
	switch score {
	case "A":
		fmt.Println("优秀")
	case "B":
		fmt.Println("良好")
		break
	case "C":
		fmt.Println("及格")
	case "D":
		fmt.Println("不及格")
	default:
		fmt.Println("没考试")
	}
	return grade
}
```
调用例子
```
GetGrade("A") // 输出 “优秀”
GetGrade("B") // 输出 “良好”
```

>> 结论：和其他语言的 break 不一样，go 里面只要 case 是 true，会在末尾自动加 break, 不会走其他的 case , 所以，break 的意义不是很大。


如果想要走下面的 case 怎么办？





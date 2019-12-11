# 利用 goto 实现程序中常用的 continue 和 break 命令, 其实非常简单
1. continue: 在 for 循环的最后一行写上一个标签，跳转到这位置即可
2. break: 在 for 循环的外面的下一句写上一个标签，跳转到这位置即可

- Sample: (伪代码)

```bat 
for /F ["options"] %variable IN (command) DO (

... do command ...

if ... goto continue

if ... goto break

... do command ...

:continue

)

:break
```
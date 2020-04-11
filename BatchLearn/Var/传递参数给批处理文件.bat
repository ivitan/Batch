@ECHO OFF

REM %[1-9]表示参数，参数是指在运行批处理文件时在文件名后加的以空格(或者Tab)分隔的字符串。

REM 变量可以从%0到%9，%0表示批处理命令本身，其它参数字符串用 %1 到 %9 顺序表示。

:: "haha" (执行同目录下的“test2.bat”文件，并输入两个参数)
call test2.bat "hello" 

:: 在“test2.bat”文件里写:

echo %1 : (打印: "hello")

echo %2 : (打印: "haha")

echo %0 : (打印: test2.bat)

echo %19 : (打印: "hello"9)

PAUSE
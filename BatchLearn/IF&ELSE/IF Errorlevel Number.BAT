@echo off
TITLE if errorlevel number
ECHO 语法: if [not] errorlevel <数字> 待执行的命令

XCOPY F:\test.bat D:\
IF ERRORLEVEL 1 (ECHO 文件拷贝失败
) Else IF ERRORLEVEL 0 ECHO 成功拷贝文件


REM 很多DOS程序在运行结束后会返回一个数字值用来表示程序运行的结果(或者状态)，称为错误码errorlevel或称返回码。
REM 常见的返回码为0、1。通过if errorlevel命令可以判断程序的返回值，根据不同的返回值来决定执行不同的命令。
pause
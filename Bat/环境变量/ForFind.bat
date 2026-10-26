@echo off
title 批处理 for 命令 查找 一个系统path环境变量
setlocal enabledelayedexpansion 
set remain=%path%
echo %remain%
echo.
::待查找字符串
set toFind=D:\dev\workspace\MarkdownTools
:loop
for /f "tokens=1* delims=;" %%a in ("%remain%") do (
	if "%toFind%"=="%%a" (echo 找到:%%a)
	rem 将截取剩下的部分赋给变量remain，其实这里可以使用延迟变量开关
	set remain=%%b
)
::如果还有剩余,则继续分割
if defined remain goto :loop

pause

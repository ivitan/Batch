@echo off
title 批处理 for 命令 遍历 系统path环境变量
setlocal enabledelayedexpansion 
set remain=%path%
:loop
for /f "tokens=1* delims=;" %%a in ("%remain%") do (
	echo %%a
	::剩下的赋值给原来的副本,以备下次分段
	set remain=%%b
)
::如果还有剩余,则继续分割
if defined remain goto :loop
pause

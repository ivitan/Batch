@echo off
TITLE 查看系统盘
set DRIVE=%systemdrive%
echo 系统盘是：%DRIVE%

wmic LogicalDisk where "Caption='D:'" get Size /value
pause
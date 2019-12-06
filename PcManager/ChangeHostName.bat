@echo off
Color 0A
echo.
echo.～～～～～～～～以下显示当前机器所有的用户名～～～～～～～
echo.
net user
echo.
set /p user=请输入要更改的用户名：
set /p newuser=请输入新的名称 ：
wmic useraccount where name='%user%' call Rename %newuser%
echo.
echo.
echo 更改完成  !!!!!    2秒后 退出
ping 127.0.0.1 -n 1 -w 2000 >nul 
cls
pause
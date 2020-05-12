@ECHO off
Color 0A
mode con cols=50 lines=30
title 添加管理员账户
REM 添加管理员账户

REM 添加用户 tmp、密码123
net user tmp 123 /add

REM 设置 tmp 为管理员
net localgroup administrators tmp /add

pause
exit

REM 删除用户tmp
net user tmp /del
@ECHO off
Color 0A
mode con cols=50 lines=30
title 添加本地账户

ECHO.
ECHO.
ECHO.
set /p UserName= [请输入账号名] # 
set /p UserPass= [请输入账号密码] # 
net user %UserName% %UserPass% /add

ECHO 提升为管理员
net localgroup administrators %UserName% /add

pause
exit
REM 删除用户
::net user tmp /del
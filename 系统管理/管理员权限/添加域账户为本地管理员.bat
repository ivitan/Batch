@ECHO off
Color 0A
mode con cols=50 lines=30
title 添加域账户为管理员

echo.
echo +++++++++++++
echo 请在加域后使用
echo +++++++++++++
echo.
set /p UserName= [请输入域账号] # 
net localgroup administrators grgbanking\%UserName% /add
pause
exit
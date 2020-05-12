@ECHO off
Color 0A
mode con cols=50 lines=30
title 添加域账户为管理员

echo.
echo 请加域后使用
echo.
set /p UserName = [请输入域账号] # 

net localgroup administrators domain\%UserName% /add

pause
exit
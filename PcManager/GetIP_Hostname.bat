@echo off
TITLE 获取本机的IP地址(局域网)
Color 0A

for /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set localip=%%i
echo 本机IP：%localip%

for /f "tokens=2 delims=:" %%b in ('ipconfig^|find /i "IPv4"') do set ADRESS=%%b
echo 本机IP：%ADRESS%

set HOSTNAME=%computername%
echo %HOSTNAME%
pause
@echo off
TITLE　获取本机IP(局域网)及MAC地址
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set localip=%%i
echo 本机IP：%localip%

for /f "skip=14 tokens=1,2* delims=:" %%a in ('ipconfig /all') do set "b=%%b"& goto a
:a
echo 本机MAC：%b%
pause
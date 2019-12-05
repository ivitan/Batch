@echo off
TITLE 获取本机的IP地址(局域网)
Color 0A
for /f "tokens=2 delims=:" %%b in ('ipconfig^|find /i "ip"') do set ADRESS=%%b
echo %ADRESS%

set HOSTNAME=%computername%
echo %HOSTNAME%
pause
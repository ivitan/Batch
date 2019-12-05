::==================批处理获取本机IP(局域网)及MAC地址==============
@echo off
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do set localip=%%i
for /f "tokens=1,3 delims=," %%a in ('getmac /fo csv /v') do (
if %%a == "本地连接" set localmac=%%~b
)
echo 本地连接的IP为%localip%
echo 本地连接的MAC为%localmac%
pause
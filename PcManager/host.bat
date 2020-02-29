@echo off
mode con cols=50 lines=20&color 0a 
TITLE 添加 A 记录到 host

REM 取消host的只读属性
attrib -R C:\WINDOWS\system32\drivers\etc\hosts 

set /p IP=请输入IP:
set /p DOMAIN=请输入域名:
REM 换行
@echo:
@echo %IP%     %DOMAIN% >>C:\WINDOWS\system32\drivers\etc\hosts 

REM 刷新DNS
ipconfig /flushdns 
echo 添加完毕
PAUSE
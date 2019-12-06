@echo off
TITLE　获取未卸载机IP、MAC地址、主机名

SET HOSTNAME=%computername%
SET Auto="D:\tools\AutoCAD 2007"
SET JT="D:\tools\JT"
SET PTC="D:\tools\PTC"
SET DWF="C:\Program Files (x86)\Autodesk\Autodesk DWF Viewer"

IF EXIST %PTC% (
ECHO PTC >> %HOSTNAME%.txt
FOR /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set localip=%%i
FOR /f "tokens=2 delims=:" %%a in ('ipconfig /all^|find "物理地址"') do ( set mac=%%a )
ECHO %HOSTNAME%，本机IP：%localip%，本机MAC：%mac% >> %HOSTNAME%.txt
)

IF EXIST %DWF% (
ECHO DWF >> %HOSTNAME%.txt
FOR /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set localip=%%i
FOR /f "tokens=2 delims=:" %%a in ('ipconfig /all^|find "物理地址"') do ( set mac=%%a )
ECHO %HOSTNAME%，本机IP：%localip%，本机MAC：%mac% >> %HOSTNAME%.txt
)

IF EXIST %Auto% (
ECHO AutoCAD >> %HOSTNAME%.txt
FOR /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set localip=%%i
FOR /f "tokens=2 delims=:" %%a in ('ipconfig /all^|find "物理地址"') do ( set mac=%%a )
ECHO %HOSTNAME%，本机IP：%localip%，本机MAC：%mac% >> %HOSTNAME%.txt
)
@ECHO off
Color 0A
mode con cols=50 lines=30
title 更改计算机名并加域
:A
cls
ECHO.
ECHO 输入 [0] 退出程序
ECHO.

CD /D %~dp0
CALL .\CopyNetdomToSystem.exe /S

set /p pc=       [请输入计算机名] #
If "%pc%"=="" goto A
If "%pc%"=="0" exit
set COMPUTERNAME=%pc%
:: PC name
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v Hostname /t reg_sz /d "%COMPUTERNAME%" /f

ECHO =====添加办公网域=====
netdom join %COMPUTERNAME% /DOMAIN:grgit.com /UserD:adddomain /PasswordD:grg8033
 
set/p=  ■<nul
for /L %%i in (1,1,38) do set /p a=■<nul&ping /n 1 127.0.0.1>nul
ECHO   100%%

ECHO 配置完成
:end
exit
@Echo off
Color 0A
title 更改计算机名
:A
cls
echo.
echo [0]退出
echo.
echo 不用重启电脑就生效
echo 必须以管理员身份运行 
echo.
echo.

set /p PCName=请输入计算机名：
If "%PCName%"=="" goto A
If "%PCName%"=="0" exit
set computername=%PCName%
:: PC name
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t reg_sz /d "%computername%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t reg_sz /d "%computername%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t reg_sz /d "%computername%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v Hostname /t reg_sz /d "%computername%" /f

echo =====添加办公网域=====
netdom join %computername% /domain:grgit.com /UserD:adddomain /PasswordD:grg8033
 
set/p=  ■<nul
for /L %%i in (1,1,38) do set /p a=■<nul&ping /n 1 127.0.0.1>nul
echo   100%%
:end
exit
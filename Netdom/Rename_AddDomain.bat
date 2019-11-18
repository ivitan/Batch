::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFAJDWA2MOzmGIrAP4/z0/9ampkk5W+8+cYGV36yLQA==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@Echo off
Color 0A
title 更改计算机名并加域
:A
cls
echo.
echo [0]退出
echo.
echo 不用重启电脑就生效
echo 必须以管理员身份运行 
echo.
echo.

set /p pc=       [请输入计算机名] #
If "%pc%"=="" goto A
If "%pc%"=="0" exit
set COMPUTERNAME=%pc%
:: PC name
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t reg_sz /d "%COMPUTERNAME%" /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v Hostname /t reg_sz /d "%COMPUTERNAME%" /f

echo =====添加办公网域=====
netdom join %COMPUTERNAME% /DOMAIN:grgit.com /UserD:adddomain /PasswordD:psssword
 
set/p=  ■<nul
for /L %%i in (1,1,38) do set /p a=■<nul&ping /n 1 127.0.0.1>nul
echo   100%%

echo 配置完成，5秒后重启
shutdown -r -t 5
:end
exit
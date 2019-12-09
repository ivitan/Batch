@ECHO OFF&PUSHD %~DP0 &TITLE 修改内网更新系统 -- Jay
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
cd %~dp0
@echo. & @echo.  请选择设备所在网络类型
@echo. & @echo.  1=办公网络   2=保密网络
@echo.
set /p  xj= 输入数字按回车：
if /i "%xj%"=="1"   call :wsus_Server WSUS_BG
if /i "%xj%"=="2"   call :wsus_Server WSUS_BM
:wsus_Server
@echo.  设置系统办公网络设备更新服务器中......
REGEDIT /S config\%1.reg >nul
@echo. & @echo.  重新加载更新服务器中......
taskkill /f /im explorer.exe & start explorer.exe >nul
ping -n 3 172.1>nul
wuauclt.exe /detectnow
@echo. & @echo.  加载完成，按任意键退出... 
@echo. & pause>nul
exit
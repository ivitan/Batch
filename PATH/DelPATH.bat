::删除环境变量JAVA_HOME
@echo off
echo 删除java环境变量
set regpath=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
set evname=JAVA_HOME
reg delete "%regpath%" /v "%evname%"  /f
pause>nul
@ECHO OFF&PUSHD %~DP0 &TITLE Uninstall Office
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
@echo off
powercfg -h off
pushd %~dp0
powershell.exe -command ^
  "& {set-executionpolicy Remotesigned -Scope Process; .'.\office-uninstall.ps1' }"
popd
pause
exit
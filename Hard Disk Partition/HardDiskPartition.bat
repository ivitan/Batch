@ECHO OFF&PUSHD %~DP0 &TITLE GRGInstall -- Jay
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
@echo off
powercfg -h off
diskpart

select volume 3
REMOVE
ASSIGN LETTER=U
select volume 0
shrink desired 373482
create partition primary size=183481
format quick
create partition primary size=189500
format quick
select volume 4
ASSIGN LETTER=D
select volume 5
ASSIGN LETTER=E
exit
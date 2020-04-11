@echo off
TITLE 系统参数
COLOR 02

::  C:\Users\vitan
ECHO USERPROFILE: %USERPROFILE%

::C:\WINDOWS (%windir% 同样)
ECHO SystemRoot: %SystemRoot%

:: C:\Program Files
ECHO ProgramFiles: %ProgramFiles%

:: C:\Documents and Settings\Administrator (子目录有“桌面”,“开始菜单”,“收藏夹”等)
ECHO USERPROFILE: %USERPROFILE%

:: C:\Documents and Settings\Administrator\Application Data
ECHO APPDATA: %APPDATA%

:: C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp (%TEM% 同样)
ECHO TEMP: %TEMP%

:: C:\Documents and Settings\Administrator\Application Data
ECHO APPDATA: %APPDATA%

:: Windows_NT (系统)
ECHO OS: %OS%

:: %SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem (原本的设置)
ECHO Path: %Path%

:: C: (系统盘)
ECHO %HOMEDRIVE%

:: \Documents and Settings\Administrator
ECHO HOMEPATH: %HOMEPATH%

PAUSE
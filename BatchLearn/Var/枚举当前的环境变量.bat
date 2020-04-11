@echo off
COLOR 02
TITLE 枚举当前的环境变量

setlocal enabledelayedexpansion
FOR /F "usebackq delims==" %%i IN (`set`) DO @echo %%i !%%i!

PAUSE
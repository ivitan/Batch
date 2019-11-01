@echo off 
set globalvar=5
SETLOCAL
set var=13145
set /A var=%var% + 5
echo %var%
echo %globalvar%
ENDLOCAL

Rem 在ENDLOCAL语句之后，'var'变量将不再存在。
pause
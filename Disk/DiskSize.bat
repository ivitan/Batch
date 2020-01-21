@echo off
setlocal enabledelayedexpansion
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk c: get Size/value') do set tsize=%%a
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk c: get FreeSpace/value') do set fsize=%%a
set gbtsize=%tsize:~0,-7%
set gbfsize=%fsize:~0,-7%
set /a newtsize = %gbtsize%-102400
set /a rsize = %newtsize%/2

:cut1
set pa=!gbtsize:~-3!
if "!gbtsize!"=="" (goto cut2)
set pa1=!pa!,!pa1!
set gbtsize=!gbtsize:~0,-3!
goto cut1

:cut2
set pb=!newtsize:~-3!
if "!newtsize!"=="" (goto cut3)
set pb1=!pb!,!pb1!
set newtsize=!newtsize:~0,-3!
goto cut2

:cut3
set pc=!rsize:~-3!
if "!rsize!"=="" (goto output)
set pc1=!pc!,!pc1!
set rsize=!rsize:~0,-3!
goto cut3

:output
echo Total Size of Drive C: !pa1:~0,-1! MB
echo Remaining Size after 100G: !pb1:~0,-1! MB
echo Half of Remaining Size: !pc1:~0,-1! MB
pause
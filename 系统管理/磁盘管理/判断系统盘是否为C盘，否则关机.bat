@echo off
set DRIVE=%systemdrive%
echo %DRIVE%

set Cpan=C:
if %DRIVE% EQU %Cpan% (echo yes) else (Shutdown -s -t 10)

for /f "tokens=2 delims==" %%a in ('wmic logicaldisk C: get Size/value') do set tsize=%%a
set gbtsize=%tsize:~0,-10%
echo %gbtsize%G

if %gbtsize% GTR 100 (echo yes) else (Shutdown -s -t 10)
pause
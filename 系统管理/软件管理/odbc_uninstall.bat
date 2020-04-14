@echo off
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Oracle"
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v NLS_LANG /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v TNS_ADMIN /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\cadence"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" /v cadence /f
pause
cd %cd%\bin\
start odbc_uninstall.exe

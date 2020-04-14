@echo off
rem 当前目录是%cd%
rem odbc_bin目录路径直
set odbc_bin_pathname=D:\tools\Oracle\instantclient\bin
set odbc_tns_pathname=D:\tools\Oracle\instantclient\network\admin
rem 导入注册表
regedit /s %cd%\bin\register.reg
rem 更新环境变量path
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v NLS_LANG /t REG_SZ /d "SIMPLIFIED CHINESE_CHINA.ZHS16GBK" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v TNS_ADMIN /t REG_SZ /d "%odbc_tns_pathname%" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "%path%;%odbc_bin_pathname%" /f
rem 运行odbc_install.exe
cd %cd%\bin\
odbc_install.exe 
ping -n 5 127.0.0.1>nul
rem 导入数据源注册表
regedit /s %cd%\bin\cadence.reg
rem 重启explorer.exe
taskkill /im explorer.exe /f
start %systemroot%\explorer.exe


@echo off
mode con cols=50 lines=20&color 0a 

net use y: \\10.1.1.42\check /user:grgbanking\check grggrg >nul
set fn=d:\sysinfo
echo computername=%computername%>%fn%%computername%.log
for /f "skip=1" %%i in ('wmic computersystem where Name^="%COMPUTERNAME%" get domain') do echo workgroup=%%i >>%fn%%computername%.log
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "IPv4 Address"') do echo IP=%%i>>%fn%%computername%.log 
move %fn%%computername%.log y:\ >nul

net use y:  /del >nul

::at 00:00 shutdown -s
::schtasks /create /tn "poweroff" /ST 00:00 /sc once /TR "shutdown /s"
@echo on
echo ok!

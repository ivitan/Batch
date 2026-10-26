@ECHO OFF
mode con cols=50 lines=20&color 0a 
TITLE 计划任务
REM 每天的19：00 以 System 权限运行C:\自动关机.bat，然后24：00终止命令
REM SCHTASKS /Create /SC onstart /delay mmmm:ss /tn name /tr "command"

SCHTASKS /Create /SC DAILY /TN "自动关机" /TR C:\自动关机.bat /ST 19:00 /ET 24:00 /K /ru "System"

EXIT
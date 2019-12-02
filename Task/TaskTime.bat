@ECHO OFF
TITLE 计划任务
::每天的12：00执行命令，然后14：00终止命令
REM SCHTASKS /Create /SC onstart /delay mmmm:ss /tn name /tr "command"
SCHTASKS /Create /SC DAILY /TN gaming /TR C:\bat.bat /ST 12:00 /ET 14:00 /K
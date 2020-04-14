@ECHO OFF
TITLE 计划任务
::每天的20：00执行命令，然后24：00终止命令
REM SCHTASKS /Create /SC onstart /delay mmmm:ss /tn name /tr "command"
SCHTASKS /Create /SC DAILY /TN 自动关机 /TR C:\自动关机.bat /ST 12:00 /ET 14:00 /K
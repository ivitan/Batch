@ECHO OFF&PUSHD %~DP0 &TITLE AutoCad Uninstall
mode con cols=58 lines=25

md c:\backup
copy /y c:\Users\Public\Desktop\* c:\backup\
del /f /s /q "C:\Users\Public\Desktop\*.lnk"
pause
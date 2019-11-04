@ECHO OFF&PUSHD %~DP0 &TITLE GRGInstall -- Jay
mode con cols=80 lines=80
color 2F
ipconfig /all
@echo.&echo.  请查看本地连接IP地址。 & echo. & echo.  按任意键退出... & pause>nul
exit
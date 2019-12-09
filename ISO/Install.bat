@ECHO OFF&PUSHD %~DP0 &TITLE Install -- Vitan
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(ECHO 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
cd %~dp0
powercfg -h off
set _PublicPath="%PUBLIC%\Desktop\说明.txt"
@ECHO. ****************** 检查安装软件情况如下 ****************** >> %_PublicPath%
:batMenu
@ECHO.
@ECHO. ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@ECHO. ::                                                    ::
@ECHO. ::          正在检查并安装软件，请稍等...             ::
@ECHO. ::                                                    ::
@ECHO. ::                                       By: VItan   ::
@ECHO. ::                                       Ver:19H1     ::
@ECHO. ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@ECHO.
SET _Net=BG
cls
IF %_Net% EQU BG call :install_FoxMail Foxmail.exe FoxMail
call :install_S 7-Zip\7z.exe 7-Zip 7-Zip_19.00_x86_x64.exe
IF %_Net% EQU BG call :install_S GRGTalk\GRGTalk.exe OA GRGTalk.exe
call :install_MSI Adobe AdobeReader AdobeReader.exe
IF %_Net% EQU BG call :install_SILENT  Sangfor\SecurityDesktop\SangforSDUI.exe 上网助手 singress.exe
call :install_SILENT Symantec Symantec setup_x64_%_Net%.exe
call :install_SP  %windir%\LVUAAgentInstBaseRoot\UniAccessAgent.exe 安全用手 lva_setupfull_%_Net%.exe 
IF NOT EXIST "%ProgramFiles%\7-Zip\7z.exe" @ECHO.  >> %_PublicPath% & ECHO. - 软件 7-Zip 安装出错！！ >> %_PublicPath%
IF %_Net% EQU BG IF NOT EXIST "%ProgramFiles(x86)%\GRGTalk\GRGTalk.exe" @ECHO.  >> %_PublicPath% & ECHO. - 软件 OA 安装出错！！ >> %_PublicPath%
IF NOT EXIST "%ProgramFiles(x86)%\Adobe" @ECHO.  >> %_PublicPath% & ECHO. - 软件 AdobeReader 安装出错！！ >> %_PublicPath%
IF %_Net% EQU BG IF NOT EXIST "%ProgramFiles%\Sangfor\SecurityDesktop\SangforSDUI.exe" @ECHO.  >> %_PublicPath% & ECHO. - 软件 上网助手 安装出错！！ >> %_PublicPath%
IF NOT EXIST "%ProgramFiles(x86)%\Symantec" @ECHO.  >> %_PublicPath% & ECHO. - 软件 Symantec 安装出错！！ >> %_PublicPath%
IF %_Net% EQU BG IF NOT EXIST "%windir%\LVUAAgentInstBaseRoot\UniAccessAgent.exe" @ECHO.  >> %_PublicPath% & ECHO. - 软件 安全用手 安装出错！！ >> %_PublicPath%
IF %_Net% EQU BG ( SET _SAMBA=\\10.1.1.5\工具软件 & SET _INNET=办公网络 ) ELSE ( SET _SAMBA=\\10.1.200.3\01-工具软件 & SET _INNET=保密网络)
@ECHO. >> %_PublicPath% & ECHO.    如未提示软件安装出错，说明软件全部安装完成。如须安装其它软件可至 “%_SAMBA%” 中查找安装包选择安装。 >> %_PublicPath%
@ECHO. >> %_PublicPath% & ECHO. - IT指南：http://it.grgbanking.com >> %_PublicPath%
@ECHO. - 软件共享：%_SAMBA% >> %_PublicPath%
@ECHO. - IT报障：6287 8033 >> %_PublicPath%
@ECHO.                                              运维保障部/桌面运维组 >> %_PublicPath%
@ECHO.                                               %date% %time% >> %_PublicPath%
@ECHO. & ECHO. 软件已安装完成。
@ECHO. & ECHO. 设置系统%_INNET%设备更新服务器中......
REGEDIT /S WSUS_%_Net%.reg >nul
del /S /Q ".\Adobe Reader XI_11.0.exe" >nul
del /S /Q ".\FoxmailSetup.exe" >nul
del /S /Q ".\GRGTalk.exe" >nul
@echo.  删除OA安装包完成 &@echo.
ping -n 10 127.1 >nul
del /S /Q ".\lva_setupfull.exe" >nul
del /S /Q ".\singress.exe" >nul
del /S /Q ".\Winrar-x64-550scp.exe" >nul
@echo.  删除安全助手安装包完成 &@echo.
ping -n 10 127.1 >nul
del /S /Q ".\SEP.exe" >nul
@echo.  系统部署完成，请检查软件是否安装正常。
@ECHO. & Pause
ping  127.1 >nul & del /S /Q ".\GRGInstall.bat" && EXIT


:install_FoxMail
IF EXIST "D:\$RECYCLE.BIN" set _FoxMailPath=D:\Program Files\FoxMail
IF DEFINED _FoxMailPath (
	@ECHO. 正在安装 %2，请稍等... &ECHO.
	IF EXIST "D:\Program Files\FoxMail\%1"  ECHO. 发现已安装 %2 。
	IF NOT EXIST "D:\Program Files\FoxMail\%1" (
		"FoxmailSetup.exe" "D:\Program Files\FoxMail" -silent
		IF ERRORLEVEL 0 @ECHO. 安装 %2 完成!!
		IF %ERRORLEVEL% NEQ 0 @ECHO. 安装 %2 出错，请手动检查。
	)
	IF NOT EXIST "D:\Program Files\FoxMail\%1"  @ECHO. & ECHO. -> 软件 %2 安装出错！！ >> %_PublicPath%
	GOTO :EOF
) else ( ECHO. 未发现分区 D 盘，暂未安装 %2 ；请稍后手动安装。>> %_PublicPath% && GOTO :EOF )
GOTO :EOF

:install_S
@ECHO. & ECHO. 正在安装 %2，请稍等... && ECHO.
IF EXIST "%ProgramFiles%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
IF EXIST "%ProgramFiles(x86)%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
"%3" /S & IF ERRORLEVEL 0 @ECHO. 安装 %2 完成!! && IF %ERRORLEVEL% NEQ 0 @ECHO. 安装 %2 出错，请手动检查。
GOTO :EOF

:install_SP
@ECHO. & ECHO. 正在安装 %2，请稍等... && ECHO.
IF EXIST "%1" ECHO. 发现已安装 %2 。& GOTO :EOF
"%3" /sp- /silent /norestart & IF ERRORLEVEL 0 @ECHO. 安装 %2 完成!! && IF %ERRORLEVEL% NEQ 0 @ECHO. 安装 %2 出错，请手动检查。
GOTO :EOF

:install_MSI
@ECHO. & ECHO. 正在安装 %2，请稍等... && ECHO.
IF EXIST "%ProgramFiles%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
IF EXIST "%ProgramFiles(x86)%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
"%3" /sALL /msi /quiet & IF ERRORLEVEL 0 @ECHO. 安装 %2 完成!! && IF %ERRORLEVEL% NEQ 0 @ECHO. 安装 %2 出错，请手动检查。
GOTO :EOF

:install_SILENT
@ECHO. & ECHO. 正在安装 %2，请稍等... && ECHO.
IF EXIST "%ProgramFiles%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
IF EXIST "%ProgramFiles(x86)%\%1" ECHO. 发现已安装 %2 。& GOTO :EOF
"%3" /silent & IF ERRORLEVEL 0 @ECHO. 安装 %2 完成!! && IF %ERRORLEVEL% NEQ 0 @ECHO. 安装 %2 出错，请手动检查。
GOTO :EOF

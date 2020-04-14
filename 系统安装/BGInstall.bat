@ECHO OFF&PUSHD %~DP0 &TITLE Install
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
@echo off
powercfg -h offg
rmdir /S /Q "%USERPROFILE%\Favorites\Microsoft Websites"
rmdir /S /Q "%USERPROFILE%\Favorites\Microsoft 网站"
rmdir /S /Q "%USERPROFILE%\Favorites\MSN Websites"
rmdir /S /Q "%USERPROFILE%\Favorites\MSN 网站"
rmdir /S /Q "%USERPROFILE%\Favorites\中国的网站"
rmdir /S /Q "%USERPROFILE%\Favorites\Windows Live"
del /S /Q "%USERPROFILE%\Favorites\Links\Web Slice Gallery.url"
del /S /Q "%USERPROFILE%\Favorites\Links\网页快讯库.url"
del /S /Q "%USERPROFILE%\Favorites\Links\建议网站.url"
attrib -R -A -S -H "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Games\*.*"
RMDIR /S /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Games"
attrib -R -A -S -H "%ProgramFiles%\Microsoft Games\*.*"
RMDIR /S /Q "%ProgramFiles%\Microsoft Games"
cls
ECHO 正在安装OA，请稍等……
".\01-OA\GRGTalk-3.0.4.exe" /S
ECHO.
ping -n 2 127.1 >nul
ECHO 正在安装Foxmail，请稍等……
".\05-FoxMail\FoxmailSetup.exe" "D:\Program Files\FoxMail" -silent
ECHO.
ping -n 2 127.1 >nul
ECHO 正在安装搜狗拼音，请稍等……
".\07-输入法\搜狗拼音输入法v8.8b(1956)去广告精简优化版.exe" /S
ECHO.
ping -n 2 127.1 >nul
ECHO 正在安装上网插件，请稍等……
".\02-上网插件\singress.exe" /sp- /silent 
ECHO.
ping -n 2 127.1 >nul
ECHO 正在安装7zip，请稍等……
".\06-WPS_PDF\7z1900-x64.exe" /S
ECHO.
ping -n 2 127.1 >nul
ECHO 正在复制WPS至桌面，请稍等……
copy /Y ".\06-WPS_PDF\W.P.S.7311.12012.0.exe" "C:\Users\Public\Desktop\"
ECHO.
ECHO 正在安装安全助手，请稍等……
".\03-办公网安全助手V8080\lva_setupfull_20181213141850.exe" /S
ping -n 2 127.1 >nul
ECHO 正在安装杀毒软件，请稍等……这里时间较长，请耐心等待……
".\04-杀毒软件\setup_14.2.760_x64.exe" /S
ECHO.
ping -n 2 127.1 >nul
ECHO 正在安装Adobe Reader，请稍等……
".\06-WPS_PDF\AdbeRdr11000_zh_CN.exe" /sALL /msi /quiet
ECHO.
ping -n 2 127.1 >nul
ECHO 正在卸载win10自带office_365，请稍等……
pushd %~dp0
powershell.exe -command ^
  "& {set-executionpolicy Remotesigned -Scope Process; .'.\office-uninstall.ps1' }"
popd
ECHO.
ping -n 2 127.1 >nul
exit
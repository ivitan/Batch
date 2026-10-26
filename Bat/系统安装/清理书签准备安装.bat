@ECHO OFF&PUSHD %~DP0 &TITLE GRGInstall -- Vitan
mode con cols=58 lines=25
color 2F
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 请使用右键管理员身份运行！&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
SetLocal EnableDelayedExpansion
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
ping -n 2 127.1 >nul
copy /Y "W.P.S.7311.12012.0.exe" "C:\Users\Public\Desktop\"
ping -n 2 127.1 >nul
copy /Y ".\W.P.S.7311.12012.0.exe" "C:\Users\Public\Desktop\"
ping -n 2 127.1 >nul
copy /Y "\\10.1.230.88\GRGinstall\06-WPS_PDF\W.P.S.7311.12012.0.exe" "C:\Users\Public\Desktop\"
exit
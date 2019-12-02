REM 后台运行
goto han
if "%1"=="hide" goto CmdBegin
start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:CmdBegin
:han

@ECHO OFF&PUSHD %~DP0 &TITLE 清理未授权软件

echo 正在清理未授权软件,所需时间较长，请勿关闭计算机、关闭此窗口，完成清理自动退出...
ping -n 5 127.0.0.1 > nul

net use \\10.1.200.3\1工具软件
COPY /y "\\10.1.200.3\1工具软件\办公软件\7-Zip_19.00_x86_x64_UnNSIS_Setup_Ha_Mod.exe" "C:\UniAccessAgentDownloadData\"

"C:\UniAccessAgentDownloadData\7-Zip_19.00_x86_x64_UnNSIS_Setup_Ha_Mod.exe" /S

TASKKILL /F /IM acad.exe
TASKKILL /F /IM xtop.exe
TASKKILL /F /IM pro_comm_msg.exe

MD "D:\tools\backup\Lnks\"
MD "D:\tools\backup\Autodesk\"
MD "D:\tools\backup\PTC\"
MD "D:\tools\backup\StartLnks\"
echo %path% > "D:\tools\backup\path.txt"

COPY /y "C:\Users\Public\Desktop\*Auto*.lnk" "D:\tools\backup\Lnks\"
COPY /y "C:\Users\Public\Desktop\*Creo*.lnk" "D:\tools\backup\Lnks\"
COPY /y "C:\Users\Public\Desktop\ModelCHECK.lnk" "D:\tools\backup\Lnks\"
XCOPY /y "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*Creo*.lnk" "D:\tools\backup\StartLnks\"
XCOPY /y "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ModelCHECK.lnk" "D:\tools\backup\StartLnks\"
XCOPY /S "C:\ProgramData\Microsoft\Windows\Start Menu\*Auto*.lnk" "D:\tools\backup\StartLnks\"
XCOPY /S "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Autodesk" "D:\tools\backup\Autodesk\"
XCOPY /S "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC" "D:\tools\backup\PTC\"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\Au.7z" "D:\tools\backup\Autodesk"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\PT.7z" "D:\tools\backup\PTC"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\DW.7z" "C:\Program Files (x86)\Autodesk\Autodesk DWF Viewer"

RMDIR /s/q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Autodesk"
RMDIR /s/q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC"
RMDIR /s/q "C:\Program Files (x86)\Autodesk\Autodesk DWF Viewer"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\L.7z" "D:\tools\backup\Lnks"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\SL.7z" "D:\tools\backup\StartLnks"

DEL /f /s /q "C:\Users\Public\Desktop\*Auto*.lnk"
DEL /f /s /q "C:\Users\Public\Desktop\*Cre*.lnk"
DEL /f /s /q "C:\Users\Public\Desktop\ModelCHECK.lnk"
DEL /f /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*Creo*.lnk"
DEL /f /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\*Auto*.lnk"
DEL /f /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ModelCHECK.lnk"
RMDIR /s/q "D:\tools\backup\Lnks"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\AC.7z" "D:\tools\AutoCAD 2007"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\P.7z" "D:\tools\PTC"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\JT.7z" "D:\tools\JT"

RMDIR /s/q "D:\tools\PTC"
RMDIR /s/q "D:\tools\AutoCAD 2007"
RMDIR /s/q "D:\tools\JT"
RMDIR /s/q "D:\tools\backup\Lnks"
RMDIR /s/q "D:\tools\backup\Autodesk"
RMDIR /s/q "D:\tools\backup\PTC"
RMDIR /s/q "D:\tools\backup\StartLnks"

setx /M PATH "C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;"

REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Creo Elements/Pro Release 5.0 Datecode M110" D:\tools\backup\Cre.reg
REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7E5A1435-D1AD-49E2-AB89-31BD7BB350CF}" D:\tools\backup\PT.reg
REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DCC7ADF1-1C02-4FAC-AC5F-E9424A0F1C68}" D:\tools\backup\PT2.reg
REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\7D2F387510054080002000060BECB6AB" D:\tools\backup\Au.reg
REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Autodesk DWF Viewer" D:\tools\backup\DW.reg

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Creo Elements/Pro Release 5.0 Datecode M110" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7E5A1435-D1AD-49E2-AB89-31BD7BB350CF}" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DCC7ADF1-1C02-4FAC-AC5F-E9424A0F1C68}" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\7D2F387510054080002000060BECB6AB" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Autodesk DWF Viewer" /f

TASKKILL /im explorer.exe /f
ping -n 2 127.0.0.1 > nul
START C:\windows\explorer.exe
ECHO.
echo Bingo
exit
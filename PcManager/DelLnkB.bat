@ECHO OFF&PUSHD %~DP0 &TITLE AutoCad Uninstall
mode con cols=58 lines=25

echo 正在安装7zip...
net use \\10.1.200.3\1工具软件
COPY /y "\\10.1.200.3\1工具软件\办公软件\7-Zip_19.00_x86_x64_UnNSIS_Setup_Ha_Mod.exe" "C:\UniAccessAgentDownloadData\"

"C:\UniAccessAgentDownloadData\7-Zip_19.00_x86_x64_UnNSIS_Setup_Ha_Mod.exe" /S

echo 正在杀部分程序进程...
TASKKILL /F /IM acad.exe
TASKKILL /F /IM xtop.exe
TASKKILL /F /IM pro_comm_msg.exe

echo 正在打包备份
MD "D:\tools\backup\Lnks\"
MD "D:\tools\backup\Autodesk\"
MD "D:\tools\backup\PTC\"

COPY /y "C:\Users\Public\Desktop\*Auto*.lnk" "D:\tools\backup\Lnks\"
COPY /y "C:\Users\Public\Desktop\*Cre*.lnk" "D:\tools\backup\Lnks\"
COPY /y "C:\Users\Public\Desktop\ModelCHECK.lnk" "D:\tools\backup\Lnks\"
XCOPY /S "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Autodesk" "D:\tools\backup\Autodesk\"
XCOPY /S "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC" "D:\tools\backup\PTC\"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\A.7z" "D:\tools\backup\Autodesk"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\P.7z" "D:\tools\backup\PTC"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\DWF.7z" "C:\Program Files (x86)\Autodesk\Autodesk DWF Viewer"

RMDIR /s/q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Autodesk"
RMDIR /s/q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC"
RMDIR /s/q "C:\Program Files (x86)\Autodesk\Autodesk DWF Viewer"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\L.7z" "D:\tools\backup\Lnks"

DEL /f /s /q "C:\Users\Public\Desktop\*Auto*.lnk"
DEL /f /s /q "C:\Users\Public\Desktop\*Cre*.lnk"
DEL /f /s /q "C:\Users\Public\Desktop\ModelCHECK.lnk"

"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\AC.7z" "D:\tools\AutoCAD 2007"
"C:\Program Files\7-Zip\7z.exe" a -pvitan.me -t7z "D:\tools\backup\P.7z" "D:\tools\PTC"

RMDIR /s/q "D:\tools\PTC"
RMDIR /s/q "D:\tools\AutoCAD 2007"

echo 完成！
quit
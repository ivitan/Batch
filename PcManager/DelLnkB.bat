@ECHO OFF&PUSHD %~DP0 &TITLE AutoCad Uninstall
mode con cols=58 lines=25

md c:\backup
copy /y c:\Users\Public\Desktop\* c:\backup\
:WinRAR a -pVitan -r secret  c:\backup
"C:\Program Files\7-Zip\7z.exe" a -pVitan C:\samp.zip c:\backup
:del /f /s /q "C:\Users\Public\Desktop\*GR*.lnk"
pause
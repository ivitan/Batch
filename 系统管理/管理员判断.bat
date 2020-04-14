@ECHO OFF
title 管理员身份判断
Rem 创建文件路径
set TempFile_Name=%SystemRoot%\System32\BatTestUACin_SysRt%Random%.batemp
echo %TempFile_Name%
 
Rem 写入文件
( echo "BAT Test UAC in Temp" >%TempFile_Name% ) 1>nul 2>nul
 
Rem 判断写入是否成功
if exist %TempFile_Name% (
echo 正在以管理员身份运行当前批处理
) else (
echo 没有以管理员身份运行当前批处理 
exit
)
pause
 
Rem 删除临时文件
del %TempFile_Name% 1>nul 2>nul
 
echo 按空格键退出……
pause >nul
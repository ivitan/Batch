@ echo off 
title: 自动关机
mode con cols=50 lines=20&color 0a 
for /l %%a in (600 -1 0) do (
echo.
echo 系统将在【%%a】秒后关机,请保存所有工作后退出.
echo.
echo 取消关机请直接关闭当前程序即可!
ping /n 2 127.1 >nul
cls
)
shutdown.exe /f /s /t 0
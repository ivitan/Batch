@echo off
certutil -urlcache -split -f https://www.xxx.com/test.bat
::指定保存文件名
certutil -urlcache -split -f https://www.xxx.com/test.bat d:\ff.bat 

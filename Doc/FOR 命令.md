## 显示当前目录下所有以bat或者txt为扩展名的文件名
```bat
for %%c in (*.bat *.txt) do (echo %%c)
```
## 显示当前目录下所有包含有 e 或者 i 的目录名。
```bat
for /D %%a in (*e* *i*) do echo %%a
```
## 显示 E盘test目录 下所有以bat或者txt为扩展名的文件名。
```bat
for /R E:\test %%b in (*.txt *.bat) do echo %%b

for /r %%c in (*) do (echo %%c) :: 遍历当前目录下所有文件
```
## 将产生序列 1 2 3 4 5
```bat
for /L %%c in (1,1,5) do echo %%c
```
## 显示当前的年月日和时间
```bat
For /f "tokens=1-3 delims=-/. " %%j In ('Date /T') do echo %%j年%%k月%%l日

For /f "tokens=1,2 delims=: " %%j In ('TIME /T') do echo %%j时%%k分
```
## 把记事本中的内容每一行前面去掉8个字符
```bat
setlocal enabledelayedexpansion

for /f %%i in (zhidian.txt) do (

set atmp=%%i

set atmp=!atmp:~8!

if {!atmp!}=={} ( echo.) else echo !atmp!

)

:: 读取记事本里的内容(使用 delims 是为了把一行显示全,否则会以空格为分隔符)

for /f "delims=" %%a in (zhidian.txt) do echo.%%a
```
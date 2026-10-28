@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

rem =========================================================
rem  sanxia 数据集整理脚本 - 复制模式，不删源文件
rem  一个源文件夹 = 一个目标文件夹 = 一个同名 zip
rem  目标文件夹名 sanxia-日期-时间，精确到毫秒
rem  例如 sanxia-20261027-114301357，毫秒级不会撞车，不需要序号
rem  毫秒基准靠开头的 PowerShell 取一次，取不到就退回百分秒
rem  目标内部结构照旧:
rem    images\train  images\val  labels\train  labels\val
rem  jpg 进 images，txt 进 labels
rem  train 进 train，test 或 valid 进 val
rem  速度：robocopy /MT 多线程，再叠加子文件夹级并行
rem  配置项：
rem    TRAIN_DIR : 源端训练集文件夹名
rem    TEST_DIR  : 源端验证集文件夹名，找不到时自动改用 valid
rem    MAX_JOBS  : 并行子任务数
rem    MT        : 每个任务的 robocopy 线程数
rem    RENAME_DUP: 1=源端跨文件夹同名的改成 源文件夹名__原文件名  0=不改名
rem    DO_ZIP    : 1=每个目标文件夹打一个 zip  0=不打包
rem    ZIP_EXE   : 7z 的路径，没装 7-Zip 就自动跳过打包
rem    ZIP_LEVEL : 压缩等级 0=仅存储最快 1=快 9=最小最慢
rem                实测 jpg 压不动，0 和 9 只差 0.09%，但耗时差 25 倍，用 0
rem
rem  每个源文件夹各自一个目标，但服务器会把所有 zip 解压到同一个文件夹，
rem  所以源端跨文件夹同名的仍然要改名，否则解压后会互相覆盖
rem  改名格式：源文件夹名__原文件名，字母序靠前的文件夹保留原名
rem  jpg 和 txt 加同样的前缀，配对不会乱
rem  上次运行留下的 sanxia-日期-时间 文件夹会被自动跳过
rem  编码注意：本文件必须保存为 GBK 即代码页 936 编码 + CRLF。
rem  第 2 行的 chcp 936 是让中文正常显示的，不要删。
rem =========================================================

rem ---- 配置项 ----
set "TRAIN_DIR=train"
set "TEST_DIR=test"
set "MAX_JOBS=8"
set "MT=8"
set "RENAME_DUP=1"
set /a "REN_train=0"
set /a "REN_val=0"

rem 打包配置
set "DO_ZIP=1"
set "ZIP_EXE=C:\Program Files\7-Zip\7z.exe"
set "ZIP_LEVEL=0"

rem 根目录 = 本脚本所在文件夹
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rem 临时工作目录，存任务脚本和锁文件，结束时删除
rem 必须放在脚本所在目录下，不能放 %TEMP%
rem 因为 %TEMP% 会被解析成 8.3 短路径，后台任务找不到文件
set "PARALLEL_OK=1"
set "WORK=%ROOT%\.sxcpy_tmp"
if exist "%WORK%\" rmdir /s /q "%WORK%" >nul 2>&1
mkdir "%WORK%" >nul 2>&1
if not exist "%WORK%\" set "PARALLEL_OK=0"

rem 本次运行的目标文件夹清单，一行一个: 源文件夹名?目标文件夹名
set "TGTS=%WORK%\tgts.txt"
type nul > "%TGTS%"

rem 取一次毫秒级时间当基准，后面每个目标文件夹在基准上加 1 毫秒
rem 只调一次 PowerShell，不每个文件夹都调，不然太慢
rem 取不到就退回 %DATE% %TIME%，只能到百分秒
set "BASE="
for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmssfff" 2^>nul') do (
    if not defined BASE set "BASE=%%T"
)
if not "!BASE:~8,1!"=="-" set "BASE="
set /a "MSIDX=0"
if defined BASE (
    set "BASEDATE=!BASE:~0,8!"
    set "BASEH=!BASE:~9,2!"
    set "BASEM=!BASE:~11,2!"
    set "BASES=!BASE:~13,2!"
    set "BASEF=!BASE:~15,3!"
)

rem 先杀掉上次异常退出残留的后台任务
taskkill /f /fi "WINDOWTITLE eq sxcpy" >nul 2>&1

echo ================================================
echo  1. 为每个源文件夹建一个 sanxia-日期-时间 目标
echo ================================================
set /a "NSUB=0"
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if /i "%%~nxD"=="sanxia" set "skip=1"
    set "SXPFX=%%~nxD"
    if /i "!SXPFX:~0,7!"=="sanxia-" set "skip=1"
    if !skip!==0 (
        set "has=0"
        if exist "%%D\%TRAIN_DIR%" set "has=1"
        set "vt=0"
        if exist "%%D\%TEST_DIR%" set "vt=1"
        set "vv=0"
        if exist "%%D\valid" set "vv=1"
        set /a "ok=has+vt+vv"
        if !ok! gtr 0 (
            call :mktarget "%%~nxD"
            set /a NSUB+=1
        )
    )
)
if !NSUB!==0 (
    echo   没有找到带 train 或 test 或 valid 的子文件夹
)
echo   共 !NSUB! 个目标文件夹

echo.
echo ================================================
echo  0. 源端检查，逐个统计子文件夹的 train / test / valid
echo ================================================
set /a "STJ=0"
set /a "STT=0"
set /a "SVJ=0"
set /a "SVT=0"
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if /i "%%~nxD"=="sanxia" set "skip=1"
    set "SXPFX=%%~nxD"
    if /i "!SXPFX:~0,7!"=="sanxia-" set "skip=1"
    if !skip!==0 (
        set "has=0"
        if exist "%%D\%TRAIN_DIR%" set "has=1"
        set "vt=0"
        if exist "%%D\%TEST_DIR%" set "vt=1"
        set "vv=0"
        if exist "%%D\valid" set "vv=1"
        if !has!==1 (
            call :count_ext "%%D\%TRAIN_DIR%" jpg
            set "tj=!RET!"
            call :count_ext "%%D\%TRAIN_DIR%" txt
            set "tt=!RET!"
            echo   %%~nxD   train  jpg=!tj!  txt=!tt!
            set /a "STJ+=!tj!"
            set /a "STT+=!tt!"
        )
        if !vt!==1 (
            call :count_ext "%%D\%TEST_DIR%" jpg
            set "vj=!RET!"
            call :count_ext "%%D\%TEST_DIR%" txt
            set "vt2=!RET!"
            echo   %%~nxD   %TEST_DIR%  jpg=!vj!  txt=!vt2!
            set /a "SVJ+=!vj!"
            set /a "SVT+=!vt2!"
        )
        if !vt!==0 if !vv!==1 (
            call :count_ext "%%D\valid" jpg
            set "vj=!RET!"
            call :count_ext "%%D\valid" txt
            set "vt2=!RET!"
            echo   %%~nxD   valid  jpg=!vj!  txt=!vt2!  - 用 valid 当 val 来源
            set /a "SVJ+=!vj!"
            set /a "SVT+=!vt2!"
        )
        if !has!==0 if !vt!==0 if !vv!==0 (
            echo   %%~nxD   没有 train / test / valid 子文件夹，跳过
        )
    )
)
set /a "SALL=STJ+STT+SVJ+SVT"
echo.
echo   -----------------------------------------------
echo   源端合计: train  jpg=!STJ!  txt=!STT!
echo   源端合计: test   jpg=!SVJ!  txt=!SVT!   来自 test 或 valid
echo   源端合计: 全部   = !SALL! 个文件
echo   -----------------------------------------------

echo.
echo ================================================
echo  2/3. 开始复制，train 进 train，test 或 valid 进 val
echo       并行任务数=%MAX_JOBS%  线程数=%MT%
echo       一个源文件夹一个目标，互不干扰，可以放心并行
echo       源端跨文件夹同名的会自动改名，服务器解压后不会撞车
echo ================================================
if "%RENAME_DUP%"=="1" if !NSUB! geq 2 (
    echo   正在预扫描源端重名，文件多的时候这步要等一会...
    call :dupscan
    echo   预扫描完成，训练 !REN_train! 个，验证 !REN_val! 个
)
set "FALLBACK=0"
call :copyloop
if !PARALLEL_OK!==1 (
    call :wait_all
)
if !FALLBACK!==1 (
    echo   有复制任务卡住了，自动转串行
    echo   正在清理残留的后台任务...
    taskkill /f /fi "WINDOWTITLE eq sxcpy" >nul 2>&1
    ping -n 2 127.0.0.1 >nul 2>&1
    del /q "%WORK%\lock_*.lck" >nul 2>&1
    echo   改为串行复制，一个源文件夹一个源文件夹来
    echo   下面会逐个打印任务，方便你看进度
    set "PARALLEL_OK=0"
    call :copyloop
)
set "NFAIL=0"
for /f %%F in ('dir /b "%WORK%\fail_*.txt" 2^>nul') do set /a NFAIL+=1
if !NFAIL! gtr 0 (
    echo.
    echo   WARNING: 有 !NFAIL! 个 robocopy 任务失败
    for /f %%F in ('dir /b "%WORK%\fail_*.txt" 2^>nul') do type "%WORK%\%%F"
)

echo.
echo ================================================
echo  3b. 源端重名的文件在目标里改名
echo ================================================
if "%RENAME_DUP%"=="0" (
    echo   已跳过 - RENAME_DUP 设为 0
) else if !NSUB! lss 2 (
    echo   只有 1 个源文件夹，不可能跨文件夹重名，无需改名
) else (
    call :renpass train
    call :renpass val
)

echo.
echo ================================================
echo  4. 复制完成后各目标文件夹的文件数量
echo ================================================
set /a "C1=0"
set /a "C2=0"
set /a "C3=0"
set /a "C4=0"
for /f "usebackq tokens=1,2 delims=?" %%A in ("%TGTS%") do (
    call :count_ext "%ROOT%\%%B\images\train" jpg
    set "ca=!RET!"
    call :count_ext "%ROOT%\%%B\labels\train" txt
    set "cb=!RET!"
    call :count_ext "%ROOT%\%%B\images\val" jpg
    set "cc=!RET!"
    call :count_ext "%ROOT%\%%B\labels\val" txt
    set "cd=!RET!"
    set /a "cs=!ca!+!cb!+!cc!+!cd!"
    echo   %%A 的目标 %%B : train jpg=!ca! txt=!cb!   val jpg=!cc! txt=!cd!   合计 !cs!
    set /a "C1+=!ca!"
    set /a "C2+=!cb!"
    set /a "C3+=!cc!"
    set /a "C4+=!cd!"
)
set /a "TOT=C1+C2+C3+C4"
echo   -----------------------------------------------
echo   目标端合计: train  jpg=!C1!  txt=!C2!
echo   目标端合计: test   jpg=!C3!  txt=!C4!
echo   目标端合计: 全部   = !TOT! 个文件
echo   -----------------------------------------------
set /a "SKIPPED=SALL-TOT"
set /a "EXTRA=TOT-SALL"
if !SKIPPED! gtr 0 (
    echo.
    echo   WARNING: 目标端 !TOT! 个文件，源端是 !SALL! 个
    echo   有 !SKIPPED! 个没进去，检查上面有没有复制失败
)
if !EXTRA! gtr 0 (
    echo.
    echo   WARNING: 目标端比源端多 !EXTRA! 个文件
    echo   可能是上次运行留下的，或者是目标里的老数据集
    echo   想要干净结果就删掉 sanxia-日期-时间 文件夹再跑一次
)
call :dups
if !TOT!==0 (
    echo.
    echo   WARNING: 什么都没复制到。这个 bat 必须放在存放
    echo   数据子文件夹的父目录里，并且每个子文件夹都要有
    echo   train / test 或 valid，里面放着 jpg 和 txt
)

echo.
echo ================================================
echo  4b. 检查 jpg 和 txt 是否一一对应
echo ================================================
for /f "usebackq tokens=1,2 delims=?" %%A in ("%TGTS%") do (
    call :paircheck "%ROOT%\%%B\images\train" "%ROOT%\%%B\labels\train" "%%B 的 train"
    call :paircheck "%ROOT%\%%B\images\val" "%ROOT%\%%B\labels\val" "%%B 的 val"
)

echo.
echo ================================================
echo  5. 逐个目标文件夹检查有没有 val
echo ================================================
for /f "usebackq tokens=1,2 delims=?" %%A in ("%TGTS%") do (
    call :count_ext "%ROOT%\%%B\images\val" jpg
    set "va=!RET!"
    call :count_ext "%ROOT%\%%B\labels\val" txt
    set "vb=!RET!"
    set /a "vs=!va!+!vb!"
    if !vs!==0 (
        echo   %%B 来自 %%A : 没有 val，源端没找到 %TEST_DIR% 或 valid
    )
)

echo.
echo ================================================
echo  6. 每个目标文件夹打一个同名 zip
echo ================================================
if "%DO_ZIP%"=="0" goto :nozip
if !TOT!==0 (
    echo   目标文件夹都是空的，跳过打包
    goto :nozip
)
if not exist "%ZIP_EXE%" (
    echo   WARNING: 找不到 %ZIP_EXE%
    echo   请安装 7-Zip，或者改开头的 ZIP_EXE 指向 7z.exe
    goto :nozip
)
pushd "%ROOT%"
for /f "usebackq tokens=1,2 delims=?" %%A in ("%TGTS%") do (
    set "ZN=%%B.zip"
    if exist "!ZN!" del /q "!ZN!" >nul 2>&1
    echo   正在打包 !ZN! ...
    "%ZIP_EXE%" a -tzip -mx=%ZIP_LEVEL% -mmt=on -bso0 -bsp0 "!ZN!" ".\%%B\*"
    set "ZRC=!errorlevel!"
    set "ZSZ=0"
    for %%S in ("!ZN!") do set "ZSZ=%%~zS"
    if !ZRC! gtr 0 (
        echo   WARNING: !ZN! 打包失败，7z 返回码 !ZRC!
    ) else (
        echo   完成 !ZN!  !ZSZ! 字节
    )
)
popd
echo   zip 内的根就是 images 和 labels，标准 YOLO 布局
:nozip

rem 清理临时目录，先杀残留后台任务
if exist "%WORK%\" (
    taskkill /f /fi "WINDOWTITLE eq sxcpy" >nul 2>&1
    ping -n 1 127.0.0.1 >nul 2>&1
    rmdir /s /q "%WORK%" >nul 2>&1
)

echo.
echo ================================================
echo  全部完成。统计结果就在上面。
echo  按任意键关闭窗口。
echo ================================================
pause
goto :eof

rem ---------- 子程序 ----------

rem 逐个源文件夹把 train / test 或 valid 排进复制队列
:copyloop
set "NJOBS=0"
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if /i "%%~nxD"=="sanxia" set "skip=1"
    set "SXPFX=%%~nxD"
    if /i "!SXPFX:~0,7!"=="sanxia-" set "skip=1"
    if !skip!==0 (
        set "TG=!TGD_%%~nxD!"
        if defined TG (
            set "VALSRC="
            if exist "%%D\%TEST_DIR%" set "VALSRC=%TEST_DIR%"
            if not defined VALSRC if exist "%%D\valid" set "VALSRC=valid"
            if exist "%%D\%TRAIN_DIR%\*.jpg" call :enqueue "%%D\%TRAIN_DIR%" "!TG!\images\train" jpg
            if exist "%%D\%TRAIN_DIR%\*.txt" call :enqueue "%%D\%TRAIN_DIR%" "!TG!\labels\train" txt
            if defined VALSRC (
                if exist "%%D\!VALSRC!\*.jpg" call :enqueue "%%D\!VALSRC!" "!TG!\images\val" jpg
                if exist "%%D\!VALSRC!\*.txt" call :enqueue "%%D\!VALSRC!" "!TG!\labels\val" txt
            )
        )
    )
)
goto :eof

rem 排一个复制任务 %1=源目录 %2=目标目录 %3=扩展名
:enqueue
set "SRC=%~1"
set "DST=%~2"
set "EXT=%~3"
if !PARALLEL_OK!==0 (
    echo   复制 *.%EXT% 到 %DST%
    robocopy "%SRC%" "%DST%" *.%EXT% /MT:%MT% /XC /XN /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul 2>&1
    if errorlevel 8 echo   ERROR: robocopy 失败 code=!errorlevel! src=%SRC%
    goto :eof
)
set /a NJOBS+=1
set "JB=%WORK%\job_!NJOBS!.bat"
set "LK=%WORK%\lock_!NJOBS!.lck"
:slot
set "c=0"
for /f %%N in ('dir /b "%WORK%\lock_*.lck" 2^>nul') do set /a c+=1
if !c! geq %MAX_JOBS% (
    ping -n 1 127.0.0.1 >nul 2>&1
    goto :slot
)
> "%JB%" echo @echo off
>> "%JB%" echo robocopy "%SRC%" "%DST%" *.%EXT% /MT:%MT% /XC /XN /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP ^>nul 2^>^&1
>> "%JB%" echo if errorlevel 8 echo FAIL src=%SRC% code=%%errorlevel%% ^> "%WORK%\fail_!NJOBS!.txt"
>> "%JB%" echo del "%LK%" ^>nul 2^>^&1
echo. > "%LK%"
start "sxcpy" /b cmd /c ""%JB%" "%LK%""
goto :eof

rem 取当前时刻，精确到毫秒
rem 有毫秒基准就在基准上加序号，没有就退回 %DATE% %TIME%
:mkstamp
if not defined BASE goto :mkt_fallback
set /a "bh=1!BASEH!-100"
set /a "bm=1!BASEM!-100"
set /a "bs=1!BASES!-100"
set /a "bf=1!BASEF!-1000"
set /a "tot=bh*3600000+bm*60000+bs*1000+bf+MSIDX"
set /a "MSIDX+=1"
if !tot! geq 86400000 set /a "tot-=86400000"
set /a "h2=tot/3600000"
set /a "r1=tot-h2*3600000"
set /a "m2=r1/60000"
set /a "r2=r1-m2*60000"
set /a "s2=r2/1000"
set /a "f3=r2-s2*1000"
set "h2=0!h2!"
set "m2=0!m2!"
set "s2=0!s2!"
set "f3=00!f3!"
set "h2=!h2:~-2!"
set "m2=!m2:~-2!"
set "s2=!s2:~-2!"
set "f3=!f3:~-3!"
set "STAMP=!BASEDATE!-!h2!!m2!!s2!!f3!"
goto :eof
:mkt_fallback
set "SDATE=%DATE%"
set "SDATE=%SDATE:/= %"
set "SDATE=%SDATE:-= %"
set "SDATE=%SDATE:.= %"
for /f "tokens=1,2,3" %%A in ("%SDATE%") do (
    set "SY=%%A"
    set "SMO=%%B"
    set "SDD=%%C"
)
if 1!SMO! lss 110 set "SMO=0!SMO!"
if 1!SDD! lss 110 set "SDD=0!SDD!"
set "STIME=%TIME: =0%"
set "SH=!STIME:~0,2!"
set "SMI=!STIME:~3,2!"
set "SS=!STIME:~6,2!"
set "SC=!STIME:~9,2!"
set "STAMP=!SY!!SMO!!SDD!-!SH!!SMI!!SS!!SC!0"
goto :eof

rem 为一个源文件夹建目标文件夹，名字 sanxia-日期-时间
rem %1 = 源文件夹名
:mktarget
set "SRCNAME=%~1"
set "TRIES=0"
:mkt_try
call :mkstamp
set "TRY=sanxia-!STAMP!"
if exist "%ROOT%\!TRY!" (
    set /a TRIES+=1
    if !TRIES! gtr 99 goto :mkt_giveup
    goto :mkt_try
)
mkdir "%ROOT%\!TRY!\images\train" >nul 2>&1
mkdir "%ROOT%\!TRY!\images\val" >nul 2>&1
mkdir "%ROOT%\!TRY!\labels\train" >nul 2>&1
mkdir "%ROOT%\!TRY!\labels\val" >nul 2>&1
set "TGD_%SRCNAME%=%ROOT%\!TRY!"
echo !SRCNAME!?!TRY!>> "%TGTS%"
echo   !SRCNAME! 的 目标  -  !TRY!
goto :eof
:mkt_giveup
echo   WARNING: !SRCNAME! 找不到可用的目标文件夹名
goto :eof

rem 预扫描源端跨文件夹的同名文件，后面的文件夹要改名
rem 优先用 PowerShell 一次算完，几万个文件也就几秒
rem PowerShell 不可用时退回纯 bat 慢速扫描
:dupscan
set "PSOK=0"
call :dupscan_ps
if !PSOK!==1 goto :eof
call :dupscan_bat
goto :eof

rem --- PowerShell 快速扫描，几秒搞定 ---
:dupscan_ps
set "PS1=%WORK%\dupscan.ps1"
if exist "%PS1%" del "%PS1%" >nul 2>&1
echo param($Root, $Work, $TrainDir, $TestDir)>> "%PS1%"
echo $first = @{}>> "%PS1%"
echo $marked = @{}>> "%PS1%"
echo $tr = New-Object System.Collections.Generic.List[string]>> "%PS1%"
echo $va = New-Object System.Collections.Generic.List[string]>> "%PS1%"
echo $dirs = [System.IO.Directory]::EnumerateDirectories($Root) ^| Sort-Object>> "%PS1%"
echo foreach($d in $dirs){>> "%PS1%"
echo   $dn = [System.IO.Path]::GetFileName($d)>> "%PS1%"
echo   if($dn -like 'sanxia-*' -or $dn -eq 'sanxia' -or $dn -eq '.sxcpy_tmp'){ continue }>> "%PS1%"
echo   $tp = Join-Path $d $TrainDir>> "%PS1%"
echo   $vp = Join-Path $d $TestDir>> "%PS1%"
echo   if(-not [System.IO.Directory]::Exists($vp)){ $vp = Join-Path $d 'valid' }>> "%PS1%"
echo   if([System.IO.Directory]::Exists($tp)){>> "%PS1%"
echo     foreach($f in [System.IO.Directory]::EnumerateFiles($tp)){>> "%PS1%"
echo       $e = [System.IO.Path]::GetExtension($f)>> "%PS1%"
echo       if($e -ne '.jpg' -and $e -ne '.txt'){ continue }>> "%PS1%"
echo       $nm = [System.IO.Path]::GetFileNameWithoutExtension($f)>> "%PS1%"
echo       $key = $nm + '^|train'>> "%PS1%"
echo       if($first.ContainsKey($key)){ if($first[$key] -ne $dn){ $rk = $dn + '?' + $nm; if(-not $marked.ContainsKey($rk)){ $marked[$rk] = 1; $tr.Add($rk) } } } else { $first[$key] = $dn }>> "%PS1%"
echo     }>> "%PS1%"
echo   }>> "%PS1%"
echo   if([System.IO.Directory]::Exists($vp)){>> "%PS1%"
echo     foreach($f in [System.IO.Directory]::EnumerateFiles($vp)){>> "%PS1%"
echo       $e = [System.IO.Path]::GetExtension($f)>> "%PS1%"
echo       if($e -ne '.jpg' -and $e -ne '.txt'){ continue }>> "%PS1%"
echo       $nm = [System.IO.Path]::GetFileNameWithoutExtension($f)>> "%PS1%"
echo       $key = $nm + '^|val'>> "%PS1%"
echo       if($first.ContainsKey($key)){ if($first[$key] -ne $dn){ $rk = $dn + '?' + $nm; if(-not $marked.ContainsKey($rk)){ $marked[$rk] = 1; $va.Add($rk) } } } else { $first[$key] = $dn }>> "%PS1%"
echo     }>> "%PS1%"
echo   }>> "%PS1%"
echo }>> "%PS1%"
echo $tr ^| Set-Content -LiteralPath (Join-Path $Work 'ren_train.txt')>> "%PS1%"
echo $va ^| Set-Content -LiteralPath (Join-Path $Work 'ren_val.txt')>> "%PS1%"
echo Write-Output ('TRAIN=' + $tr.Count)>> "%PS1%"
echo Write-Output ('VAL=' + $va.Count)>> "%PS1%"
set /a "REN_train=0"
set /a "REN_val=0"
for /f "tokens=1,2 delims==" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" "%ROOT%" "%WORK%" "%TRAIN_DIR%" "%TEST_DIR%" 2^>nul') do (
    if /i "%%A"=="TRAIN" (
        set /a "REN_train=%%B"
        set "PSOK=1"
    )
    if /i "%%A"=="VAL" set /a "REN_val=%%B"
)
goto :eof

rem --- 纯 bat 慢速扫描兜底，一次把 train 和 val 都扫完 ---
:dupscan_bat
set "NT=%WORK%\names_train.txt"
set "NV=%WORK%\names_val.txt"
set "RT=%WORK%\ren_train.txt"
set "RV=%WORK%\ren_val.txt"
if exist "%NT%" del "%NT%" >nul 2>&1
if exist "%NV%" del "%NV%" >nul 2>&1
if exist "%RT%" del "%RT%" >nul 2>&1
if exist "%RV%" del "%RV%" >nul 2>&1
set /a "SCANNED=0"
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if /i "%%~nxD"=="sanxia" set "skip=1"
    set "SXPFX=%%~nxD"
    if /i "!SXPFX:~0,7!"=="sanxia-" set "skip=1"
    if !skip!==0 (
        set /a SCANNED+=1
        set /a "tick=SCANNED %% 10"
        if !tick!==0 echo   已扫描 !SCANNED! 个源文件夹...
        set "GS=%TRAIN_DIR%"
        if exist "%%D\!GS!" (
            (for %%X in ("%%D\!GS!\*.jpg") do echo %%~nX?%%~nxD) >> "%NT%"
            (for %%X in ("%%D\!GS!\*.txt") do echo %%~nX?%%~nxD) >> "%NT%"
        )
        set "GS=%TEST_DIR%"
        if not exist "%%D\!GS!" if exist "%%D\valid" set "GS=valid"
        if exist "%%D\!GS!" (
            (for %%X in ("%%D\!GS!\*.jpg") do echo %%~nX?%%~nxD) >> "%NV%"
            (for %%X in ("%%D\!GS!\*.txt") do echo %%~nX?%%~nxD) >> "%NV%"
        )
    )
)
set /a "REN_train=0"
call :dupmark "%NT%" "%RT%" REN_train
set /a "REN_val=0"
call :dupmark "%NV%" "%RV%" REN_val
goto :eof

rem 从排好序的名字文件里挑出跨文件夹重名的
rem %1=名字文件 %2=改名清单输出 %3=计数的变量名
:dupmark
if not exist "%~1" goto :eof
set "prevname="
set "ownerfolder="
set "prevkey="
for /f "usebackq tokens=1,2 delims=?" %%A in (`sort "%~1" 2^>nul`) do (
    if not "%%A?%%B"=="!prevkey!" (
        set "prevkey=%%A?%%B"
        if "%%A"=="!prevname!" (
            if not "%%B"=="!ownerfolder!" (
                echo %%B?%%A>> "%~2"
                set /a "%~3+=1"
            )
        ) else (
            set "prevname=%%A"
            set "ownerfolder=%%B"
        )
    )
)
goto :eof

rem 把源端重名的文件在它自己的目标文件夹里改名
rem %1 = 分组 train 或 val
:renpass
if not exist "%WORK%\ren_%~1.txt" (
    echo   %~1 : 没有需要改名的文件
    goto :eof
)
set "rc=0"
for /f "usebackq tokens=1,2 delims=?" %%A in ("%WORK%\ren_%~1.txt") do (
    set "TG=!TGD_%%A!"
    if defined TG (
        if exist "!TG!\images\%~1\%%B.jpg" ren "!TG!\images\%~1\%%B.jpg" "%%A__%%B.jpg"
        if exist "!TG!\labels\%~1\%%B.txt" ren "!TG!\labels\%~1\%%B.txt" "%%A__%%B.txt"
        set /a rc+=1
    )
)
echo   %~1 : 改了 !rc! 组 jpg 和 txt，格式 源文件夹名__原文件名
goto :eof

rem 等待所有并行任务 - 自适应看门狗
rem 只要还有任务在陆续结束就不算卡死，连续 120 秒一个都没结束才转串行
:wait_all
set "FALLBACK=0"
set "secs=0"
set "best=999999"
:wa
set "c=0"
for /f %%N in ('dir /b "%WORK%\lock_*.lck" 2^>nul') do set /a c+=1
if !c! lss !best! (
    set /a "best=!c!"
    set /a "secs=0"
)
if !c! gtr 0 (
    ping -n 2 127.0.0.1 >nul 2>&1
    set /a secs+=1
    set /a "tick=secs %% 10"
    if !tick!==0 echo   还剩 !c! 个复制任务，已经 !secs! 秒没有任务结束
    if !secs! lss 120 goto :wa
    echo   连续 120 秒没有任何任务结束，判定卡死，转串行模式
    set "FALLBACK=1"
)
goto :eof

:dups
set "DUPN=0"
set "NU=0"
if exist "%WORK%\dups.txt" del "%WORK%\dups.txt" >nul 2>&1
if !NSUB! geq 2 (
    call :dupgroup "%TRAIN_DIR%" jpg
    call :dupgroup "%TRAIN_DIR%" txt
    call :dupgroup "%TEST_DIR%" jpg
    call :dupgroup "%TEST_DIR%" txt
)
echo   源端跨文件夹的同名文件数: !DUPN!
if "%RENAME_DUP%"=="0" (
    echo   RENAME_DUP=0，没有改名，服务器解压后会冲突
) else (
    echo   已改名: 训练 !REN_train! 个，验证 !REN_val! 个
    echo   改名格式：源文件夹名__原文件名，jpg 和 txt 前缀一致
)
if !NU! gtr 0 (
    echo   重名文件名示例，最多 5 个:
    set "n=0"
    for /f "usebackq delims=" %%F in ("%WORK%\dups.txt") do (
        if !n! lss 5 (
            echo     %%F
            set /a n+=1
        )
    )
)
goto :eof

:dupgroup
set "NAMES=%WORK%\names.txt"
if exist "%NAMES%" del "%NAMES%" >nul 2>&1
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if /i "%%~nxD"=="sanxia" set "skip=1"
    set "SXPFX=%%~nxD"
    if /i "!SXPFX:~0,7!"=="sanxia-" set "skip=1"
    if !skip!==0 (
        set "GS=%~1"
        if "%~1"=="%TEST_DIR%" if not exist "%%D\%TEST_DIR%" if exist "%%D\valid" set "GS=valid"
        if exist "%%D\!GS!" dir /b /a-d "%%D\!GS!\*.%~2" >> "%NAMES%" 2>nul
    )
)
set "prev="
set "lastdup="
if exist "%NAMES%" (
    for /f "delims=" %%F in ('sort "%NAMES%" 2^>nul') do (
        if "!prev!"=="%%F" (
            set /a DUPN+=1
            if not "!lastdup!"=="%%F" (
                if !NU! lss 20 (
                    echo %%F>> "%WORK%\dups.txt"
                    set /a NU+=1
                )
                set "lastdup=%%F"
            )
        )
        set "prev=%%F"
    )
)
goto :eof

rem 配对校验：每个 jpg 都要有 txt，每个 txt 都要有 jpg
rem %1=images 目录 %2=labels 目录 %3=显示用的名字
:paircheck
set "MISSJ=0"
set "MISST=0"
for %%F in ("%~1\*.jpg") do (
    if not exist "%~2\%%~nF.txt" set /a MISSJ+=1
)
for %%F in ("%~2\*.txt") do (
    if not exist "%~1\%%~nF.jpg" set /a MISST+=1
)
if !MISSJ!==0 if !MISST!==0 echo   %~3 : 所有 jpg 和 txt 都一一对应 - OK
if !MISSJ! gtr 0 echo   %~3 : WARNING !MISSJ! 个 jpg 没有对应的 txt
if !MISST! gtr 0 echo   %~3 : WARNING !MISST! 个 txt 没有对应的 jpg
goto :eof

:count_ext
set "RET=0"
for %%F in ("%~1\*.%~2") do set /a RET+=1
goto :eof

:count_all
set "RET=0"
for %%F in ("%~1\*") do if not exist "%%~fF\" set /a RET+=1
goto :eof

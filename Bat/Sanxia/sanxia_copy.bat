@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

rem =========================================================
rem  sanxia 数据集整理脚本 - 复制模式，不删源文件
rem  把每个子文件夹里的 train / test 或 valid 复制到
rem    sanxia\images 和 sanxia\labels 下面的 train / val
rem  jpg 进 images，txt 进 labels
rem  速度：robocopy /MT 多线程，SKIP 模式下再叠加子文件夹级并行
rem  配置项：
rem    TRAIN_DIR : 源端训练集文件夹名
rem    TEST_DIR  : 源端验证集文件夹名，找不到时自动改用 valid
rem    MAX_JOBS  : 并行子任务数，只对 SKIP 模式有效
rem    MT        : 每个任务的 robocopy 线程数
rem    DUP_MODE  : 重名处理方式，见下面的说明
rem
rem  重名规则 - 两种情况分开处理
rem    1 源端与目标端重名：目标里已经有了，说明上次复制过，跳过
rem    2 源端内部重名：两个不同子文件夹里有同名文件，内容并不一样
rem      KEEP  - 保留全部。字母序靠前的那个文件夹用原名，后面的
rem              改名成 子文件夹名__原文件名 再复制，一个都不丢。
rem              jpg 和 txt 加同样的前缀，配对不乱。串行执行。
rem      SKIP  - 先到的保留，后面的丢弃。文件名不变，速度最快。
rem  编码注意：本文件必须保存为 GBK 即代码页 936 编码 + CRLF。
rem  第 2 行的 chcp 936 是让中文正常显示的，不要删。
rem =========================================================

rem ---- 配置项 ----
set "TRAIN_DIR=train"
set "TEST_DIR=test"
set "MAX_JOBS=50"
set "MT=50"
set "DUP_MODE=KEEP"

rem 根目录 = 本脚本所在文件夹
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rem 目标目录
set "SANXIA=%ROOT%\sanxia"
set "IMAGES=%SANXIA%\images"
set "LABELS=%SANXIA%\labels"
set "IMG_TRAIN=%IMAGES%\train"
set "LBL_TRAIN=%LABELS%\train"
set "IMG_VAL=%IMAGES%\val"
set "LBL_VAL=%LABELS%\val"

rem 临时工作目录，存任务脚本和锁文件，结束时删除
rem 必须放在脚本所在目录下，不能放 %TEMP%
rem 因为 %TEMP% 会被解析成 8.3 短路径，后台任务找不到文件
set "PARALLEL_OK=1"
set "WORK=%ROOT%\.sxcpy_tmp"
if exist "%WORK%\" rmdir /s /q "%WORK%" >nul 2>&1
mkdir "%WORK%" >nul 2>&1
if not exist "%WORK%\" set "PARALLEL_OK=0"

rem KEEP 模式必须串行，这样重名时留下的才是字母序靠前的文件夹，
rem 才能和后面改名补复制用的名单对得上
if "%DUP_MODE%"=="KEEP" set "PARALLEL_OK=0"

rem 先杀掉上次异常退出残留的后台任务
taskkill /f /fi "WINDOWTITLE eq sxcpy" >nul 2>&1

echo ================================================
echo  1. 准备目录结构，不存在就新建
echo ================================================
if not exist "%SANXIA%"   mkdir "%SANXIA%"
if not exist "%IMAGES%"  mkdir "%IMAGES%"
if not exist "%LABELS%"  mkdir "%LABELS%"
if not exist "%IMG_TRAIN%" mkdir "%IMG_TRAIN%"
if not exist "%LBL_TRAIN%" mkdir "%LBL_TRAIN%"
if not exist "%IMG_VAL%"   mkdir "%IMG_VAL%"
if not exist "%LBL_VAL%"   mkdir "%LBL_VAL%"

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
    if /i "%%~fD"=="%SANXIA%" set "skip=1"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
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
echo       并行任务数=%MAX_JOBS%  线程数=%MT%  重名处理=%DUP_MODE%
if "%DUP_MODE%"=="KEEP" (
    echo       KEEP 模式，串行执行以保证重名结果稳定
    echo       源端和目标端重名的：跳过，说明上次已经复制过
    echo       源端内部重名的：第二个起改名后再复制，一个都不丢
    echo       改名格式：子文件夹名__原文件名
)
echo ================================================

rem 先扫描源端内部重名，名单存起来，复制完再改名补一遍
if "%DUP_MODE%"=="KEEP" (
    echo   正在预扫描源端重名，请稍候...
    call :dupscan "%TRAIN_DIR%" train
    call :dupscan "%TEST_DIR%" val
    echo   预扫描完成，训练 !REN_train! 组，验证 !REN_val! 组
)

set "FALLBACK=0"
call :copyloop
if !PARALLEL_OK!==1 (
    call :wait_all
)
if !FALLBACK!==1 (
    echo   并行任务没有在限定时间内跑完
    echo   正在清理残留后台任务和锁文件...
    taskkill /f /fi "WINDOWTITLE eq sxcpy" >nul 2>&1
    ping -n 2 127.0.0.1 >nul 2>&1
    del /q "%WORK%\lock_*.lck" >nul 2>&1
    echo   改为串行复制，一个任务一个任务来
    echo   下面会逐个打印任务，方便你看进度
    set "PARALLEL_OK=0"
    call :copyloop
)

set "NFAIL=0"
for /f %%F in ('dir /b "%WORK%\fail_*.txt" 2^>nul') do set /a NFAIL+=1
if !NFAIL! gtr 0 (
    echo.
    echo   WARNING: robocopy 报错，共 !NFAIL! 个复制任务失败
    for /f %%F in ('dir /b "%WORK%\fail_*.txt" 2^>nul') do type "%WORK%\%%F"
)

if "%DUP_MODE%"=="KEEP" (
    echo.
    echo ================================================
    echo  3b. 补复制源端重名文件，改名后放入目标
    echo ================================================
    call :renpass train "%IMG_TRAIN%" "%LBL_TRAIN%"
    call :renpass val "%IMG_VAL%" "%LBL_VAL%"
)

echo.
echo ================================================
echo  4. 复制完成后各文件夹的文件数量
echo ================================================
call :count "%IMG_TRAIN%" "images\train"
call :count "%LBL_TRAIN%" "labels\train"
call :count "%IMG_VAL%"   "images\val"
call :count "%LBL_VAL%"   "labels\val"
call :count_all "%IMG_TRAIN%"
set "C1=!RET!"
call :count_all "%LBL_TRAIN%"
set "C2=!RET!"
call :count_all "%IMG_VAL%"
set "C3=!RET!"
call :count_all "%LBL_VAL%"
set "C4=!RET!"
set /a "TOT=C1+C2+C3+C4"
echo   合计 : %TOT% 个文件
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
    echo   可能是上次运行留下的，或者混进了别的数据集
    echo   想要干净结果就删掉 sanxia 文件夹再跑一次
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
call :paircheck "%IMG_TRAIN%" "%LBL_TRAIN%" "train"
call :paircheck "%IMG_VAL%" "%LBL_VAL%" "val"

echo.
echo ================================================
echo  5. 空文件夹检查
echo ================================================
call :count_all "%IMG_VAL%"
set "IV=!RET!"
call :count_all "%LBL_VAL%"
set "LV=!RET!"
set "bothzero=0"
if !IV!==0 if !LV!==0 set "bothzero=1"
if !bothzero!==1 (
    echo   提示: images\val 和 labels\val 都是空的
    echo   所有子文件夹里都没找到 %TEST_DIR% 或 valid
    echo   检查 val 文件夹名，或者改开头的 TEST_DIR
    echo   确认每个子文件夹都有 test 或 valid 且里面有文件
)
if !bothzero!==0 (
    echo   val 文件夹生成正常 - images\val 和 labels\val 有文件
)

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

rem 主复制循环：扫描子文件夹，分派 train / test 或 valid
:copyloop
set "NJOBS=0"
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~fD"=="%SANXIA%" set "skip=1"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if !skip!==0 (
        set "VALSRC="
        if exist "%%D\%TEST_DIR%" set "VALSRC=%TEST_DIR%"
        if not defined VALSRC if exist "%%D\valid" set "VALSRC=valid"
        if exist "%%D\%TRAIN_DIR%\*.jpg" call :enqueue "%%D\%TRAIN_DIR%" "%IMG_TRAIN%" jpg
        if exist "%%D\%TRAIN_DIR%\*.txt" call :enqueue "%%D\%TRAIN_DIR%" "%LBL_TRAIN%" txt
        if defined VALSRC (
            if exist "%%D\!VALSRC!\*.jpg" call :enqueue "%%D\!VALSRC!" "%IMG_VAL%" jpg
            if exist "%%D\!VALSRC!\*.txt" call :enqueue "%%D\!VALSRC!" "%LBL_VAL%" txt
        )
    )
)
goto :eof

rem 分派一个复制任务： %1=源目录 %2=目标目录 %3=扩展名
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

rem 等一个空闲位 - 锁文件数量低于 MAX_JOBS
:slot
set "c=0"
for /f %%N in ('dir /b "%WORK%\lock_*.lck" 2^>nul') do set /a c+=1
if !c! geq %MAX_JOBS% (
    ping -n 1 127.0.0.1 >nul 2>&1
    goto :slot
)

rem 写任务脚本：robocopy 多线程，失败就记文件，最后删自己的锁
> "%JB%" echo @echo off
>> "%JB%" echo robocopy "%SRC%" "%DST%" *.%EXT% /MT:%MT% /XC /XN /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP ^>nul 2^>^&1
>> "%JB%" echo if errorlevel 8 echo FAIL src=%SRC% code=%%errorlevel%% ^> "%WORK%\fail_!NJOBS!.txt"
>> "%JB%" echo del "%LK%" ^>nul 2^>^&1

rem 建锁文件并在后台启动
echo. > "%LK%"
start "sxcpy" /b cmd /c ""%JB%" "%LK%""
goto :eof

rem 预扫描源端重名：同一个分组里名字出现在两个以上子文件夹的，
rem 字母序靠前的那个文件夹保留原名，其余的记录下来等改名补复制
rem %1 = 分组目录名 train 或 test   %2 = 标记 train 或 val
:dupscan
set "NAMES=%WORK%\names_%~2.txt"
set "RENF=%WORK%\ren_%~2.txt"
if exist "%NAMES%" del "%NAMES%" >nul 2>&1
if exist "%RENF%" del "%RENF%" >nul 2>&1
for /d %%D in ("%ROOT%\*") do (
    set "skip=0"
    if /i "%%~fD"=="%SANXIA%" set "skip=1"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
    if !skip!==0 (
        set "GS=%~1"
        if "%~1"=="%TEST_DIR%" if not exist "%%D\%TEST_DIR%" if exist "%%D\valid" set "GS=valid"
        if exist "%%D\!GS!" (
            for /f "delims=" %%X in ('dir /b /a-d "%%D\!GS!\*.jpg" 2^>nul') do echo %%~nX?%%~nxD?!GS!
            for /f "delims=" %%X in ('dir /b /a-d "%%D\!GS!\*.txt" 2^>nul') do echo %%~nX?%%~nxD?!GS!
        )
    )
) >> "%NAMES%"
set "prevname="
set "ownerfolder="
set "prevkey="
set /a "REN_%~2=0"
if exist "%NAMES%" (
    for /f "usebackq tokens=1,2,3 delims=?" %%A in (`sort "%NAMES%" 2^>nul`) do (
        if not "%%A?%%B"=="!prevkey!" (
            set "prevkey=%%A?%%B"
            if "%%A"=="!prevname!" (
                if not "%%B"=="!ownerfolder!" (
                    echo %%B?%%C?%%A>> "%RENF%"
                    set /a "REN_%~2+=1"
                )
            ) else (
                set "prevname=%%A"
                set "ownerfolder=%%B"
            )
        )
    )
)
goto :eof

rem 把源端重名的文件改名后补复制一遍
rem %1 = 标记 train 或 val   %2 = images 目标目录   %3 = labels 目标目录
:renpass
if not exist "%WORK%\ren_%~1.txt" (
    echo   %~1 : 没有需要改名补复制的文件
    goto :eof
)
set "rc=0"
for /f "usebackq tokens=1,2,3 delims=?" %%A in ("%WORK%\ren_%~1.txt") do (
    if exist "%ROOT%\%%A\%%B\%%C.jpg" copy /y "%ROOT%\%%A\%%B\%%C.jpg" "%~2\%%A__%%C.jpg" >nul
    if exist "%ROOT%\%%A\%%B\%%C.txt" copy /y "%ROOT%\%%A\%%B\%%C.txt" "%~3\%%A__%%C.txt" >nul
    set /a rc+=1
)
echo   %~1 : 改名补复制 !rc! 组 jpg 和 txt
goto :eof

rem 等待所有并行任务 - 锁清空就结束，超时则转串行
:wait_all
set "FALLBACK=0"
set "secs=0"
:wa
set "c=0"
for /f %%N in ('dir /b "%WORK%\lock_*.lck" 2^>nul') do set /a c+=1
if !c! gtr 0 (
    ping -n 1 127.0.0.1 >nul 2>&1
    set /a secs+=1
    set /a "tick=secs %% 10"
    if !tick!==0 echo   还在等待，剩 !c! 个任务，已用 !secs! 秒
    if !secs! lss 60 goto :wa
    echo   等了 !secs! 秒还没完，放弃并行模式
    set "FALLBACK=1"
)
goto :eof

:dups
set "DUPN=0"
set "NU=0"
if exist "%WORK%\dups.txt" del "%WORK%\dups.txt" >nul 2>&1
call :dupgroup "%TRAIN_DIR%" jpg
call :dupgroup "%TRAIN_DIR%" txt
call :dupgroup "%TEST_DIR%" jpg
call :dupgroup "%TEST_DIR%" txt
echo   源端重名文件数: !DUPN!
if "%DUP_MODE%"=="KEEP" (
    echo   已改名补复制: 训练 !REN_train! 组，验证 !REN_val! 组
    echo   改名后的样子：子文件夹名__原文件名
    echo   jpg 和 txt 加的是同一个前缀，配对不会错
) else (
    echo   作为重名被跳过的文件数: !SKIPPED!
    if !DUPN! lss !SKIPPED! (
        echo   提示: 重名数少于跳过数，可能有些复制失败了
    )
)
if !NU! gtr 0 (
    echo   重名文件名示例，最多 5 个:
    set "n=0"
    for /f "delims=" %%F in (%WORK%\dups.txt) do (
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
    if /i "%%~fD"=="%SANXIA%" set "skip=1"
    if /i "%%~nxD"==".sxcpy_tmp" set "skip=1"
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

rem 配对检查：每个 jpg 都要有 txt，每个 txt 都要有 jpg
rem %1=images 目录 %2=labels 目录 %3=输出用的名字
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

:count
set "cnt=0"
for /f %%F in ('dir /b /a-d "%~1" 2^>nul') do set /a cnt+=1
echo   %~2 : %cnt% 个文件
goto :eof

:count_ext
set "RET=0"
if exist "%~1\*.%~2" for /f %%F in ('dir /b /a-d "%~1\*.%~2" 2^>nul') do set /a RET+=1
goto :eof

:count_all
set "RET=0"
for /f %%F in ('dir /b /a-d "%~1" 2^>nul') do set /a RET+=1
goto :eof

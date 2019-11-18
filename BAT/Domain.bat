@echo off

color 1e

cd /d C:\Domain_Migration\xp

::功能说明与使用说明注意事项

ECHO 请在使用本脚本前修改相应的参数为实际值

set dns1=192.168.12.5

set dns2=192.168.2.3

REM 请设置自己真实环境的域名、域管理员账号和密码

set domainname=test.com

set domainadminname=testadmin

set domainadminpassword=!@@#3%%^^

::判断是否已经加入域，如果加入了则直接跳转

::wmic ntdomain get domainname | findstr /i "%domainname%

::if %errorlevel% equ 0 echo 该计算机已经加入域 && goto moveuser

ipconfig /all | findstr /i "%domainname%" >nul && echo 该计算机已经加入域,准备转移配置文件 && goto moveuser



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断当前登陆用户是否有管理员权限，如果没有则注销后重新以管理员登陆

:admin

ECHO ************************判断当前用户权限******************

net user %username% | findstr "*Administrators"

if %errorlevel% equ 1 (echo 当前用户不是本地管理员，请注销后使用有本地管理员权限的用户登录) else (goto DNS)

set /p logoff=现在要注销吗

if /i "%logoff%"=="y" logoff

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断当前DNS设置是否为指定地址，如果不是，则清空当前配置后重新设置DNS

:DNS

ECHO *************************更改DNS****************************

netsh interface ip show dns | findstr "%dns1%" 1>nul && echo DNS已经设置为%dns1% && goto renamecomputername

echo 清理更改现有DNS...

for /f "skip=2 tokens=2,* " %%i in ('netsh interface show interface') do (

set netname=%%j

if "%%j"=="环回" goto back

if "%%j"=="内部" goto back

netsh interface ip delete dns name="%%j" addr=all >nul

netsh interface ip add dns name="%%j" addr=%dns1% index=1 >nul

netsh interface ip add dns name="%%j" addr=%dns2% index=2 >nul

)

:back

echo DNS更改完成



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断计算机名是否已经更改，如更改则进入下一部分；如未更改是否需要更改计算机名，更改完成后要求重新启动计算机

:renamecomputername

ECHO *********************更改计算机名****************************

set a=%computername%

echo 当前计算机名为：%a%

set /p b=请输入要修改的计算机名称(跳过请输入s)：

if /i "%b%"=="s" goto joindomain

if /i "%b%"=="" echo 计算机名不能为空 && goto renamecomputername

wmic computersystem Where name="%a%" call rename "%b%" >nul

if %errorlevel% equ 1 (echo 更改计算机名失败,请手工更改 && pause && exit) else (echo 计算机名已更改为%b%)

set /p reboot=更改计算机名完成，现在要重起吗?y/n:

if /i "%reboot%"=="y" shutdown /r /t 0

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断计算机是否已加入域，如加入域则继续下一部分；否则检查相应服务是否启动，自动加入域（用户名密码部分参数需要自行更改）

:joindomain

ECHO ***********************计算机加入域*************************

if /i "%userdomain%"=="%domainname%" goto moveuser

rem 判断服务TCP/IP NetBIOS HELPER服务是否禁用或未启动，如果禁用则更改为自动，未启动则自动启动，否则显示服务已启动

sc query state= inactive | findstr /c:"TCP/IP NetBIOS" && (echo 服务未启动，正在启动服务... && sc config lmhosts start= auto && sc start lmhosts) || echo 服务已启动

if /i "%userdomain%"=="%domainname%" do (echo 计算机已加入域 && goto moveuser)

if not exist netdom.exe echo 请将netdom工具放到同文件夹下再尝试运行 && goto end

. etdom join %computername% /Domain:%domainname% /UserD:%domainadminname% /PasswordD:%domainadminpassword% || echo 加入域失败，请检查网络环境及批处理参数是否正确 && goto end

set /p shutdown=加入域完成，现在要重起吗?y/n:

if /i "%shutdown%"=="y" shutdown /r /t 0

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::使用moveuser工具对用户配置文件进行迁移（提示用户输入要迁移的用户和要迁移到的用户）

:moveuser

ECHO *********************用户配置文件迁移*************************

if not exist moveuser.exe echo 请将MOVEUSER工具放到同文件夹下再尝试运行 && goto end

net user

:retry

set /p user=请输入你要迁移的本地用户账户名称:

if /i "%user%"=="%username%" echo 转移的用户配置文件为当前登陆用户，请重新启动后使用域管理员登陆再进行转移 && goto end

net user %user% 2>nul 1>nul || echo 你输入的本地账户不存在,请重新输入 && goto retry

set /p domainuser=请输入你要迁移到的域账号名称：

net user %domainuser% /domain 2>nul 1>nul

if %errorlevel% neq 0 (echo 你要转移到的域账户尚未建立，请建立后重新尝试迁移) && goto end

moveuser %user% %domainname%\%domainuser% /k /y | findstr /i "failed" 2>nul 1>nul && echo用户配置文件迁移失败，请检查配置 && goto end

::if %errorlevel% neq 0 echo 用户配置文件迁移失败，请检查配置 && goto end



::如果是从本机管理员用户迁移，则域用户也变成管理员，此处删除域用户管理员权限，加入PowerUsers群组，可自行更改

echo 更改域用户为Power User权限

net localgroup administrators %domainname%\%domainuser% /delete

net localgroup "Power Users" %domainname%\%domainuser% /add

echo 配置文件迁移成功，请注销后使用您的域账号登陆

set /p logoff=现在要注销吗?y/n:

if /i "%logoff%"=="y" logoff

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::结束退出

:end

pause>nul

exit

****************************************************************

REM 脚本结束



3、Win7AutoAddDomain.bat，更改计算机名，加域，迁移用户配置文件

@echo off

color 1e

::功能说明与使用说明注意事项

ECHO 请在使用本脚本前修改相应的参数为实际值

set dns1=192.168.12.5

set dns2=192.168.2.3

REM 请设置自己真实环境的域名、域管理员账号和密码

set domainname=test.com

set domainadminname=testadmin

set domainadminpassword=!@@#3%%^^

::判断是否已经加入域，如果加入了则直接跳转

::wmic ntdomain get domainname | findstr /i "%domainname%

::if %errorlevel% equ 0 echo 该计算机已经加入域 && goto moveuser

ipconfig /all | findstr /i "%domainname%" >nul && echo 该计算机已经加入域,准备转移配置文件 && goto moveuser

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断当前登陆用户是否有管理员权限，如果没有则注销后重新以管理员登陆

:admin

ECHO ************************判断当前用户权限******************

net user %username% | findstr "*Administrators"

if %errorlevel% equ 1 (echo 当前用户不是本地管理员，请注销后使用有本地管理员权限的用户登录) else (goto DNS)

set /p logoff=现在要注销吗

if /i "%logoff%"=="y" logoff

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断当前DNS设置是否为指定地址，如果不是，则清空当前配置后重新设置DNS

:DNS

ECHO *************************更改DNS****************************

netsh interface ip show dns | findstr "%dns1%" 1>nul && echo DNS已经设置为%dns1% && goto renamecomputername

echo 清理更改现有DNS...

for /f "skip=2 tokens=2,* " %%i in ('netsh interface show interface') do (

set netname=%%j

if "%%j"=="环回" goto back

if "%%j"=="内部" goto back

netsh interface ip delete dns name="%%j" addr=all >nul

netsh interface ip add dns name="%%j" addr=%dns1% index=1 >nul

netsh interface ip add dns name="%%j" addr=%dns2% index=2 >nul

)

:back

echo DNS更改完成

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断计算机名是否已经更改，如更改则进入下一部分；如未更改是否需要更改计算机名，更改完成后要求重新启动计算机

:renamecomputername

ECHO *********************更改计算机名****************************

set a=%computername%

echo 当前计算机名为：%a%

set /p b=请输入要修改的计算机名称(跳过请输入s)：

if /i "%b%"=="s" goto joindomain

if /i "%b%"=="" echo 计算机名不能为空 && goto renamecomputername

wmic computersystem Where name="%a%" call rename "%b%" >nul

if %errorlevel% equ 1 (echo 更改计算机名失败,请手工更改 && pause && exit) else (echo 计算机名已更改为%b%)

set /p reboot=更改计算机名完成，现在要重起吗?y/n:

if /i "%reboot%"=="y" shutdown /r /t 0

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::判断计算机是否已加入域，如加入域则继续下一部分；否则检查相应服务是否启动，自动加入域（用户名密码部分参数需要自行更改）

:joindomain

ECHO ***********************计算机加入域*************************

if /i "%userdomain%"=="%domainname%" goto moveuser

rem 判断服务TCP/IP NetBIOS HELPER服务是否禁用或未启动，如果禁用则更改为自动，未启动则自动启动，否则显示服务已启动

sc query state= inactive | findstr /c:"TCP/IP NetBIOS" && (echo 服务未启动，正在启动服务... && sc config lmhosts start= auto && sc start lmhosts) || echo 服务已启动

if /i "%userdomain%"=="%domainname%" do (echo 计算机已加入域 && goto moveuser)

. etdom join %computername% /Domain:%domainname% /UserD:%domainadminname% /PasswordD:%domainadminpassword% || echo 加入域失败，请检查网络环境及批处理参数是否正确 && goto end

echo 加入域完成,重启电脑后请使用域管理员帐户登陆转移个人配置文件!

set /p shutdown=现在要重起吗?y/n:

if /i "%shutdown%"=="y" shutdown /r /t 0

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::使用moveuser工具对用户配置文件进行迁移（提示用户输入要迁移的用户和要迁移到的用户）

:moveuser

ECHO *********************用户配置文件迁移*************************

net user

:retry

set /p user=请输入你要迁移的本地用户账户名称:

if /i "%user%"=="%username%" echo 转移的用户配置文件为当前登陆用户，请重新启动后使用域管理员登陆再进行转移 && goto end

net user %user% 2>nul 1>nul || echo 你输入的本地账户不存在,请重新输入 && goto retry

set /p domainuser=请输入你要迁移到的域账号名称：

net user %domainuser% /domain 2>nul 1>nul

if %errorlevel% neq 0 (echo 你要转移到的域账户尚未建立，请建立后重新尝试迁移) && goto end

cd /d C:\Domain_Migration\USMT\x86

echo 正在备份个人配置文件，请耐心等候......

scanstate \\fileserver\migration\%computername%-%user% /c /i:miguser.xml /i:migapp.xml /v:13 /ue:*\* /ui:%computername%\%user% /l:scan.log /localonly /o /efs:copyraw

echo 正在转移个人配置文件，请耐心等候......

loadstate \\fileserver\migration\%computername%-%user% /mu:%computername%\%user%:%domainname%\%domainuser% /i:miguser.xml /i:migapp.xml /v:13

echo 将域账号加入本地PowerUser群组

net localgroup administrators %domainname%\%domainuser% /delete

net localgroup "Power Users" %domainname%\%domainuser% /add

echo 删除临时文件

del "%windir%\system32 etdom.exe"

del "%windir%\system32\en-US etdom.exe.mui"

echo 配置文件迁移成功，请注销后使用您的域账号登陆

set /p logoff=现在要注销吗?y/n:

if /i "%logoff%"=="y" logoff

goto end

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::结束退出

:end

pause>nul

exit

******************************************************************

REM 脚本结束
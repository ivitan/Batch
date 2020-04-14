::添加环境变量JAVA_HOME
@echo off
echo 添加java环境变量
set regpath=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
set evname=JAVA_HOME
set javapath=c:\java\jdk
reg add "%regpath%" /v %evname% /d %javapath% /f
pause>nul

::在path中加入JAVA执行如下：这是针对当前用户,本用户的环境变量生效！
setx Path "%Path%;%ORACLE_HOME%\bin"

::系统环境变量
setx /M wu "%comspec%;c:\wu"

:: 设置第三方库环境变量THIRD_PARTY  
rem THIRD_PARTY为环境变量名
rem <system>表示你添加的是系统环境变量
rem %~dp0表示批处理文件所在的文件夹
rem 例如，你的bat文件在e:/MyProject/test.bat,则%0就是%~dp0是e:/MyProject/,%~dp0ThirdPartyLib就是e:/MyProject/ThirdPartyLib

wmic ENVIRONMENT create name="THIRD_PARTY",username="<system>",VariableValue="%~dp0ThirdPartyLib"  
echo %THIRD_PARTY%
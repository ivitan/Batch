@echo off

rem 使用ver命令判断当前的操作系统环境
ver | find "4.0." > NUL &&  goto win_xp    
ver | find "4.10." > NUL &&  goto win_xp   
ver | find "4.90." > NUL &&  goto win_xp   
ver | find "3.51." > NUL &&  goto win_xp   
ver | find "5.0." > NUL &&  goto win_xp    
ver | find "5.1." > NUL &&  goto win_xp    
ver | find "5.2." > NUL &&  goto win_xp    
ver | find "6.0." > NUL &&  goto win7   
ver | find "6.1." > NUL &&  goto win7    
ver | find "6.2." > NUL &&  goto win7  
ver | find "10.0." > NUL &&  goto win10 

rem 假如是xp及其以下版本
:win_xp 
rem 设置第三方库环境变量THIRD_PARTY
wmic ENVIRONMENT where "name='THIRD_PARTY'" delete
wmic ENVIRONMENT create name="THIRD_PARTY",username="<system>",VariableValue="%~dp0ThirdPartyLib"
echo %THIRD_PARTY%


goto end 

rem 假如是vista及其以上版本
:win7
@setx THIRD_PARTY "%~dp0ThirdPartyLib"
echo %THIRD_PARTY%

goto end

rem Win10
:win10
setx /m path "%path%;C:\Users\Administrator\Desktop\path"

:end
pause
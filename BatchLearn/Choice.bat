@ECHO OFF
TITLE Choice

goto han
choice 使用此命令可以让用户输入一个字符(用于选择)，从而根据用户的选择返回不同的 errorlevel，
然后配合 if errorlevel 选择运行不同的命令。
注意：choice命令为DOS或者Windows系统提供的外部命令，不同版本的choice命令语法会稍有不同，请用choice /?查看用法。
choice 使用此命令可以让用户输入一个字符，从而运行不同的命令。
使用时应该加/c:参数，c:后应写提示可输入的字符，之间无空格。它的返回码为1234……
Sample: choice /c:dme defrag,mem,end
将显示: defrag,mem,end[D,M,E]?
:han

choice /c:dme defrag,mem,end
:: (下面第一行应先判断数值最高的错误码)
if errorlevel 3 goto defrag 
if errorlevel 2 goto mem
if errotlevel 1 goto end

PAUSE
@ECHO OFF 
TITLE IF
ECHO =====================
ECHO 语法: if [not] "参数" == "字符串" 待执行的命令
ECHO 参数如果等于(not表示不等，下同)指定的字符串，则条件成立，运行命令，否则运行下一句。(注意是两个等号)
ECHO Sample: if "%1" == "a" format a:
ECHO Sample: if {%1} == {} goto noparms
ECHO =====================
PAUSE